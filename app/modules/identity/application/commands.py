"""Command objects accepted by identity use cases."""

from dataclasses import dataclass

from app.modules.identity.business import AccountStatus
from app.shared.business import Role


@dataclass(frozen=True)
class LoginCommand:
    """Credentials supplied during login."""

    username: str
    password: str
    ip_address: str = "unknown"


@dataclass(frozen=True)
class CreateUserCommand:
    """Data required to create a user account."""

    username: str
    password: str
    role: Role


@dataclass(frozen=True)
class ChangePasswordCommand:
    """Data required to change the current account password."""

    current_password: str
    new_password: str


@dataclass(frozen=True)
class UpdateUserStatusCommand:
    """Data required to change an account lifecycle status."""

    username: str
    status: AccountStatus
