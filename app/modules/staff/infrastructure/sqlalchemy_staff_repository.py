"""SQLAlchemy adapter for staff persistence."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.modules.staff.business import StaffMember, StaffPosition
from app.modules.staff.infrastructure.models import StaffMember as StaffMemberRow
from app.shared.business import Gender, Person


class SQLAlchemyStaffMemberRepository:
    """Maps the staff_members table to StaffMember business objects."""

    def __init__(self, db: Session) -> None:
        self._db = db

    def create(self, staff_member: StaffMember) -> StaffMember:
        """Persist a staff member."""
        row = StaffMemberRow(
            id=staff_member.id,
            user_account_id=staff_member.user_account_id,
            first_name=staff_member.person.first_name,
            last_name=staff_member.person.last_name,
            date_of_birth=staff_member.person.date_of_birth,
            gender=staff_member.person.gender.value,
            nationality=staff_member.person.nationality,
            national_id=staff_member.person.national_id,
            phone_number=staff_member.person.phone_number,
            position=staff_member.position.value,
            department=staff_member.department,
            active=staff_member.active,
        )
        self._db.add(row)
        self._db.flush()
        self._db.refresh(row)
        return self._to_business(row)

    def get_by_id(self, staff_id: str) -> StaffMember | None:
        """Return a staff member by id."""
        row = (
            self._db.query(StaffMemberRow)
            .filter(StaffMemberRow.id == staff_id)
            .first()
        )
        return self._to_business(row) if row else None

    def get_all(self) -> list[StaffMember]:
        """Return every staff member."""
        return [self._to_business(row) for row in self._db.query(StaffMemberRow).all()]

    def save(self, staff_member: StaffMember) -> StaffMember:
        """Persist staff member changes."""
        row = self._get_row(staff_member.id)
        row.user_account_id = staff_member.user_account_id
        row.first_name = staff_member.person.first_name
        row.last_name = staff_member.person.last_name
        row.date_of_birth = staff_member.person.date_of_birth
        row.gender = staff_member.person.gender.value
        row.nationality = staff_member.person.nationality
        row.national_id = staff_member.person.national_id
        row.phone_number = staff_member.person.phone_number
        row.position = staff_member.position.value
        row.department = staff_member.department
        row.active = staff_member.active
        self._db.flush()
        self._db.refresh(row)
        return self._to_business(row)

    def _get_row(self, staff_id: str) -> StaffMemberRow:
        row = self._db.query(StaffMemberRow).filter(StaffMemberRow.id == staff_id).first()
        if row is None:
            raise LookupError(f"Staff member '{staff_id}' not found.")
        return row

    @staticmethod
    def _to_business(row: StaffMemberRow) -> StaffMember:
        return StaffMember(
            id=row.id,
            person=Person(
                first_name=row.first_name,
                last_name=row.last_name,
                date_of_birth=row.date_of_birth,
                gender=Gender(row.gender),
                nationality=row.nationality,
                national_id=row.national_id,
                phone_number=row.phone_number,
            ),
            user_account_id=row.user_account_id,
            position=StaffPosition(row.position),
            department=row.department,
            active=row.active,
        )
