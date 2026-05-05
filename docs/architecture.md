# NHIS Backend Architecture

The backend is organized by business capability. Each module follows the same
four-layer structure:

```text
api -> application -> business -> infrastructure
```

## Layers

`business` contains pure business objects and rules. It must not import
FastAPI, SQLAlchemy, JWT helpers, file storage, or request objects.

`application` contains use cases. A use case coordinates business objects,
permissions, persistence ports, audit recording, and transaction boundaries.

`infrastructure` contains technical adapters: SQLAlchemy models and
repositories, password hashing, JWT handling, file storage, QR generation, and
PDF card generation.

`api` contains FastAPI routes, request/response schemas, and dependency wiring.
Routes should parse HTTP input, call one use case, and translate errors.

## Modules

`identity` manages login accounts, roles, permissions, password changes, JWT
tokens, and account status.

`patients` manages patient registration, duplicate detection, verification,
photo upload, card generation, and patient lookup.

`staff` manages internal staff profiles linked to user accounts.

`audit` records and exposes traceability information for important actions.

`shared` contains cross-module contracts: business errors, application errors,
transaction boundaries, API error translation, roles, and reusable person data.

## Persistence

SQLAlchemy models live in each module's `infrastructure/models.py`. Table names
remain stable:

```text
users
patients
staff_members
audit_logs
```

Repositories map database rows to business objects. They use `flush()` and
`refresh()`, but they do not commit. Application services commit after a use
case completes, so related changes such as a patient update and its audit log
are persisted together.

## API Contract

The public v1 prefixes are:

```text
/api/v1/auth
/api/v1/patients
/api/v1/staff
/api/v1/audit
```

The old `user` and `patient` modules were removed after their behavior was
migrated into `identity` and `patients`.
