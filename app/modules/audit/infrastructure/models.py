"""SQLAlchemy models for audit infrastructure."""

from datetime import datetime, timezone

from sqlalchemy import JSON, Column, DateTime, Integer, String

from app.database.base import Base


class AuditLog(Base):
    """Persistent audit trail row."""

    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(100), nullable=False, index=True)
    action = Column(String(200), nullable=False)
    entity_type = Column(String(50), nullable=True)
    entity_id = Column(String(100), nullable=True, index=True)
    patient_uhid = Column(String(30), nullable=True, index=True)
    ip_address = Column(String(45), nullable=True)
    details = Column(JSON, nullable=True)
    timestamp = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(tz=timezone.utc),
        nullable=False,
    )
