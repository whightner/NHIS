"""Patient card business object."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone

from app.shared.business.errors import ValidationError


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


@dataclass
class PatientCard:
    """Metadata for a generated patient card."""

    uhid: str
    pdf_path: str
    qr_code_path: str
    generated_at: datetime
    reprint_count: int = 0

    def __post_init__(self) -> None:
        if not self.uhid or not self.uhid.strip():
            raise ValidationError("Card UHID is required.")
        if not self.pdf_path or not self.pdf_path.strip():
            raise ValidationError("Card PDF path is required.")
        if not self.qr_code_path or not self.qr_code_path.strip():
            raise ValidationError("Card QR code path is required.")
        if self.reprint_count < 0:
            raise ValidationError("Card reprint count cannot be negative.")

    @classmethod
    def generated(cls, uhid: str, pdf_path: str, qr_code_path: str) -> "PatientCard":
        """Create metadata for a newly generated card."""
        return cls(
            uhid=uhid,
            pdf_path=pdf_path,
            qr_code_path=qr_code_path,
            generated_at=_utcnow(),
        )

    def register_reprint(self, pdf_path: str | None = None) -> None:
        """Record a card reprint and optionally replace the PDF path."""
        if pdf_path is not None:
            if not pdf_path.strip():
                raise ValidationError("Card PDF path is required.")
            self.pdf_path = pdf_path
        self.reprint_count += 1
        self.generated_at = _utcnow()
