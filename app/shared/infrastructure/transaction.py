"""SQLAlchemy transaction manager."""

from sqlalchemy.orm import Session


class SQLAlchemyTransactionManager:
    """Commits or rolls back the request's SQLAlchemy session."""

    def __init__(self, db: Session) -> None:
        self._db = db

    def commit(self) -> None:
        """Commit the active transaction."""
        self._db.commit()

    def rollback(self) -> None:
        """Rollback the active transaction."""
        self._db.rollback()
