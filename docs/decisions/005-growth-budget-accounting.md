# 005. What counts against the +15 % growth budget, and what is cut in exchange

**When:** 2026-09-11 (backlog § Growth accounting)
**Status:** in force

## The problem
The brief allows the corpus to grow by at most 15 % over the measured 28,768 words (28 Markdown files at `c32367a`), unless a decision record justifies more and names what was cut. This run adds new files (`modes/triage.md`, `examples/one-defect.md`, `sql/verify-permissions.sql`) and a large volume of audit material. A budget without a definition of what is counted is not a budget.

## The choice
The count covers every file a mode can load: `SKILL.md`, `README.md`, `procedure.md`, `GLOSSARY.md`, `modes/`, `areas/`, `briefs/`, `templates/`, `examples/`, `sql/`. It is measured with `wc -w` over those paths and recorded before and after in the PR description. `audit/`, `docs/decisions/` and `CHANGELOG.md` sit outside every load list and cost nothing at runtime, so they are outside the count; wave 4 verifies that no skill file references `audit/`.

Cut in exchange for the additions: the ten-fold "These are defaults…" sentence (kept in two loaded places), the sixteen-fold language rule (kept in five), the three retyped SQL queries (now one file), and the four restatements of "the only mandatory checkpoint" (now one sentence and pointers). If the measured total exceeds 33,083 words, rows go in the order listed in `audit/06-backlog.md` § Growth accounting, `triage` first.

## Why and what we rejected
*Count every file in the repository.* Would count the audit against the skill; the audit is evidence for the PR, not text any run loads.

*Count tokens per mode instead of corpus words.* More precise, harder to reproduce with one command; the per-mode table in `audit/01-integrity.md` § 3 is kept as the secondary check.

*Exceed the budget for the executable assets.* Rejected in decision 002 for a different reason (untested tooling); the budget would also have been exceeded.

## Where it lives in the code
`audit/06-backlog.md` § Growth accounting; the PR description's before/after table; `audit/verification.md`.

## What would change our mind
Token cost per mode measured on a live run turning out to matter more than corpus words (for example, if `run 4` with its hidden dependencies made explicit crosses a context threshold). Then the budget is restated per mode.
