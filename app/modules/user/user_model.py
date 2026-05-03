"""
app/modules/user/user_model.py
-------------------------------
SQLAlchemy ORM model for the ``users`` table.

Fixes the original bug where ``role`` was defined twice, causing the
second definition to silently override the first.
"""

from sqlalchemy import Boolean, Column, DateTime, Integer, String
from sqlalchemy.sql import func

from app.database.base import Base


class User(Base):
    """
    Represents an NHIS system operator account.

    :param user_id:        Auto-increment primary key.
    :param username:       Unique login name (max 50 chars).
    :param password_hash:  Bcrypt hash of the user's password.
    :param role:           One of the roles defined in :class:`~app.core.constants.Roles`.
    :param status:         Account state (ACTIVE / INACTIVE / LOCKED).
    :param first_login:    ``True`` until the user changes their initial password.
    :param created_at:     Row-creation timestamp (server default).
    :param updated_at:     Last-modification timestamp (auto-updated).
    """

    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)

    username = Column(String(50), unique=True, nullable=False, index=True)

    password_hash = Column(String, nullable=False)

    role = Column(String(20), nullable=False, default="OPERATOR")

    status = Column(String(20), nullable=False, default="ACTIVE")

    first_login = Column(Boolean, default=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
