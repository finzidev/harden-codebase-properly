# The procedure

Applies to any project. It runs in the order of the confirmed plan (`modes/diagnose.md` § Plan), one step at a time, and every phase has the same cycle. The orchestrator **does not write code**: it dispatches, reads, decides, verifies.

Instructions here are in English. Outputs (reports, decision records, register entries, lessons, commit messages) use the host project's language, detected in Phase 0 and recorded in the stack map.

Code structure belongs to the sibling skill `design-software-properly` (`SKILL.md`, intro): assumed here, scheduled when the diagnosis shows it missing, never redone.

## The cycle of a phase

At the start of every phase: `git status --short`. Files under `docs/` written by this procedure are expected; anything else stops the phase until the user says whose it is; the list goes in the ledger row.

Before every step, read `docs/remediation/status.md`; after every step, tick its row with the evidence (`modes/status.md`). A row without evidence is not done. The ledger has eight rows per repair phase (Phase 0 has four, the re-diagnosis three): it splits Dispatch into "briefs filled" and "dispatch", and Repair into "repairs" and "variant search", so that each has its own evidence.

1. **Dispatch.** All the agents the brief marks parallel, in **a single message**, background, explicit `model`; the brief's order line wins over this sentence. Before dispatch, write the allocation table into `<remediation>/NN-<phase>/synthesis.md`: `file | agent | shared?`. A file in two lists forces sequencing, never parallelism; a shared file has one owner and the other briefs say "stop and say so". The verifier receives the table as `<allocation>`. The briefs live in `briefs/phase-N-*.md`: copy them and fill in the `<…>` placeholders with data from the diagnosis. After dispatching, stop: no polling. An agent that returns nothing, or returns without its report file, is dead: re-dispatch it once with the identical brief; twice failed, its area is recorded "not measured — agent failed twice". Never infer its findings.
2. **Synthesis.** Once all reports are in, the orchestrator writes `docs/remediation/NN-<phase>/synthesis.md`: a table of measurements, the defect queue, proposals with cost and risk. No repair yet.
3. **Decision.** What gets repaired in this phase, and in what order. For every reversible choice: a decision question through `modes/decision-qa.md`, then a decision record in `docs/decisions/` (`templates/decision-record.md`). Ask-first items and decision questions go to the user **once per phase**, in a single multiple-choice question that collects every point (`SKILL.md` § Non-negotiables).
4. **Repair.** Repair agents, one per area, **non-overlapping files** (the allocation table), a brief with the diagnosis already inside it, a starting number, and a done criterion. The agent receives **only** the brief, whatever interfaces from earlier steps it needs, and the global constraints: never the session history, never the whole plan. **It never spawns other agents.** Every repair leaves behind a test that was red once, and every closed defect triggers a **search for variants** (`briefs/phase-1-gates.md` § Common repair header).
5. **Verification.** A verifier agent (`briefs/verifier.md`) in two stages: **compliance with the brief** (every line of GOAL and DONE, yes or no, with evidence; nothing beyond scope), then **quality** (gates, re-measurement, canary, diff scope). The orchestrator trusts the verifier, **never the repair agent's own report**, and never tells the verifier what to ignore.
6. **Exit.** `docs/remediation/NN-<phase>/report.md`: before/after, defects closed, defects still open with a reason, decision records written, open questions. One line in `docs/remediation/lessons.md` (§ Artifacts in the project). If the exit criteria are not met, repeat steps 4-5 on the residue (see "Convergence"). Then the next phase.

## Autonomy contract

**The run does alone (through agents)**: measurements and reports; database reads (`select` only); repairs in the working tree; tests, skeletons, lint, static rules; caches and invalidations; UI skeletons and feedback; writes to `docs/remediation/` and `docs/decisions/`.

**Asks first**, collecting the points into one question per phase: deleting surfaces or dead code; any write to the real database (migrations, grants, policies); removing an alternative view or changing visible behavior that no decision record covers; touching live external integrations (email, backup, sync); anything that contradicts a decision record in the registry; the commit of the phase's repairs (asked in the phase's batched question; the answer goes in the Exit row).

**Never**: commit or push without explicit authorization; touch production; read or copy secrets into reports; `git stash` (the tree may be shared with another session); declare "done" without the verifier; tell the verifier what to ignore; dismiss a rejection without a ruling line in the register; repair in person instead of resuming the agent.

