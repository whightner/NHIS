"""Use cases for authentication and user account management."""

from __future__ import annotations

from dataclasses import dataclass

from app.modules.audit.application import AuditRecorder
from app.modules.audit.business import AuditAction
from app.modules.identity.application.commands import (
    ChangePasswordCommand,
    CreateUserCommand,
    LoginCommand,
    UpdateUserStatusCommand,
)
from app.modules.identity.application.ports import (
    PasswordHasher,
    TokenIssuer,
    UserAccountRepository,
)
from app.modules.identity.business import AccountStatus, Permission, UserAccount
from app.shared.application import (
    AuthenticationFailed,
    DuplicateResource,
    ResourceNotFound,
)
from app.shared.business import BusinessRuleViolation, Role, ValidationError


@dataclass(frozen=True)
class TokenResult:
    """Authentication token returned by the login use case."""

    access_token: str
    token_type: str = "bearer"


class IdentityService:
    """Coordinates account use cases without depending on HTTP or SQLAlchemy."""

    def __init__(
        self,
        users: UserAccountRepository,
        passwords: PasswordHasher,
        tokens: TokenIssuer,
        audit: AuditRecorder,
    ) -> None:
        self._users = users
        self._passwords = passwords
        self._tokens = tokens
        self._audit = audit

    def login(self, command: LoginCommand) -> TokenResult:
        """Authenticate an account and return a bearer token."""
        account = self._users.get_by_username(command.username)
        if account is None:
            self._audit.record(
                actor_id=command.username,
                action=AuditAction.LOGIN_FAILED,
                ip_address=command.ip_address,
            )
            raise AuthenticationFailed("Invalid username or password.")

        if not self._passwords.verify(command.password, account.password_hash):
            self._audit.record(
                actor_id=command.username,
                action=AuditAction.LOGIN_FAILED,
                ip_address=command.ip_address,
            )
            raise AuthenticationFailed("Invalid username or password.")

        try:
            account.ensure_active()
        except BusinessRuleViolation as exc:
            raise AuthenticationFailed("Account is inactive or locked.") from exc

        token = self._tokens.issue_access_token(account)
        self._audit.record(
            actor_id=account.username,
            action=AuditAction.LOGIN_SUCCESS,
            ip_address=command.ip_address,
        )
        return TokenResult(access_token=token)

    def create_user(
        self,
        command: CreateUserCommand,
        *,
        actor: UserAccount,
    ) -> UserAccount:
        """Create a new account after checking business permission."""
        actor.require(Permission.CREATE_USER)
        self._validate_username(command.username)
        self._validate_password(command.password)

        if self._users.get_by_username(command.username):
            raise DuplicateResource(f"Username '{command.username}' is already taken.")

        account = self._users.create(
            username=command.username,
            password_hash=self._passwords.hash(command.password),
            role=command.role,
            status=AccountStatus.ACTIVE,
        )
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.CREATED_USER,
            entity_type="UserAccount",
            entity_id=account.username,
            details={"role": command.role.value},
        )
        return account

    def get_by_username(self, username: str) -> UserAccount:
        """Return an account or raise a use-case not-found error."""
        account = self._users.get_by_username(username)
        if account is None:
            raise ResourceNotFound(f"User '{username}' not found.")
        return account

    def list_users(self, *, actor: UserAccount) -> list[UserAccount]:
        """List all accounts for administrators."""
        actor.require(Permission.LIST_USERS)
        return self._users.get_all()

    def change_password(
        self,
        command: ChangePasswordCommand,
        *,
        actor: UserAccount,
    ) -> UserAccount:
        """Change the authenticated user's password."""
        self._validate_password(command.new_password)
        if not self._passwords.verify(command.current_password, actor.password_hash):
            raise AuthenticationFailed("Current password is incorrect.")
        actor.change_password_hash(self._passwords.hash(command.new_password))
        return self._users.save(actor)

    def update_status(
        self,
        command: UpdateUserStatusCommand,
        *,
        actor: UserAccount,
    ) -> UserAccount:
        """Change an account status as an administrative action."""
        actor.require(Permission.UPDATE_USER_STATUS)
        account = self.get_by_username(command.username)
        account.status = command.status
        updated = self._users.save(account)
        self._audit.record(
            actor_id=actor.username,
            action=AuditAction.CHANGED_USER_STATUS,
            entity_type="UserAccount",
            entity_id=updated.username,
            details={"status": command.status.value},
        )
        return updated

    @staticmethod
    def _validate_username(username: str) -> None:
        if len(username.strip()) < 3:
            raise ValidationError("Username must be at least 3 characters.")

    @staticmethod
    def _validate_password(password: str) -> None:
        if len(password) < 8:
            raise ValidationError("Password must be at least 8 characters.")
