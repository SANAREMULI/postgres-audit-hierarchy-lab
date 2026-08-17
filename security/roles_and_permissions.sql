-- security/roles_and_permissions.sql
-- Least-privilege roles for application access

-- Read-only role: can connect and SELECT, nothing else
CREATE ROLE app_read;
GRANT CONNECT ON DATABASE bootcamp TO app_read;
GRANT USAGE ON SCHEMA public TO app_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO app_read;

-- Read-write role: can connect and SELECT/INSERT/UPDATE/DELETE
CREATE ROLE app_write;
GRANT CONNECT ON DATABASE bootcamp TO app_write;
GRANT USAGE ON SCHEMA public TO app_write;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_write;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_write;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_write;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO app_write;

-- Neither role is granted CREATE, DROP, TRUNCATE, or ownership rights,
-- and neither is a superuser. This keeps application connections limited
-- to exactly the operations they need.
