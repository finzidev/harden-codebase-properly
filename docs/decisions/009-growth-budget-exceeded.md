# 009. The corpus exceeds the +15 % budget by about 540 words; the overage is kept, and here is what was cut in exchange

**When:** 2026-09-11 (after wave 3; measured with `wc -w` over the loadable files, see decision 005)
**Status:** in force

## The problem
Budget: 33,083 words (28,768 + 15 %). Measured by the verifier after the patch set: **33,622** (+4,854, +16.9 %, 539 over); 33,462 without `sql/verify-permissions.sql`. The verifier's residues add a few dozen words more; the final figure is in `audit/verification.md`. The six patch authors received per-group caps summing to +4,400; two groups overran (areas a: +1,157 against 900; briefs b and templates: +981 against 700) because the mandated text of the P1 rows cost more than the backlog's estimate. Every other group landed at or under its cap.

## The choice
Keep the overage. It sits almost entirely in three files, each carrying a P1 repair or a P1 coverage class: `areas/data-security.md` (+849: object-level authorization, rollback, supply chain, boundary validation, web surface, observability, the corrected grant and token claims), `briefs/verifier.md` (+248: the canary protocol that reverted repairs, the provenance of every verifier input), `modes/diagnose.md` (+304: the two-wave dispatch, the size band, the register formats a cold agent had to guess). Cutting to the line would remove the lowest-precedence rows in the backlog's order (`triage`, the regression rate, the threat list), and removing `modes/triage.md` alone (427 words) would still leave the corpus 109 words over. Correctness and coverage outrank usability in the mandate, so the usability rows are not the ones to cut to pay for a correctness overrun; the overrun is declared instead.

Cut in exchange, all restatements whose claim survives at one canonical site: the "These are defaults…" sentence in eight of ten files; the language rule in nine of sixteen sites; the three retyped permission queries; four restatements of "the only mandatory checkpoint"; the sibling paragraph, the variant-search tail, the `lessons.md` description and the batching clause in `procedure.md` (now pointers); the verifier's `cmp` rationale; `templates/agent-brief.md` (−24) and `templates/decision-record.md` (−31). About 600 words removed; without them the total would be near 34,200.

## Why and what we rejected
*Cut `triage` and the two P3 rows to land at the line.* Still 109 words over, and it spends the one addition that changes first contact to pay for the lines that fix a permission check reading the broken state as clean.

*Cut coverage lines from `areas/data-security.md`.* They are the four confirmed P1 gaps; the brief ranks coverage above usability and forbids softening a P1.

*Restate the budget per mode.* Honest but a change of rule mid-run. The per-mode numbers are recorded here for the next round instead: the corpus growth is not the only cost that moved. Making hidden dependencies explicit (they were already paid as guesses) raised every mode's declared load. Whole files named by the cell, `SKILL.md` excluded on both sides, before → after: `status` 834 → 5,722 (the cell names `procedure.md` § Autonomy contract only; the whole file is counted here), `diagnose` 5,441 → 9,509 (17,496 with the six areas handed to the agents), `run 2` 7,397 → 11,060, `run 4` 8,625 → 11,566, `maintain` 3,500 → 7,844. The next evolution round should split `procedure.md` (§ Autonomy contract, § Convergence, § Phases) so that section-level loads cost section-level tokens (backlog X-05, issued).

## Where it lives in the code
`audit/06-backlog.md` § Growth accounting; the PR description's before/after table; `audit/verification.md`.

## What would change our mind
A live run showing that the added lines in `areas/data-security.md` are not consulted by the Phase 2 agents (they read the brief, not the area). Then the coverage lines move into the brief and the area keeps one pointer each, and the budget is re-measured.
