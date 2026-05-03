"""
app/modules/patient/patient_routes.py
---------------------------------------
HTTP route handlers for patient management.

**Routing order is intentional**: static paths (``/stats``, ``/pending``,
``/duplicates``, etc.) are declared *before* the dynamic ``/{uhid}`` handler
to prevent FastAPI from matching them as UHID values — a bug present in
the original codebase.

This layer only handles HTTP: parsing inputs, calling the service, and
translating domain exceptions into HTTP status codes.
"""

import logging
import os
from typing import List, Optional

from fastapi import (
    APIRouter,
    BackgroundTasks,
    Depends,
    HTTPException,
    Query,
    Request,
    UploadFile,
    File,
    status,
)
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.core.constants import Roles, StoragePaths, VerificationStatus
from app.core.exceptions import (
    AuthorizationError,
    CardNotFoundError,
    InvalidPhotoError,
    InvalidVerificationStatusError,
    PatientNotApprovedError,
    PatientNotFoundError,
    SecurityCodeMismatchError,
)
from app.database.database import get_db
from app.modules.patient.patient_schema import (
    PatientCreate,
    PatientRegisterResponse,
    PatientResponse,
    PatientStatistics,
    VerifyPatientResponse,
)
from app.modules.patient.patient_service import patient_service
from app.modules.user.user_model import User
from app.modules.user.user_routes import get_current_user, require_role

logger = logging.getLogger(__name__)

router = APIRouter()


# ════════════════════════════════════════════════════════════════════════
# STATIC ROUTES  (must come before /{uhid} to avoid route conflicts)
# ════════════════════════════════════════════════════════════════════════

@router.get("/stats", response_model=PatientStatistics, summary="Patient registration statistics")
def get_patient_statistics(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER])),
):
    """
    Return aggregate patient counts by verification status.

    :param db:           Active database session.
    :param current_user: Must be ADMIN or VERIFIER.
    :return: :class:`PatientStatistics` response.
    """
    return patient_service.get_statistics(db)


@router.get("/duplicates", summary="Duplicate patient review queue")
def get_duplicate_patients(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER])),
):
    """
    Return groups of patient records that are potential duplicates.

    :param db:           Active database session.
    :param current_user: Must be ADMIN or VERIFIER.
    :return: List of ``{patient_uhid, matches}`` dicts.
    """
    return patient_service.get_duplicate_groups(db)


@router.get("/pending", response_model=List[PatientResponse], summary="List pending patients")
def get_pending_patients(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Return all patients with PENDING verification status.

    :param db:           Active database session.
    :param current_user: Any authenticated user.
    :return: List of :class:`PatientResponse`.
    """
    return patient_service.get_by_status(db, VerificationStatus.PENDING)


@router.get("/approved", response_model=List[PatientResponse], summary="List approved patients")
def get_approved_patients(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER])),
):
    """
    Return all patients with APPROVED verification status.

    :param db:           Active database session.
    :param current_user: Must be ADMIN or VERIFIER.
    :return: List of :class:`PatientResponse`.
    """
    return patient_service.get_by_status(db, VerificationStatus.APPROVED)


@router.get("/rejected", response_model=List[PatientResponse], summary="List rejected patients")
def get_rejected_patients(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER])),
):
    """
    Return all patients with REJECTED verification status.

    :param db:           Active database session.
    :param current_user: Must be ADMIN or VERIFIER.
    :return: List of :class:`PatientResponse`.
    """
    return patient_service.get_by_status(db, VerificationStatus.REJECTED)


# ════════════════════════════════════════════════════════════════════════
# SEARCH & LIST
# ════════════════════════════════════════════════════════════════════════

@router.get("/", response_model=List[PatientResponse], summary="Search patients")
def search_patients(
    uhid: Optional[str] = Query(None),
    first_name: Optional[str] = Query(None),
    last_name: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Search patients with optional filters (all parameters optional).

    :param uhid:         Exact UHID match.
    :param first_name:   Case-insensitive partial first-name match.
    :param last_name:    Case-insensitive partial last-name match.
    :param db:           Active database session.
    :param current_user: Any authenticated user.
    :return: List of :class:`PatientResponse`.
    """
    return patient_service.search(db, uhid=uhid, first_name=first_name, last_name=last_name)


# ════════════════════════════════════════════════════════════════════════
# REGISTER
# ════════════════════════════════════════════════════════════════════════

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
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.OPERATOR])),
):
    """
    Register a new patient and automatically enqueue QR and card generation
    as background tasks.

    :param patient:      Patient registration payload.
    :param request:      FastAPI request (for client IP extraction).
    :param background_tasks: FastAPI background task queue.
    :param db:           Active database session.
    :param current_user: Must be ADMIN or OPERATOR.
    :return: :class:`PatientRegisterResponse` with the new patient and duplicate list.
    :raises HTTPException 403: If the actor lacks the required role.
    """
    ip = request.client.host if request.client else "unknown"
    try:
        result = patient_service.register_patient(
            db=db,
            first_name=patient.first_name,
            last_name=patient.last_name,
            date_of_birth=patient.date_of_birth,
            gender=patient.gender,
            nationality=patient.nationality,
            national_id=patient.national_id,
            phone_number=patient.phone_number,
            actor=current_user,
            ip_address=ip,
        )
    except AuthorizationError as exc:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=exc.message)

    # Enqueue background generation tasks — non-blocking
    new_patient = result["patient"]
    background_tasks.add_task(_generate_qr_background, new_patient.uhid)
    background_tasks.add_task(_generate_card_background, new_patient)

    return result


