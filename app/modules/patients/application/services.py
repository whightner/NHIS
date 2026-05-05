"""Use cases for patient registration and verification workflows."""

from __future__ import annotations

from datetime import date

from rapidfuzz import fuzz

from app.core.constants import DuplicateThresholds
from app.modules.audit.application import AuditRecorder
from app.modules.audit.business import AuditAction
from app.modules.identity.business import Permission, UserAccount
from app.modules.patients.application.commands import (
    PatientRegistrationCommand,
    PhotoUploadCommand,
    RejectPatientCommand,
)
from app.modules.patients.application.dto import (
    DuplicatePatient,
    PatientRegistrationResult,
    PatientStatistics,
)
from app.modules.patients.application.ports import (
    PatientCardGenerator,
    PatientPhotoStorage,
    PatientRepository,
    QrCodeGenerator,
    SecurityCodeGenerator,
    UhidGenerator,
)
from app.modules.patients.business import Patient, PatientCard, VerificationStatus
from app.shared.application import (
    InvalidOperation,
    ResourceNotFound,
    TransactionManager,
    VerificationFailed,
)
from app.shared.business import BusinessRuleViolation, Gender, Person, ValidationError


class PatientApplicationService:
    """Coordinates patient use cases around pure business objects."""

    def __init__(
        self,
        patients: PatientRepository,
        uhids: UhidGenerator,
        security_codes: SecurityCodeGenerator,
        photos: PatientPhotoStorage,
        qr_codes: QrCodeGenerator,
        cards: PatientCardGenerator,
        audit: AuditRecorder,
        transaction: TransactionManager,
    ) -> None:
        self._patients = patients
        self._uhids = uhids
        self._security_codes = security_codes
        self._photos = photos
        self._qr_codes = qr_codes
        self._cards = cards
        self._audit = audit
        self._transaction = transaction

    def register_patient(
        self,
        command: PatientRegistrationCommand,
        *,
        actor: UserAccount,
    ) -> PatientRegistrationResult:
        """Register a patient and return possible duplicates."""
        actor.require(Permission.REGISTER_PATIENT)
        person = self._person_from_registration(command)
        duplicates = self._find_duplicates(
            first_name=person.first_name,
            last_name=person.last_name,
            date_of_birth=person.date_of_birth,
        )
        patient = Patient(
            uhid=self._uhids.generate(),
            person=person,
            security_code=self._security_codes.generate(),
            verification_status=VerificationStatus.PENDING,
        )
        patient = self._patients.create(patient)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.REGISTERED_PATIENT,
            entity_type="Patient",
            entity_id=patient.uhid,
            ip_address=command.ip_address,
        )
        self._transaction.commit()
        return PatientRegistrationResult(
            patient=patient,
            possible_duplicates=duplicates,
        )

    def get_patient(self, uhid: str, *, actor: UserAccount) -> Patient:
        """Return a patient by UHID after permission validation."""
        actor.require(Permission.VIEW_PATIENT)
        return self._get_existing_patient(uhid)

    def search_patients(
        self,
        *,
        actor: UserAccount,
        uhid: str | None = None,
        first_name: str | None = None,
        last_name: str | None = None,
    ) -> list[Patient]:
        """Search patients with optional filters."""
        actor.require(Permission.VIEW_PATIENT)
        return self._patients.search(
            uhid=uhid,
            first_name=first_name,
            last_name=last_name,
        )

    def get_by_status(
        self,
        status: VerificationStatus,
        *,
        actor: UserAccount,
        permission: Permission = Permission.VIEW_PATIENT,
    ) -> list[Patient]:
        """Return patients in a verification status."""
        actor.require(permission)
        return self._patients.get_by_status(status)

    def get_statistics(self, *, actor: UserAccount) -> PatientStatistics:
        """Return patient counts by verification status."""
        actor.require(Permission.VIEW_PATIENT_STATISTICS)
        counts = self._patients.count_by_status()
        return PatientStatistics(
            pending=counts.get(VerificationStatus.PENDING, 0),
            approved=counts.get(VerificationStatus.APPROVED, 0),
            rejected=counts.get(VerificationStatus.REJECTED, 0),
            total=sum(counts.values()),
        )

    def get_duplicate_groups(self, *, actor: UserAccount) -> list[dict]:
        """Return possible duplicate groups for manual review."""
        actor.require(Permission.REVIEW_PATIENT_DUPLICATES)
        groups = []
        seen_uhids: set[str] = set()

        for patient in self._patients.get_all():
            if patient.uhid in seen_uhids:
                continue
            matches = [
                duplicate
                for duplicate in self._find_duplicates(
                    first_name=patient.person.first_name,
                    last_name=patient.person.last_name,
                    date_of_birth=patient.person.date_of_birth,
                )
                if duplicate.uhid != patient.uhid
            ]
            if matches:
                groups.append(
                    {
                        "patient_uhid": patient.uhid,
                        "matches": [duplicate.__dict__ for duplicate in matches],
                    }
                )
                seen_uhids.update(match.uhid for match in matches)

        return groups

    def approve_patient(
        self,
        uhid: str,
        *,
        actor: UserAccount,
        ip_address: str = "unknown",
    ) -> Patient:
        """Approve a pending patient registration."""
        actor.require(Permission.APPROVE_PATIENT)
        patient = self._get_existing_patient(uhid)
        try:
            patient.approve()
        except BusinessRuleViolation as exc:
            raise InvalidOperation(str(exc)) from exc
        patient = self._patients.save(patient)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.APPROVED_PATIENT,
            entity_type="Patient",
            entity_id=patient.uhid,
            ip_address=ip_address,
        )
        self._transaction.commit()
        return patient

    def reject_patient(
        self,
        command: RejectPatientCommand,
        *,
        actor: UserAccount,
    ) -> Patient:
        """Reject a patient registration with a reason."""
        actor.require(Permission.REJECT_PATIENT)
        patient = self._get_existing_patient(command.uhid)
        try:
            patient.reject(command.reason)
        except (BusinessRuleViolation, ValidationError) as exc:
            raise InvalidOperation(str(exc)) from exc
        patient = self._patients.save(patient)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.REJECTED_PATIENT,
            entity_type="Patient",
            entity_id=patient.uhid,
            ip_address=command.ip_address,
            details={"reason": command.reason},
        )
        self._transaction.commit()
        return patient

    def verify_patient(self, uhid: str, *, actor: UserAccount) -> Patient:
        """Verify that a patient exists and is approved."""
        actor.require(Permission.VERIFY_PATIENT)
        patient = self._get_existing_patient(uhid)
        try:
            patient.require_approved()
        except BusinessRuleViolation as exc:
            raise VerificationFailed(str(exc)) from exc
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.VERIFIED_PATIENT,
            entity_type="Patient",
            entity_id=patient.uhid,
        )
        self._transaction.commit()
        return patient

    def verify_security_code(
        self,
        uhid: str,
        security_code: str,
        *,
        actor: UserAccount,
    ) -> Patient:
        """Validate the security code printed on the patient card."""
        actor.require(Permission.VERIFY_PATIENT)
        patient = self._get_existing_patient(uhid)
        try:
            patient.verify_security_code(security_code)
        except BusinessRuleViolation as exc:
            raise VerificationFailed(str(exc)) from exc
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.VERIFIED_SECURITY_CODE,
            entity_type="Patient",
            entity_id=patient.uhid,
        )
        self._transaction.commit()
        return patient

    def upload_photo(
        self,
        command: PhotoUploadCommand,
        *,
        actor: UserAccount,
    ) -> str:
        """Save a patient photo and update the patient record."""
        actor.require(Permission.UPLOAD_PATIENT_PHOTO)
        patient = self._get_existing_patient(command.uhid)
        photo_path = self._photos.save(command.photo, patient.uhid)
        patient.update_photo(photo_path)
        self._patients.save(patient)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.UPLOADED_PATIENT_PHOTO,
            entity_type="Patient",
            entity_id=patient.uhid,
        )
        self._transaction.commit()
        return photo_path

    def generate_qr_code(self, uhid: str) -> str:
        """Generate a QR code for a patient UHID."""
        return self._qr_codes.generate(uhid)

    def generate_card(
        self,
        uhid: str,
        *,
        actor: UserAccount,
    ) -> PatientCard:
        """Generate a patient card after permission validation."""
        actor.require(Permission.GENERATE_PATIENT_CARD)
        patient = self._get_existing_patient(uhid)
        card = self.generate_card_for_patient(patient)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.GENERATED_PATIENT_CARD,
            entity_type="Patient",
            entity_id=patient.uhid,
        )
        self._transaction.commit()
        return card

    def reprint_card(self, uhid: str, *, actor: UserAccount) -> PatientCard:
        """Generate a new copy of an existing patient card."""
        actor.require(Permission.GENERATE_PATIENT_CARD)
        patient = self._get_existing_patient(uhid)
        card = self.generate_card_for_patient(patient)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.REPRINTED_PATIENT_CARD,
            entity_type="Patient",
            entity_id=patient.uhid,
        )
        self._transaction.commit()
        return card

    def generate_card_for_patient(self, patient: Patient) -> PatientCard:
        """Generate card artifacts for an already-loaded patient."""
        card = self._cards.generate(patient)
        patient.attach_card(card)
        self._patients.save(patient)
        return card

    def _get_existing_patient(self, uhid: str) -> Patient:
        patient = self._patients.get_by_uhid(uhid)
        if patient is None:
            raise ResourceNotFound(f"Patient '{uhid}' not found.")
        return patient

    def _find_duplicates(
        self,
        *,
        first_name: str,
        last_name: str,
        date_of_birth: date,
    ) -> list[DuplicatePatient]:
        duplicates: list[DuplicatePatient] = []
        for candidate in self._patients.find_by_birth_date(date_of_birth):
            first_score = fuzz.ratio(first_name.lower(), candidate.person.first_name.lower())
            last_score = fuzz.ratio(last_name.lower(), candidate.person.last_name.lower())
            if (
                first_score >= DuplicateThresholds.FIRST_NAME_MIN
                and last_score >= DuplicateThresholds.LAST_NAME_MIN
            ):
                duplicates.append(
                    DuplicatePatient(
                        uhid=candidate.uhid,
                        first_name=candidate.person.first_name,
                        last_name=candidate.person.last_name,
                        score=round((first_score + last_score) / 2, 2),
                    )
                )
        return duplicates

    @staticmethod
    def _person_from_registration(command: PatientRegistrationCommand) -> Person:
        try:
            gender = Gender(command.gender)
        except ValueError as exc:
            raise ValidationError("Gender must be one of MALE, FEMALE, OTHER, UNKNOWN.") from exc

        return Person(
            first_name=command.first_name,
            last_name=command.last_name,
            date_of_birth=command.date_of_birth,
            gender=gender,
            nationality=command.nationality,
            national_id=command.national_id,
            phone_number=command.phone_number,
        )
