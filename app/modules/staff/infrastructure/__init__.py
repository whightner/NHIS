"""Infrastructure adapters for staff workflows."""

from app.modules.staff.infrastructure.sqlalchemy_staff_repository import (
    SQLAlchemyStaffMemberRepository,
)

__all__ = ["SQLAlchemyStaffMemberRepository"]
