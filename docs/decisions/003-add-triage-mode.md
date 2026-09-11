# 003. A `triage` mode is added: one agent, ten greps, three findings, no ledger

**When:** 2026-09-11 (backlog row U-09)
**Status:** in force

## The problem
First contact with the skill is `diagnose`: six agents, an estimated 1.4M billed tokens and 20–45 minutes before the user reads a sentence (`audit/02-usability.md` § 2). A first contact that expensive is one many users abandon, and an abandoned Phase 0 leaves nothing behind.

## The choice
A seventh mode, `triage`, loaded from `modes/triage.md` only: one read-only `sonnet` agent runs ten fixed greps, returns three findings with the command and the date, writes nothing under `docs/`, ticks no ledger row, and ends by offering `diagnose`. Its numbers are marked "not a baseline"; the diagnosis re-measures with its own commands. Cost: about 2 % of Phase 0.

## Why and what we rejected
*No triage; make Phase 0 cheaper instead.* Phase 0's cost is the briefs and the two target-state comparisons, not waste; cutting it weakens the baseline every later phase re-measures against. The size band (backlog U-08) already trims it for small projects.

*A triage that can also repair the three findings.* Rejected outright: a repair on a triage number is a repair with no before/after, the first red flag in `SKILL.md`. The mode's "What it must not do" section closes this door and the anchoring risk with it.

*Fold the greps into `diagnose` step 0.1.* Keeps the same wait before the first output; solves nothing.

## Where it lives in the code
`modes/triage.md`; the router row in `SKILL.md` § Modes; the `argument-hint`.

## What would change our mind
Evidence from live runs that users who start with `triage` skip `diagnose` and ask for the three findings to be fixed. Then the mode is removed and its greps go back into the diagnosis brief.
