import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.db.base import Base, get_db
from app.core.config import settings

# Create test database
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


class TestAuth:
    """Test authentication endpoints."""
    
    def test_register_user(self):
        """Test user registration."""
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "test@example.com",
                "password": "TestPassword123"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "test@example.com"
        assert "id" in data
    
    def test_register_duplicate_user(self):
        """Test registering duplicate user."""
        # First registration
        client.post(
            "/api/v1/auth/register",
            json={
                "email": "duplicate@example.com",
                "password": "TestPassword123"
            }
        )
        
        # Duplicate registration
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "duplicate@example.com",
                "password": "TestPassword123"
            }
        )
        assert response.status_code == 400
        assert "already registered" in response.json()["message"]
    
    def test_login_user(self):
        """Test user login."""
        # Register user first
        client.post(
            "/api/v1/auth/register",
            json={
                "email": "login@example.com",
                "password": "TestPassword123"
            }
        )
        
        # Login
        response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "login@example.com",
                "password": "TestPassword123"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
    
    def test_login_invalid_credentials(self):
        """Test login with invalid credentials."""
        response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "nonexistent@example.com",
                "password": "WrongPassword"
            }
        )
        assert response.status_code == 401
        assert "Incorrect email or password" in response.json()["detail"]
    
    def test_refresh_token(self):
        """Test token refresh."""
        # Register and login
        client.post(
            "/api/v1/auth/register",
            json={
                "email": "refresh@example.com",
                "password": "TestPassword123"
            }
        )
        
        login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "refresh@example.com",
                "password": "TestPassword123"
            }
        )
        refresh_token = login_response.json()["refresh_token"]
        
        # Refresh token
        response = client.post(
            "/api/v1/auth/refresh-token",
            json={"refresh_token": refresh_token}
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data