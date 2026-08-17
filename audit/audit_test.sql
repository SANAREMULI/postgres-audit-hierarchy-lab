-- audit/audit_test.sql
-- Exercises the audit trigger with an UPDATE and a DELETE, then reads the trail

-- 1. Update a student's name
UPDATE students SET name = 'Kofi M.' WHERE id = 1;

-- 2. Delete a student record
DELETE FROM students WHERE id = 3;

-- 3. Query the audit trail
SELECT tbl, op,
       old_row->>'name' AS was,
       new_row->>'name' AS now,
       at
FROM audit_log
ORDER BY at DESC;
