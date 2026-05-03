"""
app/modules/user/user_service.py
---------------------------------
Business-logic layer for user management and authentication.

Services raise typed domain exceptions (never ``HTTPException``).
Route handlers are responsible for translating those into HTTP responses.
"""

import logging

from sqlalchemy.orm import Session

from app.core.constants import Roles, UserStatus
from app.core.exceptions import (
    AuthenticationError,
    AuthorizationError,
    DuplicateResourceError,
    UserNotFoundError,
)
from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.modules.audit.audit_service import audit_service
from app.modules.user.user_model import User
from app.modules.user.user_repository import user_repository

logger = logging.getLogger("nhis.auth")


class UserService:
    """Handles all user-account and authentication business logic."""

    # ── Authentication ────────────────────────────────────────────────

    def login(
        self,
        db: Session,
        username: str,
        password: str,
        ip_address: str = "unknown",
    ) -> dict:
        """
        Authenticate a user and return a signed JWT token.

        :param db:         Active database session.
        :param username:   Supplied username.
        :param password:   Plain-text password to verify.
        :param ip_address: Client IP for audit logging.
        :return: Dict with ``access_token`` and ``token_type`` keys.
        :raises AuthenticationError: For invalid credentials or inactive accounts.
        """
        user = user_repository.get_by_username(db, username)

        if not user or not verify_password(password, user.password_hash):
            logger.warning("Failed login attempt for username=%s ip=%s", username, ip_address)
            audit_service.log(
                db=db,
                user_id=username,
                action="LOGIN_FAILED",
                ip_address=ip_address,
            )
            raise AuthenticationError("Invalid username or password.")

        if user.status != UserStatus.ACTIVE:
            logger.warning("Login blocked for inactive user=%s", username)
            raise AuthenticationError("Account is inactive or locked.")

        token = create_access_token(data={"sub": user.username, "role": user.role})

        logger.info("Successful login: user=%s ip=%s", username, ip_address)
        audit_service.log(
            db=db,
            user_id=username,
            action="LOGIN_SUCCESS",
            ip_address=ip_address,
        )

        return {"access_token": token, "token_type": "bearer"}

    # ── User management ───────────────────────────────────────────────

    def create_user(
        self,
        db: Session,
        username: str,
        password: str,
        role: str,
        actor: User,
    ) -> User:
        """
        Create a new system user (admin-only operation).

        :param db:       Active database session.
        :param username: Desired username.
        :param password: Initial plain-text password.
        :param role:     Role to assign.
        :param actor:    The admin user performing this action.
        :return: The newly created :class:`User`.
        :raises AuthorizationError:   If actor is not ADMIN.
        :raises DuplicateResourceError: If the username is already taken.
        """
        if actor.role != Roles.ADMIN:
            raise AuthorizationError("Only ADMIN users may create accounts.")

        if user_repository.get_by_username(db, username):
            raise DuplicateResourceError(f"Username '{username}' is already taken.")

        user = user_repository.create(
            db=db,
            username=username,
            password_hash=hash_password(password),
            role=role,
            status=UserStatus.ACTIVE,
        )
        logger.info("User created: %s (role=%s) by %s", username, role, actor.username)
        return user

    def get_user_by_username(self, db: Session, username: str) -> User:
        """
        Retrieve a user or raise if not found.

        :param db:       Active database session.
        :param username: Username to look up.
        :return: :class:`User` instance.
        :raises UserNotFoundError: If no user with that username exists.
        """
        user = user_repository.get_by_username(db, username)
        if not user:
            raise UserNotFoundError(f"User '{username}' not found.")
        return user

    def change_password(
        self,
        db: Session,
        user: User,
        current_password: str,
        new_password: str,
    ) -> User:
        """
        Allow a user to change their own password.

        :param db:               Active database session.
        :param user:             The authenticated user.
        :param current_password: Must match the stored hash.
        :param new_password:     Replacement password.
        :return: Updated :class:`User`.
        :raises AuthenticationError: If current_password does not match.
        """
        if not verify_password(current_password, user.password_hash):
            raise AuthenticationError("Current password is incorrect.")
        return user_repository.update_password(db, user, hash_password(new_password))

    def update_status(
        self,
        db: Session,
        target_username: str,
        new_status: str,
        actor: User,
    ) -> User:
        """
        Update a user's account status (admin-only).

        :param db:              Active database session.
        :param target_username: Username of the account to update.
        :param new_status:      New status string.
        :param actor:           Admin performing the update.
        :return: Updated :class:`User`.
        :raises AuthorizationError: If actor is not ADMIN.
        :raises UserNotFoundError:  If the target user does not exist.
        """
        if actor.role != Roles.ADMIN:
            raise AuthorizationError("Only ADMIN users may change account status.")
        user = self.get_user_by_username(db, target_username)
        return user_repository.update_status(db, user, new_status)

    def get_all_users(self, db: Session, actor: User) -> list[User]:
        """
        Return all users (admin-only).

        :param db:    Active database session.
        :param actor: The requesting user.
        :return: List of :class:`User` instances.
        :raises AuthorizationError: If actor is not ADMIN.
        """
        if actor.role != Roles.ADMIN:
            raise AuthorizationError("Only ADMIN users may list all accounts.")
        return user_repository.get_all(db)


user_service = UserService()
