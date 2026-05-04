"""Pydantic schemas for audit endpoints."""

from datetime import datetime
from typing import Any

from pydantic import BaseModel

from app.modules.audit.business import AuditLog


class AuditLogResponse(BaseModel):
    """Public audit log representation."""

    id: str | None
    actor_id: str
    action: str
    occurred_at: datetime
    entity_type: str | None = None
    entity_id: str | None = None
    ip_address: str | None = None
    details: dict[str, Any]

    @classmethod
    def from_audit_log(cls, audit_log: AuditLog) -> "AuditLogResponse":
        """Build an API response from an audit business object."""
        return cls(
            id=audit_log.id,
            actor_id=audit_log.actor_id,
            action=audit_log.action.value,
            occurred_at=audit_log.occurred_at,
            entity_type=audit_log.entity_type,
            entity_id=audit_log.entity_id,
            ip_address=audit_log.ip_address,
            details=dict(audit_log.details),
        )
