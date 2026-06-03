"""Rider Router — /api/rider/*"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from uuid import UUID

from app.core.database import get_db
from app.core.security import require_rider
from app.models.rider import RiderProfile
from app.models.order import Order
from app.schemas.rider import (
    RiderStatusUpdate, RiderLocationUpdate, RiderProfileResponse,
    RiderEarningsSummary, RiderLocationResponse,
)
from app.schemas.order import OrderResponse, UpdateOrderStatusRequest
from app.services import order_service, rider_service

router = APIRouter(prefix="/rider", tags=["Rider"])


@router.get("/profile", response_model=RiderProfileResponse)
async def get_rider_profile(
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Get the current rider's profile."""
    result = await db.execute(
        select(RiderProfile).where(RiderProfile.user_id == payload["sub"])
    )
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Rider profile not found")
    return RiderProfileResponse.model_validate(profile)


@router.patch("/status", response_model=RiderProfileResponse)
async def update_online_status(
    data: RiderStatusUpdate,
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Toggle rider online/offline status."""
    return await rider_service.update_rider_status(db, rider_user_id=payload["sub"], is_online=data.is_online)


@router.post("/location", status_code=200)
async def update_location(
    data: RiderLocationUpdate,
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Broadcast rider's current GPS coordinates (called every ~35 seconds)."""
    await rider_service.update_rider_location(db, rider_user_id=payload["sub"], lat=data.lat, lng=data.lng)
    return {"status": "location updated"}


@router.get("/orders/available")
async def get_available_orders(
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Get orders in 'ready' status that are available for pickup."""
    return await rider_service.get_available_orders(db)


@router.patch("/orders/{order_id}/accept", response_model=OrderResponse)
async def accept_order(
    order_id: UUID,
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Accept an available order."""
    return await rider_service.accept_order(db, rider_user_id=payload["sub"], order_id=order_id)


@router.patch("/orders/{order_id}/reject", status_code=200)
async def reject_order(
    order_id: UUID,
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Reject an offered order (returns it to available pool)."""
    await rider_service.reject_order(db, rider_user_id=payload["sub"], order_id=order_id)
    return {"status": "order rejected"}


@router.patch("/orders/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: UUID,
    data: UpdateOrderStatusRequest,
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Update order status: picked_up → out_for_delivery → delivered."""
    allowed_for_rider = {"picked_up", "out_for_delivery", "delivered"}
    if data.status not in allowed_for_rider:
        raise HTTPException(status_code=400, detail=f"Riders can only set: {allowed_for_rider}")
    return await order_service.update_order_status(
        db,
        order_id=order_id,
        new_status=data.status,
        changed_by_user_id=payload["sub"],
        rider_id=payload["sub"],
    )


@router.get("/earnings", response_model=RiderEarningsSummary)
async def get_earnings(
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Get earnings summary: today, this week, this month, total."""
    return await rider_service.get_earnings_summary(db, rider_user_id=payload["sub"])


@router.get("/orders/active", response_model=OrderResponse)
async def get_active_order(
    payload: dict = Depends(require_rider),
    db: AsyncSession = Depends(get_db),
):
    """Get the current active order assigned to this rider."""
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where(
            Order.rider_id == payload["sub"],
            Order.status.in_(["picked_up", "out_for_delivery", "ready"]),
        )
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="No active order")
    return OrderResponse.model_validate(order)
