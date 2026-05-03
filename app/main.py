"""
app/main.py
-----------
FastAPI application factory and startup configuration.

Responsibilities:
  - Create the FastAPI application instance
  - Configure logging
  - Register versioned API routers
  - Expose health-check endpoint
"""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.constants import ApiPrefix
from app.core.logging_config import setup_logging

# ── Bootstrap logging before anything else ───────────────────────────
setup_logging(settings.LOG_LEVEL)
logger = logging.getLogger(__name__)

# ── Application factory ───────────────────────────────────────────────

app = FastAPI(
    title="NHIS Backend",
    description=(
        "National Health Insurance System — production-grade REST API.\n\n"
        "Supports patient registration, verification, card generation, "
        "role-based access control, and full audit logging."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS (adjust origins for production) ─────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if settings.ENVIRONMENT == "development" else [],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Startup / shutdown events ─────────────────────────────────────────
@app.on_event("startup")
def on_startup() -> None:
    """Log application startup and ensure storage directories exist."""
    import os
    from app.core.constants import StoragePaths
    for path in (StoragePaths.PHOTOS, StoragePaths.CARDS, StoragePaths.QRCODES, StoragePaths.LOGS):
        os.makedirs(path, exist_ok=True)
    logger.info("NHIS Backend starting up — environment=%s", settings.ENVIRONMENT)


@app.on_event("shutdown")
def on_shutdown() -> None:
    logger.info("NHIS Backend shutting down.")


# ── Health check ──────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    """
    Simple health-check endpoint.

    :return: JSON with system status.
    """
    return {"status": "ok", "system": "NHIS Backend", "version": app.version}


# ── Register versioned routers ────────────────────────────────────────
from app.modules.user.user_routes import router as user_router          # noqa: E402
from app.modules.patient.patient_routes import router as patient_router  # noqa: E402

# v1 — Auth & User management
app.include_router(
    user_router,
    prefix=f"{ApiPrefix.V1}/auth",
    tags=["Authentication"],
)

# v1 — Patient management
app.include_router(
    patient_router,
    prefix=f"{ApiPrefix.V1}/patients",
    tags=["Patients"],
)

logger.info("Routers registered under %s", ApiPrefix.V1)
