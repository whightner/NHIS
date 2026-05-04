"""Infrastructure adapters for audit logging."""

from app.modules.audit.infrastructure.sqlalchemy_audit_repository import (
    SQLAlchemyAuditLogRepository,
)

__all__ = ["SQLAlchemyAuditLogRepository"]
