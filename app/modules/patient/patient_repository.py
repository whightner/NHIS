"""
app/modules/patient/patient_repository.py
------------------------------------------
Data-access layer for :class:`~app.modules.patient.patient_model.Patient`.

Only SQLAlchemy queries live here.
"""

from datetime import date
from typing import Optional

from sqlalchemy.orm import Session

from app.modules.patient.patient_model import Patient


class PatientRepository:
    """Encapsulates all database operations for :class:`Patient` entities."""

    def get_by_uhid(self, db: Session, uhid: str) -> Optional[Patient]:
        """
        Fetch a patient by their UHID.

        :param db:   Active database session.
        :param uhid: Unique Health Identifier string.
        :return: Matching :class:`Patient` or ``None``.
        """
        return db.query(Patient).filter(Patient.uhid == uhid).first()

    def search(
        self,
        db: Session,
        uhid: Optional[str] = None,
        first_name: Optional[str] = None,
        last_name: Optional[str] = None,
    ) -> list[Patient]:
        """
        Filter patients by one or more criteria (all optional).

        :param db:         Active database session.
        :param uhid:       Exact UHID match.
        :param first_name: Case-insensitive partial first-name match.
        :param last_name:  Case-insensitive partial last-name match.
        :return: List of matching :class:`Patient` records.
        """
        query = db.query(Patient)
        if uhid:
            query = query.filter(Patient.uhid == uhid)
        if first_name:
            query = query.filter(Patient.first_name.ilike(f"%{first_name}%"))
        if last_name:
            query = query.filter(Patient.last_name.ilike(f"%{last_name}%"))
        return query.all()

    def get_by_status(self, db: Session, status: str) -> list[Patient]:
        """
        Return all patients with a specific verification status.

        :param db:     Active database session.
        :param status: ``VerificationStatus`` constant.
        :return: List of :class:`Patient` records.
        """
        return (
            db.query(Patient)
            .filter(Patient.verification_status == status)
            .all()
        )

    def get_by_dob(self, db: Session, dob: date) -> list[Patient]:
        """
        Return all patients with a specific date of birth.

        Used by the duplicate checker to limit the comparison set.

        :param db:  Active database session.
        :param dob: Date of birth to filter by.
        :return: List of :class:`Patient` records.
        """
        return db.query(Patient).filter(Patient.date_of_birth == dob).all()

    def count_by_status(self, db: Session) -> dict:
        """
        Return aggregate patient counts grouped by verification status.

        Uses a single query to avoid multiple round-trips.

        :param db: Active database session.
        :return: Dict with keys ``pending``, ``approved``, ``rejected``, ``total``.
        """
        from sqlalchemy import func
        from app.core.constants import VerificationStatus

        rows = (
            db.query(Patient.verification_status, func.count(Patient.uhid))
            .group_by(Patient.verification_status)
            .all()
        )
        counts = {r[0]: r[1] for r in rows}
        return {
            "pending":  counts.get(VerificationStatus.PENDING, 0),
            "approved": counts.get(VerificationStatus.APPROVED, 0),
            "rejected": counts.get(VerificationStatus.REJECTED, 0),
            "total":    sum(counts.values()),
        }

    def create(self, db: Session, patient: Patient) -> Patient:
        """
        Persist a new patient record.

        :param db:      Active database session.
        :param patient: Fully populated :class:`Patient` instance.
        :return: The persisted and refreshed :class:`Patient`.
        """
        db.add(patient)
        db.commit()
        db.refresh(patient)
        return patient

    def update_status(self, db: Session, patient: Patient, new_status: str) -> Patient:
        """
        Change a patient's verification status.

        :param db:         Active database session.
        :param patient:    :class:`Patient` instance to update.
        :param new_status: New ``VerificationStatus`` constant.
        :return: The updated :class:`Patient`.
        """
        patient.verification_status = new_status
        db.commit()
        db.refresh(patient)
        return patient

    def update_photo(self, db: Session, patient: Patient, photo_path: str) -> Patient:
        """
        Store the file-system path of the patient's photo.

        :param db:         Active database session.
        :param patient:    :class:`Patient` instance to update.
        :param photo_path: Relative path to the saved image.
        :return: The updated :class:`Patient`.
        """
        patient.photo_path = photo_path
        db.commit()
        db.refresh(patient)
        return patient

    def get_all(self, db: Session) -> list[Patient]:
        """
        Return every patient record (used by the duplicate review endpoint).

        :param db: Active database session.
        :return: Full list of :class:`Patient` records.
        """
        return db.query(Patient).all()

    def uhid_exists(self, db: Session, uhid: str) -> bool:
        """
        Check whether a UHID is already taken (O(1) existence check).

        :param db:   Active database session.
        :param uhid: UHID to test.
        :return: ``True`` if the UHID is in use, ``False`` otherwise.
        """
        return db.query(Patient.uhid).filter(Patient.uhid == uhid).first() is not None


patient_repository = PatientRepository()
