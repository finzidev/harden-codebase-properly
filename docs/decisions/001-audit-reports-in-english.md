# 001. The audit reports and this register are written in English

**When:** 2026-09-11 (branch `evolve/audit-01`, before wave 1 was dispatched)
**Status:** in force

## The problem
The evolution brief left `<LANG>` unfilled and suggested Italian as the example. The skill's own rule is "outputs in the host project's language" and the host project here is the skill itself: a public repository whose corpus, README and commit history are English.

## The choice
Every file under `audit/`, `docs/decisions/` and `CHANGELOG.md` is written in English. Quotations from the skill stay verbatim. The skill corpus stays English, as the brief required.

## Why and what we rejected
*Italian.* The author reads it and the brief hinted at it, but the PR reviewer is whoever opens the repository, and an audit that the reviewer cannot read without translation is not evidence. The skill's own "host project's language" rule resolves to English here, so this is an application of the rule, not an exception.

*Bilingual (Italian reports, English summaries).* Two languages in one PR doubles the maintenance of every number and quotation, which the skill forbids for numbers ("a number written in two places diverges").

## Where it lives in the code
`audit/*.md`, `docs/decisions/*.md`, `CHANGELOG.md`.

## What would change our mind
The maintainer stating that the audit audience is Italian-only. Then the reports are translated once, the English copies are deleted, and this record is superseded.
