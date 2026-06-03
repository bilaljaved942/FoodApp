"""Super Admin Router — /api/super/*"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from sqlalchemy.orm import selectinload
from uuid import UUID
import math

from app.core.database import get_db
from app.core.security import require_super_admin
from app.models.user import User
from app.models.store import Store
from app.models.order import Order
from app.schemas.auth import UserResponse
from app.schemas.store import StoreCreate, StoreResponse, PaginatedStoresResponse
from app.schemas.order import PaginatedOrdersResponse, OrderResponse
from app.services import order_service, storage_service
from app.core.security import hash_password

router = APIRouter(prefix="/super", tags=["Super Admin"])


# ─── Dashboard ────────────────────────────────────────────────────────────────

@router.get("/dashboard")
async def get_dashboard(
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Platform-wide metrics: users, stores, orders, revenue."""
    total_customers = (await db.execute(select(func.count(User.id)).where(User.role == "customer"))).scalar()
    total_riders = (await db.execute(select(func.count(User.id)).where(User.role == "rider"))).scalar()
    total_store_admins = (await db.execute(select(func.count(User.id)).where(User.role == "store_admin"))).scalar()
    total_stores = (await db.execute(select(func.count(Store.id)).where(Store.is_active == True))).scalar()
    total_orders = (await db.execute(select(func.count(Order.id)))).scalar()
    active_orders = (await db.execute(
        select(func.count(Order.id)).where(
            Order.status.in_(["placed", "accepted", "preparing", "ready", "picked_up", "out_for_delivery"])
        )
    )).scalar()
    total_revenue = (await db.execute(
        select(func.sum(Order.total)).where(Order.payment_status == "paid")
    )).scalar() or 0

    return {
        "total_customers": total_customers,
        "total_riders": total_riders,
        "total_store_admins": total_store_admins,
        "total_stores": total_stores,
        "total_orders": total_orders,
        "active_orders": active_orders,
        "total_revenue": float(total_revenue),
    }


# ─── User Management ─────────────────────────────────────────────────────────

@router.get("/users")
async def list_users(
    role: str | None = Query(None),
    search: str | None = Query(None),
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """List all users, filterable by role or search term."""
    query = select(User)
    if role:
        query = query.where(User.role == role)
    if search:
        query = query.where(
            (User.name.ilike(f"%{search}%")) |
            (User.email.ilike(f"%{search}%")) |
            (User.phone.ilike(f"%{search}%"))
        )
    total = (await db.execute(select(func.count()).select_from(query.subquery()))).scalar()
    result = await db.execute(query.offset((page - 1) * size).limit(size).order_by(desc(User.created_at)))
    users = result.scalars().all()
    return {
        "items": [UserResponse.model_validate(u) for u in users],
        "total": total,
        "page": page,
        "size": size,
        "pages": math.ceil(total / size),
    }


@router.patch("/users/{user_id}/status")
async def toggle_user_status(
    user_id: UUID,
    is_active: bool,
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Suspend or reactivate a user account."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = is_active
    await db.flush()
    return {"message": f"User {'activated' if is_active else 'suspended'}", "user": UserResponse.model_validate(user)}


# ─── Store Management ─────────────────────────────────────────────────────────

@router.get("/stores", response_model=PaginatedStoresResponse)
async def list_all_stores(
    page: int = Query(1, ge=1),
    size: int = Query(20),
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """List ALL stores on the platform (active + inactive)."""
    query = select(Store)
    total = (await db.execute(select(func.count()).select_from(query.subquery()))).scalar()
    result = await db.execute(query.offset((page - 1) * size).limit(size))
    stores = result.scalars().all()
    return PaginatedStoresResponse(
        items=[StoreResponse.model_validate(s) for s in stores],
        total=total, page=page, size=size, pages=math.ceil(total / size)
    )


@router.post("/stores", response_model=StoreResponse, status_code=201)
async def create_store(
    data: StoreCreate,
    admin_name: str = Query(...),
    admin_email: str = Query(...),
    admin_password: str = Query(...),
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Create a new store and its linked store_admin account."""
    import re
    slug = re.sub(r"[^a-z0-9]+", "-", data.name.lower()).strip("-")
    # Check slug uniqueness
    existing = (await db.execute(select(Store).where(Store.slug == slug))).scalar_one_or_none()
    if existing:
        slug = f"{slug}-{str(UUID.hex[:6])}"

    admin = User(name=admin_name, email=admin_email, password_hash=hash_password(admin_password), role="store_admin")
    db.add(admin)
    await db.flush()

    store = Store(admin_user_id=admin.id, slug=slug, **data.model_dump())
    db.add(store)
    await db.flush()
    return StoreResponse.model_validate(store)


@router.patch("/stores/{store_id}/status")
async def toggle_store_status(
    store_id: UUID,
    is_active: bool,
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Enable or disable a store on the platform."""
    result = await db.execute(select(Store).where(Store.id == store_id))
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    store.is_active = is_active
    await db.flush()
    return {"message": f"Store {'enabled' if is_active else 'disabled'}"}


@router.delete("/stores/{store_id}", status_code=204)
async def delete_store(
    store_id: UUID,
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Store).where(Store.id == store_id))
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    await db.delete(store)


# ─── Order Oversight ──────────────────────────────────────────────────────────

@router.get("/orders", response_model=PaginatedOrdersResponse)
async def list_all_orders(
    page: int = Query(1, ge=1),
    size: int = Query(20),
    status: str | None = Query(None),
    store_id: UUID | None = Query(None),
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """View ALL orders across the platform (filterable)."""
    return await order_service.get_all_orders(db, page=page, size=size, status=status, store_id=store_id)


@router.post("/orders/{order_id}/refund")
async def issue_refund(
    order_id: UUID,
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Issue a refund via Stripe for a paid order."""
    from app.services import payment_service
    return await payment_service.issue_refund(db, order_id=order_id)


# ─── Analytics ───────────────────────────────────────────────────────────────

@router.get("/analytics")
async def get_analytics(
    period: str = Query("monthly", regex="^(daily|weekly|monthly)$"),
    payload: dict = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Revenue and performance analytics."""
    from app.services import analytics_service
    return await analytics_service.get_platform_analytics(db, period=period)
