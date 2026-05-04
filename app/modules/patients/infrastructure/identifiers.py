"""Secure identifier generators for patient workflows."""

import secrets
from datetime import datetime

from app.core.constants import SecurityParams
from app.modules.patients.application.ports import PatientRepository


class SecureUhidGenerator:
    """Generates unique health identifiers using cryptographic randomness."""

    def __init__(self, patients: PatientRepository) -> None:
        self._patients = patients

    def generate(self) -> str:
        """Return an unused UHID in the configured NHIS format."""
        prefix = SecurityParams.UHID_COUNTRY_PREFIX
        year = datetime.now().year
        hex_len = SecurityParams.UHID_HEX_LENGTH

        while True:
            hex_part = secrets.token_hex(hex_len // 2).upper()
            uhid = f"{prefix}-{year}-{hex_part}"
            if not self._patients.uhid_exists(uhid):
                return uhid


class SecureSecurityCodeGenerator:
    """Generates fixed-length patient card security codes."""

    def generate(self) -> str:
        """Return a cryptographically random numeric code."""
        digits = SecurityParams.SECURITY_CODE_DIGITS
        return str(secrets.randbelow(10**digits)).zfill(digits)
