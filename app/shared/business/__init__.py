"""Shared business objects and rules."""

from app.shared.business.errors import (
    BusinessRuleViolation,
    DomainError,
    PermissionDenied,
    ValidationError,
)
from app.shared.business.person import Gender, Person
from app.shared.business.roles import Role

__all__ = [
    "BusinessRuleViolation",
    "DomainError",
    "Gender",
    "PermissionDenied",
    "Person",
    "Role",
    "ValidationError",
]
