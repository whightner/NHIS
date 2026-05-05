"""Command objects accepted by staff use cases."""

from dataclasses import dataclass
from datetime import date

from app.modules.staff.business import StaffPosition


@dataclass(frozen=True)
class CreateStaffMemberCommand:
    """Data required to register an internal staff member."""

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
