# Security Notes

## What Least Privilege Means

Least privilege means every account — human or application — is granted
only the permissions it needs to do its specific job, and nothing more.
An application that only ever reads and writes rows in a handful of
tables should never be able to `DROP TABLE`, alter roles, or read tables
outside its domain, even though a superuser account technically could do
all of that. Scoping permissions tightly limits the damage a compromised
credential, a buggy query, or a mistaken script can do.

## Why Applications Should Not Use Superuser Accounts

- **Blast radius** — a superuser connection can create/drop roles, disable
  triggers (including the audit trigger), bypass row-level security, and
  read or modify any object in any database. A leaked application
  connection string becomes a full database compromise instead of a
  contained incident.
- **Auditability** — when every application connects through a narrowly
  scoped role like `app_write`, unexpected schema changes or privilege
  escalation attempts stand out immediately, because that role should
  never be doing them.
- **Accidental damage** — a superuser session makes it trivially easy for
  a typo (`DROP TABLE students` instead of `DELETE FROM students`) to be
  catastrophic instead of merely rejected for lack of privilege.
- **Separation of duties** — schema changes (migrations) should go through
  a reviewed, versioned process (Flyway), not through whatever credentials
  the running application happens to hold.

## Differences Between `app_read` and `app_write`

| Capability                          | app_read | app_write |
|--------------------------------------|:--------:|:---------:|
| `CONNECT` to database                | ✅        | ✅         |
| `USAGE` on schema                    | ✅        | ✅         |
| `SELECT` on tables                   | ✅        | ✅         |
| `INSERT` / `UPDATE` / `DELETE`       | ❌        | ✅         |
| `USAGE`/`SELECT` on sequences        | ❌        | ✅         |
| `CREATE` / `DROP` / `TRUNCATE`       | ❌        | ❌         |
| Superuser                            | ❌        | ❌         |

`app_read` is intended for reporting, dashboards, or any consumer that
should never be able to modify data. `app_write` is intended for the
application's normal transactional workload — it can change data but
still cannot alter schema, drop objects, or manage other roles. Neither
role can log in directly; the `api` login user is granted membership in
`app_write` (`IN ROLE app_write`), so its effective privileges come from
the role, not from being superuser.
