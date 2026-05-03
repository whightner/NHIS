"""
app/core/security.py
--------------------
Authentication primitives: password hashing and JWT token management.

All cryptographic operations are centralised here so the algorithm and
key configuration live in a single module.
"""

from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.core.exceptions import TokenInvalidError

# ── Password hashing ──────────────────────────────────────────────────

_pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """
    Hash a plain-text password using bcrypt.

    :param password: The raw password string.
    :return: Bcrypt hash suitable for database storage.
    """
    return _pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain-text password against a stored bcrypt hash.

    :param plain_password: The raw password supplied by the user.
    :param hashed_password: The bcrypt hash stored in the database.
    :return: ``True`` if the password matches, ``False`` otherwise.
    """
    return _pwd_context.verify(plain_password, hashed_password)


# ── JWT tokens ────────────────────────────────────────────────────────

def create_access_token(data: dict) -> str:
    """
    Create a signed JWT access token.

    :param data: Claims to embed in the token payload.
    :return: Encoded JWT string.
    """
    to_encode = data.copy()
    expire = datetime.now(tz=timezone.utc) + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_access_token(token: str) -> dict:
    """
    Decode and validate a JWT access token.

    :param token: Encoded JWT string from the ``Authorization`` header.
    :return: Decoded payload dictionary.
    :raises TokenInvalidError: If the token is missing, expired, or tampered.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        return payload
    except JWTError as exc:
        raise TokenInvalidError("Token is invalid or has expired.") from exc
