# NHIS Backend — National Health Insurance System

Production-grade FastAPI backend for patient registration, identity verification,
and insurance card management.

---

## Architecture Overview

```
app/
├── main.py                          # Application factory & router registration
├── core/
│   ├── config.py                    # Pydantic Settings (single source of env vars)
│   ├── constants.py                 # All magic values: roles, statuses, paths, thresholds
│   ├── exceptions.py                # Typed domain exception hierarchy
│   ├── security.py                  # JWT + bcrypt utilities
│   └── logging_config.py            # Rotating file + console log handlers
├── database/
│   ├── base.py                      # SQLAlchemy declarative Base
│   ├── database.py                  # Engine, SessionLocal, get_db dependency
│   └── initialize_database.py       # Dev/test table creator (not for production)
├── modules/
│   ├── user/
│   │   ├── user_model.py            # ORM model
│   │   ├── user_schema.py           # Pydantic request/response models
│   │   ├── user_repository.py       # SQLAlchemy queries only
│   │   ├── user_service.py          # Business logic (never raises HTTPException)
│   │   └── user_routes.py           # HTTP handlers + auth dependencies
│   ├── patient/
│   │   ├── patient_model.py
│   │   ├── patient_schema.py
│   │   ├── patient_repository.py
│   │   ├── patient_service.py
│   │   └── patient_routes.py
│   └── audit/
│       ├── audit_model.py
│       ├── audit_repository.py
│       └── audit_service.py
├── utils/
│   ├── uhid_generator.py            # Secure UHID generation (secrets module)
│   ├── security_code_generator.py   # Secure code generation (secrets module)
│   ├── qr_code_generator.py         # QR PNG generation (config-based URL)
│   ├── patient_card_generator.py    # ReportLab PDF card generation
│   ├── duplicate_checker.py         # Fuzzy name matching with DB filter
│   └── file_handler.py              # Photo upload to storage/photos/
alembic/                             # Database migration scripts
├── env.py
├── script.py.mako
└── versions/
scripts/
└── seed_admin.py                    # One-time admin account seeder
storage/
├── photos/                          # Patient photos
├── cards/                           # Generated PDF cards
└── qrcodes/                         # Generated QR PNG images
logs/                                # nhis.log + auth.log (rotating)
tests/
├── conftest.py                      # Shared fixtures + in-memory SQLite DB
├── test_user.py
└── test_patient.py
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Route** | Parse HTTP input, call service, map exceptions → HTTP responses |
| **Service** | Business logic, validation, orchestration; raises domain exceptions |
| **Repository** | SQLAlchemy queries only; receives db session, returns models |

---

## Quick Start

### 1. Clone & install dependencies

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env — set DATABASE_URL, SECRET_KEY, API_BASE_URL
```

Generate a strong secret key:
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

### 3. Run database migrations

```bash
# First time only — create the database:
createdb nhis_db

# Apply all migrations:
alembic upgrade head
```

### 4. Seed the admin user

```bash
python -m scripts.seed_admin
# Default credentials:  admin01 / Admin@123
# Change the password on first login!
```

### 5. Start the server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc:       http://localhost:8000/redoc

---

## Running Tests

```bash
pytest tests/ -v
```

Tests use an in-memory SQLite database — no PostgreSQL required.

```bash
# With coverage:
pytest tests/ -v --cov=app --cov-report=term-missing
```

---

## Database Migrations (Alembic)

```bash
# Create a new migration after changing a model:
alembic revision --autogenerate -m "add phone_number to patients"

# Apply pending migrations:
alembic upgrade head

# Roll back one step:
alembic downgrade -1

# View migration history:
alembic history --verbose
```

> **Rule:** Never run `Base.metadata.create_all()` in production.
> Always use `alembic upgrade head`.

---

## API Reference

All endpoints are versioned under `/api/v1`.

### Authentication

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/login` | Public | Obtain JWT token |
| GET  | `/api/v1/auth/me` | Any | Get current user profile |
| POST | `/api/v1/auth/me/change-password` | Any | Change own password |
| POST | `/api/v1/auth/users` | ADMIN | Create a new user |
| GET  | `/api/v1/auth/users` | ADMIN | List all users |
| PATCH | `/api/v1/auth/users/{username}/status` | ADMIN | Update user status |

### Patients

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/patients/` | ADMIN, OPERATOR | Register patient |
| GET  | `/api/v1/patients/` | Any | Search patients |
| GET  | `/api/v1/patients/stats` | ADMIN, VERIFIER | Statistics |
| GET  | `/api/v1/patients/pending` | Any | Pending list |
| GET  | `/api/v1/patients/approved` | ADMIN, VERIFIER | Approved list |
| GET  | `/api/v1/patients/rejected` | ADMIN, VERIFIER | Rejected list |
| GET  | `/api/v1/patients/duplicates` | ADMIN, VERIFIER | Duplicate queue |
| GET  | `/api/v1/patients/{uhid}` | Any | Get by UHID |
| POST | `/api/v1/patients/{uhid}/photo` | ADMIN, OPERATOR | Upload photo |
| POST | `/api/v1/patients/{uhid}/card` | ADMIN, OPERATOR | Generate card |
| POST | `/api/v1/patients/{uhid}/reprint` | Any | Reprint card |
| GET  | `/api/v1/patients/{uhid}/card/download` | ADMIN, OPERATOR | Download card PDF |
| POST | `/api/v1/patients/{uhid}/approve` | ADMIN, VERIFIER | Approve |
| POST | `/api/v1/patients/{uhid}/reject` | ADMIN, VERIFIER | Reject |
| GET  | `/api/v1/patients/verify/{uhid}` | ADMIN, VERIFIER, OPERATOR | Verify identity |
| POST | `/api/v1/patients/verify-security/{uhid}` | ADMIN, VERIFIER, OPERATOR | Verify security code |

---

## Roles

| Role | Capabilities |
|------|-------------|
| **ADMIN** | Full access — user management, patient CRUD, approvals, audits |
| **OPERATOR** | Register patients, upload photos, generate cards |
| **VERIFIER** | Approve/reject patients, view approved/rejected lists |
| **AUDITOR** | Read-only access to audit logs (future endpoint) |

---

## Security Notes

- All random values (UHID, security codes) use Python's `secrets` module — never `random`.
- Passwords are hashed with bcrypt via `passlib`.
- JWTs are signed with HS256 and expire after `ACCESS_TOKEN_EXPIRE_MINUTES`.
- Auth events (login success/failure) are written to `logs/auth.log`.
- Every significant action is persisted to the `audit_logs` table with user ID, action, entity, timestamp, and IP address.

---

## Adding a New Module

1. Create `app/modules/{name}/` with `model`, `schema`, `repository`, `service`, `routes`.
2. Import the model in `alembic/env.py` so autogenerate detects it.
3. Import the model in `app/database/initialize_database.py`.
4. Register the router in `app/main.py` under `ApiPrefix.V1`.
5. Run `alembic revision --autogenerate -m "add {name} table"` and `alembic upgrade head`.

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | — | PostgreSQL connection string |
| `SECRET_KEY` | ✅ | — | JWT signing secret |
| `ALGORITHM` | | `HS256` | JWT algorithm |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | | `30` | Token lifetime |
| `API_BASE_URL` | | `http://127.0.0.1:8000` | Embedded in QR codes |
| `LOG_LEVEL` | | `INFO` | Python log level |
| `ENVIRONMENT` | | `development` | `development` or `production` |
