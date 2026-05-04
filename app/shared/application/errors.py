"""Framework-agnostic application errors.

Business objects raise business errors. Use cases raise these application
errors when an operation cannot be completed because of persistence,
authentication, or workflow context.
"""


class ApplicationError(Exception):
    """Base class for use-case errors."""

    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)


class AuthenticationFailed(ApplicationError):
    """Raised when credentials or tokens cannot authenticate an account."""


class DuplicateResource(ApplicationError):
    """Raised when a unique business key is already used."""


class ResourceNotFound(ApplicationError):
    """Raised when a requested resource does not exist."""


class InvalidOperation(ApplicationError):
    """Raised when a use case cannot complete in the current state."""


class VerificationFailed(ApplicationError):
    """Raised when an identity or card verification check fails."""
