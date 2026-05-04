"""Shared application-layer contracts."""

from app.shared.application.errors import (
    ApplicationError,
    AuthenticationFailed,
    DuplicateResource,
    InvalidOperation,
    ResourceNotFound,
    VerificationFailed,
)

__all__ = [
    "ApplicationError",
    "AuthenticationFailed",
    "DuplicateResource",
    "InvalidOperation",
    "ResourceNotFound",
    "VerificationFailed",
]
