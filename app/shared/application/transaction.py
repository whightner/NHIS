"""Transaction boundary contract for use cases."""

from typing import Protocol


class TransactionManager(Protocol):
    """Coordinates persistence changes made by one use case."""

    def commit(self) -> None:
        """Commit the current unit of work."""

    def rollback(self) -> None:
        """Rollback the current unit of work."""
