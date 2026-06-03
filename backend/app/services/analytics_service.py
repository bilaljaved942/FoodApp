"""Analytics Service — platform-wide metrics and reporting."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, cast, Date, text
from datetime import date, timedelta
import logging

from app.models.order import Order
from app.models.store import Store
from app.models.user import User
from app.models.rider import RiderEarning

logger = logging.getLogger(__name__)


async def get_platform_analytics(db: AsyncSession, period: str = "monthly") -> dict:
    """
    Returns:
    - Revenue chart data (daily/weekly/monthly)
    - Top performing stores
    - Most ordered products
    - Rider performance
    - Customer metrics
    """
    # Revenue over time
    if period == "daily":
        days = 30
        group_by = cast(Order.created_at, Date)
    elif period == "weekly":
        days = 84  # 12 weeks
        group_by = cast(Order.created_at, Date)
    else:
        days = 365
        group_by = cast(Order.created_at, Date)

    from_date = date.today() - timedelta(days=days)

    revenue_result = await db.execute(
        select(
            group_by.label("date"),
            func.sum(Order.total).label("revenue"),
            func.count(Order.id).label("orders"),
        )
        .where(Order.created_at >= from_date, Order.payment_status == "paid")
        .group_by(group_by)
        .order_by(group_by)
    )
    revenue_data = [
        {"date": str(row.date), "revenue": float(row.revenue or 0), "orders": row.orders}
        for row in revenue_result
    ]

    # Top stores by revenue
    top_stores_result = await db.execute(
        select(
            Store.name,
            Store.id,
            func.count(Order.id).label("order_count"),
            func.sum(Order.total).label("revenue"),
        )
        .join(Order, Order.store_id == Store.id)
        .where(Order.payment_status == "paid")
        .group_by(Store.id, Store.name)
        .order_by(desc("revenue"))
        .limit(10)
    )
    top_stores = [
        {"store_id": str(row.id), "name": row.name, "orders": row.order_count, "revenue": float(row.revenue or 0)}
        for row in top_stores_result
    ]

    # Order status breakdown
    status_result = await db.execute(
        select(Order.status, func.count(Order.id).label("count"))
        .group_by(Order.status)
    )
    status_breakdown = {row.status: row.count for row in status_result}

    # New users per role (last 30 days)
    new_customers = (await db.execute(
        select(func.count(User.id)).where(
            User.role == "customer",
            cast(User.created_at, Date) >= date.today() - timedelta(days=30)
        )
    )).scalar() or 0

    new_riders = (await db.execute(
        select(func.count(User.id)).where(
            User.role == "rider",
            cast(User.created_at, Date) >= date.today() - timedelta(days=30)
        )
    )).scalar() or 0

    return {
        "period": period,
        "revenue_chart": revenue_data,
        "top_stores": top_stores,
        "order_status_breakdown": status_breakdown,
        "new_users_last_30_days": {
            "customers": new_customers,
            "riders": new_riders,
        },
    }
