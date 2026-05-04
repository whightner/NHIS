"""HTTP routes for authentication and user account management."""

from __future__ import annotations

from fastapi import APIRouter, Depends, Form, HTTPException, Request, status

from app.modules.identity.api.dependencies import (
    get_current_account,
    get_identity_service,
    require_permission,
)
from app.modules.identity.api.schemas import (
    ChangePasswordRequest,
    TokenResponse,
    UserCreate,
    UserResponse,
    UserStatusUpdate,
)
from app.modules.identity.application import (
    ChangePasswordCommand,
    CreateUserCommand,
    IdentityService,
    LoginCommand,
    UpdateUserStatusCommand,
)
from app.modules.identity.business import Permission, UserAccount
from app.shared.api import to_http_exception

router = APIRouter()


@router.post("/login", response_model=TokenResponse, summary="Authenticate and receive a JWT")
def login(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    service: IdentityService = Depends(get_identity_service),
):
    """Authenticate with username and password."""
    ip_address = request.client.host if request.client else "unknown"
    try:
        result = service.login(
            LoginCommand(
                username=username,
                password=password,
                ip_address=ip_address,
            )
        )
        return TokenResponse(
            access_token=result.access_token,
            token_type=result.token_type,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc


@router.get("/me", response_model=UserResponse, summary="Get current user profile")
def get_me(current_account: UserAccount = Depends(get_current_account)):
    """Return the authenticated account profile."""
    return UserResponse.from_account(current_account)


@router.post("/me/change-password", summary="Change own password")
def change_password(
    payload: ChangePasswordRequest,
    current_account: UserAccount = Depends(get_current_account),
    service: IdentityService = Depends(get_identity_service),
):
    """Allow an authenticated account to change its own password."""
    try:
        service.change_password(
            ChangePasswordCommand(
                current_password=payload.current_password,
                new_password=payload.new_password,
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return {"message": "Password changed successfully."}


@router.post(
    "/users",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create user",
)
def create_user(
    payload: UserCreate,
    current_account: UserAccount = Depends(require_permission(Permission.CREATE_USER)),
    service: IdentityService = Depends(get_identity_service),
):
    """Create a user account."""
    try:
        account = service.create_user(
            CreateUserCommand(
                username=payload.username,
                password=payload.password,
                role=payload.role,
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return UserResponse.from_account(account)


@router.get("/users", response_model=list[UserResponse], summary="List all users")
def list_users(
    current_account: UserAccount = Depends(require_permission(Permission.LIST_USERS)),
    service: IdentityService = Depends(get_identity_service),
):
    """Return all accounts."""
    try:
        accounts = service.list_users(actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return [UserResponse.from_account(account) for account in accounts]


@router.patch(
    "/users/{username}/status",
    response_model=UserResponse,
    summary="Update user status",
)
def update_user_status(
    username: str,
    payload: UserStatusUpdate,
    current_account: UserAccount = Depends(
        require_permission(Permission.UPDATE_USER_STATUS)
    ),
    service: IdentityService = Depends(get_identity_service),
):
    """Activate, deactivate, or lock a user account."""
    try:
        account = service.update_status(
            UpdateUserStatusCommand(
                username=username,
                status=payload.status,
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return UserResponse.from_account(account)
