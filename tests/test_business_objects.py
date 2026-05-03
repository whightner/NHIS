"""Tests for the new pure business objects."""

from datetime import date

import pytest

from app.modules.audit.business import AuditAction, AuditLog
from app.modules.identity.business import AccountStatus, Permission, UserAccount
from app.modules.patients.business import Patient, PatientCard, VerificationStatus
from app.modules.staff.business import StaffMember, StaffPosition
from app.shared.business import BusinessRuleViolation, Gender, PermissionDenied, Person, Role


def make_person() -> Person:
    return Person(
        first_name="Jean",
        last_name="Dupont",
        date_of_birth=date(1985, 6, 15),
        gender=Gender.MALE,
        nationality="Cameroonian",
    )


def test_patient_approval_flow() -> None:
    patient = Patient(
        uhid="CMR-2026-ABC12345",
        person=make_person(),
        security_code="123456",
    )

    patient.approve()

    assert patient.verification_status == VerificationStatus.APPROVED


def test_patient_reject_requires_pending_or_approved_not_already_rejected() -> None:
    patient = Patient(
        uhid="CMR-2026-ABC12345",
        person=make_person(),
        security_code="123456",
    )

    patient.reject("Invalid documents")

    with pytest.raises(BusinessRuleViolation):
        patient.reject("Still invalid")


def test_patient_card_must_match_patient_uhid() -> None:
    patient = Patient(
        uhid="CMR-2026-ABC12345",
        person=make_person(),
        security_code="123456",
    )
    card = PatientCard.generated(
        uhid="CMR-2026-ABC12345",
        pdf_path="storage/cards/CMR-2026-ABC12345.pdf",
        qr_code_path="storage/qrcodes/CMR-2026-ABC12345.png",
    )

    patient.attach_card(card)

    assert patient.card == card


def test_user_account_permission_check() -> None:
    account = UserAccount(
        id="user-1",
        username="admin",
        password_hash="hashed-password",
        roles={Role.ADMIN},
        status=AccountStatus.ACTIVE,
    )

    account.require(Permission.REGISTER_PATIENT)


def test_user_account_permission_denied() -> None:
    account = UserAccount(
        id="user-2",
        username="auditor",
        password_hash="hashed-password",
        roles={Role.AUDITOR},
        status=AccountStatus.ACTIVE,
    )

    with pytest.raises(PermissionDenied):
        account.require(Permission.REGISTER_PATIENT)


def test_staff_member_wraps_person_and_account() -> None:
    staff = StaffMember(
        id="staff-1",
        person=make_person(),
        user_account_id="user-1",
        position=StaffPosition.NURSE,
    )

    assert staff.is_clinical is True


def test_audit_log_details_are_immutable() -> None:
    audit_log = AuditLog.record(
        actor_id="admin",
        action=AuditAction.REGISTERED_PATIENT,
        entity_type="Patient",
        entity_id="CMR-2026-ABC12345",
        details={"source": "api"},
    )

    with pytest.raises(TypeError):
        audit_log.details["source"] = "cli"
