"""SQLAlchemy ORM Models — Rider"""
import uuid
from datetime import datetime, date, timezone
from sqlalchemy import String, Boolean, DateTime, Date, Numeric, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base


class RiderProfile(Base):
    __tablename__ = "rider_profiles"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True
    )
    vehicle_type: Mapped[str | None] = mapped_column(String(50), nullable=True)  # bike, car, etc
    license_plate: Mapped[str | None] = mapped_column(String(20), nullable=True)
    cnic: Mapped[str | None] = mapped_column(String(20), nullable=True)
    is_online: Mapped[bool] = mapped_column(Boolean, default=False)
    is_approved: Mapped[bool] = mapped_column(Boolean, default=False)
    current_lat: Mapped[float | None] = mapped_column(nullable=True)
    current_lng: Mapped[float | None] = mapped_column(nullable=True)
    last_location_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    documents_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    total_deliveries: Mapped[int] = mapped_column(default=0)
    total_earnings: Mapped[float] = mapped_column(Numeric(12, 2), default=0.0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    user: Mapped["User"] = relationship("User", back_populates="rider_profile")
    location_logs: Mapped[list["RiderLocation"]] = relationship(
        "RiderLocation", back_populates="rider", cascade="all, delete-orphan"
    )
    earnings: Mapped[list["RiderEarning"]] = relationship(
        "RiderEarning", back_populates="rider", cascade="all, delete-orphan"
    )


class RiderLocation(Base):
    """High-frequency write table — mirrored to Firebase Realtime DB."""
    __tablename__ = "rider_locations"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    rider_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    lat: Mapped[float] = mapped_column(nullable=False)
    lng: Mapped[float] = mapped_column(nullable=False)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True
    )

    rider: Mapped["RiderProfile"] = relationship("RiderProfile", back_populates="location_logs",
                                                  foreign_keys=[rider_id],
                                                  primaryjoin="RiderLocation.rider_id == RiderProfile.user_id")


class RiderEarning(Base):
    __tablename__ = "rider_earnings"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    rider_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    order_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("orders.id", ondelete="RESTRICT"), nullable=False
    )
    amount: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    rider: Mapped["RiderProfile"] = relationship("RiderProfile", back_populates="earnings",
                                                  foreign_keys=[rider_id],
                                                  primaryjoin="RiderEarning.rider_id == RiderProfile.user_id")
