"""Use cases for recording and reading audit logs."""

from __future__ import annotations

from typing import Any, Mapping

from app.modules.audit.application.ports import AuditLogRepository
from app.modules.audit.business import AuditAction, AuditLog


class AuditRecorder:
    """Records significant system actions."""

    def __init__(self, repository: AuditLogRepository) -> None:
        self._repository = repository

    def record(
        self,
        actor_id: str,
        action: AuditAction,
        *,
        entity_type: str | None = None,
        entity_id: str | None = None,
        ip_address: str | None = None,
        details: Mapping[str, Any] | None = None,
    ) -> AuditLog:
        """Create and persist an audit event."""
        audit_log = AuditLog.record(
            actor_id=actor_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            ip_address=ip_address,
            details=details,
        )
        return self._repository.create(audit_log)


class AuditQueryService:
    """Reads audit history for administrative review."""

    def __init__(self, repository: AuditLogRepository) -> None:
        self._repository = repository

    def get_patient_history(self, patient_uhid: str) -> list[AuditLog]:
        """Return all audit entries for a patient."""
        return self._repository.find_by_patient(patient_uhid)

    def get_actor_history(self, actor_id: str) -> list[AuditLog]:
        """Return all audit entries made by an actor."""
        return self._repository.find_by_actor(actor_id)
