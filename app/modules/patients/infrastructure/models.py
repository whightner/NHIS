"""SQLAlchemy models for patient infrastructure."""

from sqlalchemy import Column, Date, DateTime, Integer, String
from sqlalchemy.sql import func

from app.database.base import Base
from app.modules.patients.business import VerificationStatus


class Patient(Base):
    """Persistent patient row stored in the existing patients table."""

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
        default=VerificationStatus.PENDING.value,
    )
    rejection_reason = Column(String, nullable=True)
    card_pdf_path = Column(String, nullable=True)
    card_qr_code_path = Column(String, nullable=True)
    card_generated_at = Column(DateTime(timezone=True), nullable=True)
    card_reprint_count = Column(Integer, nullable=False, default=0)
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
