"""
tests/conftest.py
------------------
Shared pytest fixtures for the NHIS test suite.

Uses an in-memory SQLite database so tests run without a live PostgreSQL
instance.  Every test gets a fresh, isolated database session.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database.base import Base
from app.database.database import get_db
from app.main import app

# ── In-memory SQLite engine for tests ────────────────────────────────

SQLALCHEMY_TEST_URL = "sqlite:///:memory:"

test_engine = create_engine(
    SQLALCHEMY_TEST_URL,
    connect_args={"check_same_thread": False},
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(autouse=True)
def create_test_tables():
    """Create all tables before each test and drop them after."""
    # Import models so metadata is populated
    import app.modules.user.user_model       # noqa: F401
    import app.modules.patient.patient_model  # noqa: F401
    import app.modules.audit.audit_model      # noqa: F401

    Base.metadata.create_all(bind=test_engine)
    yield
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def db_session():
    """Yield a test database session, rolled back after each test."""
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.rollback()
        session.close()


@pytest.fixture
def client(db_session):
    """
    FastAPI TestClient with the ``get_db`` dependency overridden to use
    the isolated test session.
    """
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


# ── Helper: seed an admin user ────────────────────────────────────────

@pytest.fixture
def admin_user(db_session):
    """Create and return a seeded ADMIN user."""
    from app.core.constants import Roles, UserStatus
    from app.core.security import hash_password
    from app.modules.user.user_model import User

    user = User(
        username="testadmin",
        password_hash=hash_password("Admin@123"),
        role=Roles.ADMIN,
        status=UserStatus.ACTIVE,
        first_login=False,
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def admin_token(client, admin_user):
    """Return a valid JWT token for the admin user."""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "testadmin", "password": "Admin@123"},
    )
    assert response.status_code == 200
    return response.json()["access_token"]


@pytest.fixture
def operator_user(db_session):
    """Create and return a seeded OPERATOR user."""
    from app.core.constants import Roles, UserStatus
    from app.core.security import hash_password
    from app.modules.user.user_model import User

    user = User(
        username="testoperator",
        password_hash=hash_password("Operator@123"),
        role=Roles.OPERATOR,
        status=UserStatus.ACTIVE,
        first_login=False,
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def operator_token(client, operator_user):
    """Return a valid JWT token for the operator user."""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "testoperator", "password": "Operator@123"},
    )
    assert response.status_code == 200
    return response.json()["access_token"]
