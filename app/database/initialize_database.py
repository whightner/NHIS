"""
app/database/initialize_database.py
------------------------------------
Development / test helper that creates all tables directly from models.

In production, schema changes must go through Alembic migrations.
This module exists only for first-time local setup and automated tests.
"""

import logging

from app.database.base import Base
from app.database.database import engine

# Import all models so that Base.metadata is fully populated before
# create_all is called.  These imports are intentional side-effects.
import app.modules.identity.infrastructure.models  # noqa: F401
import app.modules.patients.infrastructure.models  # noqa: F401
import app.modules.audit.infrastructure.models     # noqa: F401
import app.modules.staff.infrastructure.models     # noqa: F401

logger = logging.getLogger(__name__)


def initialize_database() -> None:
    """
    Create all database tables that do not yet exist.

    This is a no-op if every table is already present.  It does **not**
    run migrations; use ``alembic upgrade head`` for that.

    :return: None
    """
    logger.info("Initialising database schema …")
    Base.metadata.create_all(bind=engine)
    logger.info("Database schema ready.")