**Host precedence.** The host's `CLAUDE.md`, settings and conventions win on names and places (commands, package manager, folders, docs language, branch and commit-message format); this contract wins on actions (commit mandate, `git stash`, production, secrets, the verifier). A conflict on an action is a decision question, never a silent choice.

**Safe stopping points.** Only at a phase boundary whose Exit row carries evidence, and before any ask-first execution. Stopping elsewhere: say so, and keep the two `status.md` header lines current: `Applied to the real database: <migration|grant> on <date>` (one per line, never removed) and `Working tree: uncommitted repairs from phases <list> · guards wired into CI: <yes/no> · new environment: <none|name>`.

## Artifacts in the project

```
docs/remediation/
  00-diagnosis/
    stack-map.md            what things are called here (build, lint, unit, e2e, DB, actions, cache)
    <area>.md                one report per agent
    synthesis.md             unified measurements, defect queue, approved plan
  NN-<phase>/
    synthesis.md             (after dispatch)
    report.md                (after verification: before/after)
  defect-register.md        id | class | severity (P1 blocks handover · P2 must be fixed · P3 when touched) | effort (S/M/L) | file:line | where it lands | phase | status (open · closed · parked) | proof | ruling
  lessons.md                 one line per phase: what was surprising, ambiguous briefs, traps; read by the next phase's briefs and by whoever maintains the skill
  re-diagnosis.md            the diagnosis rerun at the end, with the diff of the numbers
  status.md                  the evidence ledger: one row per step with evidence (`templates/status.md`)
  reviews/<date>-<branch>.md a diff reviewed against the target state (`modes/review.md`)
  drift-<date>/              periodic delta diagnosis (`modes/maintain.md`)
docs/decisions/              one decision record per reversible choice (shared with the sibling skill)
docs/operations/             runbooks (Phase 6) · docs/handover/ minutes and plan (Phase 7) · docs/client/ organizational questions
```

The sibling skill writes `docs/design/` and `docs/architecture/` (layers, owners, effect map); this procedure reads them when present and never writes there.

These are defaults; host conventions win (§ Autonomy contract, Host precedence) and the stack map records them.

Numbers live **only** in the phase reports and in the re-diagnosis; each phase's `synthesis.md` points to them.

## Placeholders used in the briefs

`<repo>` path · `<stack>` one line (framework, DB, test runner) · `<map>` the contents of `stack-map.md`; a cell that reads "not found" makes the gate that needs it "not runnable", never "passed"; the verifier line stays with the cell quoted as evidence · `<remediation>` = `docs/remediation` · `<files>` file list from the diagnosis · `<before>` starting number with its date · `<record>` the binding decision record from the registry · `<scratch>` the session's temp folder · `<N>` phase number · `<area>` diagnosis area name · `<date>` today, ISO · `<project>` project name · `<language>` host project's language from the stack map · `<commit>` the commit of the last synthesis or drift report (delta mode) · `<base>`/`<head>` the revision range under review · `<list>` a list from the diagnosis · `<n>` a count · `<file:line>` · `<command>` from the stack map · `<file>` · `<path>` · `<route>` · `<components>` · `<src>` · `<actions>` · `<services>` · `<tests>` · `<migrations>` · `<routes>`, folders from the map · `<allocation>` the allocation table.

Only declared tokens are slots; `<label>`, `<Suspense>` and other HTML in prose are not. Dispatch = the harness's agent tool, in the background where it has one, `model` named, the brief as the whole prompt.

---

## Phase 0: read-only diagnosis

Lives in `modes/diagnose.md`: entry checks, dispatch of D0–D5, synthesis, the ordering rules, the plan question, exit criteria, delta mode. Nothing below starts before the plan is confirmed and `status.md` shows Phase 0 closed (the plan question: `SKILL.md` § Non-negotiables).

---

## Phase 1: quality gates and enforcement

**Entry.** The diagnosis synthesis; `stack-map.md`.

