"""Pydantic schemas for patient endpoints."""

from __future__ import annotations

from datetime import date, datetime

from pydantic import BaseModel

from app.modules.patients.application import DuplicatePatient, PatientStatistics
from app.modules.patients.business import Patient


class PatientCreate(BaseModel):
    """Payload for registering a patient."""

    national_id: str | None = None
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    phone_number: str | None = None


class PatientResponse(BaseModel):
    """Public patient record."""

    uhid: str
    national_id: str | None = None
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    phone_number: str | None = None
    verification_status: str
    created_at: datetime

    @classmethod
    def from_patient(cls, patient: Patient) -> "PatientResponse":
        """Build an API response from a business patient."""
        return cls(
            uhid=patient.uhid,
            national_id=patient.person.national_id,
            first_name=patient.person.first_name,
            last_name=patient.person.last_name,
            date_of_birth=patient.person.date_of_birth,
            gender=patient.person.gender.value,
            nationality=patient.person.nationality,
            phone_number=patient.person.phone_number,
            verification_status=patient.verification_status.value,
            created_at=patient.created_at,
        )


class DuplicateInfo(BaseModel):
    """Summary of a possible duplicate patient."""

    uhid: str
    first_name: str
    last_name: str
    score: float

    @classmethod
    def from_duplicate(cls, duplicate: DuplicatePatient) -> "DuplicateInfo":
        """Build an API response from a duplicate DTO."""
        return cls(
            uhid=duplicate.uhid,
            first_name=duplicate.first_name,
            last_name=duplicate.last_name,
            score=duplicate.score,
        )


class PatientRegisterResponse(BaseModel):
    """Response returned after patient registration."""

    patient: PatientResponse
    possible_duplicates: list[DuplicateInfo]


class PatientStatisticsResponse(BaseModel):
    """Aggregate patient counts."""

    pending: int
    approved: int
    rejected: int
    total: int

    @classmethod
    def from_statistics(
        cls,
        statistics: PatientStatistics,
    ) -> "PatientStatisticsResponse":
        """Build an API response from statistics DTO."""
        return cls(
            pending=statistics.pending,
            approved=statistics.approved,
            rejected=statistics.rejected,
            total=statistics.total,
        )


class VerifyPatientResponse(BaseModel):
    """Response for a successful patient verification."""

    status: str
    uhid: str
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
