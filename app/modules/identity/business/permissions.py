"""Business permissions derived from account roles."""

from __future__ import annotations

from enum import Enum

from app.shared.business.errors import PermissionDenied
from app.shared.business.roles import Role


class Permission(str, Enum):
    """Actions that can be protected by business policies."""

    CREATE_USER = "CREATE_USER"
    LIST_USERS = "LIST_USERS"
    UPDATE_USER_STATUS = "UPDATE_USER_STATUS"
    REGISTER_PATIENT = "REGISTER_PATIENT"
    VIEW_PATIENT = "VIEW_PATIENT"
    VIEW_PATIENT_STATISTICS = "VIEW_PATIENT_STATISTICS"
    REVIEW_PATIENT_DUPLICATES = "REVIEW_PATIENT_DUPLICATES"
    LIST_REVIEWED_PATIENTS = "LIST_REVIEWED_PATIENTS"
    APPROVE_PATIENT = "APPROVE_PATIENT"
    REJECT_PATIENT = "REJECT_PATIENT"
    UPLOAD_PATIENT_PHOTO = "UPLOAD_PATIENT_PHOTO"
    GENERATE_PATIENT_CARD = "GENERATE_PATIENT_CARD"
    VERIFY_PATIENT = "VERIFY_PATIENT"
    VIEW_AUDIT_LOGS = "VIEW_AUDIT_LOGS"
    CREATE_STAFF = "CREATE_STAFF"
    VIEW_STAFF = "VIEW_STAFF"
    UPDATE_STAFF = "UPDATE_STAFF"


ROLE_PERMISSIONS: dict[Role, frozenset[Permission]] = {
    Role.ADMIN: frozenset(permission for permission in Permission),
    Role.OPERATOR: frozenset(
        {
            Permission.REGISTER_PATIENT,
            Permission.VIEW_PATIENT,
            Permission.UPLOAD_PATIENT_PHOTO,
            Permission.GENERATE_PATIENT_CARD,
            Permission.VERIFY_PATIENT,
        }
    ),
    Role.VERIFIER: frozenset(
        {
            Permission.VIEW_PATIENT,
            Permission.VIEW_PATIENT_STATISTICS,
            Permission.REVIEW_PATIENT_DUPLICATES,
            Permission.LIST_REVIEWED_PATIENTS,
            Permission.APPROVE_PATIENT,
            Permission.REJECT_PATIENT,
            Permission.VERIFY_PATIENT,
        }
    ),
    Role.AUDITOR: frozenset(
        {
            Permission.VIEW_PATIENT,
            Permission.VIEW_AUDIT_LOGS,
        }
    ),
    Role.NURSE: frozenset(
        {
            Permission.REGISTER_PATIENT,
            Permission.VIEW_PATIENT,
            Permission.UPLOAD_PATIENT_PHOTO,
            Permission.VERIFY_PATIENT,
        }
    ),
    Role.PATIENT: frozenset(),
}


def permissions_for_roles(roles: set[Role] | frozenset[Role]) -> frozenset[Permission]:
    """Return the union of permissions granted by a role set."""
    permissions: set[Permission] = set()
    for role in roles:
        permissions.update(ROLE_PERMISSIONS.get(role, frozenset()))
    return frozenset(permissions)


def require_permission(
    roles: set[Role] | frozenset[Role],
    permission: Permission,
) -> None:
    """Raise PermissionDenied when a role set lacks a permission."""
    if permission not in permissions_for_roles(roles):
        raise PermissionDenied(f"Missing permission: {permission.value}")
