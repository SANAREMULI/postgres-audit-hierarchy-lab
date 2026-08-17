# postgres-audit-hierarchy-lab
# postgres-audit-hierarchy-lab

## Project Overview

A production-style PostgreSQL project demonstrating four core database
engineering practices in one schema: audit logging via triggers,
hierarchical data modeling via recursive queries, version-controlled
migrations via Flyway, and least-privilege access control via database
roles.

## Objectives

- Track every `INSERT`/`UPDATE`/`DELETE` on a table with a reusable
  trigger-based audit log.
- Model and traverse a self-referencing category tree with a recursive CTE.
- Manage schema changes as ordered, version-controlled Flyway migrations.
- Enforce least privilege with separate read-only and read-write roles.

## Repository Structure

```
postgres-audit-hierarchy-lab/
├── migrations/          Flyway-versioned schema changes (V1, V2, V3)
├── audit/               Audit trigger, test script, and results
├── hierarchy/            Category tree table, recursive query, and results
├── security/             Roles, application user, and security notes
├── docs/                 Design docs, migration report, and reflection
└── README.md
```

## Migration Workflow

Schema changes are applied in order via Flyway:

```bash
flyway -url=jdbc:postgresql://localhost/bootcamp -user=postgres migrate
flyway info
```

| Version | File                              | Purpose                              |
|---------|-----------------------------------|---------------------------------------|
| V1      | `migrations/V1__core_tables.sql`  | Core app tables (`students`, `courses`, `enrollments`) |
| V2      | `migrations/V2__audit_log.sql`    | `audit_log` table + `audit()` trigger |
| V3      | `migrations/V3__categories.sql`   | `categories` self-referencing table   |

See `docs/migration_report.md` for full execution details.

## Audit Logging Workflow

1. `audit/audit_trigger.sql` creates the `audit_log` table, the `audit()`
   trigger function, and attaches `trg_audit` to `students`.
2. Any `INSERT`/`UPDATE`/`DELETE` on `students` automatically writes a
   row to `audit_log` capturing the table, operation, before/after
   values (as JSONB), the acting user, and a timestamp.
3. `audit/audit_test.sql` exercises this with a sample update and delete;
   results are documented in `audit/audit_results.md`.

## Security Implementation Summary

- `app_read` — `CONNECT` + `USAGE` + `SELECT` only.
- `app_write` — `CONNECT` + `USAGE` + `SELECT`/`INSERT`/`UPDATE`/`DELETE`.
- Neither role can `CREATE`, `DROP`, or act as superuser.
- `api` is a login user created in `IN ROLE app_write`, so the
  application never connects as a superuser.

Full rationale in `security/security_notes.md`.
