# Phase 6 Brief: Documentation That Measures Itself

Common header: as in `phase-1-gates.md`, plus: **count, don't remember**: every count in a document comes from a command reported alongside it. Reference: `areas/method-documentation.md`, `templates/decision-record.md`.

Parallel: all of them with each other, except `R6.2`, which runs after `R6.1`.

---

### R6.1 Counted index
`model: sonnet` · files: `docs/INDEX.md` (these are defaults: if the host project already has a docs language and folder convention, use it — the stack map records it)
GOAL: a single front door with one line per folder (role, file count from the command, "where to start"); a "if you want to know… read…" table.
HOW: `find docs -type f | sed 's|/[^/]*$||' | sort | uniq -c`; write the count with the command next to it, in a comment.
DONE: every folder has a line; counts are reproducible.

### R6.2 One number, one place
`model: sonnet` · files: the documents that repeat the same count (from D5)
GOAL: every number lives in one document; the others point to it with a link.
TEST: grep of the number in `docs/` finds a single occurrence (or only pointers).
DONE: table number | where it lives | pointers replaced.

### R6.3 Decision register: completeness against the commits
`model: sonnet` · files: `docs/decisions/README.md`, missing records
CONTEXT: candidates without a record from D5: <list>; decisions made in phases 1-5: <list from the phase reports>.
GOAL: one record for every reversible choice made in the round, dated from the commit, with the rejected alternatives; the two open-questions tables (client / internal); records for "why someone will bring this up again," rejected mistakes, non-decisions.
HOW: number them by listing the whole folder; every record cites an **existing** file, migration, or test.
TEST: a script or test that verifies every "where it lives" points to an existing file.
DONE: records written; tables updated.

### R6.4 Guide from a single source, with coverage
`model: sonnet` · files: the in-app guide's source (`sections.ts` — or the host project's equivalent), `scripts/generate-guide.mjs` (or the host project's equivalent), `docs/guide/`, `docs/guide/coverage.md`
CONTEXT: guide today: <generated / hand-written / absent>; undocumented routes: <n>; named commands that no longer exist: <list>.
GOAL: a printable guide generated from the same source as the in-app guide; every step with the words someone would search for; figures as real screenshots or declared placeholders (never gaps); `coverage.md` that cross-checks the real routes against the source and lists the gaps.
DON'T: use drawings instead of screenshots; keep sections that name commands that no longer exist.
TEST: coverage script exits 0 or lists the gaps; grep of the vanished commands = 0.
DONE: routes covered / uncovered; missing screenshots listed for capture.

### R6.5 Debt register with a reopening trigger
`model: sonnet` · files: `docs/planning/TECH-DEBT.md`, the markers in the code
CONTEXT: markers without a line: <n> (from D5); re-export barrels and documented refusals written by the sibling skill `design-software-properly`: <list>.
GOAL: one line per debt item: origin, destination, priority, reopening trigger; every marker in the code has a line; every line has a marker or a file.
TEST: grep of the markers against the register: aligned.
DONE: complete table.

### R6.6 Questions in a single place, by audience
`model: sonnet` · files: `docs/decisions/README.md` (product table), `docs/client/open-questions.md` (organizational)
CONTEXT: scattered questions found in: <chat, reports, records, work log>.
GOAL: every question in one of the two lists, with the record that informs it and what it's blocking; internal questions kept separate from organizational ones; a declared tie-breaker if a question lives in more than one place.
DONE: count per list, with the date.

### R6.7 Operational runbooks
`model: sonnet` · files: `docs/operations/BACKUP-RESTORE.md`, `MONITORING.md`, `ACCESS-REVOCATION.md`, `RELEASE.md`
CONTEXT: existing: <list>; executed: <yes/no>.
GOAL: every runbook with executable steps, where the outcome is read (run log line, query), a "what it hits, what it doesn't" table for revocation, a "migration before code" checklist for release; whatever has never been executed is **declared** as such at the top.
DONE: runbooks written; not-executed declarations with their date.

### R6.8 Architecture and features against the code
`model: sonnet` · files: `docs/architecture/*.md`, `docs/features/*.md`
GOAL: every structural claim (layers, forbidden imports, tables, routes) counted against the code with the command next to it; every feature record with a freshness note (date and commit).
TEST: the numbers in the documents match the commands.
DONE: documents rewritten, or marked "needs rewrite" with a reason.
