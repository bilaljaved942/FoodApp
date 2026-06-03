"""Auth Service — handles all authentication business logic."""
import random
import string
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_
from fastapi import HTTPException, status

from app.models.user import User
from app.schemas.auth import RegisterRequest, LoginRequest, UserResponse
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token, decode_token
from app.core.redis_client import blacklist_token, store_otp, verify_otp, cache_set, cache_get
import logging

logger = logging.getLogger(__name__)


async def register_user(db: AsyncSession, data: RegisterRequest) -> User:
    """Register a new customer or rider."""
    # Check for duplicate email or phone
    query = select(User).where(
        or_(
            User.email == data.email if data.email else False,
            User.phone == data.phone if data.phone else False,
        )
    )
    result = await db.execute(query)
    existing = result.scalar_one_or_none()
    if existing:
        field = "Email" if existing.email == data.email else "Phone"
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"{field} is already registered"
        )

    user = User(
        name=data.name,
        email=data.email,
        phone=data.phone,
        password_hash=hash_password(data.password),
        role=data.role,
        is_active=True,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return user


async def authenticate_user(db: AsyncSession, data: LoginRequest) -> User:
    """Verify credentials and return the user."""
    query = select(User).where(
        or_(
            User.email == data.email if data.email else False,
            User.phone == data.phone if data.phone else False,
        )
    )
    result = await db.execute(query)
    user = result.scalar_one_or_none()

    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is suspended. Please contact support."
        )
    return user


def generate_tokens(user: User) -> dict:
    """Generate access + refresh JWT tokens for a user."""
    payload = {
        "sub": str(user.id),
        "role": user.role,
        "email": user.email,
    }
    access_token = create_access_token(payload)
    refresh_token = create_refresh_token(payload)
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user": UserResponse.model_validate(user),
    }


async def refresh_access_token(db: AsyncSession, refresh_token: str) -> dict:
    """Validate refresh token and issue new access token."""
    payload = decode_token(refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found or inactive")

    return generate_tokens(user)


async def logout_user(access_token: str, refresh_token: str | None = None):
    """Blacklist access (and optionally refresh) token in Redis."""
    await blacklist_token(access_token, ttl_seconds=900)  # 15 min
    if refresh_token:
        await blacklist_token(refresh_token, ttl_seconds=60 * 60 * 24 * 7)


async def send_otp(identifier: str):
    """Generate and store OTP for password reset (email or phone)."""
    otp = "".join(random.choices(string.digits, k=6))
    await store_otp(identifier, otp, ttl_seconds=300)
    # TODO: Send via email (SendGrid) or SMS (Twilio/Firebase)
    logger.info(f"OTP for {identifier}: {otp}")  # Remove in production
    return otp


async def reset_password(db: AsyncSession, identifier: str, otp: str, new_password: str):
    """Validate OTP and update the user's password."""
    valid = await verify_otp(identifier, otp)
    if not valid:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    result = await db.execute(
        select(User).where(or_(User.email == identifier, User.phone == identifier))
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password_hash = hash_password(new_password)
    await db.flush()


async def update_fcm_token(db: AsyncSession, user_id: str, fcm_token: str):
    """Update Firebase device token for push notifications."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user:
        user.fcm_token = fcm_token
        await db.flush()
