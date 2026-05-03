"""
scripts/seed_admin.py
----------------------
One-time script to create the initial ADMIN user account.

Run from the project root::

    python -m scripts.seed_admin

The script is idempotent — it will not create a duplicate if the admin
account already exists.
"""

import sys
import os

# Ensure the project root is on the path when run directly
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.core.constants import Roles, UserStatus
from app.core.security import hash_password
from app.database.database import SessionLocal
from app.modules.user.user_model import User


DEFAULT_ADMIN_USERNAME = "admin01"
DEFAULT_ADMIN_PASSWORD = "Admin@123"


def seed_admin() -> None:
    """
    Create the default ADMIN user if it does not already exist.

    :return: None
    """
    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.username == DEFAULT_ADMIN_USERNAME).first()
        if existing:
            print(f"Admin user '{DEFAULT_ADMIN_USERNAME}' already exists — skipping.")
            return

        admin = User(
            username=DEFAULT_ADMIN_USERNAME,
            password_hash=hash_password(DEFAULT_ADMIN_PASSWORD),
            role=Roles.ADMIN,
            status=UserStatus.ACTIVE,
            first_login=True,
        )
        db.add(admin)
        db.commit()
        print(f"Admin user '{DEFAULT_ADMIN_USERNAME}' created successfully.")
        print(f"  Username : {DEFAULT_ADMIN_USERNAME}")
        print(f"  Password : {DEFAULT_ADMIN_PASSWORD}  ← change on first login!")

    except Exception as exc:
        db.rollback()
        print(f"Error creating admin user: {exc}", file=sys.stderr)
        sys.exit(1)
    finally:
        db.close()


if __name__ == "__main__":
    seed_admin()
