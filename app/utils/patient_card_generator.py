"""
app/utils/patient_card_generator.py
-------------------------------------
PDF ID card generator for registered patients.

Card dimensions are read from :class:`~app.core.constants.CardDimensions`
and storage paths from :class:`~app.core.constants.StoragePaths` so no
magic numbers or paths are hardcoded here.
"""

import logging
import os

from reportlab.lib.pagesizes import mm
from reportlab.pdfgen import canvas

from app.core.constants import CardDimensions, StoragePaths
from app.utils.qr_code_generator import generate_qr_code

logger = logging.getLogger(__name__)


def generate_card(patient) -> str:
    """
    Generate a PDF ID card for a patient.

    The card is stored at ``storage/cards/{uhid}.pdf``.  If the QR code
    image does not yet exist it is generated first.

    :param patient: A :class:`~app.modules.patient.patient_model.Patient`
                    ORM instance (duck-typed to support test stubs).
    :return: Relative file path to the saved PDF card.
    :raises OSError: If the storage directory cannot be created or the PDF
                     cannot be written.
    """
    os.makedirs(StoragePaths.CARDS, exist_ok=True)

    # Ensure QR code exists before embedding it
    qr_path = generate_qr_code(patient.uhid)

    filename = f"{patient.uhid}.pdf"
    file_path = os.path.join(StoragePaths.CARDS, filename)

    # Card dimensions from constants (ISO/IEC 7810 ID-1 landscape)
    width  = CardDimensions.WIDTH_MM  * mm
    height = CardDimensions.HEIGHT_MM * mm

    c = canvas.Canvas(file_path, pagesize=(width, height))

    # ── Header ────────────────────────────────────────────────────────
    c.setFont("Helvetica-Bold", 8)
    c.drawString(10, height - 10, "NATIONAL HEALTH ID CARD")

    # ── Patient details ───────────────────────────────────────────────
    c.setFont("Helvetica", 7)
    full_name = f"{patient.first_name} {patient.last_name}"
    c.drawString(10, height - 20, f"Name: {full_name}")
    c.drawString(10, height - 28, f"UHID: {patient.uhid}")
    c.drawString(10, height - 36, f"DOB:  {patient.date_of_birth}")
    c.drawString(10, height - 44, f"Gender: {patient.gender}")

    # ── Photo (optional) ──────────────────────────────────────────────
    if patient.photo_path and os.path.exists(patient.photo_path):
        c.drawImage(patient.photo_path, width - 60, height - 50, width=25, height=30)

    # ── QR code ───────────────────────────────────────────────────────
    if os.path.exists(qr_path):
        c.drawImage(qr_path, width - 30, 10, width=20, height=20)

    c.save()

    logger.debug("Card generated: %s", file_path)
    return file_path
