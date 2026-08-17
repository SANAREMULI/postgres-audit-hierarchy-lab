-- V2__audit_log.sql
-- Audit log table, trigger function, and trigger attachment

CREATE TABLE IF NOT EXISTS audit_log (
    id          SERIAL PRIMARY KEY,
    tbl         TEXT NOT NULL,
    op          TEXT NOT NULL,
    old_row     JSONB,
    new_row     JSONB,
    changed_by  TEXT NOT NULL DEFAULT current_user,
    at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

DROP TRIGGER IF EXISTS trg_audit ON students;
CREATE TRIGGER trg_audit
AFTER INSERT OR UPDATE OR DELETE ON students
FOR EACH ROW EXECUTE FUNCTION audit();
