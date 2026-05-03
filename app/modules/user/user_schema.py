"""
app/modules/user/user_schema.py
--------------------------------
Pydantic request/response models for the user module.
"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_validator

from app.core.constants import Roles


class UserCreate(BaseModel):
    """
    Payload for creating a new user account.

    :param username: Unique login name (3–50 chars).
    :param password: Plain-text password (hashed before storage).
    :param role:     One of the valid NHIS roles.
    """

    username: str
    password: str
    role: str = Roles.OPERATOR

    @field_validator("role")
    @classmethod
    def role_must_be_valid(cls, v: str) -> str:
        """
        :raises ValueError: If the supplied role is not in :attr:`Roles.ALL`.
        """
        if v not in Roles.ALL:
            raise ValueError(f"Role must be one of {Roles.ALL}")
        return v

    @field_validator("username")
    @classmethod
    def username_length(cls, v: str) -> str:
        """
        :raises ValueError: If the username is shorter than 3 characters.
        """
        if len(v) < 3:
            raise ValueError("Username must be at least 3 characters.")
        return v


class UserResponse(BaseModel):
    """
    Public-facing user representation (no password fields).

    :param user_id:     Internal numeric identifier.
    :param username:    Login name.
    :param role:        Assigned role.
    :param status:      Account state.
    :param first_login: Whether the user has yet to change their password.
    :param created_at:  Account creation timestamp.
    """

    user_id: int
    username: str
    role: str
    status: str
    first_login: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class LoginRequest(BaseModel):
    """
    Credentials submitted to the login endpoint.

    :param username: Account username.
    :param password: Plain-text password.
    """

    username: str
    password: str


class TokenResponse(BaseModel):
    """
    JWT token returned after a successful login.

    :param access_token: Signed JWT string.
    :param token_type:   Always ``"bearer"``.
    """

    access_token: str
    token_type: str = "bearer"


class ChangePasswordRequest(BaseModel):
    """
    Payload to change the current user's password.

    :param current_password: The existing password for verification.
    :param new_password:     The replacement password.
    """

    current_password: str
    new_password: str


class UserStatusUpdate(BaseModel):
    """
    Payload for an admin updating a user's account status.

    :param status: New status value (ACTIVE / INACTIVE / LOCKED).
    """

    status: str
