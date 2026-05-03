"""
app/modules/patient/patient_schema.py
---------------------------------------
Pydantic request/response models for the patient module.
"""

from datetime import date, datetime
from typing import List, Optional

from pydantic import BaseModel


class PatientCreate(BaseModel):
    """
    Payload for registering a new patient.

    :param national_id:   Optional national ID / passport number.
    :param first_name:    Patient's first name.
    :param last_name:     Patient's last name.
    :param date_of_birth: Date of birth in ISO-8601 format (YYYY-MM-DD).
    :param gender:        Gender string.
    :param nationality:   Nationality or country of origin.
    :param phone_number:  Optional contact phone number.
    """

    national_id: Optional[str] = None
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    phone_number: Optional[str] = None


class PatientResponse(BaseModel):
    """
    Public-facing patient record representation.

    :param uhid:                Unique Health Identifier.
    :param national_id:         Optional national ID.
    :param first_name:          First name.
    :param last_name:           Last name.
    :param date_of_birth:       Date of birth.
    :param gender:              Gender.
    :param nationality:         Nationality.
    :param phone_number:        Optional phone number.
    :param verification_status: Current verification state.
    :param created_at:          Registration timestamp.
    """

    uhid: str
    national_id: Optional[str] = None
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    phone_number: Optional[str] = None
    verification_status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class DuplicateInfo(BaseModel):
    """
    Summary of a potential duplicate patient record.

    :param uhid:       UHID of the possible duplicate.
    :param first_name: First name.
    :param last_name:  Last name.
    :param score:      Average fuzzy-match score (0–100).
    """

    uhid: str
    first_name: str
    last_name: str
    score: float


class PatientRegisterResponse(BaseModel):
    """
    Response returned after a patient registration attempt.

    :param patient:              The newly created patient record.
    :param possible_duplicates:  List of existing records that may be the same person.
    """

    patient: PatientResponse
    possible_duplicates: List[DuplicateInfo]


class PatientStatistics(BaseModel):
    """
    Aggregate counts of patients by verification status.

    :param pending:  Number of patients awaiting review.
    :param approved: Number of approved patients.
    :param rejected: Number of rejected patients.
    :param total:    Grand total across all statuses.
    """

    pending: int
    approved: int
    rejected: int
    total: int


class VerifyPatientResponse(BaseModel):
    """
    Response for a patient identity verification check.

    :param status:        Always ``"VALID"`` when returned successfully.
    :param uhid:          Patient UHID.
    :param first_name:    First name.
    :param last_name:     Last name.
    :param date_of_birth: Date of birth.
    :param gender:        Gender.
    :param nationality:   Nationality.
    """

    status: str
    uhid: str
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
