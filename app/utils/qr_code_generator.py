"""
app/utils/qr_code_generator.py
--------------------------------
QR code generator for patient identity verification.

The QR data URL is built from :attr:`~app.core.config.settings.API_BASE_URL`
so it works in every environment without code changes.
"""

import logging
import os

import qrcode

from app.core.config import settings
from app.core.constants import StoragePaths

logger = logging.getLogger(__name__)


def generate_qr_code(uhid: str) -> str:
    """
    Generate a QR code PNG image for a patient's verification URL.

    The encoded URL points to the public verification endpoint:
    ``{API_BASE_URL}/api/v1/patients/verify/{uhid}``

    :param uhid: Patient UHID to encode in the QR.
    :return: Relative file path to the saved QR image.
    :raises OSError: If the storage directory cannot be created or the file
                     cannot be written.
    """
    os.makedirs(StoragePaths.QRCODES, exist_ok=True)

    verify_url = f"{settings.API_BASE_URL}/api/v1/patients/verify/{uhid}"

    filename = f"{uhid}.png"
    file_path = os.path.join(StoragePaths.QRCODES, filename)

    qr = qrcode.make(verify_url)
    qr.save(file_path)

    logger.debug("QR code saved: %s → %s", verify_url, file_path)
    return file_path
