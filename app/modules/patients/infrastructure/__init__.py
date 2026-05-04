"""Infrastructure adapters for patient workflows."""

from app.modules.patients.infrastructure.identifiers import (
    SecureSecurityCodeGenerator,
    SecureUhidGenerator,
)
from app.modules.patients.infrastructure.local_media import (
    LocalPatientPhotoStorage,
    ReportLabPatientCardGenerator,
    SettingsQrCodeGenerator,
)
from app.modules.patients.infrastructure.sqlalchemy_patient_repository import (
    SQLAlchemyPatientRepository,
)

__all__ = [
    "LocalPatientPhotoStorage",
    "ReportLabPatientCardGenerator",
    "SQLAlchemyPatientRepository",
    "SecureSecurityCodeGenerator",
    "SecureUhidGenerator",
    "SettingsQrCodeGenerator",
]
