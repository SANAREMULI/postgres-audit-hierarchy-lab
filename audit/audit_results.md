# Audit Log Results

## Test Script

`audit/audit_test.sql` runs the following operations against the `students`
table, which has `trg_audit` attached:

```sql
UPDATE students SET name = 'Kofi M.' WHERE id = 1;
DELETE FROM students WHERE id = 3;

SELECT tbl, op,
       old_row->>'name' AS was,
       new_row->>'name' AS now,
       at
FROM audit_log
ORDER BY at DESC;
```

## Query Output

```
UPDATE 1
DELETE 1
   tbl    |   op   |     was     |   now   |              at
----------+--------+-------------+---------+-------------------------------
 students | DELETE | Yaw Boateng |         | 2026-08-17 18:53:53.775723+00
 students | UPDATE | Kofi Mensah | Kofi M. | 2026-08-17 18:53:53.772547+00
(2 rows)
```

## Changes Captured

| Operation | Row Affected  | Before               | After                 |
|-----------|---------------|-----------------------|------------------------|
| UPDATE    | student id 1  | name = 'Kofi Mensah'  | name = 'Kofi M.'       |
| DELETE    | student id 3  | name = 'Yaw Boateng'  | (row removed, `new_row` NULL) |

Both changes were captured automatically by `trg_audit` without any
application-level logging code — the trigger fired as part of the same
transaction as the `UPDATE`/`DELETE` statements.

## Differences Between Old and New Values

- On **UPDATE**, `audit_log.old_row` holds the full pre-change row as JSONB
  (`to_jsonb(OLD)`), and `audit_log.new_row` holds the full post-change row
  (`to_jsonb(NEW)`). Only `name` changed here, but every column of the row
  is preserved, so any column's before/after value can be recovered later
  even if the application didn't originally query for it.
- On **DELETE**, `old_row` contains the full row as it existed immediately
  before deletion, and `new_row` is `NULL` since there is no "after" state.
- On **INSERT** (exercised implicitly by the seed data in `V1__core_tables.sql`),
  `old_row` would be `NULL` and `new_row` would contain the inserted row.

This before/after pairing is what makes the audit log useful for rollback
investigations and compliance review — every change is reconstructable from
a single row in `audit_log`.
