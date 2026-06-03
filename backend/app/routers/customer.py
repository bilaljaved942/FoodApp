"""Customer Router — GET /api/stores, /api/orders"""
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from uuid import UUID
import math

from app.core.database import get_db
from app.core.security import require_customer, get_current_user_payload
from app.models.store import Store, Product
from app.models.order import Order
from app.schemas.store import StoreResponse, StoreDetailResponse, PaginatedStoresResponse
from app.schemas.order import PlaceOrderRequest, OrderResponse, OrderPlacedResponse, PaginatedOrdersResponse
from app.schemas.auth import UserResponse
from app.services import order_service

router = APIRouter(tags=["Customer"])


# ─── Stores ──────────────────────────────────────────────────────────────────

@router.get("/stores", response_model=PaginatedStoresResponse)
async def list_stores(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    category: str | None = Query(None),
    search: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    """List all active stores with optional category/search filter (paginated)."""
    query = select(Store).where(Store.is_active == True)

    if category:
        query = query.where(Store.category.ilike(f"%{category}%"))
    if search:
        query = query.where(Store.name.ilike(f"%{search}%"))

    # Count
    count_result = await db.execute(select(func.count()).select_from(query.subquery()))
    total = count_result.scalar()

    # Paginate
    query = query.offset((page - 1) * size).limit(size).order_by(Store.total_orders.desc())
    result = await db.execute(query)
    stores = result.scalars().all()

    return PaginatedStoresResponse(
        items=[StoreResponse.model_validate(s) for s in stores],
        total=total,
        page=page,
        size=size,
        pages=math.ceil(total / size),
    )


@router.get("/stores/{store_id}", response_model=StoreDetailResponse)
async def get_store_detail(store_id: UUID, db: AsyncSession = Depends(get_db)):
    """Get store detail with full menu (categories + products)."""
    from sqlalchemy.orm import selectinload
    result = await db.execute(
        select(Store)
        .options(
            selectinload(Store.product_categories),
            selectinload(Store.products),
        )
        .where(Store.id == store_id, Store.is_active == True)
    )
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    return StoreDetailResponse.model_validate(store)


# ─── Orders ──────────────────────────────────────────────────────────────────

@router.post("/orders", response_model=OrderPlacedResponse, status_code=201)
async def place_order(
    data: PlaceOrderRequest,
    payload: dict = Depends(require_customer),
    db: AsyncSession = Depends(get_db),
):
    """Place a new food order. Returns order + Stripe client_secret for card payments."""
    return await order_service.place_order(db, customer_id=payload["sub"], data=data)


@router.get("/orders/my", response_model=PaginatedOrdersResponse)
async def my_orders(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=50),
    payload: dict = Depends(require_customer),
    db: AsyncSession = Depends(get_db),
):
    """Get current customer's order history (paginated)."""
    return await order_service.get_customer_orders(db, customer_id=payload["sub"], page=page, size=size)


@router.get("/orders/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: UUID,
    payload: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db),
):
    """Get order detail with current status and items."""
    from sqlalchemy.orm import selectinload
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items), selectinload(Order.status_logs))
        .where(Order.id == order_id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Customers can only see their own orders; admins/super_admin can see all
    user_role = payload.get("role")
    if user_role == "customer" and str(order.customer_id) != payload["sub"]:
        raise HTTPException(status_code=403, detail="Access denied")

    return OrderResponse.model_validate(order)


@router.get("/orders/{order_id}/rider-location")
async def get_rider_location(order_id: UUID, db: AsyncSession = Depends(get_db)):
    """Get live rider GPS coordinates for active order (from Firebase)."""
    result = await db.execute(select(Order).where(Order.id == order_id))
    order = result.scalar_one_or_none()
    if not order or not order.rider_id:
        raise HTTPException(status_code=404, detail="No rider assigned to this order")

    from app.core.firebase_client import get_firebase_db
    rider_ref = get_firebase_db().reference(f"rider_locations/{order.rider_id}")
    location = rider_ref.get()
    if not location:
        raise HTTPException(status_code=404, detail="Rider location not available")
    return location


# ─── Customer Profile ─────────────────────────────────────────────────────────

@router.get("/profile", response_model=UserResponse)
async def get_profile(
    payload: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db),
):
    from sqlalchemy.select import select as _select
    from app.models.user import User
    result = await db.execute(select(User).where(User.id == payload["sub"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.model_validate(user)
