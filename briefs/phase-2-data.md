# Phase 2 Brief: Data and Security

Common header: as in `phase-1-gates.md`, plus: **no writes to the database**. Migrations are written into the repo and applied only after the user's go-ahead, by a dedicated agent, with the verification query run immediately after. Reference: `areas/data-security.md`.

Parallel: `R2.1`, `R2.4`, `R2.5` with each other. `R2.2` and `R2.3` touch the migrations: one at a time. `R2.6` is read-only plus a plan.

---

### R2.1 Fail-fast configuration module
`model: sonnet` · files: config module (`lib/config/env.ts` or equivalent), `.env.example`, a test `env-placeholder.test.ts` (or the host project's equivalent)
CONTEXT: required variables: <list from D2>; fail-fast today: <yes/no>; secrets for distinct purposes: <list>.
GOAL: in production the app refuses to start if a required secret is missing, equals the example's placeholder, or two secrets for distinct purposes coincide; in development, a clear message; the same module sets the security headers (CSP with `frame-ancestors`, HSTS, `X-Content-Type-Options`, `Referrer-Policy`) and the cookie attributes in one place.
HOW: one module loaded at startup; validates presence, non-placeholder, shape (URL, minimum length); the error names the variable but NEVER the value.
DON'T: log values; use silent defaults in production; use public variables for secrets.
TEST: a test that simulates `NODE_ENV=production` with one variable missing and one equal to the placeholder: it must throw; one test asserts the headers and the cookie attributes.
DONE: test green, and red on the canary; list of variables with their rule.

### R2.2 Row-level security and grants: proposed migration plus verification
`model: sonnet` · files: a new migration (not applied), `sql/verify-permissions.sql` (shipped with this skill) copied into the repo as `verify-permissions.sql`
CONTEXT: from D2: tables without a policy: <list>; functions executable by public roles: <list>; functions rewritten without reasserting grants: <list>.
GOAL: active deny-all policies on every table; every sensitive function with an explicit `revoke execute from public, anon, authenticated` and `alter default privileges … revoke execute on functions from anon, authenticated`; grants only to the expected roles; idempotent migration.
HOW: write the migration starting from the LATEST definition of every function (grep every migration that touches it, diff against the most recent); reassert the grants in the same migration. Do not retype the verification queries: run `sql/verify-permissions.sql` as the API roles (`anon`, `authenticated`); a null ACL, a policy with `qual = true`, or a table with row security off is a rejection.
DON'T: apply it; use `revoke from public` alone; rewrite a function from an old version.
DONE: migration in the repo with a header explaining why; verification file with expected results; note in the report: "apply after the go-ahead, then run verify-permissions.sql."

### R2.3 Migrations: idempotency, replay, order relative to deploy
`model: sonnet` · files: non-idempotent migrations (from D2), a test `migrations-idempotency.test.ts` (or the host project's equivalent), `docs/operations/RELEASE.md` (or the existing release checklist)
CONTEXT: migrations: <n>; non-idempotent: <list>; squashes present: <yes/no>; CLI and app on the same DB: <yes/no>.
GOAL: every migration rerunnable (`if not exists`, `drop … if exists`, `create or replace`); a test that replays them twice on an ephemeral DB, or analyzes them statically; release checklist with "migration applied and column present on the DB BEFORE the code push" and "CLI project reference = the env's host"; every migration carries its reverse in the same file or a written line saying why not and what the recovery is, with its data-loss window; `RELEASE.md` carries the forward order **and the backout order**, and for each step the observation that says it worked and the one that says stop.
DON'T: squash migrations; touch the database.
TEST: apply, reverse, apply again on an ephemeral database; table state matches after each; canary: remove one reverse, the test fails.
DONE: list of migrations fixed; release checklist written; one row per migration: migration | reverse | recovery if none | data-loss window.

### R2.4 Tokens, sessions, revocation
`model: sonnet` · files: token signing/verification module, session guards, `docs/operations/ACCESS-REVOCATION.md`, test `token-three-outcomes.test.ts` (or the host project's equivalent)
CONTEXT: from D2: does verification distinguish the three outcomes? <yes/no>; does the embedded expiry win online? <yes/no>; does a password change revoke access? <yes/no>.
GOAL: `verifyToken` returns a separated cause (unreadable / invalid signature / expired); online, the entity read from the DB can only narrow what the token allows; offline, the token decides; runbook with a "what it hits, what it doesn't" table (password, session secret, signing secret, revocation counter), plus two more sections: where each secret lives and its rotation trigger; leaked secret: revoke, rotate, purge, then investigate, in that order.
DON'T: make the signature check optional; collapse everything into a single `null`.
TEST: test on the three outcomes; with the DB reachable, the entity can only narrow what the token allows: an expired token is rejected even if the entity is valid; a revoked entity is rejected even if the token is valid; offline, the token decides `[ASVS 5.0 V9.2.1]`; canary.
DONE: tests green, and red on the canary; runbook written.

### R2.5 Dates as instants
`model: sonnet` · files: `sameInstant` / `isAfter` helpers in `lib/format` (or equivalent), the comparisons found by D2, test `timestamps-two-forms.test.ts` (or the host project's equivalent)
CONTEXT: timestamp comparisons done as strings: <file:line>.
GOAL: no `===`/`!==` between timestamps re-read from the DB; comparison by instant.
HOW: helper plus replacement; test with the two literal forms (`+00:00` and `Z`) because the fake adapter has no real columns and does not reproduce the defect.
TEST: red on the old code, green on the new one.
DONE: grep of the comparisons = 0.

### R2.6 Channels: live test plan with an injected failure
`model: sonnet` · READ-ONLY plus `<remediation>/02-data/channels-plan.md`
CONTEXT: channels from D2 with their last-tested date: <list>. Backup: success read from <first link / last link>.
GOAL: for every channel (transactional email, alert email, dead-letter, backup, sync): how to inject a real failure, what must arrive, where the arrival is observed (a run log line written by the last link, not the first 200), who runs it and when. Look for optional fields sent empty to the provider (empty arrays, empty strings) that one message family sends and another doesn't.
DON'T: run the tests (ask first).
DONE: plan with one line per channel and the proposed code fixes (e.g. omit a field when empty) to be assigned after the go-ahead.

### R2.7 Webhook idempotency, keys on external calls, outbox and reconciliation
`model: sonnet` · files: the webhook handlers (from the coupling diagnosis of the sibling skill `design-software-properly`, D3, when it exists; otherwise found in this brief), the external calls made by the processes (payments, email, sync), a `received_events` table (or the host project's equivalent) (migration, not applied), a reconciliation job, the tests
CONTEXT: from the coupling diagnosis of the sibling skill `design-software-properly` (D3) when it exists, otherwise measured in this brief: handlers without dedupe: <list>; external calls without a key: <list>; multi-table writes outside a transaction: <file:line>; reconciliation: <absent / present>.
GOAL: every handler records the external event id before acting and ignores duplicates (unique constraint on the received-events table); every external call that creates something carries an idempotency key derived from the internal entity; writes that must land together sit in one transaction or go through an outbox with retry; a job periodically compares external state against internal state and reports the differences (never silently fixes them).
DON'T: apply the migration; fix reconciliation differences without a visible outcome; dedupe in memory (it does not survive a restart).
TEST: for every handler, a "same event twice, one effect only" test; a test "external call succeeds, write fails → the retry or the reconciliation catches it"; canary.
DONE: table handler | dedupe | test; external calls with their key; reconciliation job with a readable outcome (see user-communication.md).
