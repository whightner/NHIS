"""
app/modules/patient/patient_service.py
----------------------------------------
Business-logic layer for patient registration and management.

This layer:
  - Orchestrates UHID generation, duplicate detection, photo storage, card generation
  - Enforces verification-status transitions
  - Delegates persistence to the repository
  - Raises typed domain exceptions (never HTTPException)
"""

import logging
import os
from datetime import date
from typing import Optional

from fastapi import UploadFile
from sqlalchemy.orm import Session

from app.core.constants import PhotoUpload, Roles, VerificationStatus
from app.core.exceptions import (
    AuthorizationError,
    CardNotFoundError,
    InvalidPhotoError,
    InvalidVerificationStatusError,
    PatientNotApprovedError,
    PatientNotFoundError,
    SecurityCodeMismatchError,
)
from app.modules.audit.audit_service import audit_service
from app.modules.patient.patient_model import Patient
from app.modules.patient.patient_repository import patient_repository
from app.modules.user.user_model import User
from app.utils.duplicate_checker import check_duplicate
from app.utils.patient_card_generator import generate_card
from app.utils.qr_code_generator import generate_qr_code
from app.utils.security_code_generator import generate_security_code
from app.utils.uhid_generator import generate_uhid

logger = logging.getLogger(__name__)


class PatientService:
    """Handles all patient-related business logic."""

    # ── Registration ──────────────────────────────────────────────────

    def register_patient(
        self,
        db: Session,
        first_name: str,
        last_name: str,
        date_of_birth: date,
        gender: str,
        nationality: str,
        national_id: Optional[str],
        phone_number: Optional[str],
        actor: User,
        ip_address: str = "unknown",
    ) -> dict:
        """
        Register a new patient and check for duplicates.

        :param db:            Active database session.
        :param first_name:    Patient's first name.
        :param last_name:     Patient's last name.
        :param date_of_birth: Date of birth.
        :param gender:        Gender string.
        :param nationality:   Nationality.
        :param national_id:   Optional national ID.
        :param phone_number:  Optional phone number.
        :param actor:         The authenticated user performing this action.
        :param ip_address:    Client IP for audit.
        :return: Dict with ``patient`` and ``possible_duplicates`` keys.
        :raises AuthorizationError: If actor lacks ADMIN or OPERATOR role.
        """
        if actor.role not in [Roles.ADMIN, Roles.OPERATOR]:
            raise AuthorizationError("Only ADMIN or OPERATOR may register patients.")

        duplicates = check_duplicate(db, first_name, last_name, date_of_birth)
        uhid = generate_uhid(db)

        new_patient = Patient(
            uhid=uhid,
            national_id=national_id,
            first_name=first_name,
            last_name=last_name,
            date_of_birth=date_of_birth,
            gender=gender,
            nationality=nationality,
            phone_number=phone_number,
            security_code=generate_security_code(),
            verification_status=VerificationStatus.PENDING,
        )

        patient = patient_repository.create(db, new_patient)

        audit_service.log(
            db=db,
            user_id=actor.username,
            action="REGISTERED_PATIENT",
            entity_type="Patient",
            patient_uhid=uhid,
            ip_address=ip_address,
        )

        logger.info("Patient registered: %s by %s", uhid, actor.username)
        return {"patient": patient, "possible_duplicates": duplicates}

    # ── Lookup ────────────────────────────────────────────────────────

    def get_by_uhid(self, db: Session, uhid: str) -> Patient:
        """
        Retrieve a patient or raise if not found.

        :param db:   Active database session.
        :param uhid: UHID to look up.
        :return: :class:`Patient` instance.
        :raises PatientNotFoundError: If no patient has that UHID.
        """
        patient = patient_repository.get_by_uhid(db, uhid)
        if not patient:
            raise PatientNotFoundError(f"Patient '{uhid}' not found.")
        return patient

    def search(
        self,
        db: Session,
        uhid: Optional[str] = None,
        first_name: Optional[str] = None,
        last_name: Optional[str] = None,
    ) -> list[Patient]:
        """
        Search patients by optional filters.

        :param db:         Active database session.
        :param uhid:       Exact UHID filter.
        :param first_name: Partial first-name filter (case-insensitive).
        :param last_name:  Partial last-name filter (case-insensitive).
        :return: Matching :class:`Patient` list.
        """
        return patient_repository.search(db, uhid=uhid, first_name=first_name, last_name=last_name)

    def get_by_status(self, db: Session, status: str) -> list[Patient]:
        """
        Return all patients with a given verification status.

        :param db:     Active database session.
        :param status: ``VerificationStatus`` constant.
        :return: List of :class:`Patient` records.
        """
        return patient_repository.get_by_status(db, status)

    def get_statistics(self, db: Session) -> dict:
        """
        Return patient counts grouped by verification status.

        :param db: Active database session.
        :return: Dict with ``pending``, ``approved``, ``rejected``, ``total``.
        """
        return patient_repository.count_by_status(db)

    # ── Verification workflow ─────────────────────────────────────────

    def approve_patient(
        self,
        db: Session,
        uhid: str,
        actor: User,
        ip_address: str = "unknown",
    ) -> Patient:
        """
        Approve a patient registration.

        :param db:         Active database session.
        :param uhid:       UHID of the patient to approve.
        :param actor:      User performing the approval.
        :param ip_address: Client IP for audit.
        :return: Updated :class:`Patient`.
        :raises PatientNotFoundError:           If the patient does not exist.
        :raises InvalidVerificationStatusError: If patient is already approved/rejected.
        """
        patient = self.get_by_uhid(db, uhid)
        if patient.verification_status != VerificationStatus.PENDING:
            raise InvalidVerificationStatusError(
                f"Cannot approve a patient with status '{patient.verification_status}'."
            )
        patient = patient_repository.update_status(db, patient, VerificationStatus.APPROVED)
        audit_service.log(
            db=db,
            user_id=actor.username,
            action="APPROVED_PATIENT",
            entity_type="Patient",
            patient_uhid=uhid,
            ip_address=ip_address,
        )
        logger.info("Patient approved: %s by %s", uhid, actor.username)
        return patient

    def reject_patient(
        self,
        db: Session,
        uhid: str,
        reason: str,
        actor: User,
        ip_address: str = "unknown",
    ) -> Patient:
        """
        Reject a patient registration with a reason.

        :param db:         Active database session.
        :param uhid:       UHID of the patient to reject.
        :param reason:     Human-readable rejection reason.
        :param actor:      User performing the rejection.
        :param ip_address: Client IP for audit.
        :return: Updated :class:`Patient`.
        :raises PatientNotFoundError:           If the patient does not exist.
        :raises InvalidVerificationStatusError: If patient is already rejected.
        """
        patient = self.get_by_uhid(db, uhid)
        if patient.verification_status == VerificationStatus.REJECTED:
            raise InvalidVerificationStatusError("Patient is already rejected.")
        patient = patient_repository.update_status(db, patient, VerificationStatus.REJECTED)
        audit_service.log(
            db=db,
            user_id=actor.username,
            action=f"REJECTED_PATIENT: {reason}",
            entity_type="Patient",
            patient_uhid=uhid,
            ip_address=ip_address,
        )
        logger.info("Patient rejected: %s by %s — %s", uhid, actor.username, reason)
        return patient

    # ── Verification check ────────────────────────────────────────────

    def verify_patient(self, db: Session, uhid: str) -> Patient:
        """
        Verify a patient is approved and return their public record.

        :param db:   Active database session.
        :param uhid: UHID to verify.
        :return: :class:`Patient` with APPROVED status.
        :raises PatientNotFoundError:    If the patient does not exist.
        :raises PatientNotApprovedError: If the patient is not APPROVED.
        """
        patient = self.get_by_uhid(db, uhid)
        if patient.verification_status != VerificationStatus.APPROVED:
            raise PatientNotApprovedError(
                f"Patient '{uhid}' is not approved (status: {patient.verification_status})."
            )
        return patient

    def verify_security_code(self, db: Session, uhid: str, code: str) -> Patient:
        """
        Validate the security code printed on a patient's card.

        :param db:   Active database session.
        :param uhid: Patient UHID.
        :param code: Security code to check.
        :return: The :class:`Patient` if the code matches.
        :raises PatientNotFoundError:      If the patient does not exist.
        :raises SecurityCodeMismatchError: If the code does not match.
        """
        patient = self.get_by_uhid(db, uhid)
        if patient.security_code != code:
            raise SecurityCodeMismatchError("Invalid security code.")
        return patient

    # ── Photo upload ──────────────────────────────────────────────────

    def upload_photo(
        self,
        db: Session,
        uhid: str,
        file: UploadFile,
        actor: User,
    ) -> str:
        """
        Validate and save a patient photo, then update the database.

        :param db:    Active database session.
        :param uhid:  UHID of the target patient.
        :param file:  Uploaded image file.
        :param actor: User performing the upload.
        :return: Relative path to the saved photo.
        :raises PatientNotFoundError: If the patient does not exist.
        :raises InvalidPhotoError:    If the file type or size is invalid.
        """
        from app.utils.file_handler import save_photo

        patient = self.get_by_uhid(db, uhid)

        ext = os.path.splitext(file.filename or "")[-1].lower()
        if ext not in PhotoUpload.ALLOWED_EXTENSIONS:
            raise InvalidPhotoError(
                f"File type '{ext}' is not allowed. Use: {PhotoUpload.ALLOWED_EXTENSIONS}"
            )

        photo_path = save_photo(file, uhid)
        patient_repository.update_photo(db, patient, photo_path)
        return photo_path

    # ── Duplicate review ──────────────────────────────────────────────

    def get_duplicate_groups(self, db: Session) -> list[dict]:
        """
        Return groups of patient records that are potential duplicates.

        Uses a single query to fetch all patients and then performs
        in-memory fuzzy matching — O(n²) in the worst case but avoids
        N+1 database queries from the original implementation.

        :param db: Active database session.
        :return: List of dicts with ``patient_uhid`` and ``matches`` keys.
        """
        all_patients = patient_repository.get_all(db)
        groups = []
        seen_uhids: set[str] = set()

        for patient in all_patients:
            if patient.uhid in seen_uhids:
                continue
            matches = check_duplicate(
                db, patient.first_name, patient.last_name, patient.date_of_birth
            )
            # Exclude the patient themselves from their own match list
            matches = [m for m in matches if m["uhid"] != patient.uhid]
            if matches:
                groups.append({"patient_uhid": patient.uhid, "matches": matches})
                seen_uhids.update(m["uhid"] for m in matches)

        return groups


patient_service = PatientService()
