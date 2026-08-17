# Audit Log Design

## How the Audit Log Works

Every change to a monitored table (`students`, via `trg_audit`) fires the
`audit()` trigger function `AFTER INSERT OR UPDATE OR DELETE`. The
function inspects `TG_OP` to determine which operation occurred and
inserts one row into `audit_log` capturing:

- `tbl` — the table name (`TG_TABLE_NAME`), so one audit table can serve
  many source tables.
- `op` — `INSERT`, `UPDATE`, or `DELETE`.
- `old_row` — the row's prior state as JSONB (`NULL` for `INSERT`).
- `new_row` — the row's new state as JSONB (`NULL` for `DELETE`).
- `changed_by` — `current_user`, the database role that made the change.
- `at` — `now()`, the timestamp of the change.

Because the insert into `audit_log` happens inside the same trigger
invocation as the original statement, it runs in the same transaction —
if the original statement is rolled back, the audit row is rolled back
with it, so the log never records a change that didn't actually commit.

## Why Triggers Are Useful

- **Cannot be bypassed accidentally** — logging happens at the database
  layer, so it doesn't depend on every application code path
  remembering to write an audit entry. Ad-hoc `psql` sessions, ORM code,
  and background jobs are all covered equally.
- **Centralized logic** — one trigger function (`audit()`) is reused
  across tables instead of duplicating logging code throughout the
  application.
- **Atomicity** — the audit entry and the data change either both commit
  or both roll back together, since they're part of the same transaction.

## Advantages of Storing Changes as JSONB

- **Schema-flexible** — `old_row`/`new_row` capture the entire row
  regardless of how many columns the table has or how it changes over
  time; adding a column to `students` doesn't require touching the audit
  trigger or `audit_log` schema.
- **Queryable** — JSONB supports operators like `->>` to pull individual
  fields out of a historical row (as used in `audit_test.sql` to compare
  `old_row->>'name'` vs `new_row->>'name'`), so investigators can query
  specific fields without needing a rigid, wide audit table.
- **Compact diffs** — comparing `old_row` and `new_row` for a single audit
  row shows exactly what changed, without needing a separate column per
  tracked field.
- **Indexable** — JSONB supports GIN indexes, so large audit tables can
  still be searched efficiently by specific field values if needed later.
