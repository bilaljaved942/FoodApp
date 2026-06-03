"""Rider Service — rider-specific business logic."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from fastapi import HTTPException
from uuid import UUID
from datetime import datetime, date, timedelta, timezone
import logging

from app.models.rider import RiderProfile, RiderLocation, RiderEarning
from app.models.order import Order
from app.models.user import User
from app.schemas.rider import RiderProfileResponse, RiderEarningsSummary, RiderEarningResponse
from app.schemas.order import OrderResponse
from app.core.firebase_client import update_rider_location_realtime, clear_rider_location_realtime

logger = logging.getLogger(__name__)


async def update_rider_status(
    db: AsyncSession, rider_user_id: str, is_online: bool
) -> RiderProfileResponse:
    """Toggle rider's online/offline availability."""
    result = await db.execute(select(RiderProfile).where(RiderProfile.user_id == rider_user_id))
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Rider profile not found")
    if not profile.is_approved:
        raise HTTPException(status_code=403, detail="Rider account not yet approved")

    profile.is_online = is_online
    if not is_online:
        # Clear location from Firebase when going offline
        clear_rider_location_realtime(rider_user_id)

    await db.flush()
    return RiderProfileResponse.model_validate(profile)


async def update_rider_location(
    db: AsyncSession, rider_user_id: str, lat: float, lng: float
):
    """Store rider GPS coordinates in DB and sync to Firebase Realtime DB."""
    # Update profile's last known location
    result = await db.execute(select(RiderProfile).where(RiderProfile.user_id == rider_user_id))
    profile = result.scalar_one_or_none()
    if profile:
        profile.current_lat = lat
        profile.current_lng = lng
        profile.last_location_at = datetime.now(timezone.utc)

    # Write to RiderLocation log (can be used for history/analytics)
    db.add(RiderLocation(rider_id=rider_user_id, lat=lat, lng=lng))

    # Push to Firebase (this is what the customer app reads in real-time)
    update_rider_location_realtime(rider_user_id, lat, lng)

    # Broadcast via WebSocket
    try:
        from app.routers.websocket import manager
        import asyncio
        asyncio.create_task(
            manager.broadcast_rider_location(
                rider_user_id, {"lat": lat, "lng": lng, "rider_id": rider_user_id}
            )
        )
    except Exception as e:
        logger.warning(f"WS rider location broadcast skipped: {e}")

    await db.flush()


async def get_available_orders(db: AsyncSession) -> list[OrderResponse]:
    """Get orders with status 'ready' (store has prepared them, waiting for rider)."""
    result = await db.execute(
        select(Order)
        .where(Order.status == "ready", Order.rider_id == None)
        .order_by(Order.created_at)
    )
    orders = result.scalars().all()
    return [OrderResponse.model_validate(o) for o in orders]


async def accept_order(db: AsyncSession, rider_user_id: str, order_id: UUID) -> OrderResponse:
    """Assign rider to an available order."""
    from sqlalchemy.orm import selectinload
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items), selectinload(Order.status_logs))
        .where(Order.id == order_id, Order.status == "ready", Order.rider_id == None)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=409, detail="Order not available (already taken or invalid status)")

    order.rider_id = rider_user_id
    order.status = "picked_up"

    from app.models.order import OrderStatusLog
    db.add(OrderStatusLog(order_id=order.id, status="picked_up", changed_by_user_id=rider_user_id))

    # Notify customer via FCM
    try:
        from app.core.firebase_client import send_fcm_notification, update_order_status_realtime
        update_order_status_realtime(str(order.id), "picked_up", {"rider_id": rider_user_id})
        # FCM to customer — token lookup needed
    except Exception as e:
        logger.warning(f"FCM/Firebase notification skipped: {e}")

    await db.flush()
    return OrderResponse.model_validate(order)


async def reject_order(db: AsyncSession, rider_user_id: str, order_id: UUID):
    """Record that rider rejected this order (order stays available for other riders)."""
    result = await db.execute(select(Order).where(Order.id == order_id))
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if str(order.rider_id) == rider_user_id:
        order.rider_id = None
    # Order status stays "ready" for another rider to pick up
    await db.flush()


async def get_earnings_summary(db: AsyncSession, rider_user_id: str) -> RiderEarningsSummary:
    """Calculate earnings for today, this week, this month, and total."""
    today = date.today()
    week_start = today - timedelta(days=today.weekday())
    month_start = today.replace(day=1)

    def earnings_query(from_date: date):
        return select(func.sum(RiderEarning.amount)).where(
            RiderEarning.rider_id == rider_user_id,
            RiderEarning.date >= from_date,
        )

    today_earnings = (await db.execute(
        select(func.sum(RiderEarning.amount)).where(
            RiderEarning.rider_id == rider_user_id, RiderEarning.date == today
        )
    )).scalar() or 0.0

    week_earnings = (await db.execute(earnings_query(week_start))).scalar() or 0.0
    month_earnings = (await db.execute(earnings_query(month_start))).scalar() or 0.0

    result = await db.execute(
        select(RiderProfile.total_earnings).where(RiderProfile.user_id == rider_user_id)
    )
    total = result.scalar() or 0.0

    recent_result = await db.execute(
        select(RiderEarning)
        .where(RiderEarning.rider_id == rider_user_id)
        .order_by(RiderEarning.date.desc())
        .limit(10)
    )
    recent = recent_result.scalars().all()

    return RiderEarningsSummary(
        today=float(today_earnings),
        this_week=float(week_earnings),
        this_month=float(month_earnings),
        total=float(total),
        recent=[RiderEarningResponse.model_validate(e) for e in recent],
    )
