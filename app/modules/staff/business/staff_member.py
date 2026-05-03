"""Staff member business object."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum

from app.shared.business.errors import ValidationError
from app.shared.business.person import Person


class StaffPosition(str, Enum):
    """Administrative or clinical position held by a staff member."""

    ADMINISTRATOR = "ADMINISTRATOR"
    OPERATOR = "OPERATOR"
    VERIFIER = "VERIFIER"
    AUDITOR = "AUDITOR"
    NURSE = "NURSE"


@dataclass
class StaffMember:
    """A person working inside the NHIS system."""

    id: str
    person: Person
    user_account_id: str
    position: StaffPosition
    department: str | None = None
    active: bool = True

    def __post_init__(self) -> None:
        if not self.id or not self.id.strip():
            raise ValidationError("Staff member id is required.")
        if not self.user_account_id or not self.user_account_id.strip():
            raise ValidationError("Staff member account id is required.")

    @property
    def is_clinical(self) -> bool:
        """Return True for positions that can participate in care operations."""
        return self.position == StaffPosition.NURSE

    def assign_department(self, department: str) -> None:
        """Assign the staff member to a department."""
        if not department or not department.strip():
            raise ValidationError("Department is required.")
        self.department = department

    def activate(self) -> None:
        """Mark the staff member as active."""
        self.active = True

    def deactivate(self) -> None:
        """Mark the staff member as inactive."""
        self.active = False
