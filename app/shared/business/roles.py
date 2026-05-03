"""Role names used by business policies."""

from enum import Enum


class Role(str, Enum):
    """System roles.

    Roles describe what an account may do. They are intentionally separate
    from person types such as Patient or StaffMember.
    """

    ADMIN = "ADMIN"
    OPERATOR = "OPERATOR"
    VERIFIER = "VERIFIER"
    AUDITOR = "AUDITOR"
    NURSE = "NURSE"
    PATIENT = "PATIENT"

    @property
    def is_staff_role(self) -> bool:
        """Return True for roles used by internal staff accounts."""
        return self in {
            Role.ADMIN,
            Role.OPERATOR,
            Role.VERIFIER,
            Role.AUDITOR,
            Role.NURSE,
        }
