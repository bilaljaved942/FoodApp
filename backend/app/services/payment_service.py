"""Payment Service — Stripe integration."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException
from uuid import UUID
import logging

from app.models.payment import Payment
from app.models.order import Order
from app.core.config import settings

logger = logging.getLogger(__name__)


async def issue_refund(db: AsyncSession, order_id: UUID) -> dict:
    """Issue a full refund for a paid Stripe order."""
    result = await db.execute(select(Payment).where(Payment.order_id == order_id))
    payment = result.scalar_one_or_none()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment record not found")
    if payment.gateway != "stripe":
        raise HTTPException(status_code=400, detail="Only Stripe payments can be refunded via this endpoint")
    if payment.status not in ("paid",):
        raise HTTPException(status_code=400, detail=f"Cannot refund payment with status: {payment.status}")

    try:
        import stripe
        stripe.api_key = settings.STRIPE_SECRET_KEY
        refund = stripe.Refund.create(payment_intent=payment.stripe_payment_intent_id)
        payment.status = "refunded"
        payment.refund_id = refund.id

        from datetime import datetime, timezone
        payment.refunded_at = datetime.now(timezone.utc)

        # Update order payment status
        order_result = await db.execute(select(Order).where(Order.id == order_id))
        order = order_result.scalar_one_or_none()
        if order:
            order.payment_status = "refunded"

        await db.flush()
        return {"message": "Refund issued successfully", "refund_id": refund.id}
    except Exception as e:
        logger.error(f"Stripe refund error: {e}")
        raise HTTPException(status_code=500, detail="Refund processing failed")


async def confirm_stripe_payment(db: AsyncSession, payment_intent_id: str):
    """Webhook handler: mark payment as paid after Stripe confirms."""
    result = await db.execute(
        select(Payment).where(Payment.stripe_payment_intent_id == payment_intent_id)
    )
    payment = result.scalar_one_or_none()
    if not payment:
        logger.warning(f"Payment record not found for intent: {payment_intent_id}")
        return
    payment.status = "paid"
    order_result = await db.execute(select(Order).where(Order.id == payment.order_id))
    order = order_result.scalar_one_or_none()
    if order:
        order.payment_status = "paid"
    await db.flush()
    logger.info(f"Payment confirmed for order {payment.order_id}")
