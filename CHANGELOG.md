# Changelog

## evolve/audit-01 (2026-09-11) — first audit-and-repair round, against `c32367a`

The audit evidence is under `audit/` (summary: `audit/SUMMARY.md`; backlog with every id below: `audit/06-backlog.md`); reversible choices are under `docs/decisions/001`–`009`. One line per backlog id, grouped by what it buys the reader. Corpus: 28,768 → 33,699 words after the verifier's residues were applied (decision 009; `audit/verification.md` § Re-verification).

### More correct

- C-01 `create or replace function` does not reset grants (PostgreSQL 12–18); the trap is drop+create or a changed signature. `areas/data-security.md`, `SKILL.md`, `GLOSSARY.md`.
- C-02 The permission queries move into one shipped file, `sql/verify-permissions.sql`: a null ACL prints as `DEFAULT: PUBLIC CAN EXECUTE` (a P1, not a pass), `pg_class` row-security flags, every policy's predicate; run as the API roles, never the owner. Three retyped copies replaced by pointers.
- C-03 `npx gitleaks` cannot run; the brief now names the Go binary and `gitleaks dir . --no-banner`.
- C-04 Online, the database entity can only narrow what a token allows, never extend it past its own expiry (ASVS 5.0 V9.2.1); R2.4's test inverted accordingly.
- C-05 "Lint Errors block the build" is qualified: on Next.js 16 lint is its own verify step; `next lint` removed from the diagnosis template.
- C-06 Cache invalidation must use an API callable from every path that reaches the service; R3.4 verifies the API against the installed major (`updateTag` throws outside a Server Action).
- C-07 Phase 0 dispatches in two waves: D0 alone, then D1–D5 with the stack map.
- C-08 `copies` and `churn` come from the sibling's diagnosis; absent, ordering uses defects-landing alone.
- C-09 A dead agent is re-dispatched once, then recorded "not measured — agent failed twice"; never inferred.
- C-10 `grep disabled` gains `-rn` and a path.
- C-11 One cap regex everywhere, matching `.limit(1000)` too.
- C-12 The token-escape regex is case-insensitive for hex.
- C-13 Every brief runs its commands from `<repo>`; recursive greps carry a path.
- C-14 `error\.message` escaped.
- C-15 Decision numbering no longer hides `ls` failure behind a pipe.
- C-16 Superseded by F-03: the canary baseline is now the working-tree file, so the new-file caveat is unnecessary; not applied.
- C-17 "Eight rows per repair phase; Phase 0 has four, the re-diagnosis three."
- C-18 `R5.1–R5.8`; the decision record's parts are counted.
- C-19 "The run does alone (through agents)."
- C-20 `git stash` is never allowed, for everyone: the tree may be shared.
- C-21 The commit of a phase's repairs is an ask-first item, answered in the phase's batched question.
- C-22 Phase 7 has a Verification paragraph.
- C-23 The plan question is "the only checkpoint that always fires"; every ask-first item blocks too. Four restatements became pointers.
- C-24 Phase 7 is the declared exception to one question round per phase.
- C-25 The batched question is asked once the repair step has produced the artifacts it approves.
- C-26 "The brief's order line wins" over "all agents in one message".
- C-27 Placeholders: seven recurring tokens declared, `<N>` no longer doubles as a word cap, literals and HTML are not slots.
- C-28 A `disabled` field is absent from `FormData`, not "cleared"; `readonly` is the submitted case; a hidden `required` field blocks submission silently (HTML § 4.10.22.4, § 4.10.21.2).
- C-29 `aria-busy` withholds announcements; a `role="status"` message names the pending and finished state (WAI-ARIA 1.2, WCAG 4.1.3).
- C-30 The ARIA-props claim corrected: the gap is a component that declares but does not spread them.
- C-31 Color by verb also carries the verb in the label (SC 1.4.1); the destructive confirmation is SC 3.3.4; tooltips follow SC 1.4.13 and 2.5.3.
- C-32 The build's advantage is prerendering every route unvisited; `$LASTEXITCODE` on PowerShell; expression indexes exist, the client is the constraint; exact counts where a number is read as truth; the dev server is a different build; `--mutate` and build-log strings marked unverified.
- C-33 "Public roles" replaced by "the API roles (`anon`, `authenticated`)"; default-privilege entries are per grantor role.
- C-34 Timestamp `!==` holds for differently serialized strings; the `tags: []` and `router.push()` stories labeled as seen once.
- C-35 Destructive migrations split (add and backfill before, drop after); "never squashed" conditional on a stateless runner.
- C-36 The documentation map is an audience/lifecycle taxonomy, not Diátaxis; the tutorial named at handover.
- C-37 The six conditions are this skill's scope, not a quality model.
- C-38 "Rules with mechanical verification" say what is specified and what is shipped.
- C-39 API names were written against Next.js 14; Phase 0 re-verifies every named API against the installed major.

### Evidence

- E-01 One default-provenance sentence in `SKILL.md` § Note on the stack; 45 inline citation keys on the rows that rest on HTML, PostgreSQL, ASVS, WCAG, ARIA, POSIX, RFC 3339, RFC 9111, Next.js and three papers (decision 006).
- E-02 Just et al. 2014, Yuan et al. 2014 and Sadowski et al. 2018 cited on the canary, the invoke-it test and lint at zero Error.
- E-03 README origin numbers marked not reproducible here.

### Easier to use

