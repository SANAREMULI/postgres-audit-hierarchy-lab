-- audit/audit_trigger.sql
-- Reusable audit logging system: table, trigger function, and trigger

-- 1. Audit log table -----------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
    id          SERIAL PRIMARY KEY,
    tbl         TEXT NOT NULL,          -- table that changed
    op          TEXT NOT NULL,          -- INSERT / UPDATE / DELETE
    old_row     JSONB,                  -- row values before the change
    new_row     JSONB,                  -- row values after the change
    changed_by  TEXT NOT NULL DEFAULT current_user,
    at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Trigger function ------------------------------------------------------
CREATE OR REPLACE FUNCTION audit() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (tbl, op, old_row, new_row, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, NULL, to_jsonb(NEW), current_user);
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (tbl, op, old_row, new_row, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD), to_jsonb(NEW), current_user);
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (tbl, op, old_row, new_row, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD), NULL, current_user);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3. Attach trigger to the students table -----------------------------
DROP TRIGGER IF EXISTS trg_audit ON students;
CREATE TRIGGER trg_audit
AFTER INSERT OR UPDATE OR DELETE ON students
FOR EACH ROW EXECUTE FUNCTION audit();
