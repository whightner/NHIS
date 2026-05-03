"""Person business object shared by patients and staff members."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from enum import Enum

from app.shared.business.errors import ValidationError


class Gender(str, Enum):
    """Supported gender values for a person."""

    MALE = "MALE"
    FEMALE = "FEMALE"
    OTHER = "OTHER"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True)
class Person:
    """Identity details for a real person.

    This class is not a database model and does not represent a login account.
    It captures reusable personal information that can belong to a patient,
    a nurse, an operator, or any other staff member.
    """

    first_name: str
    last_name: str
    date_of_birth: date
    gender: Gender
    nationality: str
    national_id: str | None = None
    phone_number: str | None = None

    def __post_init__(self) -> None:
        self._require_text("first_name", self.first_name)
        self._require_text("last_name", self.last_name)
        self._require_text("nationality", self.nationality)

        if self.date_of_birth > date.today():
            raise ValidationError("Date of birth cannot be in the future.")

    @property
    def full_name(self) -> str:
        """Return the display name used in cards and search results."""
        return f"{self.first_name} {self.last_name}"

    @staticmethod
    def _require_text(field_name: str, value: str) -> None:
        if not value or not value.strip():
            raise ValidationError(f"{field_name} is required.")
