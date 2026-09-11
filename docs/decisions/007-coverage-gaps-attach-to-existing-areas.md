# 007. The coverage gaps attach to existing areas and briefs as checklist lines; nothing new is a phase or an area

**When:** 2026-09-11 (backlog rows V-01…V-13; `audit/04-coverage.md` § 3)
**Status:** in force

## The problem
The coverage pass confirmed six of ten hypotheses outright (supply chain, object-level authorization, input validation, rollback, regression budget, non-web translation) and four in part. Four are P1: a method whose premise is safety applies migrations, grants and environments with no backout, and its strongest control (deny-all RLS) is never evaluated on the request path because the data layer holds the service key. The brief forbids adding a phase ("eight is already at the edge") and forbids generic security prose.

## The choice
Every gap lands as one to three target-state lines, a trap row, or a brief clause inside the area and briefs that already own the subject: `areas/data-security.md` for authorization, input, supply chain, web surface, secrets, observability, rollback and the outbox; `briefs/phase-1-gates.md` R1.2 for the two new static rules; `briefs/phase-5-tests.md` R5.5 for the wrong-owner test; `briefs/phase-2/3/7` for the backout; `modes/maintain.md` for the regression rate; `areas/user-communication.md` for the five accessibility criteria. Classes that belong to nobody here (platform and perimeter, identity infrastructure, repository governance, post-handover operations, native code) become five bullets in `SKILL.md` § When not to use it. Total added: about 900 words.

## Why and what we rejected
*A new area `areas/attack-surface.md` with its own diagnosis agent D6 and brief set.* Cleaner on paper, a seventh agent in Phase 0 and a ninth row block in the ledger in practice, on a method the brief says is already at the edge of what a user runs to the end.

*Import the ASVS chapters the skill lacks.* The coverage pass listed them (V1, V4, V5, V12, V14.1, V16.1/V16.4). Most are platform or generic; the skill's value is the specific control in its own voice, and "a control the skill does not need is noise".

*Leave the gaps to the sibling skill.* None of them is code structure; the sibling's mandate is layers, coupling and duplication.

## Where it lives in the code
`areas/data-security.md` § Security, § Migrations, § Integrations; `briefs/phase-1-gates.md`, `phase-2-data.md`, `phase-3-performance.md`, `phase-5-tests.md`, `phase-7-handover.md`; `modes/maintain.md`; `SKILL.md` § When not to use it.

## What would change our mind
A live run where the data-security brief set (now R2.1–R2.7 plus the added lines) exceeds what one phase closes. Then the added lines split into a Phase 2b with its own briefs, and this record is superseded.
