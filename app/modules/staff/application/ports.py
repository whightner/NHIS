"""Ports required by staff application services."""

from __future__ import annotations

from typing import Protocol

from app.modules.staff.business import StaffMember


class StaffMemberRepository(Protocol):
    """Persistence contract for staff members."""

    def create(self, staff_member: StaffMember) -> StaffMember:
        """Persist a staff member."""

    def get_by_id(self, staff_id: str) -> StaffMember | None:
        """Return a staff member by id."""

    def get_all(self) -> list[StaffMember]:
        """Return every staff member."""

    def save(self, staff_member: StaffMember) -> StaffMember:
        """Persist staff member changes."""
