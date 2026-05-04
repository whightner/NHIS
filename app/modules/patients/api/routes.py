"""HTTP routes for patient registration and verification."""

from __future__ import annotations

import logging
import os

from fastapi import (
    APIRouter,
    BackgroundTasks,
    Depends,
    File,
    HTTPException,
    Query,
    Request,
    UploadFile,
    status,
)
from fastapi.responses import FileResponse

from app.core.constants import StoragePaths
from app.modules.identity.api.dependencies import get_current_account, require_permission
from app.modules.identity.business import Permission, UserAccount
from app.modules.patients.api.dependencies import get_patient_service
from app.modules.patients.api.schemas import (
    PatientCreate,
    PatientRegisterResponse,
    PatientResponse,
    PatientStatisticsResponse,
    VerifyPatientResponse,
)
from app.modules.patients.application import (
    PatientApplicationService,
    PatientRegistrationCommand,
    PhotoUpload,
    PhotoUploadCommand,
    RejectPatientCommand,
)
from app.modules.patients.business import Patient, VerificationStatus
from app.modules.patients.infrastructure import (
    ReportLabPatientCardGenerator,
    SettingsQrCodeGenerator,
)
from app.shared.api import to_http_exception

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/stats",
    response_model=PatientStatisticsResponse,
    summary="Patient registration statistics",
)
def get_patient_statistics(
    current_account: UserAccount = Depends(
        require_permission(Permission.VIEW_PATIENT_STATISTICS)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Return patient counts by verification status."""
    try:
        return PatientStatisticsResponse.from_statistics(
            service.get_statistics(actor=current_account)
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc


@router.get("/duplicates", summary="Duplicate patient review queue")
def get_duplicate_patients(
    current_account: UserAccount = Depends(
        require_permission(Permission.REVIEW_PATIENT_DUPLICATES)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Return possible duplicate patient groups."""
    try:
        return service.get_duplicate_groups(actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc


@router.get(
    "/pending",
    response_model=list[PatientResponse],
    summary="List pending patients",
)
def get_pending_patients(
    current_account: UserAccount = Depends(get_current_account),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Return all pending patient registrations."""
    try:
        patients = service.get_by_status(
            VerificationStatus.PENDING,
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return [PatientResponse.from_patient(patient) for patient in patients]


@router.get(
    "/approved",
    response_model=list[PatientResponse],
    summary="List approved patients",
)
def get_approved_patients(
    current_account: UserAccount = Depends(
        require_permission(Permission.LIST_REVIEWED_PATIENTS)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Return all approved patients."""
    try:
        patients = service.get_by_status(
            VerificationStatus.APPROVED,
            actor=current_account,
            permission=Permission.LIST_REVIEWED_PATIENTS,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return [PatientResponse.from_patient(patient) for patient in patients]


@router.get(
    "/rejected",
    response_model=list[PatientResponse],
    summary="List rejected patients",
)
def get_rejected_patients(
    current_account: UserAccount = Depends(
        require_permission(Permission.LIST_REVIEWED_PATIENTS)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Return all rejected patients."""
    try:
        patients = service.get_by_status(
            VerificationStatus.REJECTED,
            actor=current_account,
            permission=Permission.LIST_REVIEWED_PATIENTS,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return [PatientResponse.from_patient(patient) for patient in patients]


@router.get("/", response_model=list[PatientResponse], summary="Search patients")
def search_patients(
    uhid: str | None = Query(None),
    first_name: str | None = Query(None),
    last_name: str | None = Query(None),
    current_account: UserAccount = Depends(
        require_permission(Permission.VIEW_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Search patients with optional filters."""
    try:
        patients = service.search_patients(
            actor=current_account,
            uhid=uhid,
            first_name=first_name,
            last_name=last_name,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return [PatientResponse.from_patient(patient) for patient in patients]


@router.post(
    "/",
    response_model=PatientRegisterResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new patient",
)
def register_patient(
    patient: PatientCreate,
    request: Request,
    background_tasks: BackgroundTasks,
    current_account: UserAccount = Depends(
        require_permission(Permission.REGISTER_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Register a patient and enqueue card artifact generation."""
    ip_address = request.client.host if request.client else "unknown"
    try:
        result = service.register_patient(
            PatientRegistrationCommand(
                first_name=patient.first_name,
                last_name=patient.last_name,
                date_of_birth=patient.date_of_birth,
                gender=patient.gender,
                nationality=patient.nationality,
                national_id=patient.national_id,
                phone_number=patient.phone_number,
                ip_address=ip_address,
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc

    background_tasks.add_task(_generate_qr_background, result.patient.uhid)
    background_tasks.add_task(_generate_card_background, result.patient)

    return PatientRegisterResponse(
        patient=PatientResponse.from_patient(result.patient),
        possible_duplicates=[
            duplicate.__dict__ for duplicate in result.possible_duplicates
        ],
    )


@router.get("/{uhid}", response_model=PatientResponse, summary="Get patient by UHID")
def get_patient_by_uhid(
    uhid: str,
    current_account: UserAccount = Depends(
        require_permission(Permission.VIEW_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Retrieve a patient by UHID."""
    try:
        patient = service.get_patient(uhid, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return PatientResponse.from_patient(patient)


@router.post("/{uhid}/photo", summary="Upload patient photo")
def upload_patient_photo(
    uhid: str,
    file: UploadFile = File(...),
    current_account: UserAccount = Depends(
        require_permission(Permission.UPLOAD_PATIENT_PHOTO)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Upload or replace a patient photo."""
    try:
        photo_path = service.upload_photo(
            PhotoUploadCommand(
                uhid=uhid,
                photo=PhotoUpload(
                    filename=file.filename or "",
                    stream=file.file,
                ),
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return {"message": "Photo uploaded successfully.", "photo_path": photo_path}


@router.post("/{uhid}/card", summary="Generate patient ID card")
def generate_patient_card(
    uhid: str,
    background_tasks: BackgroundTasks,
    current_account: UserAccount = Depends(
        require_permission(Permission.GENERATE_PATIENT_CARD)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Queue card and QR generation for a patient."""
    try:
        patient = service.get_patient(uhid, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc

    background_tasks.add_task(_generate_qr_background, patient.uhid)
    background_tasks.add_task(_generate_card_background, patient)
    return {"message": "Card generation queued.", "uhid": uhid}


@router.post("/{uhid}/reprint", summary="Reprint patient card")
def reprint_patient_card(
    uhid: str,
    background_tasks: BackgroundTasks,
    current_account: UserAccount = Depends(
        require_permission(Permission.GENERATE_PATIENT_CARD)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Queue a patient card reprint."""
    try:
        patient = service.get_patient(uhid, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc

    background_tasks.add_task(_generate_card_background, patient)
    return {"message": "Card reprint queued.", "uhid": uhid}


@router.get("/{uhid}/card/download", summary="Download patient card PDF")
def download_patient_card(
    uhid: str,
    current_account: UserAccount = Depends(
        require_permission(Permission.GENERATE_PATIENT_CARD)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Download a generated patient card PDF."""
    try:
        service.get_patient(uhid, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc

    card_path = os.path.join(StoragePaths.CARDS, f"{uhid}.pdf")
    if not os.path.exists(card_path):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Card not yet generated.",
        )
    return FileResponse(
        card_path,
        media_type="application/pdf",
        filename=f"{uhid}_card.pdf",
    )


@router.post("/{uhid}/approve", summary="Approve patient")
def approve_patient(
    uhid: str,
    request: Request,
    current_account: UserAccount = Depends(
        require_permission(Permission.APPROVE_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Approve a pending patient registration."""
    ip_address = request.client.host if request.client else "unknown"
    try:
        service.approve_patient(
            uhid,
            actor=current_account,
            ip_address=ip_address,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return {"message": "Patient approved successfully."}


@router.post("/{uhid}/reject", summary="Reject patient")
def reject_patient(
    uhid: str,
    request: Request,
    reason: str = Query(..., description="Reason for rejection"),
    current_account: UserAccount = Depends(
        require_permission(Permission.REJECT_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Reject a patient registration."""
    ip_address = request.client.host if request.client else "unknown"
    try:
        service.reject_patient(
            RejectPatientCommand(
                uhid=uhid,
                reason=reason,
                ip_address=ip_address,
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return {"message": "Patient rejected.", "reason": reason}


@router.get(
    "/verify/{uhid}",
    response_model=VerifyPatientResponse,
    summary="Verify patient identity",
)
def verify_patient(
    uhid: str,
    current_account: UserAccount = Depends(
        require_permission(Permission.VERIFY_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Verify that a patient exists and is approved."""
    try:
        patient = service.verify_patient(uhid, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return {
        "status": "VALID",
        "uhid": patient.uhid,
        "first_name": patient.person.first_name,
        "last_name": patient.person.last_name,
        "date_of_birth": patient.person.date_of_birth,
        "gender": patient.person.gender.value,
        "nationality": patient.person.nationality,
    }


@router.post("/verify-security/{uhid}", summary="Verify card security code")
def verify_security_code(
    uhid: str,
    security_code: str = Query(...),
    current_account: UserAccount = Depends(
        require_permission(Permission.VERIFY_PATIENT)
    ),
    service: PatientApplicationService = Depends(get_patient_service),
):
    """Validate the security code printed on a patient card."""
    try:
        patient = service.verify_security_code(
            uhid,
            security_code,
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return {"status": "SECURITY VERIFIED", "uhid": patient.uhid}


def _generate_qr_background(uhid: str) -> None:
    """Background task for QR generation."""
    try:
        SettingsQrCodeGenerator().generate(uhid)
        logger.info("QR generated for %s", uhid)
    except Exception as exc:
        logger.error("QR generation failed for %s: %s", uhid, exc)


def _generate_card_background(patient: Patient) -> None:
    """Background task for card generation."""
    try:
        ReportLabPatientCardGenerator().generate(patient)
        logger.info("Card generated for %s", patient.uhid)
    except Exception as exc:
        logger.error("Card generation failed for %s: %s", patient.uhid, exc)
