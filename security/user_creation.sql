-- security/user_creation.sql
-- Creates the application login user in the app_write role.
--
-- NOTE: replace 'strong-secret' with a securely generated secret
-- (e.g. from a secrets manager) before using this outside the lab.

CREATE USER api
LOGIN PASSWORD 'strong-secret'
IN ROLE app_write;

-- Example of a second, reporting-only user in the read-only role:
-- CREATE USER reporting
-- LOGIN PASSWORD 'another-strong-secret'
-- IN ROLE app_read;
