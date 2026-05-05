"""
tests/test_user.py
-------------------
Automated tests for authentication and user management endpoints.

Covers:
  - Successful login
  - Login with wrong password
  - Login with unknown user
  - ``/me`` endpoint
  - Admin creating users
  - Duplicate username rejection
  - Role-based access enforcement
  - Password change
"""

import pytest


class TestLogin:

    def test_login_success(self, client, admin_user):
        """Valid credentials return a Bearer token."""
        resp = client.post(
            "/api/v1/auth/login",
            data={"username": "testadmin", "password": "Admin@123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    def test_login_wrong_password(self, client, admin_user):
        """Wrong password returns 401."""
        resp = client.post(
            "/api/v1/auth/login",
            data={"username": "testadmin", "password": "WrongPass"},
        )
        assert resp.status_code == 401

    def test_login_unknown_user(self, client):
        """Non-existent username returns 401."""
        resp = client.post(
            "/api/v1/auth/login",
            data={"username": "nobody", "password": "anything"},
        )
        assert resp.status_code == 401

    def test_login_inactive_user(self, client, db_session):
        """Locked/inactive account returns 401."""
        from app.core.constants import Roles, UserStatus
        from app.core.security import hash_password
        from app.modules.identity.infrastructure.models import User

        locked = User(
            username="lockeduser",
            password_hash=hash_password("Pass@123"),
            role=Roles.OPERATOR,
            status=UserStatus.LOCKED,
            first_login=False,
        )
        db_session.add(locked)
        db_session.commit()

        resp = client.post(
            "/api/v1/auth/login",
            data={"username": "lockeduser", "password": "Pass@123"},
        )
        assert resp.status_code == 401


class TestMe:

    def test_get_me_authenticated(self, client, admin_token):
        """Authenticated user can fetch their own profile."""
        resp = client.get(
            "/api/v1/auth/me",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["username"] == "testadmin"
        assert data["role"] == "ADMIN"

    def test_get_me_no_token(self, client):
        """Missing token returns 401."""
        resp = client.get("/api/v1/auth/me")
        assert resp.status_code == 401

    def test_get_me_invalid_token(self, client):
        """Malformed token returns 401."""
        resp = client.get(
            "/api/v1/auth/me",
            headers={"Authorization": "Bearer not.a.real.token"},
        )
        assert resp.status_code == 401


class TestCreateUser:

    def test_admin_can_create_user(self, client, admin_token):
        """ADMIN can create a new OPERATOR account."""
        resp = client.post(
            "/api/v1/auth/users",
            json={"username": "newoperator", "password": "Pass@123", "role": "OPERATOR"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 201
        data = resp.json()
        assert data["username"] == "newoperator"
        assert data["role"] == "OPERATOR"

    def test_duplicate_username_rejected(self, client, admin_token, admin_user):
        """Creating a user with an existing username returns 409."""
        resp = client.post(
            "/api/v1/auth/users",
            json={"username": "testadmin", "password": "Pass@123", "role": "OPERATOR"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 409

    def test_operator_cannot_create_user(self, client, operator_token):
        """OPERATOR attempting to create a user receives 403."""
        resp = client.post(
            "/api/v1/auth/users",
            json={"username": "another", "password": "Pass@123", "role": "OPERATOR"},
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 403

    def test_invalid_role_rejected(self, client, admin_token):
        """Creating a user with an unrecognised role returns 422."""
        resp = client.post(
            "/api/v1/auth/users",
            json={"username": "baduser", "password": "Pass@123", "role": "SUPERUSER"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 422


class TestChangePassword:

    def test_change_password_success(self, client, admin_token):
        """User can change their own password with the correct current password."""
        resp = client.post(
            "/api/v1/auth/me/change-password",
            json={"current_password": "Admin@123", "new_password": "NewPass@456"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 200

    def test_change_password_wrong_current(self, client, admin_token):
        """Supplying the wrong current password returns 401."""
        resp = client.post(
            "/api/v1/auth/me/change-password",
            json={"current_password": "WrongCurrent", "new_password": "NewPass@456"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 401
