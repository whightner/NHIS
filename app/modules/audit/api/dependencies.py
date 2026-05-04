"""FastAPI dependencies for audit endpoints."""

from fastapi import Depends
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.modules.audit.application import AuditQueryService
from app.modules.audit.infrastructure import SQLAlchemyAuditLogRepository


def get_audit_query_service(db: Session = Depends(get_db)) -> AuditQueryService:
    """Build the audit query service for one request."""
    return AuditQueryService(SQLAlchemyAuditLogRepository(db))
