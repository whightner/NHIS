"""Common business exceptions.

These exceptions are framework-agnostic. API layers can translate them to
HTTP responses, CLI commands can translate them to exit codes, and tests can
assert them directly.
"""


class DomainError(Exception):
    """Base class for business-layer errors."""


class ValidationError(DomainError):
    """Raised when a business object receives invalid data."""


class BusinessRuleViolation(DomainError):
    """Raised when an operation breaks a business rule."""


class PermissionDenied(DomainError):
    """Raised when an actor is not allowed to perform an action."""
