"""DTOs returned by patient use cases."""

from __future__ import annotations

from dataclasses import dataclass
from typing import BinaryIO

from app.modules.patients.business import Patient


@dataclass(frozen=True)
class PhotoUpload:
    """Framework-neutral representation of an uploaded photo."""

    filename: str
    stream: BinaryIO


@dataclass(frozen=True)
class DuplicatePatient:
    """Summary of a possible duplicate patient."""

    uhid: str
    first_name: str
    last_name: str
    score: float


@dataclass(frozen=True)
class PatientRegistrationResult:
    """Result returned after patient registration."""

    patient: Patient
    possible_duplicates: list[DuplicatePatient]


@dataclass(frozen=True)
class PatientStatistics:
    """Aggregate patient counts grouped by verification status."""

    pending: int
    approved: int
    rejected: int
    total: int
