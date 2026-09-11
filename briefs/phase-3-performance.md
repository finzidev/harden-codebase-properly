# Phase 3 Brief: Performance

Common header: as in `phase-1-gates.md`, plus: **parity before speed**: every fix leaves a test that compares the on-screen numbers before and after. Reference: `areas/performance.md`.

Parallel: `R3.1`, `R3.2`, `R3.3` on **distinct** services (one agent per hot path). `R3.4` after `R3.3`. `R3.5`, `R3.7`, `R3.8` in parallel with the others as long as they don't touch the same files. `R3.6` writes a migration (applying it: ask first).

---

### R3.1 Full scan → targeted access (one agent per hot path)
`model: sonnet` · files: `<service>`, `<adapter>` if a targeted method is missing, parity test
CONTEXT: path `<page/action>`: today `<before>` round-trips, `<ms>` ms on <date> over `<cardinality>` rows; full scan at `<file:line>`.
GOAL: same result with targeted access (`byField`, `byIds`, DB-filtered query); DB-side pagination with an exact count.
HOW: if the targeted method is missing from the ports, add it to **both** adapters with the same semantics; "tested against: both" test.
DON'T: use an estimated count; change the on-screen numbers.
TEST: parity test (same output before/after on a known dataset); remeasure ms and round-trips.
DONE: before/after with date; grep of the full scan on the path = 0.

### R3.2 Counts and aggregations in the database
`model: sonnet` · files: a migration with the counting function (not applied), `<service>`, fake adapter with the same semantics, test
CONTEXT: count `<which>` today done in memory after downloading `<n>` rows in `<k>` round-trips.
GOAL: one `count(*) group by` function (or equivalent) called once; the fake adapter replicates it in memory with the same contract; grants reasserted in the migration; no hidden `limit`.
DON'T: apply the migration; cache the count if it is used to decide something.
TEST: parity test between the old and new count on a known dataset, "tested against: both."
DONE: migration in the repo with a header; expected before/after; note "apply after the go-ahead."

### R3.3 Per-page reads and tabbed routes
`model: sonnet` · files: the route `<route>` and its sub-routes, the loaders
CONTEXT: opening `<route>` today takes `<before>` reads; only `<k>` are needed for what is actually shown.
GOAL: one route per tab with its own reads; independent reads in `Promise.all`; one `<Suspense>` per slow piece.
DON'T: add "just in case" reads; unmount editors (see Phase 4).
TEST: count of adapter calls per route (test with a counting adapter).
DONE: reads before/after per route.

### R3.4 Peripheral cache with tags and invalidation in the service
`model: sonnet` · files: `lib/peripheral-cache` and `lib/invalidation` (or the host project's equivalents), the services that write, test `revalidate-two-paths.test.ts` (or the host project's equivalent)
CONTEXT: peripheral data reread on every interaction: <list>; writes that change it: <service:function>; different paths that call the same service: <list: action, sync, import>.
GOAL: cache only on stable peripheral data, short TTL AND tags; invalidation co-located with the write **inside the service**; a written list of what never enters the cache (consents and deletions, locks and revocations, pre-deletion counts, data-layer health, the number on the "apply to all" button); a `catch` that swallows exactly one recognized condition and rethrows everything else; verify the invalidation API against the installed major (this brief assumes `unstable_cache` / single-argument `revalidateTag`: Next.js 14–15; on 16 use `revalidateTag(tag, { expire: 0 })` from shared services, never `updateTag` outside a Server Action).
DON'T: invalidate from the action; use an empty `catch {}`; cache anything used to decide something.
TEST: a test that writes through two paths (an action and a second path) and reads fresh; canary: remove one invalidation, the test must turn red.
DONE: table tag | who invalidates | where; the non-cacheable list in the code; the one-line kill switch that turns the cache off, and the test that the product is correct with it off.

### R3.5 Per-request timeout, batched parallel pagination on top
`model: sonnet` · files: pagination/resilience helpers in the data layer, the loops found by D3, test
CONTEXT: loops inside the guard: <file:line>; with `<n>` rows the loop makes `<k>` requests in `<s>` s inside a `<t>` s window.
GOAL: timeout window scoped per **request**; a helper that runs the loop in parallel batches (first page alone as a probe, then batches of 8); every paginated loop goes through it.
TEST: test starting red: a loop of N slow pages must not fail on an overall timeout.
DONE: list of loops converted; loop timing before/after.

### R3.6 Generated columns and indexes
`model: sonnet` · files: a migration (not applied), the application code that uses runtime expressions
CONTEXT: from D3: SQL expressions inside `.order(`/`.eq(`: <file:line>; hot columns without an index: <list>; empty strings in `NOT NULL` columns used for ordering: <list>.
GOAL: a generated column for every normalization (accent-insensitive, digits-only, `''` → `NULL` for ordering), an index (a partial one is fine) on it; the code orders and filters by column name.
DON'T: apply it; keep the runtime expression "just in case."
TEST: after it is applied (verification phase): `explain` uses the index; parity test on ordering with empties trailing.
DONE: migration with a header; code ready; note "apply after the go-ahead, then remeasure."

### R3.7 Declared caps
`model: sonnet` · files: the bulk actions with a fixed `limit` (from D3), the components that show the number
CONTEXT: undeclared caps: <file:line>.
GOAL: every count that could be a cap returns `truncated: true`, and the screen says so ("at least N"); no irreversible action starts on an ambiguous number.
TEST: test with a dataset above the cap: `truncated` true and the correct wording.
DONE: list of caps with their on-screen rendering.

### R3.8 Per-route skeletons and Suspense
`model: sonnet` · files: a `loading.tsx` (or equivalent) for every route with reads, the shared skeleton primitive
CONTEXT: routes with reads and no skeleton: <list>. Real-component metric: <e.g. `px-4 py-3` cells>.
GOAL: one skeleton per route that mirrors the real layout (table, card, header), `aria-hidden`; the container with `role="status"` and `aria-busy`.
DON'T: use one generic shared skeleton; put a skeleton on frequent commands (that's Phase 4's feedback signal).
TEST: build green; every route with reads has the file.
DONE: list of routes covered.
