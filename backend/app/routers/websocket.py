"""WebSocket Router — Real-time order status & rider location."""
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from typing import Dict, Set
import json
import logging

logger = logging.getLogger(__name__)

router = APIRouter(tags=["WebSocket"])


class ConnectionManager:
    """Manages WebSocket connections grouped by channel."""

    def __init__(self):
        # order_id → set of connected WebSocket clients
        self.order_connections: Dict[str, Set[WebSocket]] = {}
        # rider_id → set of connected WebSocket clients (for tracking)
        self.rider_connections: Dict[str, Set[WebSocket]] = {}

    async def connect_order(self, order_id: str, websocket: WebSocket):
        await websocket.accept()
        self.order_connections.setdefault(order_id, set()).add(websocket)
        logger.info(f"WS connected to order/{order_id}")

    async def connect_rider(self, rider_id: str, websocket: WebSocket):
        await websocket.accept()
        self.rider_connections.setdefault(rider_id, set()).add(websocket)

    def disconnect_order(self, order_id: str, websocket: WebSocket):
        if order_id in self.order_connections:
            self.order_connections[order_id].discard(websocket)
            if not self.order_connections[order_id]:
                del self.order_connections[order_id]

    def disconnect_rider(self, rider_id: str, websocket: WebSocket):
        if rider_id in self.rider_connections:
            self.rider_connections[rider_id].discard(websocket)
            if not self.rider_connections[rider_id]:
                del self.rider_connections[rider_id]

    async def broadcast_order_update(self, order_id: str, data: dict):
        """Broadcast order status change to all subscribers."""
        dead = set()
        for ws in self.order_connections.get(order_id, set()):
            try:
                await ws.send_json(data)
            except Exception:
                dead.add(ws)
        for ws in dead:
            self.disconnect_order(order_id, ws)

    async def broadcast_rider_location(self, rider_id: str, data: dict):
        """Broadcast rider GPS update to all tracking subscribers."""
        dead = set()
        for ws in self.rider_connections.get(rider_id, set()):
            try:
                await ws.send_json(data)
            except Exception:
                dead.add(ws)
        for ws in dead:
            self.disconnect_rider(rider_id, ws)


# Global connection manager (singleton)
manager = ConnectionManager()


@router.websocket("/ws/orders/{order_id}")
async def order_status_ws(websocket: WebSocket, order_id: str):
    """
    WebSocket endpoint for real-time order status updates.
    Clients (Customer app, Store Admin app) connect here to receive
    live status changes for a specific order.
    """
    await manager.connect_order(order_id, websocket)
    try:
        await websocket.send_json({"type": "connected", "order_id": order_id})
        while True:
            # Keep connection alive; server pushes updates via manager.broadcast_order_update()
            data = await websocket.receive_text()
            # Ping/pong heartbeat support
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect_order(order_id, websocket)
        logger.info(f"WS disconnected from order/{order_id}")


@router.websocket("/ws/rider/{rider_id}")
async def rider_location_ws(websocket: WebSocket, rider_id: str):
    """
    WebSocket endpoint for real-time rider location tracking.
    Customer app connects to track their assigned rider's GPS position.
    Rider app can also connect to confirm location is being received.
    """
    await manager.connect_rider(rider_id, websocket)
    try:
        await websocket.send_json({"type": "connected", "rider_id": rider_id})
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect_rider(rider_id, websocket)
