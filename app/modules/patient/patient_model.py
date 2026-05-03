"""
app/modules/patient/patient_model.py
--------------------------------------
SQLAlchemy ORM model for the ``patients`` table.
"""

from sqlalchemy import Column, Date, DateTime, String
from sqlalchemy.sql import func

from app.database.base import Base
from app.core.constants import VerificationStatus


class Patient(Base):
    """
    Represents a registered patient in the NHIS system.

    :param uhid:                Unique Health Identifier (primary key).
    :param national_id:         Optional national ID / passport number.
    :param first_name:          Patient's first name.
    :param last_name:           Patient's last name.
    :param date_of_birth:       Date of birth.
    :param gender:              Gender string (e.g. MALE / FEMALE / OTHER).
    :param nationality:         Nationality or country of origin.
    :param phone_number:        Optional contact phone number.
    :param photo_path:          Relative path to the stored photo file.
    :param security_code:       Unique numeric security code for card verification.
    :param verification_status: Registration lifecycle state (PENDING / APPROVED / REJECTED).
    :param created_at:          Record-creation timestamp.
    :param updated_at:          Last-modification timestamp.
    """

    __tablename__ = "patients"

    uhid = Column(String(30), primary_key=True, index=True)

    national_id = Column(String(50), nullable=True)

    first_name = Column(String(100), nullable=False)

    last_name = Column(String(100), nullable=False)

    date_of_birth = Column(Date, nullable=False)

    gender = Column(String(10), nullable=False)

    nationality = Column(String(100), nullable=False)

    phone_number = Column(String(20), nullable=True)

    photo_path = Column(String, nullable=True)

    security_code = Column(String(20), unique=True, nullable=True)

    verification_status = Column(
        String(20),
        nullable=False,
        default=VerificationStatus.PENDING,
    )

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
