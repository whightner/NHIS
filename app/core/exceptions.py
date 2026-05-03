"""
app/core/exceptions.py
----------------------
Custom exception hierarchy for the NHIS application.

Service-layer code raises these typed exceptions.  The route layer
catches them and converts them into the appropriate HTTP response.
This keeps ``HTTPException`` out of business logic entirely.
"""


class NHISBaseException(Exception):
    """
    Root exception for all NHIS domain errors.

    :param message: Human-readable description of the problem.
    """

    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)


# ── Authentication / Authorization ───────────────────────────────────

class AuthenticationError(NHISBaseException):
    """Raised when credentials cannot be verified (401)."""


class AuthorizationError(NHISBaseException):
    """Raised when the caller lacks permission for an action (403)."""


class TokenInvalidError(NHISBaseException):
    """Raised when a JWT token is missing, malformed, or expired (401)."""


# ── Resource errors ───────────────────────────────────────────────────

class PatientNotFoundError(NHISBaseException):
    """Raised when a patient record cannot be located (404)."""


class UserNotFoundError(NHISBaseException):
    """Raised when a user record cannot be located (404)."""


class DuplicateResourceError(NHISBaseException):
    """Raised when a resource with the same unique key already exists (409)."""


# ── Business-logic errors ─────────────────────────────────────────────

class InvalidVerificationStatusError(NHISBaseException):
    """
    Raised when a status transition is not permitted, e.g. trying to
    approve a patient who is already approved (422).
    """


class SecurityCodeMismatchError(NHISBaseException):
    """Raised when the supplied security code does not match the record (403)."""


class PatientNotApprovedError(NHISBaseException):
    """Raised when an action requires APPROVED status but the patient is not (403)."""


class CardNotFoundError(NHISBaseException):
    """Raised when a patient card file does not exist on disk (404)."""


class InvalidPhotoError(NHISBaseException):
    """Raised when an uploaded photo fails validation (422)."""
