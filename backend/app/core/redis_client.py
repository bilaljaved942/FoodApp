import redis.asyncio as aioredis
from app.core.config import settings

_redis_client: aioredis.Redis | None = None


async def get_redis() -> aioredis.Redis:
    global _redis_client
    if _redis_client is None:
        _redis_client = await aioredis.from_url(
            settings.REDIS_URL,
            encoding="utf-8",
            decode_responses=True,
        )
    return _redis_client


async def close_redis():
    global _redis_client
    if _redis_client:
        await _redis_client.aclose()
        _redis_client = None


# ─── Token Blacklist (for logout) ────────────────────────────────────────────

async def blacklist_token(token: str, ttl_seconds: int = 900):
    """Blacklist a JWT token (stores in Redis with TTL matching token expiry)."""
    redis = await get_redis()
    await redis.setex(f"blacklist:{token}", ttl_seconds, "1")


async def is_token_blacklisted(token: str) -> bool:
    redis = await get_redis()
    result = await redis.get(f"blacklist:{token}")
    return result is not None


# ─── OTP Store ───────────────────────────────────────────────────────────────

async def store_otp(identifier: str, otp: str, ttl_seconds: int = 300):
    """Store OTP for phone/email with 5-minute expiry."""
    redis = await get_redis()
    await redis.setex(f"otp:{identifier}", ttl_seconds, otp)


async def verify_otp(identifier: str, otp: str) -> bool:
    redis = await get_redis()
    stored = await redis.get(f"otp:{identifier}")
    if stored and stored == otp:
        await redis.delete(f"otp:{identifier}")
        return True
    return False


# ─── Session / Cache helpers ─────────────────────────────────────────────────

async def cache_set(key: str, value: str, ttl_seconds: int = 300):
    redis = await get_redis()
    await redis.setex(key, ttl_seconds, value)


async def cache_get(key: str) -> str | None:
    redis = await get_redis()
    return await redis.get(key)


async def cache_delete(key: str):
    redis = await get_redis()
    await redis.delete(key)
