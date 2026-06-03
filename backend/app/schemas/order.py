"""Pydantic Schemas — Orders"""
from pydantic import BaseModel, field_validator
from typing import Optional
from uuid import UUID
from datetime import datetime


class OrderItemRequest(BaseModel):
    product_id: UUID
    quantity: int

    @field_validator("quantity")
    @classmethod
    def validate_qty(cls, v):
        if v < 1:
            raise ValueError("Quantity must be at least 1")
        return v


class DeliveryAddressRequest(BaseModel):
    label: str = "Home"
    address_line: str
    lat: Optional[float] = None
    lng: Optional[float] = None


class PlaceOrderRequest(BaseModel):
    store_id: UUID
    items: list[OrderItemRequest]
    delivery_address: DeliveryAddressRequest
    payment_method: str  # card | cod
    special_instructions: Optional[str] = None

    @field_validator("payment_method")
    @classmethod
    def validate_payment_method(cls, v):
        if v not in {"card", "cod"}:
            raise ValueError("payment_method must be 'card' or 'cod'")
        return v

    @field_validator("items")
    @classmethod
    def validate_items(cls, v):
        if not v:
            raise ValueError("Order must have at least one item")
        return v


class UpdateOrderStatusRequest(BaseModel):
    status: str
    note: Optional[str] = None

    @field_validator("status")
    @classmethod
    def validate_status(cls, v):
        allowed = {
            "accepted", "rejected", "preparing", "ready",
            "picked_up", "out_for_delivery", "delivered", "cancelled"
        }
        if v not in allowed:
            raise ValueError(f"Invalid status. Allowed: {allowed}")
        return v


class OrderItemResponse(BaseModel):
    id: UUID
    product_id: Optional[UUID] = None
    product_name: str
    quantity: int
    unit_price: float
    total_price: float
    model_config = {"from_attributes": True}


class OrderStatusLogResponse(BaseModel):
    status: str
    note: Optional[str] = None
    timestamp: datetime
    model_config = {"from_attributes": True}


class OrderResponse(BaseModel):
    id: UUID
    customer_id: UUID
    store_id: UUID
    rider_id: Optional[UUID] = None
    status: str
    payment_method: str
    payment_status: str
    subtotal: float
    delivery_fee: float
    total: float
    delivery_address: dict
    special_instructions: Optional[str] = None
    estimated_delivery_at: Optional[datetime] = None
    items: list[OrderItemResponse] = []
    status_logs: list[OrderStatusLogResponse] = []
    created_at: datetime
    model_config = {"from_attributes": True}


class PaginatedOrdersResponse(BaseModel):
    items: list[OrderResponse]
    total: int
    page: int
    size: int
    pages: int


class OrderPlacedResponse(BaseModel):
    order: OrderResponse
    stripe_client_secret: Optional[str] = None  # Only for card payments
