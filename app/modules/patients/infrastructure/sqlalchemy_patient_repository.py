"""SQLAlchemy adapter for patient persistence."""

from __future__ import annotations

from datetime import date, timezone

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.modules.patients.business import Patient, PatientCard, VerificationStatus
from app.modules.patients.infrastructure.models import Patient as PatientRow
from app.shared.business import Gender, Person


class SQLAlchemyPatientRepository:
    """Maps the existing patients table to Patient business objects."""

    def __init__(self, db: Session) -> None:
        self._db = db

    def get_by_uhid(self, uhid: str) -> Patient | None:
        """Return a patient by UHID."""
        row = self._db.query(PatientRow).filter(PatientRow.uhid == uhid).first()
        return self._to_business(row) if row else None

    def find_by_birth_date(self, date_of_birth: date) -> list[Patient]:
        """Return patients born on the supplied date."""
        rows = (
            self._db.query(PatientRow)
            .filter(PatientRow.date_of_birth == date_of_birth)
            .all()
        )
        return [self._to_business(row) for row in rows]

    def search(
        self,
        *,
        uhid: str | None = None,
        first_name: str | None = None,
        last_name: str | None = None,
    ) -> list[Patient]:
        """Search patients by optional filters."""
        query = self._db.query(PatientRow)
        if uhid:
            query = query.filter(PatientRow.uhid == uhid)
        if first_name:
            query = query.filter(PatientRow.first_name.ilike(f"%{first_name}%"))
        if last_name:
            query = query.filter(PatientRow.last_name.ilike(f"%{last_name}%"))
        return [self._to_business(row) for row in query.all()]

    def get_by_status(self, status: VerificationStatus) -> list[Patient]:
        """Return patients by verification status."""
        rows = (
            self._db.query(PatientRow)
            .filter(PatientRow.verification_status == status.value)
            .all()
        )
        return [self._to_business(row) for row in rows]

    def get_all(self) -> list[Patient]:
        """Return all patients."""
        return [self._to_business(row) for row in self._db.query(PatientRow).all()]

    def count_by_status(self) -> dict[VerificationStatus, int]:
        """Return patient counts grouped by verification status."""
        rows = (
            self._db.query(PatientRow.verification_status, func.count(PatientRow.uhid))
            .group_by(PatientRow.verification_status)
            .all()
        )
        counts: dict[VerificationStatus, int] = {}
        for status_value, count in rows:
            counts[VerificationStatus(status_value)] = count
        return counts

    def uhid_exists(self, uhid: str) -> bool:
        """Return True when a UHID is already used."""
        return (
            self._db.query(PatientRow.uhid)
            .filter(PatientRow.uhid == uhid)
            .first()
            is not None
        )

    def create(self, patient: Patient) -> Patient:
        """Persist a new patient."""
        row = PatientRow(
            uhid=patient.uhid,
            national_id=patient.person.national_id,
            first_name=patient.person.first_name,
            last_name=patient.person.last_name,
            date_of_birth=patient.person.date_of_birth,
            gender=patient.person.gender.value,
            nationality=patient.person.nationality,
            phone_number=patient.person.phone_number,
            photo_path=patient.photo_path,
            security_code=patient.security_code,
            verification_status=patient.verification_status.value,
            rejection_reason=patient.rejection_reason,
            card_pdf_path=patient.card.pdf_path if patient.card else None,
            card_qr_code_path=patient.card.qr_code_path if patient.card else None,
            card_generated_at=patient.card.generated_at if patient.card else None,
            card_reprint_count=patient.card.reprint_count if patient.card else 0,
        )
        self._db.add(row)
        self._db.flush()
        self._db.refresh(row)
        return self._to_business(row)

    def save(self, patient: Patient) -> Patient:
        """Persist patient changes."""
        row = self._get_row(patient.uhid)
        row.national_id = patient.person.national_id
        row.first_name = patient.person.first_name
        row.last_name = patient.person.last_name
        row.date_of_birth = patient.person.date_of_birth
        row.gender = patient.person.gender.value
        row.nationality = patient.person.nationality
        row.phone_number = patient.person.phone_number
        row.photo_path = patient.photo_path
        row.security_code = patient.security_code
        row.verification_status = patient.verification_status.value
        row.rejection_reason = patient.rejection_reason
        if patient.card:
            row.card_pdf_path = patient.card.pdf_path
            row.card_qr_code_path = patient.card.qr_code_path
            row.card_generated_at = patient.card.generated_at
            row.card_reprint_count = patient.card.reprint_count
        self._db.flush()
        self._db.refresh(row)
        return self._to_business(row)

    def _get_row(self, uhid: str) -> PatientRow:
        row = self._db.query(PatientRow).filter(PatientRow.uhid == uhid).first()
        if row is None:
            raise LookupError(f"Patient '{uhid}' not found.")
        return row

    @staticmethod
    def _to_business(row: PatientRow) -> Patient:
        card = None
        if row.card_pdf_path and row.card_qr_code_path and row.card_generated_at:
            card = PatientCard(
                uhid=row.uhid,
                pdf_path=row.card_pdf_path,
                qr_code_path=row.card_qr_code_path,
                generated_at=SQLAlchemyPatientRepository._ensure_timezone(
                    row.card_generated_at
                ),
                reprint_count=row.card_reprint_count or 0,
            )

        return Patient(
            uhid=row.uhid,
            person=Person(
                first_name=row.first_name,
                last_name=row.last_name,
                date_of_birth=row.date_of_birth,
                gender=Gender(row.gender),
                nationality=row.nationality,
                national_id=row.national_id,
                phone_number=row.phone_number,
            ),
            security_code=row.security_code,
            verification_status=VerificationStatus(row.verification_status),
            photo_path=row.photo_path,
            card=card,
            rejection_reason=row.rejection_reason,
            created_at=SQLAlchemyPatientRepository._ensure_timezone(row.created_at),
            updated_at=SQLAlchemyPatientRepository._ensure_timezone(row.updated_at),
        )

    @staticmethod
    def _ensure_timezone(value):
        if value.tzinfo is not None:
            return value
        return value.replace(tzinfo=timezone.utc)
