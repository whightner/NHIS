"""
app/core/config.py
------------------
Centralised application configuration loaded from environment variables.

All settings are validated by Pydantic and available as a singleton
``settings`` object imported throughout the application.  No raw
``os.getenv`` calls should appear outside this module.
"""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application-wide settings sourced from the ``.env`` file or the
    process environment.

    :param DATABASE_URL: Full SQLAlchemy-compatible database connection string.
    :param SECRET_KEY: Secret used to sign JWT tokens.
    :param ALGORITHM: JWT signing algorithm (default HS256).
    :param ACCESS_TOKEN_EXPIRE_MINUTES: Token lifetime in minutes.
    :param API_BASE_URL: Public base URL of the API (used in QR codes etc.).
    :param LOG_LEVEL: Python logging level string (DEBUG / INFO / WARNING …).
    :param ENVIRONMENT: Runtime environment label (development / production).
    """

    # ── Database ──────────────────────────────────────────────────────────
    DATABASE_URL: str

    # ── JWT / Security ────────────────────────────────────────────────────
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # ── Public API URL (used in QR codes, never hardcoded elsewhere) ──────
    API_BASE_URL: str = "http://127.0.0.1:8000"

    # ── Logging ───────────────────────────────────────────────────────────
    LOG_LEVEL: str = "INFO"

    # ── Runtime environment ───────────────────────────────────────────────
    ENVIRONMENT: str = "development"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )


@lru_cache
def get_settings() -> Settings:
    """
    Return the cached Settings singleton.

    :return: Validated :class:`Settings` instance.
    """
    return Settings()


# Module-level convenience alias consumed by the rest of the application.
settings: Settings = get_settings()
