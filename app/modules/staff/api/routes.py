"""HTTP routes for staff management."""

from fastapi import APIRouter, Depends, status

from app.modules.identity.api.dependencies import require_permission
from app.modules.identity.business import Permission, UserAccount
from app.modules.staff.api.dependencies import get_staff_service
from app.modules.staff.api.schemas import StaffMemberCreate, StaffMemberResponse
from app.modules.staff.application import CreateStaffMemberCommand, StaffApplicationService
from app.shared.api import to_http_exception

router = APIRouter()


@router.post(
    "/",
    response_model=StaffMemberResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create staff member",
)
def create_staff_member(
    payload: StaffMemberCreate,
    current_account: UserAccount = Depends(require_permission(Permission.CREATE_STAFF)),
    service: StaffApplicationService = Depends(get_staff_service),
):
    """Create an internal staff member profile."""
    try:
        staff_member = service.create_staff_member(
            CreateStaffMemberCommand(
                id=payload.id,
                first_name=payload.first_name,
                last_name=payload.last_name,
                date_of_birth=payload.date_of_birth,
                gender=payload.gender,
                nationality=payload.nationality,
                national_id=payload.national_id,
                phone_number=payload.phone_number,
                user_account_id=payload.user_account_id,
                position=payload.position,
                department=payload.department,
            ),
            actor=current_account,
        )
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return StaffMemberResponse.from_staff_member(staff_member)


@router.get("/", response_model=list[StaffMemberResponse], summary="List staff members")
def list_staff_members(
    current_account: UserAccount = Depends(require_permission(Permission.VIEW_STAFF)),
    service: StaffApplicationService = Depends(get_staff_service),
):
    """Return all staff member profiles."""
    try:
        staff_members = service.list_staff_members(actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return [
        StaffMemberResponse.from_staff_member(staff_member)
        for staff_member in staff_members
    ]


@router.get(
    "/{staff_id}",
    response_model=StaffMemberResponse,
    summary="Get staff member",
)
def get_staff_member(
    staff_id: str,
    current_account: UserAccount = Depends(require_permission(Permission.VIEW_STAFF)),
    service: StaffApplicationService = Depends(get_staff_service),
):
    """Return one staff member profile."""
    try:
        staff_member = service.get_staff_member(staff_id, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return StaffMemberResponse.from_staff_member(staff_member)


@router.post(
    "/{staff_id}/deactivate",
    response_model=StaffMemberResponse,
    summary="Deactivate staff member",
)
def deactivate_staff_member(
    staff_id: str,
    current_account: UserAccount = Depends(require_permission(Permission.UPDATE_STAFF)),
    service: StaffApplicationService = Depends(get_staff_service),
):
    """Deactivate a staff member profile."""
    try:
        staff_member = service.deactivate_staff_member(staff_id, actor=current_account)
    except Exception as exc:
        raise to_http_exception(exc) from exc
    return StaffMemberResponse.from_staff_member(staff_member)
