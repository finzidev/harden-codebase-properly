# Performance and loading

Principle: **slowness is almost always a shape problem, not a speed problem** — where you read, how many times, and under what timeout window. Measure against real data, put the date next to every number, and verify the on-screen numbers match before and after.

## Target state

- [ ] No hot path loads a full table to filter it in memory; every occurrence of the `.all()` equivalent is justified.
- [ ] Database-side pagination with an **exact** count wherever a number is shown to a user or gates an action; an estimate only where nobody reads it as truth `[PostgREST v12 count]`.
- [ ] Counts and aggregations run in the database (`count(*) group by`, a dedicated function), never in memory after pulling down the join.
- [ ] One read per thing being viewed: tabbed pages split into routes with their own reads.
- [ ] Independent reads run in parallel; one `<Suspense>` per slow piece; a skeleton per route.
- [ ] Cache only the **stable periphery**, with a short TTL **and** tag invalidation `[RFC 9111 § 4.4]` co-located with the write inside the service (never in the action); the invalidation call must work from every path that reaches the service (in Next.js 16, `revalidateTag(tag, { expire: 0 })`, not `updateTag`, which throws outside a Server Action `[Next.js 16.3.4]`).
- [ ] An explicit list of what **never enters cache**: consents and deletions, locks and revocations, counts that precede an irreversible action, data-layer health status, the number on the "apply to all N" button.
- [ ] Search and sort normalized on a **generated, indexed column**, never on a runtime expression built in application code (Postgres indexes expressions; the client cannot be trusted to emit the matching one `[PostgreSQL § 11.7]`); empty strings become real `NULL`s.
- [ ] Every cap declares `truncated`, and the screen says so.
- [ ] A round of paginated requests sits **above** the timeout guard (a per-request window, a batched parallel round, the first page alone as a probe).
- [ ] Every volume number carries the date it was measured.
- [ ] Framework configuration proposals are verified against the **installed** package, not against the latest version's documentation.

## What to measure

1. **Baseline on real data**: milliseconds and round-trips for the three most-visited pages, against the production database or a bench of the same cardinality. A dev sample lies — the shape of the defect changes with order of magnitude.
2. **Full-scan inventory**: `grep -rn "\.all()" src/features` (or the local equivalent), with file:line and the path that hits it.
3. **Reads per page**: count adapter calls needed to open every hot page; separate what the view actually needs from what's read "just in case."
4. **In-memory counts**: search for `length`, `reduce`, `filter(...).length` on read results inside services.
5. **Cache**: does one exist? with tags? who invalidates it, and where (service or action)? does it hold anything used to decide something?
6. **Timeout**: is there a request loop running inside a guard meant for a single request? At what data volume does it always fail?
7. **Hot columns with no index**; searches using `unaccent(`, `lower(`, `nullif(` inside `.order(` or `.eq(` in application code.
8. **Caps**: `grep -rnE "\.limit\(|limit:\s*[0-9]{3,}" <src>` in bulk actions; does every occurrence declare truncation?

Measurement method: no external profiler is needed. Isolate the function, count calls by reading the adapter, run the query in both forms for five rounds and take the median, compare the dev sample against real data, verify with the real client against the real database (a defect can exist only on the real branch). After the change: same path cold and warm, time and round-trips, and **identical on-screen numbers** before and after.

## Repairs

The path is the briefs: `briefs/phase-3-performance.md` R3.1–R3.8. Diagnosis measures: D3.

## Rules with mechanical verification (specified here; `sql/` ships the queries, the brief builds the rest)

- Never `.all()` plus an in-memory filter on a hot path: grep for it, every occurrence justified.
- Every cache invalidates next to the write inside the service: cross-check declared tags against invalidations in the same file; a two-path test; check the call, not only its location: a Server-Action-only API in a shared service is a latent throw on the webhook path.
- Never an empty `catch {}` around an invalidation: swallow exactly one recognized condition ("outside a request"), rethrow everything else.
- Normalizations run on a generated column: grep for SQL functions inside `.order(` / `.eq(` returns empty.
- Every fixed bulk `limit` declares `truncated`.
- Every paginated loop goes through a batched-round helper above the guard, never a `while` inside the timeout window.
- A configuration proposal is verified inside `node_modules`, and the default found there is written as a comment next to the line **not** added.

## Known traps

- **Advice from the latest version's docs** applied to an older one: it sounds measured, cites a precise default, and is wrong or makes things worse.
- **A broad `catch {}` around an invalidation**: passes the tests, silently kills the update in production.
- **Caching decision-critical data** that "looks peripheral."
- **A timeout guard wrapped around the whole round**: looks like a flaky network, is actually deterministic and tied to data growth.
- **An estimate instead of a count**, "close enough anyway": measure the real difference (often a few milliseconds) before sacrificing correctness.
- **A volume number with no date**: true only on the day it was written.
- **`NOT NULL` with an empty string** instead of `NULL`: sorting "works by coincidence" in one direction only.
- **Eagerly loading everything that might be needed** on a tabbed page: you always pay for it, and only one tab ever gets looked at.
