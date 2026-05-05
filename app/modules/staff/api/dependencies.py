"""FastAPI dependencies for staff endpoints."""

from fastapi import Depends
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.modules.staff.application import StaffApplicationService
from app.modules.staff.infrastructure import SQLAlchemyStaffMemberRepository
from app.shared.infrastructure import SQLAlchemyTransactionManager


def get_staff_service(db: Session = Depends(get_db)) -> StaffApplicationService:
    """Build the staff application service for one request."""
    return StaffApplicationService(
        staff_members=SQLAlchemyStaffMemberRepository(db),
        transaction=SQLAlchemyTransactionManager(db),
    )
