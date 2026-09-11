# 002. One SQL file ships now; the rest of the executable assets stay a specification and an issue

**When:** 2026-09-11 (backlog rows C-02, U-12)
**Status:** in force

## The problem
The skill demands 18 mechanical artifacts (static rules with fixtures, `tests-declared`, glossary and coverage checks, permission SQL, a canary harness) and ships none: every one is re-derived per project, at an estimated 495k tokens per full run, with a different guard each time (`audit/02-usability.md` § 4). One of them, the `pg_proc.proacl` query, is retyped in three files and is wrong in all three: a NULL ACL prints as an empty cell, which is the default-privileges case the check exists to catch (`audit/01-integrity.md` A6-02).

## The choice
`sql/verify-permissions.sql` ships in this run: the corrected `proacl` query with `coalesce(..., 'DEFAULT: PUBLIC CAN EXECUTE')`, the `pg_class` row-security flags, the policies listing joined to the full table list, and a header stating that a null ACL is a P1 and that the queries run as the API roles, never as the owner. The three files that retyped the query now point at it. Everything else in `audit/specs/executable-assets.md` (16 scripts, 5 semgrep rules, fixtures, `stack-map.json`) is committed as a specification and opened as an issue, not applied.

## Why and what we rejected
*Apply the whole spec now.* It is the largest single usability win, but it is new tooling: it needs fixtures, a self-test and a run on a real project before it can be trusted, and this run has no host project to run it on. Shipping untested guards contradicts the skill's own rule that a rig must have failed once before it counts.

*Fix the query text in the three places.* Three copies of a query the skill says must be one; the drift between them is how the defect survived.

*Ship nothing non-prose, keep the skill "Markdown only".* Leaves a P1 in place and keeps the retyping. The skill's documentation for Claude Code explicitly allows a `scripts/` folder, so the shape is supported.

## Where it lives in the code
`sql/verify-permissions.sql`; pointers in `areas/data-security.md` § Rules, `briefs/phase-0-diagnosis.md` D2, `briefs/phase-2-data.md` R2.2. Spec: `audit/specs/executable-assets.md`.

## What would change our mind
A first live run of Phases 1 and 2 on a host project. If the run re-derives the static rules and the tests-declared check again at the estimated cost, the spec is applied in the next evolution round, fixtures first.
