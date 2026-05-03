"""Patient verification status."""

from enum import Enum


class VerificationStatus(str, Enum):
    """Lifecycle states for a patient registration."""

    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
