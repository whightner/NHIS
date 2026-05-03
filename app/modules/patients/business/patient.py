"""Patient business object."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone

from app.modules.patients.business.patient_card import PatientCard
from app.modules.patients.business.patient_status import VerificationStatus
from app.shared.business.errors import BusinessRuleViolation, ValidationError
from app.shared.business.person import Person


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


@dataclass
class Patient:
    """A person registered for national health insurance."""

    uhid: str
    person: Person
    security_code: str
    verification_status: VerificationStatus = VerificationStatus.PENDING
    photo_path: str | None = None
    card: PatientCard | None = None
    rejection_reason: str | None = None
    created_at: datetime = field(default_factory=_utcnow)
    updated_at: datetime = field(default_factory=_utcnow)

    def __post_init__(self) -> None:
        if not self.uhid or not self.uhid.strip():
            raise ValidationError("Patient UHID is required.")
        if not self.security_code or not self.security_code.strip():
            raise ValidationError("Patient security code is required.")

    @property
    def is_pending(self) -> bool:
        return self.verification_status == VerificationStatus.PENDING

    @property
    def is_approved(self) -> bool:
        return self.verification_status == VerificationStatus.APPROVED

    @property
    def is_rejected(self) -> bool:
        return self.verification_status == VerificationStatus.REJECTED

    def approve(self) -> None:
        """Approve a pending patient registration."""
        if not self.is_pending:
            raise BusinessRuleViolation(
                f"Cannot approve patient with status {self.verification_status.value}."
            )
        self.verification_status = VerificationStatus.APPROVED
        self.rejection_reason = None
        self._touch()

    def reject(self, reason: str) -> None:
        """Reject a patient registration with a required reason."""
        if self.is_rejected:
            raise BusinessRuleViolation("Patient is already rejected.")
        if not reason or not reason.strip():
            raise ValidationError("Rejection reason is required.")
        self.verification_status = VerificationStatus.REJECTED
        self.rejection_reason = reason
        self._touch()

    def require_approved(self) -> None:
        """Raise when an operation requires an approved patient."""
        if not self.is_approved:
            raise BusinessRuleViolation(
                f"Patient {self.uhid} is not approved."
            )

    def update_photo(self, photo_path: str) -> None:
        """Attach or replace the patient photo path."""
        if not photo_path or not photo_path.strip():
            raise ValidationError("Photo path is required.")
        self.photo_path = photo_path
        self._touch()

    def attach_card(self, card: PatientCard) -> None:
        """Attach the generated card metadata to the patient."""
        if card.uhid != self.uhid:
            raise ValidationError("Card UHID must match patient UHID.")
        self.card = card
        self._touch()

    def verify_security_code(self, code: str) -> None:
        """Raise when the supplied card security code is incorrect."""
        if self.security_code != code:
            raise BusinessRuleViolation("Invalid security code.")

    def _touch(self) -> None:
        self.updated_at = _utcnow()
