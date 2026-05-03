"""
app/core/constants.py
---------------------
Central registry for every magic value used across the application.

Import from here instead of scattering literals through the code-base.
This is the single source of truth for roles, statuses, thresholds,
storage paths, card dimensions, and security parameters.
"""

import os


# ════════════════════════════════════════════════════════════════════════
# ROLES
# ════════════════════════════════════════════════════════════════════════

class Roles:
    """Enumeration of all valid user roles in the NHIS system."""

    ADMIN: str    = "ADMIN"
    OPERATOR: str = "OPERATOR"
    VERIFIER: str = "VERIFIER"
    AUDITOR: str  = "AUDITOR"

    ALL: list[str] = [ADMIN, OPERATOR, VERIFIER, AUDITOR]


# ════════════════════════════════════════════════════════════════════════
# USER STATUS
# ════════════════════════════════════════════════════════════════════════

class UserStatus:
    """Valid states for a user account."""

    ACTIVE:   str = "ACTIVE"
    INACTIVE: str = "INACTIVE"
    LOCKED:   str = "LOCKED"


# ════════════════════════════════════════════════════════════════════════
# VERIFICATION STATUS
# ════════════════════════════════════════════════════════════════════════

class VerificationStatus:
    """Lifecycle states for a patient registration."""

    PENDING:  str = "PENDING"
    APPROVED: str = "APPROVED"
    REJECTED: str = "REJECTED"


# ════════════════════════════════════════════════════════════════════════
# STORAGE PATHS  (relative to project root)
# ════════════════════════════════════════════════════════════════════════

class StoragePaths:
    """
    Standard file-system paths for all persistent artefacts.

    All paths are relative to the project root so they work correctly
    regardless of where the process is launched from.
    """

    BASE:     str = "storage"
    PHOTOS:   str = os.path.join(BASE, "photos")
    CARDS:    str = os.path.join(BASE, "cards")
    QRCODES:  str = os.path.join(BASE, "qrcodes")
    LOGS:     str = "logs"


# ════════════════════════════════════════════════════════════════════════
# DUPLICATE DETECTION THRESHOLDS
# ════════════════════════════════════════════════════════════════════════

class DuplicateThresholds:
    """
    Fuzzy-match score thresholds used by the duplicate checker.

    Scores are percentages returned by ``rapidfuzz.fuzz.ratio``.
    """

    FIRST_NAME_MIN: int = 80   # Minimum match score for first name
    LAST_NAME_MIN:  int = 80   # Minimum match score for last name


# ════════════════════════════════════════════════════════════════════════
# CARD DIMENSIONS  (ReportLab uses points; 1 mm ≈ 2.835 pt)
# ════════════════════════════════════════════════════════════════════════

class CardDimensions:
    """Physical size of the patient ID card (ISO/IEC 7810 ID-1 landscape)."""

    WIDTH_MM:  int = 85   # Standard credit-card width
    HEIGHT_MM: int = 54   # Standard credit-card height


# ════════════════════════════════════════════════════════════════════════
# SECURITY / RANDOM GENERATION
# ════════════════════════════════════════════════════════════════════════

class SecurityParams:
    """Parameters that control random value generation."""

    SECURITY_CODE_DIGITS: int = 6   # Length of patient security code
    UHID_HEX_LENGTH:      int = 8   # Hex segment length in UHID
    UHID_COUNTRY_PREFIX:  str = "CMR"


# ════════════════════════════════════════════════════════════════════════
# PHOTO UPLOAD
# ════════════════════════════════════════════════════════════════════════

class PhotoUpload:
    """Constraints applied when accepting patient photos."""

    ALLOWED_EXTENSIONS: set[str] = {".jpg", ".jpeg", ".png"}
    MAX_SIZE_BYTES:      int = 5 * 1024 * 1024   # 5 MB


# ════════════════════════════════════════════════════════════════════════
# API
# ════════════════════════════════════════════════════════════════════════

class ApiPrefix:
    """Versioned URL prefixes."""

    V1: str = "/api/v1"
    # Reserve for future: V2 = "/api/v2"
