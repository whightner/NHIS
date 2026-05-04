"""HTTP routes for audit history."""

from fastapi import APIRouter, Depends

from app.modules.audit.api.dependencies import get_audit_query_service
from app.modules.audit.api.schemas import AuditLogResponse
from app.modules.audit.application import AuditQueryService
from app.modules.identity.api.dependencies import require_permission
from app.modules.identity.business import Permission, UserAccount

router = APIRouter()


@router.get(
    "/patients/{uhid}",
    response_model=list[AuditLogResponse],
    summary="Get patient audit history",
)
def get_patient_audit_history(
    uhid: str,
    current_account: UserAccount = Depends(
        require_permission(Permission.VIEW_AUDIT_LOGS)
    ),
    service: AuditQueryService = Depends(get_audit_query_service),
):
    """Return audit entries for one patient."""
    return [
        AuditLogResponse.from_audit_log(entry)
        for entry in service.get_patient_history(uhid)
    ]


@router.get(
    "/users/{username}",
    response_model=list[AuditLogResponse],
    summary="Get user audit history",
)
def get_user_audit_history(
    username: str,
    current_account: UserAccount = Depends(
        require_permission(Permission.VIEW_AUDIT_LOGS)
    ),
    service: AuditQueryService = Depends(get_audit_query_service),
):
    """Return audit entries produced by one account."""
    return [
        AuditLogResponse.from_audit_log(entry)
        for entry in service.get_actor_history(username)
    ]
