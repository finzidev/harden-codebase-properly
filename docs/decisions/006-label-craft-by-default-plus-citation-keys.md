# 006. Craft is labeled by a default-provenance rule plus citation keys on the sourced rows, not by marking 164 lines

**When:** 2026-09-11 (backlog row E-01; `audit/03-evidence.md`)
**Status:** in force

## The problem
165 of 321 normative rows (51.4 %) are craft distilled from one project, and 164 carry no marker; the one provenance sentence lives in `README.md`, which no mode loads. A reader, or an agent writing a verifier report, cannot tell a WCAG clause from one team's habit because both use the same flat imperative. Nothing in the corpus is self-verifying.

## The choice
Two moves. (1) One sentence in `SKILL.md` § Note on the stack, loaded by every mode: unless a line cites a standard, a specification or a vendor manual, it is distilled from one project (README § Origin), a default to confirm against the host, not a law; it may be adopted, but it may not be cited as evidence in a verifier report or a decision record. (2) Short inline citation keys on the rows that do rest on a primary source and carry weight (HTML § for `disabled`; PostgreSQL for grants; ASVS ids on the security lines; WCAG success criteria on the interface lines; POSIX for the pipe; RFC 9111 for cache). The unmarked rows become self-identifying as craft without touching them.

## Why and what we rejected
*A trailing `(n=1)` on every craft row.* 164 edits, about 330 words, on every run forever, to say what one sentence says once. Also brittle: the next added line will forget the marker and read as sourced.

*Delete or soften the craft rows.* The brief forbids it and the coverage pass shows why: the craft rows (the canary as admission criterion, "tested against", the evidence ledger, the exit code never read through a pipe) are the part no standard requires and the part worth keeping.

*Cite everything, craft included, with "origin project" as the source.* Noise; the default rule already says it.

## Where it lives in the code
`SKILL.md` § Note on the stack; citation keys in `areas/*.md`; the full mapping in `audit/03-evidence.md` and `audit/sources.md`.

## What would change our mind
A second project confirming or contradicting a specific craft row. Then that row gets its own key (`[n=2]` or a vendor citation), or is rewritten.
