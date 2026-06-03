# FoodApp — Food Delivery Platform

> A complete, production-ready food delivery platform (Foodpanda/DoorDash-like) built for 500 concurrent users.

## 📱 Apps

| App | Stack | Description |
|-----|-------|-------------|
| `mobile/customer_app` | Flutter (Dart) | Customer browsing, ordering, tracking |
| `mobile/rider_app` | Flutter (Dart) | Rider delivery management + GPS |
| `mobile/store_admin_app` | Flutter (Dart) | Restaurant menu & order management |
| `admin-panel` | React.js | Super Admin web dashboard |
| `backend` | Python + FastAPI | REST API + WebSocket backend |

## 🏗️ Tech Stack

- **Backend**: Python 3.12, FastAPI, SQLAlchemy (async), Alembic
- **Database**: PostgreSQL (DigitalOcean Managed)
- **Cache**: Redis (DigitalOcean Managed)
- **Real-time**: Firebase Realtime DB + FastAPI WebSocket
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Storage**: DigitalOcean Spaces (S3-compatible)
- **Payments**: Stripe
- **Maps**: Google Maps Flutter Plugin + Directions API
- **Hosting**: DigitalOcean Droplet (4 vCPU / 8GB RAM)
- **CDN/Security**: Cloudflare Free Plan

## 🚀 Quick Start (Local Development)

### Prerequisites
- Docker & Docker Compose
- Flutter SDK ≥ 3.19
- Node.js ≥ 18 (for admin panel)
- Python 3.12+

### Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your credentials

# Start with Docker Compose
docker compose up -d

# Check API docs
open http://localhost:8000/docs
```

### Run migrations manually (if needed)
```bash
cd backend
docker compose exec api alembic upgrade head
```

### Flutter Apps

```bash
cd mobile/customer_app
flutter pub get
flutter run
```

### React Admin Panel

```bash
cd admin-panel
npm install
npm run dev
```

## 📁 Project Structure

```
FoodApp/
├── backend/          # Python FastAPI Backend
├── mobile/
│   ├── customer_app/ # Flutter Customer App
│   ├── rider_app/    # Flutter Rider App
│   └── store_admin_app/ # Flutter Store Admin App
├── admin-panel/      # React.js Super Admin Dashboard
└── docs/             # API docs, schema docs, deployment guide
```

## 🔑 Environment Variables

See `backend/.env.example` for all required environment variables.

Key variables:
- `SECRET_KEY` — JWT signing secret (change in production!)
- `DATABASE_URL` — PostgreSQL async URL
- `REDIS_URL` — Redis connection URL
- `STRIPE_SECRET_KEY` — Stripe API key
- `FIREBASE_CREDENTIALS_PATH` — Path to Firebase service account JSON
- `DO_SPACES_KEY/SECRET` — DigitalOcean Spaces credentials
- `GOOGLE_MAPS_API_KEY` — Google Maps Platform API key

## 📡 API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🔐 User Roles

| Role | Description |
|------|-------------|
| `customer` | Browse stores, place orders, track delivery |
| `rider` | Accept/deliver orders, GPS tracking |
| `store_admin` | Manage store, products, incoming orders |
| `super_admin` | Full platform control, analytics, refunds |

## 📊 Scalability

This setup handles **500 concurrent users** on a single DigitalOcean Droplet:
- FastAPI async with 4 Uvicorn workers via Gunicorn
- Redis for session caching and rate limiting
- Firebase for real-time updates (scalable externally)
- PostgreSQL connection pooling (asyncpg)
- Cloudflare CDN for static assets

## 🔄 CI/CD

GitHub Actions pipeline: `.github/workflows/deploy.yml`
- Push to `main` → tests → Docker build → deploy to DigitalOcean

## 📅 Development Timeline

- **Phase 1** (Weeks 1-2): Foundation, Auth, Store/Product APIs ← *Current*
- **Phase 2** (Weeks 3-5): Core ordering flow, payments, real-time
- **Phase 3** (Weeks 6-8): Rider system, GPS tracking, maps
- **Phase 4** (Weeks 9-10): Super Admin panel, analytics
- **Phase 5** (Weeks 11-12): Testing, polish, production deployment

---

*Document Version: 1.0 | Confidential Development Team Use*
