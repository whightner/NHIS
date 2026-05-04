"""Command objects accepted by patient use cases."""

from dataclasses import dataclass
from datetime import date

from app.modules.patients.application.dto import PhotoUpload


@dataclass(frozen=True)
class PatientRegistrationCommand:
    """Data required to register a new patient."""

    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    national_id: str | None = None
    phone_number: str | None = None
    ip_address: str = "unknown"


@dataclass(frozen=True)
class RejectPatientCommand:
    """Data required to reject a patient registration."""

    uhid: str
    reason: str
    ip_address: str = "unknown"


@dataclass(frozen=True)
class PhotoUploadCommand:
    """Data required to save a patient photo."""

    uhid: str
    photo: PhotoUpload
