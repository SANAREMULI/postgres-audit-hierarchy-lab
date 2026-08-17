# Reflection

Working through this lab connected four database engineering practices
that I'd previously only understood in isolation, and it was useful to
see how they reinforce each other in a single project.

**Audit logging** turned out to be less about "adding a log table" and
more about pushing correctness down to the layer where changes actually
happen. Writing the `audit()` trigger function made it clear why
application-level logging is fragile: any code path that touches the
`students` table — a script, a different service, a manual `psql`
session — gets audited automatically, without remembering to call a
logging function. Using JSONB for `old_row`/`new_row` was the detail that
surprised me most; instead of designing a rigid audit schema with a
column per tracked field, the entire row is captured as-is, and
individual fields can still be pulled out later with `->>`. That
flexibility scales naturally if the underlying table's schema changes.

**Recursive queries** were the part I had to think through most
carefully. The adjacency-list model (`parent_id` referencing the same
table) is deceptively simple to create, but reading it back requires the
`WITH RECURSIVE` anchor/recursive-member pattern to actually walk the
tree. Building `path` and `depth` incrementally in the recursive member,
and watching PostgreSQL stop automatically once a pass returns no new
rows, made the mechanics click in a way that just reading about CTEs
hadn't. It's a good example of a query that stays correct even if the
tree's depth changes later, since nothing about the query is hard-coded
to three levels.

**Versioned migrations** reframed schema changes as code, not as one-off
commands typed into a terminal. Splitting the work into `V1`, `V2`, and
`V3` files, each independently reviewable and each responsible for one
concern (core tables, audit infrastructure, categories), made it obvious
why teams prefer this over ad-hoc `ALTER TABLE` statements: the sequence
is reproducible in any environment and the history is permanent and
queryable.

**Least-privilege security** was the most immediately practical part.
Separating `app_read` from `app_write`, and creating a login user that
inherits from `app_write` rather than connecting as a superuser, is a
small amount of extra setup that meaningfully shrinks what a compromised
or buggy application connection can do — it can't drop the audit trigger,
alter roles, or touch other schemas.

If I had to pick the single most useful topic, it would be **audit
logging combined with least privilege**, since they compound: an
audit trail is only trustworthy if the accounts capable of writing to the
tables it monitors are themselves tightly scoped and can't disable the
trigger that produces it.
