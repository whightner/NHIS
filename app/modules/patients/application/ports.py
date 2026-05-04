"""Ports required by patient application services."""

from __future__ import annotations

from datetime import date
from typing import Protocol

from app.modules.patients.application.dto import PhotoUpload
from app.modules.patients.business import Patient, PatientCard, VerificationStatus


class PatientRepository(Protocol):
    """Persistence contract for patient records."""

    def get_by_uhid(self, uhid: str) -> Patient | None:
        """Return a patient by UHID."""

    def find_by_birth_date(self, date_of_birth: date) -> list[Patient]:
        """Return patients born on a specific date."""

    def search(
        self,
        *,
        uhid: str | None = None,
        first_name: str | None = None,
        last_name: str | None = None,
    ) -> list[Patient]:
        """Search patients by optional criteria."""

    def get_by_status(self, status: VerificationStatus) -> list[Patient]:
        """Return patients by verification status."""

    def get_all(self) -> list[Patient]:
        """Return every patient."""

    def count_by_status(self) -> dict[VerificationStatus, int]:
        """Return counts grouped by verification status."""

    def uhid_exists(self, uhid: str) -> bool:
        """Return True when a UHID is already used."""

    def create(self, patient: Patient) -> Patient:
        """Persist a new patient."""

    def save(self, patient: Patient) -> Patient:
        """Persist patient changes."""


class UhidGenerator(Protocol):
    """Unique health identifier generator."""

    def generate(self) -> str:
        """Return an unused UHID."""


class SecurityCodeGenerator(Protocol):
    """Patient card security-code generator."""

    def generate(self) -> str:
        """Return a new security code."""


class PatientPhotoStorage(Protocol):
    """Storage contract for patient photos."""

    def save(self, upload: PhotoUpload, uhid: str) -> str:
        """Persist a photo and return its storage path."""


class QrCodeGenerator(Protocol):
    """QR code generator contract."""

    def generate(self, uhid: str) -> str:
        """Generate a QR code and return its path."""


class PatientCardGenerator(Protocol):
    """Patient card generator contract."""

    def generate(self, patient: Patient) -> PatientCard:
        """Generate a patient card."""
