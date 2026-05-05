"""complete modular schema baseline

Revision ID: 20260505_0001
Revises:
Create Date: 2026-05-05
"""

from alembic import op
import sqlalchemy as sa


revision = "20260505_0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create the current modular schema."""
    op.create_table(
        "users",
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("username", sa.String(length=50), nullable=False),
        sa.Column("password_hash", sa.String(), nullable=False),
        sa.Column("role", sa.String(length=20), nullable=False),
        sa.Column("roles", sa.JSON(), nullable=True),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("first_login", sa.Boolean(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("user_id"),
        sa.UniqueConstraint("username"),
    )
    op.create_index("ix_users_user_id", "users", ["user_id"], unique=False)
    op.create_index("ix_users_username", "users", ["username"], unique=False)

    op.create_table(
        "patients",
        sa.Column("uhid", sa.String(length=30), nullable=False),
        sa.Column("national_id", sa.String(length=50), nullable=True),
        sa.Column("first_name", sa.String(length=100), nullable=False),
        sa.Column("last_name", sa.String(length=100), nullable=False),
        sa.Column("date_of_birth", sa.Date(), nullable=False),
        sa.Column("gender", sa.String(length=10), nullable=False),
        sa.Column("nationality", sa.String(length=100), nullable=False),
        sa.Column("phone_number", sa.String(length=20), nullable=True),
        sa.Column("photo_path", sa.String(), nullable=True),
        sa.Column("security_code", sa.String(length=20), nullable=True),
        sa.Column("verification_status", sa.String(length=20), nullable=False),
        sa.Column("rejection_reason", sa.String(), nullable=True),
        sa.Column("card_pdf_path", sa.String(), nullable=True),
        sa.Column("card_qr_code_path", sa.String(), nullable=True),
        sa.Column("card_generated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("card_reprint_count", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("uhid"),
        sa.UniqueConstraint("security_code"),
    )
    op.create_index("ix_patients_uhid", "patients", ["uhid"], unique=False)

    op.create_table(
        "audit_logs",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.String(length=100), nullable=False),
        sa.Column("action", sa.String(length=200), nullable=False),
        sa.Column("entity_type", sa.String(length=50), nullable=True),
        sa.Column("entity_id", sa.String(length=100), nullable=True),
        sa.Column("patient_uhid", sa.String(length=30), nullable=True),
        sa.Column("ip_address", sa.String(length=45), nullable=True),
        sa.Column("details", sa.JSON(), nullable=True),
        sa.Column("timestamp", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_audit_logs_id", "audit_logs", ["id"], unique=False)
    op.create_index("ix_audit_logs_user_id", "audit_logs", ["user_id"], unique=False)
    op.create_index("ix_audit_logs_entity_id", "audit_logs", ["entity_id"], unique=False)
    op.create_index("ix_audit_logs_patient_uhid", "audit_logs", ["patient_uhid"], unique=False)

    op.create_table(
        "staff_members",
        sa.Column("id", sa.String(length=50), nullable=False),
        sa.Column("user_account_id", sa.String(length=50), nullable=False),
        sa.Column("first_name", sa.String(length=100), nullable=False),
        sa.Column("last_name", sa.String(length=100), nullable=False),
        sa.Column("date_of_birth", sa.Date(), nullable=False),
        sa.Column("gender", sa.String(length=10), nullable=False),
        sa.Column("nationality", sa.String(length=100), nullable=False),
        sa.Column("national_id", sa.String(length=50), nullable=True),
        sa.Column("phone_number", sa.String(length=20), nullable=True),
        sa.Column("position", sa.String(length=30), nullable=False),
        sa.Column("department", sa.String(length=100), nullable=True),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_staff_members_id", "staff_members", ["id"], unique=False)
    op.create_index(
        "ix_staff_members_user_account_id",
        "staff_members",
        ["user_account_id"],
        unique=False,
    )


def downgrade() -> None:
    """Drop the current modular schema."""
    op.drop_index("ix_staff_members_user_account_id", table_name="staff_members")
    op.drop_index("ix_staff_members_id", table_name="staff_members")
    op.drop_table("staff_members")

    op.drop_index("ix_audit_logs_entity_id", table_name="audit_logs")
    op.drop_index("ix_audit_logs_patient_uhid", table_name="audit_logs")
    op.drop_index("ix_audit_logs_user_id", table_name="audit_logs")
    op.drop_index("ix_audit_logs_id", table_name="audit_logs")
    op.drop_table("audit_logs")

    op.drop_index("ix_patients_uhid", table_name="patients")
    op.drop_table("patients")

    op.drop_index("ix_users_username", table_name="users")
    op.drop_index("ix_users_user_id", table_name="users")
    op.drop_table("users")
