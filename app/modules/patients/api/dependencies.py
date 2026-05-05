"""FastAPI dependencies for patient endpoints."""

from fastapi import Depends
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.modules.audit.application import AuditRecorder
from app.modules.audit.infrastructure import SQLAlchemyAuditLogRepository
from app.modules.patients.application import PatientApplicationService
from app.modules.patients.infrastructure import (
    LocalPatientPhotoStorage,
    ReportLabPatientCardGenerator,
    SQLAlchemyPatientRepository,
    SecureSecurityCodeGenerator,
    SecureUhidGenerator,
    SettingsQrCodeGenerator,
)
from app.shared.infrastructure import SQLAlchemyTransactionManager


def get_patient_service(db: Session = Depends(get_db)) -> PatientApplicationService:
    """Build the patient application service for one request."""
    patients = SQLAlchemyPatientRepository(db)
    audit_repository = SQLAlchemyAuditLogRepository(db)
    return PatientApplicationService(
        patients=patients,
        uhids=SecureUhidGenerator(patients),
        security_codes=SecureSecurityCodeGenerator(),
        photos=LocalPatientPhotoStorage(),
        qr_codes=SettingsQrCodeGenerator(),
        cards=ReportLabPatientCardGenerator(),
        audit=AuditRecorder(audit_repository),
        transaction=SQLAlchemyTransactionManager(db),
    )
