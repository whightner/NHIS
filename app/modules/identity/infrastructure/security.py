"""Security adapters used by identity use cases."""

from app.core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)
from app.modules.identity.business import UserAccount


class BcryptPasswordHasher:
    """Password hasher backed by passlib bcrypt."""

    def hash(self, password: str) -> str:
        """Return a bcrypt password hash."""
        return hash_password(password)

    def verify(self, password: str, password_hash: str) -> bool:
        """Return True when a password matches its hash."""
        return verify_password(password, password_hash)


class JwtTokenIssuer:
    """JWT issuer backed by the project's security module."""

    def issue_access_token(self, account: UserAccount) -> str:
        """Create a signed access token for an account."""
        return create_access_token(
            data={
                "sub": account.username,
                "role": account.primary_role.value,
            }
        )

    def decode_access_token(self, token: str) -> dict:
        """Decode and validate a signed access token."""
        return decode_access_token(token)
