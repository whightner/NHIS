"""SQLAlchemy models for identity infrastructure."""

from sqlalchemy import JSON, Boolean, Column, DateTime, Integer, String
from sqlalchemy.sql import func

from app.database.base import Base


class User(Base):
    """Persistent user account row.

    The legacy ``role`` column is kept as the primary role for compatibility
    with existing data. The ``roles`` JSON column stores the complete role set
    used by the business object.
    """

    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    role = Column(String(20), nullable=False, default="OPERATOR")
    roles = Column(JSON, nullable=True)
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
