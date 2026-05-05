"""Pydantic schemas for staff endpoints."""

from __future__ import annotations

from datetime import date

from pydantic import BaseModel

from app.modules.staff.business import StaffMember, StaffPosition


class StaffMemberCreate(BaseModel):
    """Payload for creating a staff member profile."""

    id: str
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    user_account_id: str
    position: StaffPosition
    national_id: str | None = None
    phone_number: str | None = None
    department: str | None = None


class StaffMemberResponse(BaseModel):
    """Public staff member representation."""

    id: str
    first_name: str
    last_name: str
    date_of_birth: date
    gender: str
    nationality: str
    user_account_id: str
    position: str
    national_id: str | None = None
    phone_number: str | None = None
    department: str | None = None
    active: bool

    @classmethod
    def from_staff_member(cls, staff_member: StaffMember) -> "StaffMemberResponse":
        """Build an API response from a StaffMember."""
        return cls(
            id=staff_member.id,
            first_name=staff_member.person.first_name,
            last_name=staff_member.person.last_name,
            date_of_birth=staff_member.person.date_of_birth,
            gender=staff_member.person.gender.value,
            nationality=staff_member.person.nationality,
            national_id=staff_member.person.national_id,
            phone_number=staff_member.person.phone_number,
            user_account_id=staff_member.user_account_id,
            position=staff_member.position.value,
            department=staff_member.department,
            active=staff_member.active,
        )