- U-01 Every mode's Load cell names its real dependencies (the common repair header, `templates/status.md`, the autonomy contract, the decision-record template, the areas each diagnosis agent gets); `briefs/phase-1-gates.md` gains a `## Common repair header` heading and `Reference: areas/quality.md`.
- U-02 `review` and `maintain` load § Convergence; the verifier's diff mode points at it.
- U-03 Frontmatter: `argument-hint` and `compatibility` added; `disallowed-tools` rejected (the orchestrator writes docs).
- U-04 Seven failure-and-recovery rules: DB unreachable in Phase 2, dirty tree at phase start, resume onto a half-repaired tree, uncommitted repairs from a previous session, two sessions on one repo, a build blocked by missing env, a "not found" stack-map cell.
- U-05 Phase 0 names its five report files, the register columns, the two decision tables, `<pending D0>`, one P1 definition, `lessons.md` in the create list.
- U-06 Dispatch described harness-neutrally.
- U-07 The `maintain` guard table has a `Command` column and a `Condition` column; "not installed" is never "failing".
- U-08 `modes/diagnose.md` § 0b Size band: three measures, three bands, fan-out at three, "skipped: <measure> = 0" as the evidence line.
- U-09 New mode `triage`: one agent, ten greps, three findings, no ledger (decision 003).
- U-10 New `examples/one-defect.md`: the chain from measure to decision record on the `disabled`-editor defect (decision 004).
- U-11 README installs the sibling skill; `SKILL.md` § When not to use it carries the "never run live" status before the plan question.
- U-12 The eighteen executable guards: specified in `audit/specs/executable-assets.md`, not applied; issue to open (decision 002).

### Covers more

- V-01 Object-level authorization: three target-state lines and three traps; R1.2 rule (5); R5.5 tests the wrong owner. The text states that RLS on the service key is a perimeter, never evaluated on the request path.
- V-02 Rollback: every migration carries its reverse or a written recovery; `RELEASE.md` has a backout order; R3.4 has a kill switch; R7.2 has the way back.
- V-03 Supply chain: audit in the verify chain, lockfile and pinned CI, SBOM at handover; D1/D2 measures.
- V-04 Input parsed against a schema at every public entry point; R1.2 rule (6).
- V-05 Security headers and cookie attributes in R2.1; sinks, redirect targets, outbound URLs and uploads.
- V-06 Request id end to end, the list of events that must be logged, retention and alert routing; `MONITORING.md` has content.
- V-07 Secret home and rotation trigger; leaked-secret order in the revocation runbook.
- V-08 Webhook idempotency, idempotency keys, outbox and reconciliation now have area rows.
- V-09 The stack map's fourth column, *absent here; replaced by*; the gate table notes its framework-specific rows.
- V-10 § When not to use it names platform, identity infrastructure, repository governance, operations after handover, native code.
- V-11 Five WCAG 2.2 criteria on the accessibility bullet; the EAA does not reach a B2B back-office, EN 301 549 still can.
- V-12 `maintain` has a blast-radius fallback and a regression rate (step 3b).
- V-13 Ordering rule 2 names its threat list; the guide opens with a tutorial and passes its own checks.

### How the method breaks (failure modes)

- F-01 The verifier derives the canary's test list from the tree, never from the repair report.
- F-02 The canary breaks a product file the repair changed, inside the function body; a test that stays green does not cover the product.
- F-03 The canary baseline is the working-tree file (`cp`), never HEAD; a 0-byte baseline aborts; RED is `$?` non-zero and the assertion named; the restore is checked with `git diff --stat`; the unit gate re-runs after the last canary. Mirrored in `areas/quality.md` and R5.1.
- F-04 Verifier inputs have provenance: commands verbatim from the stack map, brief clause counts, MISSING gates, a criterion on skipped tests.
- F-05 Evidence paths must exist (one-line check before dispatch and on resume); the verdict line is copied byte-for-byte; the re-diagnosis resolves every evidence path.
- F-06 Phase 7 lists every parked P1 in the minutes with its ruling, signed separately; the re-diagnosis re-confirms parked defects.
- F-07 Caps: two round-4s per phase, two reopenings per run, four hunt rounds.
- F-08 Safe stopping points; `status.md` header records what was applied to the real database, the tree state, CI wiring, a new environment.
- F-09 An allocation table (`file | agent | shared?`) is written before dispatch; Stage B names one owner for the action files; the verifier flags a diff crossing two owners and re-checks a rejected agent's files in full.
- F-10 Host precedence: the host wins on names and places, the contract wins on actions.
- F-11 Measures that need a running app are marked and deferred to R5.6, never "not measured".
- F-12 The policy predicate is read, not counted (`using (true)` is a hole).
- F-13 R5.6 has `files:`, a diagnosis CONTEXT and a named environment with two accounts.
- F-14 Each acceptance-checklist entry carries the rule it satisfies, from client material.
- F-15 The cache guard compares tag expressions at read and write sites.

### Compression

- X-01 "These are defaults…" kept in `procedure.md` § Artifacts in the project, `briefs/verifier.md` and the common repair header of `briefs/phase-1-gates.md`; removed from eight files.
- X-02 The language rule kept in `SKILL.md`, `procedure.md`, the two common headers and the verifier; removed from nine sites.
- X-03, X-04 The checkpoint restatements and the retyped SQL became pointers.
- X-05 Splitting `procedure.md` § Phases per phase: not applied, issue to open.

### Applied by the orchestrator in person

- `areas/interface.md` known-traps line on skeletons aligned with the corrected `aria-busy` line (flagged by the areas-b author as outside its rows).

### Not done, and why

- The executable guards (`scripts/`, `rules/`, fixtures, `stack-map.json`): untested tooling contradicts the skill's own canary rule; spec committed, issue to open (decision 002).
- `procedure.md` split per phase: structural, ~1,200 tokens per `run`; issue to open.
- Nothing in the sibling skill's territory; no phase added.
