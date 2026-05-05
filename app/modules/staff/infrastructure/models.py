"""SQLAlchemy models for staff infrastructure."""

from sqlalchemy import Boolean, Column, Date, DateTime, String
from sqlalchemy.sql import func

from app.database.base import Base


class StaffMember(Base):
    """Persistent staff member row."""

    __tablename__ = "staff_members"

    id = Column(String(50), primary_key=True, index=True)
    user_account_id = Column(String(50), nullable=False, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False)
    gender = Column(String(10), nullable=False)
    nationality = Column(String(100), nullable=False)
    national_id = Column(String(50), nullable=True)
    phone_number = Column(String(20), nullable=True)
    position = Column(String(30), nullable=False)
    department = Column(String(100), nullable=True)
    active = Column(Boolean, nullable=False, default=True)
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