# ════════════════════════════════════════════════════════════════════════
# DYNAMIC ROUTES  /{uhid}  — must come AFTER all static routes
# ════════════════════════════════════════════════════════════════════════

@router.get("/{uhid}", response_model=PatientResponse, summary="Get patient by UHID")
def get_patient_by_uhid(
    uhid: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve a single patient record by UHID.

    :param uhid:         Patient UHID.
    :param db:           Active database session.
    :param current_user: Any authenticated user.
    :return: :class:`PatientResponse`.
    :raises HTTPException 404: If the patient does not exist.
    """
    try:
        return patient_service.get_by_uhid(db, uhid)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)


@router.post("/{uhid}/photo", summary="Upload patient photo")
def upload_patient_photo(
    uhid: str,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.OPERATOR])),
):
    """
    Upload or replace the photo for a patient.

    :param uhid:         Patient UHID.
    :param file:         Image file (JPEG or PNG, max 5 MB).
    :param db:           Active database session.
    :param current_user: Must be ADMIN or OPERATOR.
    :return: Success message and saved photo path.
    :raises HTTPException 404: If the patient does not exist.
    :raises HTTPException 422: If the file type is invalid.
    """
    try:
        photo_path = patient_service.upload_photo(db, uhid, file, actor=current_user)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)
    except InvalidPhotoError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=exc.message)
    return {"message": "Photo uploaded successfully.", "photo_path": photo_path}


@router.post("/{uhid}/card", summary="Generate patient ID card (background)")
def generate_patient_card(
    uhid: str,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.OPERATOR])),
):
    """
    Trigger background generation of the patient's ID card and QR code.

    :param uhid:             Patient UHID.
    :param background_tasks: FastAPI background task queue.
    :param db:               Active database session.
    :param current_user:     Must be ADMIN or OPERATOR.
    :return: Acknowledgement message.
    :raises HTTPException 404: If the patient does not exist.
    """
    try:
        patient = patient_service.get_by_uhid(db, uhid)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)

    background_tasks.add_task(_generate_qr_background, patient.uhid)
    background_tasks.add_task(_generate_card_background, patient)
    return {"message": "Card generation queued.", "uhid": uhid}


@router.post("/{uhid}/reprint", summary="Reprint patient card (background)")
def reprint_patient_card(
    uhid: str,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Re-queue generation of the patient card (reprint request).

    :param uhid:             Patient UHID.
    :param background_tasks: FastAPI background task queue.
    :param db:               Active database session.
    :param current_user:     Any authenticated user.
    :return: Acknowledgement message.
    :raises HTTPException 404: If the patient does not exist.
    """
    try:
        patient = patient_service.get_by_uhid(db, uhid)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)

    background_tasks.add_task(_generate_card_background, patient)
    return {"message": "Card reprint queued.", "uhid": uhid}


@router.get("/{uhid}/card/download", summary="Download patient card PDF")
def download_patient_card(
    uhid: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.OPERATOR])),
):
    """
    Download the generated PDF card for a patient.

    :param uhid:         Patient UHID.
    :param db:           Active database session.
    :param current_user: Must be ADMIN or OPERATOR.
    :return: PDF file as a downloadable :class:`FileResponse`.
    :raises HTTPException 404: If the patient or card file does not exist.
    """
    try:
        patient_service.get_by_uhid(db, uhid)  # Validate patient exists
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)

    card_path = os.path.join(StoragePaths.CARDS, f"{uhid}.pdf")
    if not os.path.exists(card_path):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Card not yet generated.")

    return FileResponse(card_path, media_type="application/pdf", filename=f"{uhid}_card.pdf")


