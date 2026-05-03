"""
app/core/logging_config.py
--------------------------
Structured logging configuration for the NHIS application.

Call :func:`setup_logging` once at application start-up (in ``main.py``).
Every module that needs a logger should use::

    import logging
    logger = logging.getLogger(__name__)

Log files are stored in the ``logs/`` directory at the project root.
"""

import logging
import logging.handlers
import os
import sys

from app.core.constants import StoragePaths


def setup_logging(log_level: str = "INFO") -> None:
    """
    Configure root logger with both console and rotating-file handlers.

    Log files rotate at 10 MB and keep the last 5 archives.

    :param log_level: Python logging level string (DEBUG / INFO / WARNING …).
    :return: None
    """
    os.makedirs(StoragePaths.LOGS, exist_ok=True)

    numeric_level = getattr(logging, log_level.upper(), logging.INFO)

    formatter = logging.Formatter(
        fmt="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # ── Console handler ───────────────────────────────────────────────
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    console_handler.setLevel(numeric_level)

    # ── Rotating file handler ─────────────────────────────────────────
    log_file = os.path.join(StoragePaths.LOGS, "nhis.log")
    file_handler = logging.handlers.RotatingFileHandler(
        log_file,
        maxBytes=10 * 1024 * 1024,   # 10 MB
        backupCount=5,
        encoding="utf-8",
    )
    file_handler.setFormatter(formatter)
    file_handler.setLevel(numeric_level)

    # ── Security / auth events in a dedicated file ────────────────────
    auth_log_file = os.path.join(StoragePaths.LOGS, "auth.log")
    auth_handler = logging.handlers.RotatingFileHandler(
        auth_log_file,
        maxBytes=5 * 1024 * 1024,
        backupCount=10,
        encoding="utf-8",
    )
    auth_handler.setFormatter(formatter)
    auth_handler.setLevel(logging.INFO)

    # Attach security handler only to the auth logger
    auth_logger = logging.getLogger("nhis.auth")
    auth_logger.addHandler(auth_handler)
    auth_logger.propagate = True

    # ── Root configuration ────────────────────────────────────────────
    root_logger = logging.getLogger()
    root_logger.setLevel(numeric_level)
    root_logger.addHandler(console_handler)
    root_logger.addHandler(file_handler)

    # Reduce verbosity of third-party libs
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
