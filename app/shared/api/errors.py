"""HTTP translation for framework-neutral errors."""

from fastapi import HTTPException, status

from app.shared.application import (
    ApplicationError,
    AuthenticationFailed,
    DuplicateResource,
    InvalidOperation,
    ResourceNotFound,
    VerificationFailed,
)
from app.shared.business import BusinessRuleViolation, PermissionDenied, ValidationError


def to_http_exception(error: Exception) -> HTTPException:
    """Translate application and business errors to HTTP responses."""
    if isinstance(error, AuthenticationFailed):
        return HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=error.message,
        )
    if isinstance(error, PermissionDenied):
        return HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(error),
        )
    if isinstance(error, VerificationFailed):
        return HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=error.message,
        )
    if isinstance(error, ResourceNotFound):
        return HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error.message,
        )
    if isinstance(error, DuplicateResource):
        return HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=error.message,
        )
    if isinstance(error, (InvalidOperation, BusinessRuleViolation, ValidationError)):
        detail = error.message if isinstance(error, ApplicationError) else str(error)
        return HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail,
        )
    return HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Internal server error.",
    )
