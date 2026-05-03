"""Audit log business object."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from types import MappingProxyType
from typing import Any, Mapping

from app.shared.business.errors import ValidationError


class AuditAction(str, Enum):
    """Actions that are meaningful for traceability."""

    LOGIN_SUCCESS = "LOGIN_SUCCESS"
    LOGIN_FAILED = "LOGIN_FAILED"
    REGISTERED_PATIENT = "REGISTERED_PATIENT"
    APPROVED_PATIENT = "APPROVED_PATIENT"
    REJECTED_PATIENT = "REJECTED_PATIENT"
    UPLOADED_PATIENT_PHOTO = "UPLOADED_PATIENT_PHOTO"
    GENERATED_PATIENT_CARD = "GENERATED_PATIENT_CARD"
    REPRINTED_PATIENT_CARD = "REPRINTED_PATIENT_CARD"
    VERIFIED_PATIENT = "VERIFIED_PATIENT"
    VERIFIED_SECURITY_CODE = "VERIFIED_SECURITY_CODE"
    CREATED_USER = "CREATED_USER"
    CHANGED_USER_STATUS = "CHANGED_USER_STATUS"


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


@dataclass(frozen=True)
class AuditLog:
    """Immutable trace of a significant action."""

    actor_id: str
    action: AuditAction
    occurred_at: datetime = field(default_factory=_utcnow)
    entity_type: str | None = None
    entity_id: str | None = None
    ip_address: str | None = None
    details: Mapping[str, Any] = field(default_factory=dict)
    id: str | None = None

    def __post_init__(self) -> None:
        if not self.actor_id or not self.actor_id.strip():
            raise ValidationError("Audit actor id is required.")
        object.__setattr__(self, "details", MappingProxyType(dict(self.details)))

    @classmethod
    def record(
        cls,
        actor_id: str,
        action: AuditAction,
        *,
        entity_type: str | None = None,
        entity_id: str | None = None,
        ip_address: str | None = None,
        details: Mapping[str, Any] | None = None,
    ) -> "AuditLog":
        """Create a new audit log entry."""
        return cls(
            actor_id=actor_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            ip_address=ip_address,
            details=details or {},
        )
