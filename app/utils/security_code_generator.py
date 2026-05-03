"""
app/utils/security_code_generator.py
--------------------------------------
Cryptographically secure patient card security code generator.

Replaces the original ``random.randint(1000, 9999)`` with
``secrets.randbelow`` to ensure the code is unpredictable.
"""

import secrets

from app.core.constants import SecurityParams


def generate_security_code() -> str:
    """
    Generate a zero-padded numeric security code of configurable length.

    Uses ``secrets.randbelow`` to guarantee cryptographic randomness.
    The code is zero-padded to :attr:`SecurityParams.SECURITY_CODE_DIGITS`
    digits so it always has a fixed length.

    :return: Numeric string of fixed length (e.g. ``"047392"`` for 6 digits).
    """
    digits = SecurityParams.SECURITY_CODE_DIGITS
    upper_bound = 10 ** digits          # e.g. 1_000_000 for 6 digits
    code = secrets.randbelow(upper_bound)
    return str(code).zfill(digits)
