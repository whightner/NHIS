"""Ports required by identity application services."""

from __future__ import annotations

from typing import Protocol

from app.modules.identity.business import AccountStatus, UserAccount
from app.shared.business import Role


class UserAccountRepository(Protocol):
    """Persistence contract for user accounts."""

    def get_by_username(self, username: str) -> UserAccount | None:
        """Return an account by username."""

    def get_all(self) -> list[UserAccount]:
        """Return all user accounts."""

    def create(
        self,
        *,
        username: str,
        password_hash: str,
        role: Role,
        status: AccountStatus,
    ) -> UserAccount:
        """Persist a new account."""

    def save(self, account: UserAccount) -> UserAccount:
        """Persist account changes."""


class PasswordHasher(Protocol):
    """Password hashing and verification contract."""

    def hash(self, password: str) -> str:
        """Return a password hash."""

    def verify(self, password: str, password_hash: str) -> bool:
        """Return True when the password matches the hash."""


class TokenIssuer(Protocol):
    """Access-token contract."""

    def issue_access_token(self, account: UserAccount) -> str:
        """Create an access token for an authenticated account."""

    def decode_access_token(self, token: str) -> dict:
        """Decode and validate an access token."""
