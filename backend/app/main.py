"""
FoodApp — FastAPI Backend Entry Point
Food Delivery Platform (Foodpanda/DoorDash-like)
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import sentry_sdk

from app.core.config import settings
from app.core.database import engine
from app.core.redis_client import get_redis, close_redis
from app.core.firebase_client import init_firebase

# Routers
from app.routers import auth, customer, store_admin, rider, super_admin, websocket

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

# ─── Sentry (production error tracking) ─────────────────────────────────────

if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        environment=settings.APP_ENV,
        traces_sample_rate=0.1,
    )

# ─── Rate Limiter ────────────────────────────────────────────────────────────

limiter = Limiter(key_func=get_remote_address, default_limits=[f"{settings.RATE_LIMIT_PER_MINUTE}/minute"])


# ─── Lifespan (startup/shutdown) ─────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events."""
    logger.info("🚀 Starting FoodApp API...")

    # Initialize Firebase
    init_firebase()

    # Initialize Redis connection
    await get_redis()
    logger.info("✅ Redis connected")

    logger.info(f"✅ FoodApp API running in {settings.APP_ENV} mode")
    yield

    # Shutdown
    await close_redis()
    await engine.dispose()
    logger.info("👋 FoodApp API shutdown complete")


# ─── FastAPI App ──────────────────────────────────────────────────────────────

app = FastAPI(
    title="FoodApp API",
    description="""
## 🍔 FoodApp — Food Delivery Platform API

A complete food delivery backend powering:
- **Customer App** (Flutter) — Browse, order, track
- **Rider App** (Flutter) — Accept deliveries, GPS tracking
- **Store Admin App** (Flutter) — Manage menu, orders
- **Super Admin Panel** (React) — Platform oversight

### Authentication
All protected endpoints require `Authorization: Bearer <access_token>` header.
Register at `/api/auth/register` and login at `/api/auth/login` to get tokens.

### Real-time
Connect to WebSocket endpoints:
- `ws://host/ws/orders/{order_id}` — Order status updates
- `ws://host/ws/rider/{rider_id}` — Rider GPS tracking
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# ─── Middleware ───────────────────────────────────────────────────────────────

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Exception Handlers ───────────────────────────────────────────────────────

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = [{"field": ".".join(str(l) for l in e["loc"]), "message": e["msg"]} for e in exc.errors()]
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": "Validation error", "errors": errors},
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


# ─── Routes ───────────────────────────────────────────────────────────────────

app.include_router(auth.router, prefix="/api")
app.include_router(customer.router, prefix="/api")
app.include_router(store_admin.router, prefix="/api")
app.include_router(rider.router, prefix="/api")
app.include_router(super_admin.router, prefix="/api")
app.include_router(websocket.router)  # WebSocket (no /api prefix)


# ─── Stripe Webhook ──────────────────────────────────────────────────────────

@app.post("/webhooks/stripe", include_in_schema=False)
async def stripe_webhook(request: Request):
    """Handle Stripe payment confirmation webhooks."""
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")
    try:
        import stripe
        from app.core.config import settings as s
        event = stripe.Webhook.construct_event(payload, sig_header, s.STRIPE_WEBHOOK_SECRET)
        if event["type"] == "payment_intent.succeeded":
            payment_intent = event["data"]["object"]
            from app.core.database import AsyncSessionLocal
            from app.services.payment_service import confirm_stripe_payment
            async with AsyncSessionLocal() as db:
                await confirm_stripe_payment(db, payment_intent["id"])
                await db.commit()
        return {"status": "ok"}
    except Exception as e:
        logger.error(f"Stripe webhook error: {e}")
        return JSONResponse(status_code=400, content={"detail": str(e)})


# ─── Health Check ─────────────────────────────────────────────────────────────

@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint for load balancer / monitoring."""
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "env": settings.APP_ENV,
        "version": "1.0.0",
    }


@app.get("/", include_in_schema=False)
async def root():
    return {"message": "FoodApp API is running. Visit /docs for API documentation."}
