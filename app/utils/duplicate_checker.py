"""
app/utils/duplicate_checker.py
--------------------------------
Fuzzy duplicate-detection utility for patient registration.

Uses a single targeted database query (filtered by date of birth) and
then performs in-memory fuzzy matching — far more efficient than the
original O(n) scan of the entire patients table.
"""

from datetime import date
from typing import List

from rapidfuzz import fuzz
from sqlalchemy.orm import Session

from app.core.constants import DuplicateThresholds
from app.modules.patient.patient_repository import patient_repository


def check_duplicate(
    db: Session,
    first_name: str,
    last_name: str,
    date_of_birth: date,
) -> List[dict]:
    """
    Find existing patients who may be the same person as the candidate.

    Strategy:
    1. Query only patients who share the same date of birth (indexed column).
    2. Run fuzzy string comparison on first and last names in memory.
    3. Return records whose name scores both exceed the configured thresholds.

    :param db:            Active database session.
    :param first_name:    Candidate first name.
    :param last_name:     Candidate last name.
    :param date_of_birth: Candidate date of birth (used as the DB filter key).
    :return: List of dicts with ``uhid``, ``first_name``, ``last_name``,
             and ``score`` (average of first/last name scores).
    """
    candidates = patient_repository.get_by_dob(db, date_of_birth)

    duplicates: List[dict] = []

    for candidate in candidates:
        first_score = fuzz.ratio(
            first_name.lower(),
            candidate.first_name.lower(),
        )
        last_score = fuzz.ratio(
            last_name.lower(),
            candidate.last_name.lower(),
        )

        if (
            first_score >= DuplicateThresholds.FIRST_NAME_MIN
            and last_score >= DuplicateThresholds.LAST_NAME_MIN
        ):
            duplicates.append({
                "uhid":       candidate.uhid,
                "first_name": candidate.first_name,
                "last_name":  candidate.last_name,
                "score":      round((first_score + last_score) / 2, 2),
            })

    return duplicates
