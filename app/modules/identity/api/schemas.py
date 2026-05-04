"""Pydantic schemas for identity endpoints."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, field_validator

from app.modules.identity.business import AccountStatus, UserAccount
from app.shared.business import Role


class UserCreate(BaseModel):
    """Payload for creating a new user account."""

    username: str
    password: str
    role: Role = Role.OPERATOR

    @field_validator("username")
    @classmethod
    def username_length(cls, value: str) -> str:
        """Validate username length before reaching the use case."""
        if len(value.strip()) < 3:
            raise ValueError("Username must be at least 3 characters.")
        return value

    @field_validator("password")
    @classmethod
    def password_length(cls, value: str) -> str:
        """Validate password length before hashing."""
        if len(value) < 8:
            raise ValueError("Password must be at least 8 characters.")
        return value


class UserResponse(BaseModel):
    """Public account representation."""

    user_id: int
    username: str
    role: str
    status: str
    first_login: bool
    created_at: datetime | None = None

    @classmethod
    def from_account(cls, account: UserAccount) -> "UserResponse":
        """Build an API response from a UserAccount."""
        return cls(
            user_id=int(account.id) if account.id.isdigit() else 0,
            username=account.username,
            role=account.primary_role.value,
            status=account.status.value,
            first_login=account.first_login,
            created_at=account.created_at,
        )


class TokenResponse(BaseModel):
    """Bearer token response."""

    access_token: str
    token_type: str = "bearer"


class ChangePasswordRequest(BaseModel):
    """Payload used to change the current password."""

    current_password: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_length(cls, value: str) -> str:
        """Validate password length before hashing."""
        if len(value) < 8:
            raise ValueError("Password must be at least 8 characters.")
        return value


class UserStatusUpdate(BaseModel):
    """Payload used to update account status."""

    status: AccountStatus
