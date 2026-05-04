"""SQLAlchemy adapter for user account persistence."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.modules.identity.business import AccountStatus, UserAccount
from app.modules.user.user_model import User as UserRow
from app.shared.business import Role


class SQLAlchemyUserAccountRepository:
    """Maps the existing users table to UserAccount business objects."""

    def __init__(self, db: Session) -> None:
        self._db = db

    def get_by_username(self, username: str) -> UserAccount | None:
        """Return an account by username."""
        row = self._db.query(UserRow).filter(UserRow.username == username).first()
        return self._to_business(row) if row else None

    def get_all(self) -> list[UserAccount]:
        """Return every account."""
        return [self._to_business(row) for row in self._db.query(UserRow).all()]

    def create(
        self,
        *,
        username: str,
        password_hash: str,
        role: Role,
        status: AccountStatus,
    ) -> UserAccount:
        """Persist a new account."""
        row = UserRow(
            username=username,
            password_hash=password_hash,
            role=role.value,
            status=status.value,
            first_login=True,
        )
        self._db.add(row)
        self._db.commit()
        self._db.refresh(row)
        return self._to_business(row)

    def save(self, account: UserAccount) -> UserAccount:
        """Persist account changes."""
        row = self._get_row(account.username)
        row.password_hash = account.password_hash
        row.role = account.primary_role.value
        row.status = account.status.value
        row.first_login = account.first_login
        self._db.commit()
        self._db.refresh(row)
        return self._to_business(row)

    def _get_row(self, username: str) -> UserRow:
        row = self._db.query(UserRow).filter(UserRow.username == username).first()
        if row is None:
            raise LookupError(f"User '{username}' not found.")
        return row

    @staticmethod
    def _to_business(row: UserRow) -> UserAccount:
        return UserAccount(
            id=str(row.user_id),
            username=row.username,
            password_hash=row.password_hash,
            roles={Role(row.role)},
            status=AccountStatus(row.status),
            first_login=row.first_login,
            created_at=row.created_at,
            updated_at=row.updated_at,
        )
