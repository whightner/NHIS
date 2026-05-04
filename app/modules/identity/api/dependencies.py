"""FastAPI dependencies for identity endpoints."""

from collections.abc import Callable

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.exceptions import TokenInvalidError
from app.database.database import get_db
from app.modules.audit.application import AuditRecorder
from app.modules.audit.infrastructure import SQLAlchemyAuditLogRepository
from app.modules.identity.application import IdentityService
from app.modules.identity.business import Permission, UserAccount
from app.modules.identity.infrastructure import (
    BcryptPasswordHasher,
    JwtTokenIssuer,
    SQLAlchemyUserAccountRepository,
)
from app.shared.business import PermissionDenied

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_identity_service(db: Session = Depends(get_db)) -> IdentityService:
    """Build the identity application service for one request."""
    audit_repository = SQLAlchemyAuditLogRepository(db)
    return IdentityService(
        users=SQLAlchemyUserAccountRepository(db),
        passwords=BcryptPasswordHasher(),
        tokens=JwtTokenIssuer(),
        audit=AuditRecorder(audit_repository),
    )


def get_current_account(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> UserAccount:
    """Validate a bearer token and return the current account."""
    token_issuer = JwtTokenIssuer()
    try:
        payload = token_issuer.decode_access_token(token)
    except TokenInvalidError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=exc.message,
        ) from exc

    username = payload.get("sub")
    if not username:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload.",
        )

    account = SQLAlchemyUserAccountRepository(db).get_by_username(username)
    if account is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found.",
        )
    return account


def require_permission(permission: Permission) -> Callable[[UserAccount], UserAccount]:
    """Return a dependency that enforces a business permission."""

    def checker(account: UserAccount = Depends(get_current_account)) -> UserAccount:
        try:
            account.require(permission)
        except PermissionDenied as exc:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(exc),
            ) from exc
        return account

    return checker
