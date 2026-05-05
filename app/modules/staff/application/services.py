"""Use cases for staff management."""

from app.modules.identity.business import Permission, UserAccount
from app.modules.staff.application.commands import CreateStaffMemberCommand
from app.modules.staff.application.ports import StaffMemberRepository
from app.modules.staff.business import StaffMember
from app.shared.application import DuplicateResource, ResourceNotFound, TransactionManager
from app.shared.business import Gender, Person, ValidationError


class StaffApplicationService:
    """Coordinates staff use cases around StaffMember business objects."""

    def __init__(
        self,
        staff_members: StaffMemberRepository,
        transaction: TransactionManager,
    ) -> None:
        self._staff_members = staff_members
        self._transaction = transaction

    def create_staff_member(
        self,
        command: CreateStaffMemberCommand,
        *,
        actor: UserAccount,
    ) -> StaffMember:
        """Create an internal staff member profile."""
        actor.require(Permission.CREATE_STAFF)
        if self._staff_members.get_by_id(command.id):
            raise DuplicateResource(f"Staff member '{command.id}' already exists.")

        staff_member = StaffMember(
            id=command.id,
            person=self._person_from_command(command),
            user_account_id=command.user_account_id,
            position=command.position,
            department=command.department,
        )
        created = self._staff_members.create(staff_member)
        self._transaction.commit()
        return created

    def get_staff_member(self, staff_id: str, *, actor: UserAccount) -> StaffMember:
        """Return one staff member after permission validation."""
        actor.require(Permission.VIEW_STAFF)
        staff_member = self._staff_members.get_by_id(staff_id)
        if staff_member is None:
            raise ResourceNotFound(f"Staff member '{staff_id}' not found.")
        return staff_member

    def list_staff_members(self, *, actor: UserAccount) -> list[StaffMember]:
        """Return all staff members."""
        actor.require(Permission.VIEW_STAFF)
        return self._staff_members.get_all()

    def deactivate_staff_member(
        self,
        staff_id: str,
        *,
        actor: UserAccount,
    ) -> StaffMember:
        """Deactivate a staff member profile."""
        actor.require(Permission.UPDATE_STAFF)
        staff_member = self.get_staff_member(staff_id, actor=actor)
        staff_member.deactivate()
        updated = self._staff_members.save(staff_member)
        self._transaction.commit()
        return updated

    @staticmethod
    def _person_from_command(command: CreateStaffMemberCommand) -> Person:
        try:
            gender = Gender(command.gender)
        except ValueError as exc:
            raise ValidationError("Gender must be one of MALE, FEMALE, OTHER, UNKNOWN.") from exc

        return Person(
            first_name=command.first_name,
            last_name=command.last_name,
            date_of_birth=command.date_of_birth,
            gender=gender,
            nationality=command.nationality,
            national_id=command.national_id,
            phone_number=command.phone_number,
        )
