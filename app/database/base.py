"""
app/database/base.py
--------------------
Shared SQLAlchemy declarative base.

All ORM models must inherit from :data:`Base` so that Alembic
autogenerate can discover the full schema.
"""

from sqlalchemy.orm import declarative_base

Base = declarative_base()
