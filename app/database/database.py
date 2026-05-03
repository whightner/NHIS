"""
app/database/database.py
------------------------
SQLAlchemy engine, session factory, and FastAPI dependency.

Import :func:`get_db` as a FastAPI ``Depends`` to obtain a database
session that is automatically closed after each request.
"""

import logging

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings

logger = logging.getLogger(__name__)

# ── Engine ────────────────────────────────────────────────────────────

engine = create_engine(
    settings.DATABASE_URL,
    echo=False,          # Set to True only for local debugging
    pool_pre_ping=True,  # Recycle stale connections
    pool_size=10,
    max_overflow=20,
)

# ── Session factory ───────────────────────────────────────────────────

SessionLocal: sessionmaker[Session] = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


# ── FastAPI dependency ────────────────────────────────────────────────

def get_db():
    """
    Yield a database session and ensure it is closed after the request.

    Usage::

        @router.get("/example")
        def example(db: Session = Depends(get_db)):
            ...

    :return: Active SQLAlchemy :class:`Session`.
    :raises: Any database connectivity error is propagated after rollback.
    """
    db: Session = SessionLocal()
    try:
        yield db
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
