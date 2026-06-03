"""Pydantic Schemas — Store & Products"""
from pydantic import BaseModel, field_validator
from typing import Optional
from uuid import UUID
from datetime import datetime


# ─── Product Category ────────────────────────────────────────────────────────

class ProductCategoryCreate(BaseModel):
    name: str
    sort_order: int = 0


class ProductCategoryResponse(BaseModel):
    id: UUID
    store_id: UUID
    name: str
    sort_order: int
    model_config = {"from_attributes": True}


# ─── Product ─────────────────────────────────────────────────────────────────

class ProductCreate(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    category_id: Optional[UUID] = None
    sort_order: int = 0

    @field_validator("price")
    @classmethod
    def validate_price(cls, v):
        if v < 0:
            raise ValueError("Price cannot be negative")
        return v


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    category_id: Optional[UUID] = None
    is_available: Optional[bool] = None
    sort_order: Optional[int] = None


class ProductResponse(BaseModel):
    id: UUID
    store_id: UUID
    category_id: Optional[UUID] = None
    name: str
    description: Optional[str] = None
    price: float
    image_url: Optional[str] = None
    is_available: bool
    sort_order: int
    model_config = {"from_attributes": True}


# ─── Store ───────────────────────────────────────────────────────────────────

class OperatingHoursDay(BaseModel):
    open: str = "09:00"   # HH:MM
    close: str = "22:00"
    is_closed: bool = False


class StoreCreate(BaseModel):
    name: str
    category: str
    description: Optional[str] = None
    address: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    phone: Optional[str] = None
    estimated_delivery_minutes: int = 30
    delivery_fee: float = 0.0
    minimum_order: float = 0.0
    operating_hours: Optional[dict] = None


class StoreUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    address: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    phone: Optional[str] = None
    estimated_delivery_minutes: Optional[int] = None
    delivery_fee: Optional[float] = None
    minimum_order: Optional[float] = None
    is_open: Optional[bool] = None
    operating_hours: Optional[dict] = None


class StoreResponse(BaseModel):
    id: UUID
    name: str
    slug: str
    logo_url: Optional[str] = None
    banner_url: Optional[str] = None
    category: str
    description: Optional[str] = None
    address: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    phone: Optional[str] = None
    estimated_delivery_minutes: int
    delivery_fee: float
    minimum_order: float
    is_active: bool
    is_open: bool
    average_rating: float
    total_orders: int
    operating_hours: Optional[dict] = None
    model_config = {"from_attributes": True}


class StoreDetailResponse(StoreResponse):
    """Store detail with categories and products."""
    product_categories: list[ProductCategoryResponse] = []
    products: list[ProductResponse] = []


class PaginatedStoresResponse(BaseModel):
    items: list[StoreResponse]
    total: int
    page: int
    size: int
    pages: int
