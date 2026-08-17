-- V3__categories.sql
-- Self-referencing category hierarchy table and seed data

CREATE TABLE IF NOT EXISTS categories (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    parent_id   INTEGER REFERENCES categories(id) ON DELETE CASCADE
);

INSERT INTO categories (name, parent_id) VALUES ('Electronics', NULL);

INSERT INTO categories (name, parent_id)
SELECT 'Computers', id FROM categories WHERE name = 'Electronics';

INSERT INTO categories (name, parent_id)
SELECT 'Phones', id FROM categories WHERE name = 'Electronics';

INSERT INTO categories (name, parent_id)
SELECT 'Laptops', id FROM categories WHERE name = 'Computers';
