"""Store Admin Router — /api/admin/*"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from uuid import UUID
import math

from app.core.database import get_db
from app.core.security import require_store_admin
from app.models.store import Store, Product, ProductCategory
from app.models.order import Order
from app.schemas.store import (
    StoreUpdate, StoreResponse, StoreDetailResponse,
    ProductCreate, ProductUpdate, ProductResponse,
    ProductCategoryCreate, ProductCategoryResponse,
)
from app.schemas.order import UpdateOrderStatusRequest, OrderResponse, PaginatedOrdersResponse
from app.services import order_service, storage_service

router = APIRouter(prefix="/admin", tags=["Store Admin"])


async def get_admin_store(payload: dict, db: AsyncSession) -> Store:
    """Helper: get the store owned by the current store_admin."""
    result = await db.execute(
        select(Store).where(Store.admin_user_id == payload["sub"], Store.is_active == True)
    )
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="No store linked to this admin account")
    return store


# ─── Store Management ─────────────────────────────────────────────────────────

@router.get("/store", response_model=StoreDetailResponse)
async def get_my_store(
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    """Get the store profile managed by the current admin."""
    result = await db.execute(
        select(Store)
        .options(selectinload(Store.product_categories), selectinload(Store.products))
        .where(Store.admin_user_id == payload["sub"])
    )
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="No store linked to this account")
    return StoreDetailResponse.model_validate(store)


@router.put("/store", response_model=StoreResponse)
async def update_my_store(
    data: StoreUpdate,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    """Update store profile, operating hours, or open/closed status."""
    store = await get_admin_store(payload, db)
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(store, field, value)
    await db.flush()
    return StoreResponse.model_validate(store)


@router.post("/store/logo", response_model=StoreResponse)
async def upload_store_logo(
    file: UploadFile = File(...),
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    """Upload store logo to DigitalOcean Spaces."""
    store = await get_admin_store(payload, db)
    url = await storage_service.upload_file(file, folder="stores/logos")
    store.logo_url = url
    await db.flush()
    return StoreResponse.model_validate(store)


@router.post("/store/banner", response_model=StoreResponse)
async def upload_store_banner(
    file: UploadFile = File(...),
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    """Upload store banner to DigitalOcean Spaces."""
    store = await get_admin_store(payload, db)
    url = await storage_service.upload_file(file, folder="stores/banners")
    store.banner_url = url
    await db.flush()
    return StoreResponse.model_validate(store)


# ─── Product Categories ───────────────────────────────────────────────────────

@router.post("/categories", response_model=ProductCategoryResponse, status_code=201)
async def create_category(
    data: ProductCategoryCreate,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    store = await get_admin_store(payload, db)
    category = ProductCategory(store_id=store.id, **data.model_dump())
    db.add(category)
    await db.flush()
    return ProductCategoryResponse.model_validate(category)


@router.delete("/categories/{category_id}", status_code=204)
async def delete_category(
    category_id: UUID,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    store = await get_admin_store(payload, db)
    result = await db.execute(
        select(ProductCategory).where(ProductCategory.id == category_id, ProductCategory.store_id == store.id)
    )
    category = result.scalar_one_or_none()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    await db.delete(category)


# ─── Products ─────────────────────────────────────────────────────────────────

@router.post("/products", response_model=ProductResponse, status_code=201)
async def create_product(
    data: ProductCreate,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    store = await get_admin_store(payload, db)
    product = Product(store_id=store.id, **data.model_dump())
    db.add(product)
    await db.flush()
    return ProductResponse.model_validate(product)


@router.put("/products/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: UUID,
    data: ProductUpdate,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    store = await get_admin_store(payload, db)
    result = await db.execute(
        select(Product).where(Product.id == product_id, Product.store_id == store.id)
    )
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(product, field, value)
    await db.flush()
    return ProductResponse.model_validate(product)


@router.post("/products/{product_id}/image", response_model=ProductResponse)
async def upload_product_image(
    product_id: UUID,
    file: UploadFile = File(...),
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    store = await get_admin_store(payload, db)
    result = await db.execute(
        select(Product).where(Product.id == product_id, Product.store_id == store.id)
    )
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    url = await storage_service.upload_file(file, folder="products")
    product.image_url = url
    await db.flush()
    return ProductResponse.model_validate(product)


@router.delete("/products/{product_id}", status_code=204)
async def delete_product(
    product_id: UUID,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    store = await get_admin_store(payload, db)
    result = await db.execute(
        select(Product).where(Product.id == product_id, Product.store_id == store.id)
    )
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    await db.delete(product)


# ─── Orders ───────────────────────────────────────────────────────────────────

@router.get("/orders", response_model=PaginatedOrdersResponse)
async def get_store_orders(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=50),
    status: str | None = Query(None),
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    """List all orders for this store (paginated, filterable by status)."""
    store = await get_admin_store(payload, db)
    return await order_service.get_store_orders(db, store_id=store.id, page=page, size=size, status=status)


@router.patch("/orders/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: UUID,
    data: UpdateOrderStatusRequest,
    payload: dict = Depends(require_store_admin),
    db: AsyncSession = Depends(get_db),
):
    """Update order status (accept/reject/preparing/ready)."""
    store = await get_admin_store(payload, db)
    return await order_service.update_order_status(
        db,
        order_id=order_id,
        new_status=data.status,
        changed_by_user_id=payload["sub"],
        store_id=store.id,
        note=data.note,
    )
