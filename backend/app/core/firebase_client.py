import firebase_admin
from firebase_admin import credentials, db, messaging, storage
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

_firebase_app: firebase_admin.App | None = None


def init_firebase() -> firebase_admin.App | None:
    """Initialize Firebase Admin SDK. Safe to call multiple times."""
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app

    try:
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
        _firebase_app = firebase_admin.initialize_app(cred, {
            "databaseURL": settings.FIREBASE_REALTIME_DB_URL,
            "storageBucket": f"{settings.FIREBASE_REALTIME_DB_URL.split('//')[1].split('-')[0]}.appspot.com",
        })
        logger.info("✅ Firebase Admin SDK initialized")
        return _firebase_app
    except Exception as e:
        logger.warning(f"⚠️  Firebase not initialized (missing credentials): {e}")
        return None


def get_firebase_db():
    """Get Firebase Realtime Database reference."""
    return db


# ─── Realtime DB Helpers ─────────────────────────────────────────────────────

def update_order_status_realtime(order_id: str, status: str, extra: dict = None):
    """Push order status update to Firebase Realtime DB."""
    try:
        ref = db.reference(f"orders/{order_id}")
        payload = {"status": status}
        if extra:
            payload.update(extra)
        ref.update(payload)
    except Exception as e:
        logger.error(f"Firebase order update error: {e}")


def update_rider_location_realtime(rider_id: str, lat: float, lng: float):
    """Write rider GPS coordinates to Firebase Realtime DB."""
    try:
        ref = db.reference(f"rider_locations/{rider_id}")
        ref.set({"lat": lat, "lng": lng, "timestamp": {".sv": "timestamp"}})
    except Exception as e:
        logger.error(f"Firebase rider location update error: {e}")


def clear_rider_location_realtime(rider_id: str):
    """Remove rider location from Firebase after delivery."""
    try:
        ref = db.reference(f"rider_locations/{rider_id}")
        ref.delete()
    except Exception as e:
        logger.error(f"Firebase rider location clear error: {e}")


# ─── FCM Push Notifications ───────────────────────────────────────────────────

def send_fcm_notification(token: str, title: str, body: str, data: dict = None) -> bool:
    """Send FCM push notification to a single device token."""
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={str(k): str(v) for k, v in (data or {}).items()},
            token=token,
        )
        messaging.send(message)
        return True
    except Exception as e:
        logger.error(f"FCM send error: {e}")
        return False


def send_fcm_multicast(tokens: list[str], title: str, body: str, data: dict = None) -> bool:
    """Send FCM notification to multiple device tokens."""
    if not tokens:
        return False
    try:
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={str(k): str(v) for k, v in (data or {}).items()},
            tokens=tokens,
        )
        messaging.send_each_for_multicast(message)
        return True
    except Exception as e:
        logger.error(f"FCM multicast error: {e}")
        return False
