# Migration Report

## Migration Files Created

| Version | File                        | Purpose                                              |
|---------|------------------------------|-------------------------------------------------------|
| V1      | `migrations/V1__core_tables.sql` | `students`, `courses`, `enrollments` + seed data  |
| V2      | `migrations/V2__audit_log.sql`   | `audit_log` table, `audit()` function, `trg_audit` trigger |
| V3      | `migrations/V3__categories.sql`  | `categories` self-referencing table + sample tree |

## Order of Execution

Flyway applies migrations strictly in ascending version order based on the
`V<number>__description.sql` filename convention, tracking applied
versions in its `flyway_schema_history` table so each migration runs
exactly once:

1. `V1__core_tables.sql`
2. `V2__audit_log.sql`
3. `V3__categories.sql`

## `flyway migrate` — Expected Output

Run from the project root once `flyway.conf` (or CLI flags) point at the
`bootcamp` database:

```
flyway -url=jdbc:postgresql://localhost/bootcamp -user=postgres migrate
```

```
Flyway Community Edition 10.x.x by Redgate

Database: jdbc:postgresql://localhost/bootcamp (PostgreSQL 16.x)
Successfully validated 3 migrations (execution time 00:00.031s)
Creating Schema History table "public"."flyway_schema_history" ...
Current version of schema "public": << Empty Schema >>
Migrating schema "public" to version "1 - core tables"
Migrating schema "public" to version "2 - audit log"
Migrating schema "public" to version "3 - categories"
Successfully applied 3 migrations to schema "public", now at version v3
(execution time 00:00.112s)
```

## `flyway info` — Expected Output

```
flyway info
```

```
Schema version: 3

+-----------+---------+---------------+------+---------------------+---------+----------+
| Category  | Version | Description   | Type | Installed On        | State   | Undoable |
+-----------+---------+---------------+------+---------------------+---------+----------+
| Versioned | 1       | core tables   | SQL  | 2026-08-17 18:54:xx  | Success | No       |
| Versioned | 2       | audit log     | SQL  | 2026-08-17 18:54:xx  | Success | No       |
| Versioned | 3       | categories    | SQL  | 2026-08-17 18:54:xx  | Success | No       |
+-----------+---------+---------------+------+---------------------+---------+----------+
```

> Applying the same three scripts directly with `psql` against the
> `bootcamp` database (V1 → V2 → V3) completed without error and produced
> the tables listed above (`students`, `courses`, `enrollments`,
> `audit_log`, `categories`), confirming the SQL in each migration is
> valid and runs cleanly in order. Running the Flyway CLI itself against
> your local Postgres instance will populate the actual timestamps in
> `flyway_schema_history` for your submission screenshot.

## Why Migrations Are Preferred Over Manual Schema Changes

- **Repeatability** — the exact same sequence of DDL runs in dev, staging,
  and production. A manually-run `ALTER TABLE` in a psql session is easy
  to forget to apply somewhere else.
- **History and auditability** — `flyway_schema_history` is a permanent,
  queryable record of exactly which changes were applied and when, which
  pairs naturally with the audit logging built in Part A.
- **Version control** — migration files live in Git alongside application
  code, so schema changes go through the same review (pull request) process
  as everything else, and can be bisected/reverted like code.
- **Safety** — Flyway checksums applied migrations and refuses to silently
  re-apply or skip a modified file, preventing schema drift between
  environments.
- **Team coordination** — multiple engineers can add new `V4__...`,
  `V5__...` files without stepping on each other, instead of coordinating
  manual changes over chat.
