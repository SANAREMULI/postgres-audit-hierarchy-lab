# Category Hierarchy Design

## Adjacency-List Hierarchy Design

The `categories` table uses the **adjacency-list model**: each row stores
a reference to its own parent (`parent_id`), and the tree shape emerges
from following those references rather than from any explicit
tree-structure column. It's the simplest way to represent a hierarchy in
a relational table — one extra nullable column — at the cost of needing a
recursive query (rather than a single flat `WHERE`) to read more than one
level at a time.

## Self-Referencing Foreign Keys

```sql
CREATE TABLE categories (
    id        SERIAL PRIMARY KEY,
    name      TEXT NOT NULL,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE
);
```

`parent_id` is a foreign key that points back to `categories.id` in the
same table:

- `parent_id IS NULL` marks a root node (e.g. `Electronics`).
- Any other row's `parent_id` must match an existing `id` in the same
  table, which is what the foreign key constraint enforces — it's
  impossible to insert a category whose parent doesn't exist.
- `ON DELETE CASCADE` means deleting a category also deletes its entire
  subtree, since children reference it directly and grandchildren
  reference the children.

## Recursive CTE Traversal

`hierarchy/category_tree_query.sql` reads the tree with `WITH RECURSIVE`:

1. The **anchor member** selects all rows with `parent_id IS NULL` — the
   roots — starting `depth` at 1 and `path` at just the category's name.
2. The **recursive member** joins `categories` back to the CTE's own
   growing result set (`c.parent_id = ct.id`), pulling in each node's
   direct children, incrementing `depth`, and appending to `path`.
3. PostgreSQL repeats step 2 against the newly added rows until a pass
   returns nothing new, at which point the full tree has been collected.
4. The final `SELECT` indents each row by `depth` to render the tree
   visually and orders by `path` so children stay grouped under their
   parents.

This is what lets a single, fixed query handle a tree of any depth: three
levels in this lab's sample data, but the same query works unmodified for
a much deeper category tree.
