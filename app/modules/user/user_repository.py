"""
app/modules/user/user_repository.py
-------------------------------------
Data-access layer for :class:`~app.modules.user.user_model.User` records.

Only SQLAlchemy queries live here.  No business logic, no HTTP concerns.
"""

from typing import Optional

from sqlalchemy.orm import Session

from app.modules.user.user_model import User


class UserRepository:
    """Encapsulates all database operations for :class:`User` entities."""

    def get_by_id(self, db: Session, user_id: int) -> Optional[User]:
        """
        Fetch a user by primary key.

        :param db:      Active database session.
        :param user_id: Integer primary key.
        :return: Matching :class:`User` or ``None``.
        """
        return db.query(User).filter(User.user_id == user_id).first()

    def get_by_username(self, db: Session, username: str) -> Optional[User]:
        """
        Fetch a user by their unique username.

        :param db:       Active database session.
        :param username: Username string (case-sensitive).
        :return: Matching :class:`User` or ``None``.
        """
        return db.query(User).filter(User.username == username).first()

    def get_all(self, db: Session) -> list[User]:
        """
        Return all user records.

        :param db: Active database session.
        :return: List of all :class:`User` instances.
        """
        return db.query(User).all()

    def create(
        self,
        db: Session,
        username: str,
        password_hash: str,
        role: str,
        status: str,
    ) -> User:
        """
        Persist a new user record.

        :param db:            Active database session.
        :param username:      Unique username.
        :param password_hash: Pre-hashed password string.
        :param role:          Assigned role constant.
        :param status:        Initial account status.
        :return: The newly created and refreshed :class:`User`.
        """
        user = User(
            username=username,
            password_hash=password_hash,
            role=role,
            status=status,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    def update_password(self, db: Session, user: User, new_hash: str) -> User:
        """
        Update the stored password hash and clear the first-login flag.

        :param db:       Active database session.
        :param user:     :class:`User` instance to update.
        :param new_hash: New bcrypt hash.
        :return: The updated :class:`User`.
        """
        user.password_hash = new_hash
        user.first_login = False
        db.commit()
        db.refresh(user)
        return user

    def update_status(self, db: Session, user: User, status: str) -> User:
        """
        Change a user's account status.

        :param db:     Active database session.
        :param user:   :class:`User` instance to update.
        :param status: New status string.
        :return: The updated :class:`User`.
        """
        user.status = status
        db.commit()
        db.refresh(user)
        return user


user_repository = UserRepository()
