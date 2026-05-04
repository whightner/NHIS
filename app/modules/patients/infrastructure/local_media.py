"""Local filesystem adapters for patient photos, QR codes, and cards."""

from __future__ import annotations

import os
from types import SimpleNamespace

from app.core.constants import PhotoUpload, StoragePaths
from app.modules.patients.application.dto import PhotoUpload as PhotoUploadDTO
from app.modules.patients.business import Patient, PatientCard
from app.shared.business import ValidationError
from app.utils.patient_card_generator import generate_card
from app.utils.qr_code_generator import generate_qr_code


class LocalPatientPhotoStorage:
    """Stores patient photos in the configured local storage directory."""

    def save(self, upload: PhotoUploadDTO, uhid: str) -> str:
        """Validate and store a patient photo."""
        ext = os.path.splitext(upload.filename or "")[-1].lower()
        if ext not in PhotoUpload.ALLOWED_EXTENSIONS:
            raise ValidationError(
                f"File type '{ext}' is not allowed. Use: {PhotoUpload.ALLOWED_EXTENSIONS}"
            )

        content = upload.stream.read(PhotoUpload.MAX_SIZE_BYTES + 1)
        if len(content) > PhotoUpload.MAX_SIZE_BYTES:
            raise ValidationError("Photo exceeds the maximum allowed size.")

        os.makedirs(StoragePaths.PHOTOS, exist_ok=True)
        path = os.path.join(StoragePaths.PHOTOS, f"{uhid}{ext}")
        with open(path, "wb") as destination:
            destination.write(content)
        return path


class SettingsQrCodeGenerator:
    """Generates QR codes using the existing project utility."""

    def generate(self, uhid: str) -> str:
        """Generate and return a QR code path."""
        return generate_qr_code(uhid)


class ReportLabPatientCardGenerator:
    """Generates patient card PDFs using the existing ReportLab utility."""

    def generate(self, patient: Patient) -> PatientCard:
        """Generate a patient card and return card metadata."""
        card_input = SimpleNamespace(
            uhid=patient.uhid,
            first_name=patient.person.first_name,
            last_name=patient.person.last_name,
            date_of_birth=patient.person.date_of_birth,
            gender=patient.person.gender.value,
            photo_path=patient.photo_path,
        )
        pdf_path = generate_card(card_input)
        qr_path = os.path.join(StoragePaths.QRCODES, f"{patient.uhid}.png")
        return PatientCard.generated(
            uhid=patient.uhid,
            pdf_path=pdf_path,
            qr_code_path=qr_path,
        )
