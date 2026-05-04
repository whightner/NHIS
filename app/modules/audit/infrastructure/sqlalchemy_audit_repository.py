"""SQLAlchemy adapter for audit log persistence."""

from __future__ import annotations

from datetime import timezone

from sqlalchemy.orm import Session

from app.modules.audit.audit_model import AuditLog as AuditLogRow
from app.modules.audit.business import AuditAction, AuditLog


class SQLAlchemyAuditLogRepository:
    """Stores audit business objects in the existing audit_logs table."""

    def __init__(self, db: Session) -> None:
        self._db = db

    def create(self, audit_log: AuditLog) -> AuditLog:
        """Persist an audit entry and return it with its database id."""
        row = AuditLogRow(
            user_id=audit_log.actor_id,
            action=audit_log.action.value,
            entity_type=audit_log.entity_type,
            patient_uhid=(
                audit_log.entity_id
                if audit_log.entity_type == "Patient"
                else None
            ),
            ip_address=audit_log.ip_address,
            timestamp=audit_log.occurred_at,
        )
        self._db.add(row)
        self._db.commit()
        self._db.refresh(row)
        return self._to_business(row)

    def find_by_patient(self, patient_uhid: str) -> list[AuditLog]:
        """Return patient-related audit entries ordered newest first."""
        rows = (
            self._db.query(AuditLogRow)
            .filter(AuditLogRow.patient_uhid == patient_uhid)
            .order_by(AuditLogRow.timestamp.desc())
            .all()
        )
        return [self._to_business(row) for row in rows]

    def find_by_actor(self, actor_id: str) -> list[AuditLog]:
        """Return actor audit entries ordered newest first."""
        rows = (
            self._db.query(AuditLogRow)
            .filter(AuditLogRow.user_id == actor_id)
            .order_by(AuditLogRow.timestamp.desc())
            .all()
        )
        return [self._to_business(row) for row in rows]

    def _to_business(self, row: AuditLogRow) -> AuditLog:
        action_value, details = self._parse_action(row.action)
        return AuditLog(
            id=str(row.id),
            actor_id=row.user_id,
            action=action_value,
            occurred_at=self._ensure_timezone(row.timestamp),
            entity_type=row.entity_type,
            entity_id=row.patient_uhid,
            ip_address=row.ip_address,
            details=details,
        )

    @staticmethod
    def _parse_action(action: str) -> tuple[AuditAction, dict[str, str]]:
        clean_action, _, suffix = action.partition(":")
        try:
            return AuditAction(clean_action.strip()), (
                {"legacy_details": suffix.strip()} if suffix.strip() else {}
            )
        except ValueError:
            return AuditAction.UNKNOWN, {"legacy_action": action}

    @staticmethod
    def _ensure_timezone(value):
        if value.tzinfo is not None:
            return value
        return value.replace(tzinfo=timezone.utc)
