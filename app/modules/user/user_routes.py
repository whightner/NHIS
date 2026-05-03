"""
app/modules/user/user_routes.py
---------------------------------
HTTP route handlers for authentication and user management.

This layer:
  - Accepts HTTP requests and extracts input
  - Calls the service layer
  - Translates domain exceptions into HTTP responses
  - Returns structured responses

No business logic or database queries live here.
"""

import logging
from typing import List

from fastapi import APIRouter, Depends, Form, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.exceptions import (
    AuthenticationError,
    AuthorizationError,
    DuplicateResourceError,
    TokenInvalidError,
    UserNotFoundError,
)
from app.core.security import decode_access_token
from app.database.database import get_db
from app.modules.user.user_model import User
from app.modules.user.user_schema import (
    ChangePasswordRequest,
    TokenResponse,
    UserCreate,
    UserResponse,
    UserStatusUpdate,
)
from app.modules.user.user_service import user_service

logger = logging.getLogger(__name__)

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


# ── Auth dependency ───────────────────────────────────────────────────

def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    """
    FastAPI dependency that validates the Bearer token and returns the
    authenticated :class:`User`.

    :param token: JWT Bearer token from the Authorization header.
    :param db:    Active database session.
    :return: Authenticated :class:`User` instance.
    :raises HTTPException 401: If the token is invalid or the user is gone.
    """
    try:
        payload = decode_access_token(token)
    except TokenInvalidError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=exc.message)

    username: str = payload.get("sub")
    if not username:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload.")

    from app.modules.user.user_repository import user_repository
    user = user_repository.get_by_username(db, username)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found.")
    return user


def require_role(allowed_roles: list):
    """
    FastAPI dependency factory that enforces role-based access.

    :param allowed_roles: List of role strings permitted to access the endpoint.
    :return: A dependency callable that returns the current user if authorised.
    :raises HTTPException 403: If the current user's role is not in ``allowed_roles``.
    """
    def checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied: insufficient permissions.",
            )
        return current_user
    return checker


# ── Login ─────────────────────────────────────────────────────────────

@router.post("/login", response_model=TokenResponse, summary="Authenticate and receive a JWT")
def login(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db),
):
    """
    Authenticate with username + password and receive a Bearer token.

    :param request:  FastAPI request (used to extract client IP).
    :param username: Account username.
    :param password: Plain-text password.
    :param db:       Active database session.
    :return: ``TokenResponse`` containing the signed JWT.
    :raises HTTPException 401: If credentials are invalid or account is inactive.
    """
    ip = request.client.host if request.client else "unknown"
    try:
        return user_service.login(db, username, password, ip_address=ip)
    except AuthenticationError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=exc.message)


# ── Current user ──────────────────────────────────────────────────────

@router.get("/me", response_model=UserResponse, summary="Get current user profile")
def get_me(current_user: User = Depends(get_current_user)):
    """
    Return the profile of the currently authenticated user.

    :param current_user: Injected by :func:`get_current_user`.
    :return: :class:`UserResponse` for the authenticated user.
    """
    return current_user


# ── Change password ───────────────────────────────────────────────────

@router.post("/me/change-password", summary="Change own password")
def change_password(
    payload: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Allow an authenticated user to update their own password.

    :param payload:      Current and new password.
    :param db:           Active database session.
    :param current_user: Authenticated user performing the change.
    :return: Success message.
    :raises HTTPException 401: If the current password is wrong.
    """
    try:
        user_service.change_password(db, current_user, payload.current_password, payload.new_password)
    except AuthenticationError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=exc.message)
    return {"message": "Password changed successfully."}


# ── Admin: manage users ───────────────────────────────────────────────

@router.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED, summary="Create user (ADMIN)")
def create_user(
    payload: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role(["ADMIN"])),
):
    """
    Create a new system user account (ADMIN only).

    :param payload:      New user details.
    :param db:           Active database session.
    :param current_user: Must be ADMIN.
    :return: The created :class:`UserResponse`.
    :raises HTTPException 409: If the username is already taken.
    """
    try:
        return user_service.create_user(db, payload.username, payload.password, payload.role, actor=current_user)
    except DuplicateResourceError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=exc.message)
    except AuthorizationError as exc:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=exc.message)


@router.get("/users", response_model=List[UserResponse], summary="List all users (ADMIN)")
def list_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role(["ADMIN"])),
):
    """
    Return all user accounts (ADMIN only).

    :param db:           Active database session.
    :param current_user: Must be ADMIN.
    :return: List of :class:`UserResponse` objects.
    """
    return user_service.get_all_users(db, actor=current_user)


@router.patch("/users/{username}/status", response_model=UserResponse, summary="Update user status (ADMIN)")
def update_user_status(
    username: str,
    payload: UserStatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role(["ADMIN"])),
):
    """
    Activate, deactivate, or lock a user account (ADMIN only).

    :param username:     Target user's login name.
    :param payload:      New status value.
    :param db:           Active database session.
    :param current_user: Must be ADMIN.
    :return: Updated :class:`UserResponse`.
    :raises HTTPException 404: If the target user is not found.
    """
    try:
        return user_service.update_status(db, username, payload.status, actor=current_user)
    except UserNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)
    except AuthorizationError as exc:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=exc.message)
