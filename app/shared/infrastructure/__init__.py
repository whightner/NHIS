"""Shared infrastructure adapters."""

from app.shared.infrastructure.transaction import SQLAlchemyTransactionManager

__all__ = ["SQLAlchemyTransactionManager"]
