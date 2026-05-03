"""
app/modules/audit/audit_service.py
-----------------------------------
Business-logic façade for recording and querying audit events.

Route handlers and other services call this module to log actions
without needing to know the repository or model details.
"""

import logging
from typing import Optional

from sqlalchemy.orm import Session

from app.modules.audit.audit_model import AuditLog
from app.modules.audit.audit_repository import audit_repository

logger = logging.getLogger("nhis.auth")


class AuditService:
    """
    Provides a clean interface for creating and querying audit log entries.
    """

    def log(
        self,
        db: Session,
        user_id: str,
        action: str,
        entity_type: Optional[str] = None,
        patient_uhid: Optional[str] = None,
        ip_address: Optional[str] = None,
    ) -> AuditLog:
        """
        Record an auditable action.

        :param db:           Active database session.
        :param user_id:      Actor's username or system identifier.
        :param action:       Short action label (e.g. APPROVED_PATIENT).
        :param entity_type:  Name of the affected entity class.
        :param patient_uhid: UHID of the affected patient, if applicable.
        :param ip_address:   Client IP address extracted from the request.
        :return: The persisted :class:`AuditLog` entry.
        """
        logger.info(
            "AUDIT | user=%s | action=%s | entity=%s | uhid=%s | ip=%s",
            user_id,
            action,
            entity_type,
            patient_uhid,
            ip_address,
        )
        return audit_repository.create(
            db=db,
            user_id=user_id,
            action=action,
            entity_type=entity_type,
            patient_uhid=patient_uhid,
            ip_address=ip_address,
        )

    def get_patient_history(self, db: Session, patient_uhid: str) -> list[AuditLog]:
        """
        Return full audit history for a patient.

        :param db:           Active database session.
        :param patient_uhid: UHID of the patient.
        :return: List of :class:`AuditLog` entries.
        """
        return audit_repository.get_by_patient(db, patient_uhid)

    def get_user_history(self, db: Session, user_id: str) -> list[AuditLog]:
        """
        Return all actions performed by a specific user.

        :param db:      Active database session.
        :param user_id: Username to look up.
        :return: List of :class:`AuditLog` entries.
        """
        return audit_repository.get_by_user(db, user_id)


audit_service = AuditService()