@router.post("/{uhid}/approve", summary="Approve patient (VERIFIER/ADMIN)")
def approve_patient(
    uhid: str,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER])),
):
    """
    Approve a pending patient registration.

    :param uhid:         Patient UHID.
    :param request:      FastAPI request (for client IP).
    :param db:           Active database session.
    :param current_user: Must be ADMIN or VERIFIER.
    :return: Success message.
    :raises HTTPException 404: If the patient does not exist.
    :raises HTTPException 422: If the patient is not in PENDING status.
    """
    ip = request.client.host if request.client else "unknown"
    try:
        patient_service.approve_patient(db, uhid, actor=current_user, ip_address=ip)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)
    except InvalidVerificationStatusError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=exc.message)
    return {"message": "Patient approved successfully."}


@router.post("/{uhid}/reject", summary="Reject patient (VERIFIER/ADMIN)")
def reject_patient(
    uhid: str,
    request: Request,
    reason: str = Query(..., description="Reason for rejection"),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER])),
):
    """
    Reject a patient registration with a mandatory reason.

    :param uhid:         Patient UHID.
    :param request:      FastAPI request (for client IP).
    :param reason:       Human-readable rejection reason.
    :param db:           Active database session.
    :param current_user: Must be ADMIN or VERIFIER.
    :return: Success message and reason.
    :raises HTTPException 404: If the patient does not exist.
    :raises HTTPException 422: If the patient is already rejected.
    """
    ip = request.client.host if request.client else "unknown"
    try:
        patient_service.reject_patient(db, uhid, reason, actor=current_user, ip_address=ip)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)
    except InvalidVerificationStatusError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=exc.message)
    return {"message": "Patient rejected.", "reason": reason}


# ════════════════════════════════════════════════════════════════════════
# VERIFICATION ENDPOINTS
# ════════════════════════════════════════════════════════════════════════

@router.get("/verify/{uhid}", response_model=VerifyPatientResponse, summary="Verify patient identity")
def verify_patient(
    uhid: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER, Roles.OPERATOR])),
):
    """
    Verify a patient's identity (they must be APPROVED).

    :param uhid:         Patient UHID to verify.
    :param db:           Active database session.
    :param current_user: Must be ADMIN, VERIFIER, or OPERATOR.
    :return: :class:`VerifyPatientResponse` if valid.
    :raises HTTPException 404: If the patient does not exist.
    :raises HTTPException 403: If the patient is not APPROVED.
    """
    try:
        patient = patient_service.verify_patient(db, uhid)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)
    except PatientNotApprovedError as exc:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=exc.message)

    return {
        "status": "VALID",
        "uhid": patient.uhid,
        "first_name": patient.first_name,
        "last_name": patient.last_name,
        "date_of_birth": patient.date_of_birth,
        "gender": patient.gender,
        "nationality": patient.nationality,
    }


@router.post("/verify-security/{uhid}", summary="Verify card security code")
def verify_security_code(
    uhid: str,
    security_code: str = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([Roles.ADMIN, Roles.VERIFIER, Roles.OPERATOR])),
):
    """
    Validate the security code printed on a patient's physical card.

    :param uhid:          Patient UHID.
    :param security_code: Security code to validate.
    :param db:            Active database session.
    :param current_user:  Must be ADMIN, VERIFIER, or OPERATOR.
    :return: Verification result.
    :raises HTTPException 404: If the patient does not exist.
    :raises HTTPException 403: If the code is incorrect.
    """
    try:
        patient = patient_service.verify_security_code(db, uhid, security_code)
    except PatientNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=exc.message)
    except SecurityCodeMismatchError as exc:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=exc.message)

    return {"status": "SECURITY VERIFIED", "uhid": patient.uhid}


# ════════════════════════════════════════════════════════════════════════
# BACKGROUND TASK HELPERS
# ════════════════════════════════════════════════════════════════════════

def _generate_qr_background(uhid: str) -> None:
    """
    Background task: generate the QR code image for a patient.

    :param uhid: Patient UHID.
    :return: None
    """
    try:
        from app.utils.qr_code_generator import generate_qr_code
        generate_qr_code(uhid)
        logger.info("QR generated for %s", uhid)
    except Exception as exc:
        logger.error("QR generation failed for %s: %s", uhid, exc)


def _generate_card_background(patient) -> None:
    """
    Background task: generate the PDF card for a patient.

    :param patient: :class:`Patient` model instance.
    :return: None
    """
    try:
        from app.utils.patient_card_generator import generate_card
        generate_card(patient)
        logger.info("Card generated for %s", patient.uhid)
    except Exception as exc:
        logger.error("Card generation failed for %s: %s", patient.uhid, exc)
