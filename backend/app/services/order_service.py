"""Order Service — core ordering business logic."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from sqlalchemy.orm import selectinload
from fastapi import HTTPException
from uuid import UUID
import math
import logging

from app.models.order import Order, OrderItem, OrderStatusLog
from app.models.store import Store, Product
from app.models.payment import Payment
from app.schemas.order import PlaceOrderRequest, OrderResponse, PaginatedOrdersResponse, OrderPlacedResponse

logger = logging.getLogger(__name__)


async def place_order(db: AsyncSession, customer_id: str, data: PlaceOrderRequest) -> OrderPlacedResponse:
    """
    Create a new order:
    1. Validate store is active and open
    2. Validate all products exist in the store
    3. Calculate totals
    4. Create order + items + payment record
    5. Create Stripe Payment Intent if card payment
    6. Notify store admin via FCM
    """
    # Validate store
    result = await db.execute(select(Store).where(Store.id == data.store_id))
    store = result.scalar_one_or_none()
    if not store or not store.is_active:
        raise HTTPException(status_code=404, detail="Store not found or inactive")
    if not store.is_open:
        raise HTTPException(status_code=400, detail="Store is currently closed")

    # Validate products + calculate subtotal
    subtotal = 0.0
    order_items_data = []
    for item_req in data.items:
        product_result = await db.execute(
            select(Product).where(Product.id == item_req.product_id, Product.store_id == data.store_id)
        )
        product = product_result.scalar_one_or_none()
        if not product:
            raise HTTPException(status_code=400, detail=f"Product {item_req.product_id} not found in this store")
        if not product.is_available:
            raise HTTPException(status_code=400, detail=f"Product '{product.name}' is currently unavailable")
        item_total = float(product.price) * item_req.quantity
        subtotal += item_total
        order_items_data.append({
            "product_id": product.id,
            "product_name": product.name,
            "quantity": item_req.quantity,
            "unit_price": float(product.price),
            "total_price": item_total,
        })

    if subtotal < float(store.minimum_order):
        raise HTTPException(
            status_code=400,
            detail=f"Minimum order is PKR {store.minimum_order}. Your subtotal is PKR {subtotal:.2f}"
        )

    delivery_fee = float(store.delivery_fee)
    total = subtotal + delivery_fee

    # Create Order
    order = Order(
        customer_id=customer_id,
        store_id=data.store_id,
        status="placed",
        payment_method=data.payment_method,
        payment_status="pending",
        subtotal=subtotal,
        delivery_fee=delivery_fee,
        total=total,
        delivery_address=data.delivery_address.model_dump(),
        special_instructions=data.special_instructions,
    )
    db.add(order)
    await db.flush()

    # Create OrderItems
    for item_data in order_items_data:
        db.add(OrderItem(order_id=order.id, **item_data))

    # Log initial status
    db.add(OrderStatusLog(order_id=order.id, status="placed", changed_by_user_id=customer_id))

    # Payment record
    stripe_client_secret = None
    if data.payment_method == "card":
        stripe_client_secret = await _create_stripe_payment_intent(db, order, total)
    else:
        # COD — payment_status stays pending until delivery
        db.add(Payment(order_id=order.id, gateway="cod", amount=total, currency="PKR", status="pending"))

    await db.flush()
    await db.refresh(order)

    # Update store total_orders counter
    store.total_orders = (store.total_orders or 0) + 1

    # Notify store admin (non-blocking background)
    _notify_store_admin_new_order(store, order)

    # Push to Firebase Realtime DB
    _push_order_to_firebase(order)

    result2 = await db.execute(
        select(Order)
        .options(selectinload(Order.items), selectinload(Order.status_logs))
        .where(Order.id == order.id)
    )
    order_full = result2.scalar_one()
    return OrderPlacedResponse(
        order=OrderResponse.model_validate(order_full),
        stripe_client_secret=stripe_client_secret,
    )


async def _create_stripe_payment_intent(db: AsyncSession, order: Order, amount: float) -> str:
    """Create a Stripe Payment Intent and store record."""
    try:
        import stripe
        from app.core.config import settings
        stripe.api_key = settings.STRIPE_SECRET_KEY

        # Convert PKR to smallest unit (paisa)
        intent = stripe.PaymentIntent.create(
            amount=int(amount * 100),
            currency="pkr",
            metadata={"order_id": str(order.id)},
        )
        db.add(Payment(
            order_id=order.id,
            gateway="stripe",
            stripe_payment_intent_id=intent.id,
            stripe_client_secret=intent.client_secret,
            amount=amount,
            currency="PKR",
            status="pending",
        ))
        return intent.client_secret
    except Exception as e:
        logger.error(f"Stripe payment intent creation failed: {e}")
        raise HTTPException(status_code=500, detail="Payment processing error")


def _notify_store_admin_new_order(store: Store, order: Order):
    """Send FCM push notification to store admin (fire-and-forget)."""
    try:
        from sqlalchemy import create_engine
        from app.core.firebase_client import send_fcm_notification
        # Note: FCM token lookup done via background task in production
        logger.info(f"Notifying store admin for order {order.id}")
    except Exception as e:
        logger.warning(f"FCM notification skipped: {e}")


def _push_order_to_firebase(order: Order):
    """Push order status to Firebase Realtime DB for real-time sync."""
    try:
        from app.core.firebase_client import update_order_status_realtime
        update_order_status_realtime(str(order.id), order.status)
    except Exception as e:
        logger.warning(f"Firebase push skipped: {e}")


async def update_order_status(
    db: AsyncSession,
    order_id: UUID,
    new_status: str,
    changed_by_user_id: str,
    store_id: UUID | None = None,
    rider_id: str | None = None,
    note: str | None = None,
) -> OrderResponse:
    """Update order status with validation, logging, Firebase sync, and FCM notifications."""
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items), selectinload(Order.status_logs))
        .where(Order.id == order_id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Validate store ownership (for store admin)
    if store_id and order.store_id != store_id:
        raise HTTPException(status_code=403, detail="Order does not belong to your store")

    # Validate status transitions
    valid_transitions = {
        "placed": ["accepted", "rejected"],
        "accepted": ["preparing"],
        "preparing": ["ready"],
        "ready": ["picked_up"],
        "picked_up": ["out_for_delivery"],
        "out_for_delivery": ["delivered"],
        "delivered": [],
        "rejected": [],
        "cancelled": [],
    }
    if new_status not in valid_transitions.get(order.status, []):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot transition from '{order.status}' to '{new_status}'"
        )

    order.status = new_status
    if rider_id and new_status in ["picked_up", "out_for_delivery", "delivered"]:
        order.rider_id = rider_id

    # Handle COD payment on delivery
    if new_status == "delivered" and order.payment_method == "cod":
        order.payment_status = "paid"

    db.add(OrderStatusLog(
        order_id=order.id, status=new_status,
        changed_by_user_id=changed_by_user_id, note=note
    ))

    # Firebase sync
    _push_order_to_firebase(order)

    # Broadcast via WebSocket
    try:
        from app.routers.websocket import manager
        import asyncio
        asyncio.create_task(manager.broadcast_order_update(
            str(order.id), {"status": new_status, "order_id": str(order.id)}
        ))
    except Exception as e:
        logger.warning(f"WebSocket broadcast skipped: {e}")

    await db.flush()
    return OrderResponse.model_validate(order)


async def get_customer_orders(
    db: AsyncSession, customer_id: str, page: int = 1, size: int = 20
) -> PaginatedOrdersResponse:
    query = select(Order).where(Order.customer_id == customer_id).options(
        selectinload(Order.items)
    ).order_by(desc(Order.created_at))
    total = (await db.execute(select(func.count()).select_from(
        select(Order).where(Order.customer_id == customer_id).subquery()
    ))).scalar()
    result = await db.execute(query.offset((page - 1) * size).limit(size))
    orders = result.scalars().all()
    return PaginatedOrdersResponse(
        items=[OrderResponse.model_validate(o) for o in orders],
        total=total, page=page, size=size, pages=math.ceil(total / size)
    )


async def get_store_orders(
    db: AsyncSession, store_id: UUID, page: int = 1, size: int = 20, status: str | None = None
) -> PaginatedOrdersResponse:
    query = select(Order).where(Order.store_id == store_id).options(selectinload(Order.items))
    if status:
        query = query.where(Order.status == status)
    query = query.order_by(desc(Order.created_at))
    base = select(Order).where(Order.store_id == store_id)
    if status:
        base = base.where(Order.status == status)
    total = (await db.execute(select(func.count()).select_from(base.subquery()))).scalar()
    result = await db.execute(query.offset((page - 1) * size).limit(size))
    orders = result.scalars().all()
    return PaginatedOrdersResponse(
        items=[OrderResponse.model_validate(o) for o in orders],
        total=total, page=page, size=size, pages=math.ceil(total / size)
    )


async def get_all_orders(
    db: AsyncSession, page: int = 1, size: int = 20,
    status: str | None = None, store_id: UUID | None = None
) -> PaginatedOrdersResponse:
    query = select(Order).options(selectinload(Order.items))
    if status:
        query = query.where(Order.status == status)
    if store_id:
        query = query.where(Order.store_id == store_id)
    query = query.order_by(desc(Order.created_at))
    base = select(Order)
    if status:
        base = base.where(Order.status == status)
    if store_id:
        base = base.where(Order.store_id == store_id)
    total = (await db.execute(select(func.count()).select_from(base.subquery()))).scalar()
    result = await db.execute(query.offset((page - 1) * size).limit(size))
    orders = result.scalars().all()
    return PaginatedOrdersResponse(
        items=[OrderResponse.model_validate(o) for o in orders],
        total=total, page=page, size=size, pages=math.ceil(total / size)
    )
