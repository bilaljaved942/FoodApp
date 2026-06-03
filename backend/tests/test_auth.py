"""Tests for authentication endpoints."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_register_customer():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/auth/register", json={
            "name": "Test Customer",
            "email": "testcustomer@example.com",
            "password": "password123",
            "role": "customer"
        })
        assert response.status_code == 201
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["user"]["role"] == "customer"


@pytest.mark.asyncio
async def test_register_rider():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/auth/register", json={
            "name": "Test Rider",
            "phone": "+92-300-1234567",
            "password": "password123",
            "role": "rider"
        })
        assert response.status_code == 201


@pytest.mark.asyncio
async def test_login_with_email():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Register first
        await client.post("/api/auth/register", json={
            "name": "Login Test",
            "email": "logintest@example.com",
            "password": "password123",
        })
        # Then login
        response = await client.post("/api/auth/login", json={
            "email": "logintest@example.com",
            "password": "password123",
        })
        assert response.status_code == 200
        assert "access_token" in response.json()


@pytest.mark.asyncio
async def test_login_wrong_password():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/auth/login", json={
            "email": "anyone@example.com",
            "password": "wrongpassword",
        })
        assert response.status_code == 401


@pytest.mark.asyncio
async def test_invalid_role_register():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/auth/register", json={
            "name": "Bad Role",
            "email": "bad@example.com",
            "password": "password123",
            "role": "hacker"
        })
        assert response.status_code == 422


@pytest.mark.asyncio
async def test_health_check():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"
