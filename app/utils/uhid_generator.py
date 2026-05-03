"""
app/utils/uhid_generator.py
-----------------------------
Cryptographically secure Unique Health Identifier (UHID) generator.

Format:  {COUNTRY_PREFIX}-{YEAR}-{HEX8}
Example: CMR-2026-A3F7C219

Replaces the original ``random.choices`` usage with ``secrets.token_hex``
to ensure the hex segment is unpredictable.
"""

import secrets
from datetime import datetime

from sqlalchemy.orm import Session

from app.core.constants import SecurityParams
from app.modules.patient.patient_repository import patient_repository


def generate_uhid(db: Session) -> str:
    """
    Generate a unique, cryptographically random UHID.

    Retries until a UHID that is not already in the database is found.
    Collision probability is negligible (1/16^8 ≈ 1.5×10⁻¹⁰ per attempt).

    :param db: Active database session used for uniqueness checks.
    :return:   A unique UHID string in ``CMR-YYYY-XXXXXXXX`` format.
    """
    prefix = SecurityParams.UHID_COUNTRY_PREFIX
    year = datetime.now().year
    hex_len = SecurityParams.UHID_HEX_LENGTH

    while True:
        hex_part = secrets.token_hex(hex_len // 2).upper()  # token_hex(n) → 2n hex chars
        uhid = f"{prefix}-{year}-{hex_part}"
        if not patient_repository.uhid_exists(db, uhid):
            return uhid
