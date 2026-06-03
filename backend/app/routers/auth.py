"""Auth Router — POST /api/auth/*"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import get_current_user_payload, bearer_scheme
from app.schemas.auth import (
    RegisterRequest, LoginRequest, TokenResponse, RefreshRequest,
    ForgotPasswordRequest, ResetPasswordRequest, UpdateFCMTokenRequest,
)
from app.services import auth_service

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(data: RegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register a new customer or rider account."""
    user = await auth_service.register_user(db, data)
    return auth_service.generate_tokens(user)


@router.post("/login", response_model=TokenResponse)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Login with email/phone + password. Returns JWT tokens."""
    user = await auth_service.authenticate_user(db, data)
    return auth_service.generate_tokens(user)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(data: RefreshRequest, db: AsyncSession = Depends(get_db)):
    """Refresh access token using a valid refresh token."""
    return await auth_service.refresh_access_token(db, data.refresh_token)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    data: RefreshRequest | None = None,
    credentials=Depends(bearer_scheme),
):
    """Blacklist the current access token (and refresh token if provided)."""
    refresh_token = data.refresh_token if data else None
    await auth_service.logout_user(credentials.credentials, refresh_token)


@router.post("/forgot-password", status_code=status.HTTP_200_OK)
async def forgot_password(data: ForgotPasswordRequest):
    """Send OTP to email or phone for password reset."""
    identifier = data.email or data.phone
    if not identifier:
        raise HTTPException(status_code=400, detail="Email or phone required")
    await auth_service.send_otp(identifier)
    return {"message": "OTP sent successfully"}


@router.post("/reset-password", status_code=status.HTTP_200_OK)
async def reset_password(data: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    """Reset password using OTP."""
    await auth_service.reset_password(db, data.identifier, data.otp, data.new_password)
    return {"message": "Password reset successful"}


@router.post("/fcm-token", status_code=status.HTTP_200_OK)
async def update_fcm_token(
    data: UpdateFCMTokenRequest,
    payload: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db),
):
    """Update Firebase Cloud Messaging device token for push notifications."""
    await auth_service.update_fcm_token(db, payload["sub"], data.fcm_token)
    return {"message": "FCM token updated"}


@router.get("/me")
async def get_me(
    payload: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db),
):
    """Get current authenticated user's profile."""
    from sqlalchemy import select
    from app.models.user import User
    from app.schemas.auth import UserResponse
    result = await db.execute(select(User).where(User.id == payload["sub"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.model_validate(user)
