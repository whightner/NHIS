"""User account business object."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum

from app.modules.identity.business.permissions import Permission, require_permission
from app.shared.business.errors import BusinessRuleViolation, ValidationError
from app.shared.business.roles import Role


class AccountStatus(str, Enum):
    """Lifecycle states for a login account."""

    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    LOCKED = "LOCKED"


@dataclass
class UserAccount:
    """A system account that can authenticate and perform protected actions."""

    id: str
    username: str
    password_hash: str
    roles: set[Role] = field(default_factory=set)
    status: AccountStatus = AccountStatus.ACTIVE
    first_login: bool = True

    def __post_init__(self) -> None:
        if not self.id or not self.id.strip():
            raise ValidationError("User account id is required.")
        if not self.username or not self.username.strip():
            raise ValidationError("Username is required.")
        if not self.password_hash or not self.password_hash.strip():
            raise ValidationError("Password hash is required.")
        if not self.roles:
            raise ValidationError("At least one role is required.")

    @property
    def is_active(self) -> bool:
        """Return True when the account may authenticate."""
        return self.status == AccountStatus.ACTIVE

    def ensure_active(self) -> None:
        """Raise when the account cannot authenticate or act."""
        if not self.is_active:
            raise BusinessRuleViolation("Account is inactive or locked.")

    def has_role(self, role: Role) -> bool:
        """Return True when the account has a role."""
        return role in self.roles

    def has_any_role(self, roles: set[Role] | frozenset[Role]) -> bool:
        """Return True when the account has at least one role in roles."""
        return bool(self.roles.intersection(roles))

    def require(self, permission: Permission) -> None:
        """Ensure the account has a business permission."""
        self.ensure_active()
        require_permission(self.roles, permission)

    def grant_role(self, role: Role) -> None:
        """Attach a new role to the account."""
        self.roles.add(role)

    def revoke_role(self, role: Role) -> None:
        """Remove a role while keeping the account usable."""
        if role not in self.roles:
            return
        if len(self.roles) == 1:
            raise BusinessRuleViolation("An account must keep at least one role.")
        self.roles.remove(role)

    def change_password_hash(self, password_hash: str) -> None:
        """Replace the stored password hash and clear first-login state."""
        if not password_hash or not password_hash.strip():
            raise ValidationError("Password hash is required.")
        self.password_hash = password_hash
        self.first_login = False

    def activate(self) -> None:
        """Mark the account as active."""
        self.status = AccountStatus.ACTIVE

    def deactivate(self) -> None:
        """Mark the account as inactive."""
        self.status = AccountStatus.INACTIVE

    def lock(self) -> None:
        """Lock the account after a security or administrative decision."""
        self.status = AccountStatus.LOCKED