**Dispatch.** Briefs in `briefs/phase-1-gates.md`: `R1.1` single verification script and lint at zero errors · `R1.2` custom static rules with tests · `R1.3` red e2e tests (fixed on the property, or `fixme` with a reason) · `R1.4` "tested against" declaration in tests. `R1.1` first; the rest in parallel (the brief's order line). The dependency rule in lint is the sibling skill's brief R1.2, which assumes this phase's verify script.

**Typical repairs.** Blocking lint errors; tests with no declaration; static rules shipped without a fixture.

**Verification.** The verification script runs green start to finish; a static rule fires when a suppression is removed; `tests-declared` fails when a header is removed.

**Exit.** Gates green and at `error`; e2e with no background red; every test declares its world or is on the frozen exemption list.

---

## Phase 2: data and security

**Entry.** Diagnosis queries already run (policies, grants, environments); channel list with the date of the last test. If D2 reported "not measured" on policies or grants, R2.2 is not dispatched: the step is parked with a ruling line and the ask-first question becomes "give read-only database access, or accept Phase 2 without permissions". A migration written against an unread database is a guess.

**Dispatch.** Briefs in `briefs/phase-2-data.md`: `R2.1` fail-fast configuration module · `R2.2` RLS policies and grants: **migration proposal** plus verification queries (applying it is ask-first) · `R2.3` migrations: idempotency, replay, order relative to deploy · `R2.4` tokens and sessions: rejection causes, online/offline, revocation runbook · `R2.5` dates as instants · `R2.6` channels: live-test plan with an injected failure (running it is ask-first) · `R2.7` webhook idempotency, idempotency keys on external calls, transactional outbox and reconciliation.

**Decision.** Applying the permissions migrations; running the live tests; rate-limiting policy (a "pending" decision record if the client's input is needed).

**Verification.** Startup in production with a missing variable fails; policy and grant queries come back clean **after** applying the migration; migration replay succeeds; test on the three token outcomes; test on the two date shapes; "same event twice, one effect" on every webhook.

**Exit.** The security checklist from `areas/data-security.md`, with every item checked off or declared open with its own question.

---

## Phase 3: performance

**Entry.** A dated baseline on real data (if real data is unreachable: a test bed of the same cardinality, declared as such).

**Dispatch.** Briefs in `briefs/phase-3-performance.md`: `R3.1` full scans → targeted access (one agent per hot path) · `R3.2` counts and aggregations moved into the database (functions: migration is ask-first) · `R3.3` per-page reads and paginated routes · `R3.4` peripheral cache with tags, invalidation in the service, a list of what is never cached · `R3.5` per-request guard and wave-based batching · `R3.6` generated columns and indexes (migration: ask-first) · `R3.7` declared caps · `R3.8` per-route skeletons and `<Suspense>`.
`R3.1`-`R3.3` take separate service files; `R3.4` runs after `R3.3`.

**Verification.** The same baseline re-measured, cold and warm; **the on-screen numbers match** before and after; two-path test on the cache; grep for full scans comes back empty, or each hit is justified.

**Exit.** A before/after table for every operation in the baseline, with dates.

---

## Phase 4: interface

**Entry.** The UX inventory from D4; the table shell and the field registry, built by the sibling skill or scheduled in the plan (repairs land on the shell when it exists, on the existing list components otherwise, and are repeated once the shell arrives); counts in the database (Phase 3).

**Dispatch.** Briefs in `briefs/phase-4-interface.md`, in **stages**, not all at once:
Stage A: `R4.1` tokens and color language (everything else renders through them).
Stage B (parallel, separate files): `R4.2` auto-apply filter panel · `R4.3` single view per list (removing views is ask-first) · `R4.4` read-only pages plus mounted, hidden editors · `R4.5` two tracks for actions · `R4.6` feedback, discriminated outcomes, isolated irreversible action · `R4.7` per-route skeletons and navigation · `R4.8` readable errors and five distinct states · `R4.9` labels, hints, tooltips, glossary · `R4.10` worded outcomes after every action, confirmations with quantities, announced deadlines, self-explanatory reports.

**Verification.** Existing e2e tests green; no "Apply" button; `grep -rn "disabled" <components>` empty or justified; the read → Edit → Cancel cycle verified against `FormData`; grep for `error.message` and digest reaching the client comes back empty; fields without a label = 0; icons without `aria-label` = 0; glossary script at zero; every visible error path has a test on its text.

**Exit.** Report with: screens converted / excluded with a reason; the "Target state" checklists from `areas/interface.md` and `areas/user-communication.md` with every item checked off or declared open.

---

## Phase 5: tests that tell the truth

**Entry.** Gates green; repairs from Phases 2-4 landed.

**Dispatch.** Briefs in `briefs/phase-5-tests.md`: `R5.1` canary on every harness (one agent per harness) · `R5.2` e2e warm-up · `R5.3` acceptance checklist generated from code with automatic checks · `R5.4` dirty fixture corpus with a manifest · `R5.5` assumed guards: a test that actually invokes the action · `R5.6` adversarial bug hunt, in rounds (the `bugtcher` skill if available, otherwise three hunters with different lenses plus a skeptic, reproduction mandatory) · `R5.7` channels exercised live (running it is ask-first, planning it is not) · `R5.8` flow test for every multi-module process, including its failing steps (one agent per process).

**Verification.** For every invariant, a red result logged with a date; checklist checks at zero; corpus with an oracle and an observed count; every hunt finding backed by an executed artifact; every process in the list has its flow test, and every webhook has its "twice, one effect" test.

**Exit.** `defect-register.md` updated; no background red e2e.

---

## Phase 6: documentation that is measured

**Entry.** All decisions from earlier phases, each with a decision record.

**Dispatch.** Briefs in `briefs/phase-6-documentation.md`: `R6.1` counted index · `R6.2` numbers in a single place · `R6.3` decision registry: completeness checked against the round's commits · `R6.4` guide from a single source, with coverage · `R6.5` debt register with a trigger · `R6.6` questions in one place, by recipient · `R6.7` runbook · `R6.8` architecture and features rewritten against the code.

**Verification.** Counts reproducible on command; guide coverage at zero gaps, or gaps listed; every debt marker has a line; grep for duplicate numbers comes back empty.

**Exit.** `docs/INDEX.md` as the single entry point.

---

## Phase 7: handover

**Entry.** Phases 1-6 closed; the re-diagnosis done (below).

**Dispatch.** Briefs in `briefs/phase-7-handover.md`: `R7.1` handover plan in stages · `R7.2` fresh environment: accounts, empty database, regenerated secrets (running it is ask-first) · `R7.3` migration replay and table verification · `R7.4` backup and restore proven in the new environment · `R7.5` channels proven in the new environment · `R7.6` signed minutes.

**Verification.** Migration replay with table, function and policy counts as expected; restore proven with counts; every channel seen arriving in the new environment, with a date; no team credential in any config; minutes signed.

**Exit.** The checks above green; every P1 with status `parked` listed in the minutes by id with its Ruling line verbatim and its cost-if-wrong, signed by the client as a separate item; a parked P1 absent from the minutes blocks the handover.

---

## Re-diagnosis (after Phase 6, before Phase 7)

**Phase 0 is rerun identically** (same briefs, same commands) and `docs/remediation/re-diagnosis.md` is written: a table of measure | before | after | command. Every line that got worse, or stayed unchanged with no written reason, reopens the corresponding phase. The diagnosis agents read the earlier reports and mark every defect in the register: **RESOLVED / UNCHANGED / NEW**; a defect marked closed in the register and found again by the diagnosis is a P1. A parked defect found again is marked RE-CONFIRMED with the date and its ruling re-priced. At most two reopenings per run; then back to the plan question. `re-diagnosis.md` resolves every evidence path in `status.md` and reports `evidence cells: <n> claimed, <n> existing`; any gap is a P1. Lines expected to **increase**: number of tests, number of decision records, number of channels with a live-test date.

## Convergence

A phase closes when the exit criteria are met **and** the verifier confirms it. If the verifier rejects the work:

- **Rounds 1-3**: **resume the same agent** (its context is intact) with the rejections quoted verbatim, not summarized. On resumption, the verifier looks **only at the diff of the fix**: for every rejection, RESOLVED / NOT RESOLVED, and new breakage only within that diff.
- **Round 4**: a **fresh agent on a more capable model**, given the brief, the previous report, and the line "an agent has tried three times, now it's yours". At most two round-4s per phase; then the residue is ruled.
- **After round 4**, the orchestrator decides, for each residue: **parked**, with a line in the defect register `Ruling: <decision> — <why> — <cost if wrong>` and a decision record marked "decided, being applied" or "pending"; or **structural**, which blocks and returns to the plan, because silently parking a structural defect means everything that follows gets built on top of it.

No residue disappears without a line. A declared residue is worth more than a forced green.
