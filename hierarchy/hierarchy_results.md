# Category Hierarchy Results

## Query Used

```sql
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
```

## Hierarchy Output

```
    hierarchy    | depth |               path
-----------------+-------+-------------------------------------
 Electronics     |     1 | Electronics
     Computers   |     2 | Electronics > Computers
         Laptops |     3 | Electronics > Computers > Laptops
     Phones      |     2 | Electronics > Phones
(4 rows)
```

Which corresponds to the intended tree:

```
Electronics
├── Computers
│    └── Laptops
└── Phones
```

## How Recursive CTEs Work

A recursive CTE (`WITH RECURSIVE`) has two parts joined by `UNION ALL`:

1. **Anchor member** — runs once and produces the starting rows. Here it
   selects every category with `parent_id IS NULL`, i.e. the roots of the
   tree (`Electronics`).
2. **Recursive member** — refers back to the CTE's own name
   (`category_tree`) and is re-executed repeatedly. Each pass joins
   `categories` to the *previous* result set on `c.parent_id = ct.id`,
   pulling in the next level of children. `depth` is incremented and
   `path` is extended by one step on each pass.
3. **Termination** — PostgreSQL keeps re-running the recursive member
   until a pass produces zero new rows (i.e. no more children are found).
   At that point the recursion stops and all accumulated rows are unioned
   together as the final result.

This lets a single query walk an arbitrarily deep adjacency-list tree
without knowing its depth in advance — three levels here, but the same
query would work unmodified for ten levels.
