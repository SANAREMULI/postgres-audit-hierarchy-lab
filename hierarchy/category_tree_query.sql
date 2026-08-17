-- hierarchy/category_tree_query.sql
-- Recursive CTE that walks the category tree from root to leaves
-- and prints an indented hierarchy.

WITH RECURSIVE category_tree AS (
    -- Anchor member: root categories (no parent)
    SELECT
        id,
        name,
        parent_id,
        1 AS depth,
        name::TEXT AS path
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    -- Recursive member: children of the previous level
    SELECT
        c.id,
        c.name,
        c.parent_id,
        ct.depth + 1 AS depth,
        ct.path || ' > ' || c.name AS path
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT
    repeat('    ', depth - 1) || name AS hierarchy,
    depth,
    path
FROM category_tree
ORDER BY path;
