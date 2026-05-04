"""Ports required by audit application services."""

from __future__ import annotations

from typing import Protocol

from app.modules.audit.business import AuditLog


class AuditLogRepository(Protocol):
    """Persistence port for audit log entries."""

    def create(self, audit_log: AuditLog) -> AuditLog:
        """Persist an audit entry."""

    def find_by_patient(self, patient_uhid: str) -> list[AuditLog]:
        """Return audit entries related to a patient."""

    def find_by_actor(self, actor_id: str) -> list[AuditLog]:
        """Return audit entries created by an actor."""
