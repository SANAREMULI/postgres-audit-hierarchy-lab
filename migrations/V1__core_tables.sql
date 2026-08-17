-- V1__core_tables.sql
-- Core application tables for the bootcamp database

CREATE TABLE IF NOT EXISTS students (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    email       TEXT UNIQUE NOT NULL,
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS courses (
    id          SERIAL PRIMARY KEY,
    title       TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, course_id)
);

-- Sample seed data used throughout the lab
INSERT INTO students (name, email) VALUES
    ('Kofi Mensah', 'kofi@example.com'),
    ('Ama Owusu',   'ama@example.com'),
    ('Yaw Boateng', 'yaw@example.com')
ON CONFLICT DO NOTHING;

INSERT INTO courses (title) VALUES
    ('Database Systems'),
    ('Web Development')
ON CONFLICT DO NOTHING;
