"""Pydantic Schemas — Rider"""
from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime, date


class RiderStatusUpdate(BaseModel):
    is_online: bool


class RiderLocationUpdate(BaseModel):
    lat: float
    lng: float


class AcceptOrderRequest(BaseModel):
    order_id: UUID


class RiderProfileResponse(BaseModel):
    id: UUID
    user_id: UUID
    vehicle_type: Optional[str] = None
    license_plate: Optional[str] = None
    is_online: bool
    is_approved: bool
    total_deliveries: int
    total_earnings: float
    current_lat: Optional[float] = None
    current_lng: Optional[float] = None
    model_config = {"from_attributes": True}


class RiderEarningResponse(BaseModel):
    id: UUID
    order_id: UUID
    amount: float
    date: date
    model_config = {"from_attributes": True}


class RiderEarningsSummary(BaseModel):
    today: float
    this_week: float
    this_month: float
    total: float
    recent: list[RiderEarningResponse]


class RiderLocationResponse(BaseModel):
    rider_id: str
    lat: float
    lng: float
    timestamp: Optional[datetime] = None
