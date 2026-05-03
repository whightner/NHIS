"""
app/modules/audit/audit_model.py
---------------------------------
SQLAlchemy ORM model for the ``audit_logs`` table.

Every significant action in the system creates an audit entry.
"""

from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Integer, String

from app.database.base import Base


class AuditLog(Base):
    """
    Persistent audit trail entry.

    Each row records who did what, when, from where, and on which entity.

    :param id:           Auto-increment primary key.
    :param user_id:      Username (or system identifier) of the actor.
    :param action:       Verb describing the operation (e.g. APPROVED_PATIENT).
    :param entity_type:  Type of the affected entity (e.g. Patient, User).
    :param patient_uhid: UHID of the affected patient, if applicable.
    :param ip_address:   Remote IP address of the request, if available.
    :param timestamp:    UTC timestamp of the event.
    """

    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(String(100), nullable=False, index=True)

    action = Column(String(200), nullable=False)

    entity_type = Column(String(50), nullable=True)

    patient_uhid = Column(String(30), nullable=True, index=True)

    ip_address = Column(String(45), nullable=True)   # IPv4 or IPv6

    timestamp = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(tz=timezone.utc),
        nullable=False,
    )
