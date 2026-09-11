# 02 — Cold-start usability

Question answered: *can a fresh orchestrator, on a project it has never seen, with no memory of any conversation, execute this skill without guessing and without an absurd budget?* Not "is it good".

Method: the three cold-start traces were run **before** the rest of the corpus was read, on the load lists `SKILL.md:18/20/22` declare. All 28 files were then read. Branch `evolve/audit-01`, commit `c32367a`, 2026-09-11.

## Summary

36 findings: **4 P1**, **26 P2**, **6 P3**. The answer is *almost*: the method is executable, but a cold orchestrator guesses at four points where the corpus contradicts itself or asks for a number nothing produces.

The three that matter: **A2-22** — 18 mechanical artifacts are demanded as prose and re-derived per project, an estimated 450-550k tokens per run and a different guard every time (the single largest win). **A2-01/A2-02** — Phase 0's dispatch is unexecutable as written (all six agents in one message, yet five need D0's output), and the multiplier table that drives the entire plan ordering asks for `copies` and `churn`, which no agent in this skill measures. **A2-33** — "the only mandatory user checkpoint" is false in five places; a real run blocks on the user 6-10 times.

Three specs written: `audit/specs/executable-assets.md`, `audit/specs/worked-example.md`, `audit/specs/triage-mode.md`.

---

## 1. Cold-start traces

### (a) `diagnose` — load list `SKILL.md:18`

Files a fresh orchestrator has: `SKILL.md`, `modes/diagnose.md`, `modes/decision-qa.md`, `briefs/phase-0-diagnosis.md`, `templates/status.md`, `templates/diagnosis-report.md`. Nothing else. Imaginary host: a Next.js/Supabase back-office it has never opened.

| step | what it knows | what it must guess | what it would plausibly get wrong |
|---|---|---|---|
| 0.1 notes | the six-step notes protocol, `modes/decision-qa.md:7-14` | — | — |
| 0.1 git clean | `git status --short` must be empty, `modes/diagnose.md:9` | what "stop and say so" means: abort, or ask? whether `docs/`-only dirt counts | stops on an unrelated dirty file and ends the session |
| 0.1 DB reachable | that unreachable ⇒ "not measured", `modes/diagnose.md:10` | the command that establishes reachability | claims "reachable" from the presence of an MCP name |
| 0.1 MCP identity | compare "the project reference or the expected tables", `modes/diagnose.md:11` | **what the expected tables are** — the schema is D0's output, and D0 has not run | skips the check, or invents a table list (**A2-06**) |
| 0.1 create ledger | `templates/status.md` | whether to instantiate all 7 phase blocks now; the header wants a stack-map path and a host language that D0 produces at 0.2 (**A2-07**) | writes a header pointing at a file that does not exist |
| 0.2 dispatch | six agents, `sonnet`, briefs filled | **how to reconcile "all in one message" (`:16`) with "D0 goes first… the other five receive `<map>`" (`:20`)** (**A2-01**) | dispatches all six with `<map>` empty, so D1-D5 guess every local name — exactly what D0 exists to prevent |
| 0.2 dispatch | `model: sonnet`, `run_in_background` | the subagent type; `run_in_background` is not a parameter of this harness's Agent tool (**A2-08**) | passes an unknown field, or picks an agent type with the wrong tools |
| 0.2 brief fill | `<repo> <stack> <map> <date>` defined in `procedure.md` § Placeholders — **not loaded in this mode** | `<remediation>`, `<area>`, and the five report filenames (only `stack-map.md` is named, `:35`) (**A2-05**) | five reports land under five invented names; the verifier's "same commands as the diagnosis" later cannot find them |
| 0.2 wait | "After dispatch, stop: no polling", `:20` | what happens if a report never arrives (**A2-28**) | waits forever, or polls against the instruction |
| 0.3 synthesis | the six report sections | — | — |
| 0.3 places table | `place \| copies \| defects landing \| churn`, `:28` | **where `copies` and `churn` come from** — D4 excludes duplication (`briefs/phase-0-diagnosis.md:96`), churn is the sibling's (`GLOSSARY.md:12`) (**A2-02**) | invents copy counts, and ordering rule 3 (`:41`) ranks multipliers on fiction |
| 0.3 registers | create `defect-register.md` and `docs/decisions/README.md`, `:33` | both formats: columns live at `procedure.md:39`, the two tables at `templates/decision-record.md:44-54`, neither loaded (**A2-03, A2-04**) | a register with invented columns; Phase 6 R6.3 then "completes" a register it cannot parse |
| 0.3 severity | P1/P2/P3, `:27` | which definition: "one step from irreversible damage" (`:27`) or "blocks handover" (`templates/diagnosis-report.md:61`) (**A2-10**) | mixed severities across six reports |
| 0.4 plan question | the exact format, `modes/decision-qa.md:58-67` | — | — |

### (b) `run 2` — load list `SKILL.md:20`, highest blast radius

Files: `procedure.md`, `modes/status.md`, `briefs/phase-2-data.md`, `areas/data-security.md`, `briefs/verifier.md`, `modes/decision-qa.md`, `templates/decision-record.md`.

| step | what it knows | what it must guess | what it would plausibly get wrong |
|---|---|---|---|
| read ledger | resume rules, `modes/status.md:20-27` | — | — |
| fill briefs | R2.1-R2.7 with `<…>` filled from D2 | **the common repair header**: `briefs/phase-2-data.md:3` says "as in `phase-1-gates.md`", which this mode does not load (**A2-12**) | dispatches repair agents with no "do not commit / no `git stash` / tested-against / canary / variant-search" clause — i.e. without the skill's core constraints |
| fill briefs | `<list from D2>` etc. | what to do when D2 wrote "not measured" because the DB was unreachable (**A2-25**) | fills `<tables without a policy>` with a repo-side guess, and Phase 2 repairs a database it never read |
| dispatch | one message, all agents, `procedure.md:13` | `briefs/phase-2-data.md:5` says R2.2 and R2.3 go "one at a time" (**A2-11**) | four agents on the migrations folder at once |
| decision | one batched question per phase at cycle step 3, `procedure.md:15`, ledger row N.4 before N.5 | **when to ask for the migration go-ahead**: R2.2 writes the migration at step 4 and its DONE line says "apply after the go-ahead" (`:24`) (**A2-13**) | asks for blanket approval of a migration that does not exist, or asks a second time and breaks the one-round rule (`modes/decision-qa.md:45`) |
| repair | non-overlapping files | — | — |
| verify | the full two-stage brief | `<command>` for typecheck/lint/unit/build/static rules comes from the stack map; a "not found" cell leaves the line unfillable (**A2-32**) | pastes a plausible npm script that does not exist; verifier reports exit 127 as a rejection |
| verify | "real production build" then `$?`, `briefs/verifier.md:16` | what to do when R2.1's own fail-fast module (`briefs/phase-2-data.md:12`) makes the build refuse to start without production secrets (**A2-31**) | reads the repair's success as a failed gate and opens a rejection round against correct work |
| convergence | rounds 1-3 same agent, round 4 "a more capable model", `procedure.md:165` | which model | — (low harm) |

### (c) `maintain` — load list `SKILL.md:22`

| step | what it knows | what it must guess | what it would plausibly get wrong |
|---|---|---|---|
| guard set | the eight-row table, `modes/maintain.md:9-18` | **"check each guard's presence with its command" (`:22`) — no row carries a command** (**A2-15**) | declares guards present because a plausible file name exists |
| guard set | `Enforces` column: `2, 3, 5 / 2 / 4,5 / 6 / 6 / 2 / 3 / 1` | that these are the six conditions of `SKILL.md:31-36` (**A2-17**) | reads them as phase numbers |
| install | "dispatch the source brief" | the common repair header again (`briefs/phase-1-gates.md`, not loaded) | same as (b) |
| change-time | read `status.md` and `lessons.md`, `:27` | `lessons.md` is created by nothing in Phase 0 (**A2-14**) | reports a broken project state on a diagnosis-only repo |
| drift | delta mode paragraph, `modes/diagnose.md:67` | — | — |
| drift | "Run the read-only scripts (acceptance coverage, guide coverage, debt markers, the live channel table)", `:47` | those exist only if phases 5 and 6 ran (**A2-16**) | reports "guards failed" where the guards were never installed |
| record | `status.md` § Maintenance, `:22/38/49` | `templates/status.md` is not in this load list (**A2-18**) | invents the section on a project whose ledger predates it |

**Findings**

| id | file:line | sev | evidence | change |
|---|---|---|---|---|
| A2-01 | `modes/diagnose.md:16` vs `:20` | P1 | "Six agents, `model: sonnet`, `run_in_background`, all in one message" vs "`D0` goes first when the stack is unknown; the other five receive `<map>` in their brief." On first contact the stack is always unknown. | Rewrite `:16` as "Two waves in two messages: `D0` alone; then `D1`-`D5` in one message with `<map>`." |
| A2-02 | `modes/diagnose.md:28`, `templates/diagnosis-report.md:82` | P1 | "place \| copies (how many implementations exist) \| defects landing there \| churn" — `briefs/phase-0-diagnosis.md:96` excludes duplication, `GLOSSARY.md:12` assigns churn to the sibling skill. | Add to `:28`: "`copies` and `churn` come from `docs/design/00-diagnosis/`; absent, both read `—` and the ordering uses defects landing alone." |
| A2-03 | `modes/diagnose.md:33` | P2 | "Create `docs/remediation/defect-register.md` … if missing" with no format in the loaded set; columns live at `procedure.md:39`. | Append the column line to `:33`. |
| A2-04 | `modes/diagnose.md:33` | P2 | Same for `docs/decisions/README.md`; the two-table format is at `templates/decision-record.md:44-54`. | Append "two tables, client and internal, never merged". |
| A2-05 | `briefs/phase-0-diagnosis.md:19` | P2 | "WRITE the report to `<remediation>/00-diagnosis/<area>.md`" — only D0's filename is fixed (`:35`). | Name the five files in `modes/diagnose.md:18`. |
| A2-06 | `modes/diagnose.md:11` | P2 | "compare the project reference or the expected tables" at step 0.1, before D0 exists. | Add: "if the expected tables are not known yet, defer to D0 and do not use the tool until it confirms." |
| A2-07 | `modes/diagnose.md:12`, `templates/status.md:3` | P2 | The ledger header names the stack map and host language at 0.1; D0 produces both at 0.2. | Add to `:12`: "leave stack map and language `<pending D0>`; fill at 0.3." |
| A2-08 | `SKILL.md:42`, `modes/diagnose.md:16`, `procedure.md:13` | P2 | Dispatch is specified as "`model: sonnet`, `run_in_background`" with no agent type; this harness's Agent tool has no `run_in_background` parameter. | One line in `procedure.md` § Placeholders giving the dispatch call shape, agent type included. |
| A2-09 | `briefs/phase-0-diagnosis.md:18` | P3 | "Max `<2200>` words" — a value inside placeholder brackets. | Drop the brackets. |
| A2-10 | `modes/diagnose.md:27` vs `templates/diagnosis-report.md:61` | P3 | "P1 one step from irreversible damage or data loss" vs "P1 (blocks handover)". | Use the `modes/diagnose.md` wording in both. |
| A2-11 | `procedure.md:13` | P2 | "All of the phase's agents in **a single message**" vs `briefs/phase-1-gates.md:9`, `phase-2-data.md:5`, `phase-3-performance.md:5`, `phase-4-interface.md:5`, `phase-5-tests.md:5`, `phase-7-handover.md:5`, all of which sequence. | "All of the phase's agents the brief marks parallel, in a single message; the brief's order line wins." |
| A2-12 | `SKILL.md:20` | P2 | The `run <N>` load list omits `briefs/phase-1-gates.md`, which holds the common repair header every other phase brief requires. | Add it to the row. |
| A2-13 | `procedure.md:15`, `templates/status.md:24-25`, `briefs/phase-2-data.md:24` | P2 | Decision is cycle step 3, repair step 4, ledger row N.4 before N.5; but R2.2/R3.2/R3.6/R5.7/R7.2 all seek a go-ahead on an artifact step 4 produces. | Add a ledger row "N.4b Go-ahead on artifacts produced in this phase" and one line in `modes/decision-qa.md:45` naming it as the permitted second round. |
| A2-14 | `SKILL.md:46`, `modes/status.md:24` | P3 | "Read `lessons.md`" on resume; nothing creates it before Phase 1 exit. | Add `lessons.md` to the create list at `modes/diagnose.md:33`. |
| A2-15 | `modes/maintain.md:22` | P2 | "check each guard's presence with its command" — the table at `:9-18` has columns `Guard \| Enforces \| Source brief`, no command. | Add a `command` column (values in `audit/specs/executable-assets.md` § 3). |
| A2-16 | `modes/maintain.md:47` | P2 | "Run the read-only scripts (acceptance coverage, guide coverage, debt markers, the live channel table)" — none exist unless phases 5-6 ran. | Append: "a script the project does not have reports *not installed*, and the drift report lists it as a missing guard." |
| A2-17 | `modes/maintain.md:9-18` | P3 | `Enforces` holds bare digits with no key. | Rename the column "Condition (`SKILL.md` § What a production-grade product is)". |
| A2-18 | `SKILL.md:22` | P3 | The `maintain` load list omits `templates/status.md`, though `modes/maintain.md:22/38/49` all write `status.md` § Maintenance. | Add it. |

---

## 2. Time to first value

**Assumptions, stated.** Brief tokens = words × 1.3. Per-agent brief = common header + closing (≈290 words) + its own body (200-450 words) ≈ 500-740 words ≈ **650-960 tokens**, plus `<map>` pasted into D1-D5 (a ~25-row table, ≈700 words ≈ **900 tokens**). Host: the size the skill is sized for — a ~400-commit Next.js/Supabase back-office, ~600 source files, ~150 routes and components, ~60 migrations, ~120 test files. Model: `sonnet` for all six (`modes/diagnose.md:16`). Agentic loop multiplier: billed input ≈ 4 × unique bytes read (each tool call re-sends accumulated context; 30-60 calls per agent).

| agent | unique read (est.) | billed input ≈ ×4 | output |
|---|---|---|---|
| D0 stack map | 25k | 100k | 9k |
| D1 quality | 40k | 160k | 9k |
| D2 data/security | 60k | 240k | 9k |
| D3 performance | 60k | 240k | 9k |
| D4 interface (11 measures, two full target-state lists) | 120k | 480k | 9k |
| D5 docs/method | 50k | 200k | 9k |
| **total** | **355k** | **≈1.42M** | **≈54k** |

Wall clock: D0 must complete before D1-D5 can receive `<map>` (`modes/diagnose.md:20`), so the path is serial-then-parallel: D0 ≈ 4-8 min, then the slowest of five (D4) ≈ 10-25 min, then orchestrator synthesis + plan ≈ 5-10 min. **First user-visible output: 20-45 minutes and ~1.4M billed tokens.** If A2-01 is resolved the other way (all six at once with an empty map) the wall clock drops to 15-35 min and the reports lose their local names.

**A2-19 · `modes/diagnose.md:16-20` · P2** — nothing cheaper than the full six-agent dispatch exists; a user's first contact costs ~1.4M tokens and up to 45 minutes of silence. Change: add a `triage` mode row to `SKILL.md` § Modes.

**Does a `triage` mode weaken the evidence discipline?** No, and the spec shows why row by row. The two invariants at risk are measure-before-assert (`SKILL.md:38`) and read-only rounds never repair (`SKILL.md:43`). A triage that (1) reports only grep results with the command and date, (2) writes nothing inside `docs/`, (3) ticks no ledger row, (4) is marked "not a baseline" so the diagnosis re-measures with its own commands, and (5) whose only exits are `diagnose` or stop — touches neither. The real risk is anchoring, not evidence: a user who hears "the three worst things" may ask for those three to be fixed. That is closed explicitly in § What it must not do and § Handover, with the skill's own line as the reason ("A repair without a number before and after", `SKILL.md:79`).

Cost of `triage`: one sonnet agent, 10 fixed greps, no deep reads → ≈25k billed input, ≈1.5k output, 2-4 minutes. **~2% of Phase 0 for a first result.**

Spec: `audit/specs/triage-mode.md` (load list, brief, output, prohibitions, handover).

---

## 3. The missing scale rule

**What happens on a 30-file project** (say 8 routes, 4 tables, 40 commits, no e2e, no CI):

| phase | on 30 files |
|---|---|
| 0 | still six agents. The cost is the brief and the two target-state comparisons, not the repo: D4 alone compares ~40 checklist items (`areas/interface.md:11-31` + `areas/user-communication.md:9-21`) against 8 routes. Fixed cost, near-zero yield. |
| 1 | survives: a verify script and lint at zero are worth the same at any size. R1.3 collapses (no e2e). |
| 2 | R2.1, R2.5 survive. R2.7 collapses if there are no webhooks. R2.3 is one migration. |
| 3 | R3.1/R3.3 collapse (no hot path worth splitting); R3.2, R3.6 are premature on 4 tables. |
| 4 | R4.2-R4.5 collapse (one list, no bulk actions). R4.8-R4.10 survive: readable errors and labels scale down fine. |
| 5 | R5.1 collapses (no rig has ever existed to be canaried). R5.8 collapses (`briefs/phase-0-diagnosis.md:34` will find zero multi-module processes). R5.4, R5.6 survive. |
| 6, 7 | survive unchanged; documentation and handover do not scale with file count. |

**Measures that become meaningless**: `copies` and the multiplier ordering (`modes/diagnose.md:41`) — with 30 files copies ≈ 1 by construction, so rule 3 has no input at all; `churn`/hotspot over 40 commits; "three most-visited pages" when there are 8; "red e2e for how many days" with no e2e; "baseline on real data" with no production data.

**Proposed rule.** Expressed in measures the stack map already collects (`briefs/phase-0-diagnosis.md:31-32`) plus one command. Lives in `modes/diagnose.md`, new § between `## 0. Entry` and `## 1. Dispatch`; its three numbers become part of step 0.1's evidence.

```markdown
## 0b. Size band

Three commands, run before dispatch; the numbers go in `status.md` step 0.1 and in the stack map.

| measure | command |
|---|---|
| source files | `git ls-files | grep -cE '\.(ts|tsx|js|jsx|py|go|rb|php)$'` |
| routes | count of `<routes>` entries from D0's folder list |
| commits | `git rev-list --count HEAD` |

| band | condition (any one) | dispatch | plan |
|---|---|---|---|
| small | files < 100 · routes < 15 · commits < 100 | D0, D1, D2, D4 only; D3 and D5 folded into the plan as "not dispatched: <measure> = <n>" | no multiplier ordering: rule 3 has no input under 100 files. Order by severity, then dependency. |
| standard | files 100-800 | all six, as written | as written |
| large | files > 800 · routes > 120 | all six; D4 split by route group, one agent per group, same brief | multipliers first, as written |

Fan-out rule, all bands: a brief that says "one agent per X" (`R3.1` hot path, `R5.1` rig, `R5.8` process) dispatches one agent per X only when count(X) >= 3; below that, one agent for all of them. A step whose subject count is 0 is not dispatched and is recorded in the plan as "skipped: <measure> = 0", which is the evidence line for that row.

A band is never a reason to skip a measure; it is a reason not to pay six agents for a number that is structurally 1.
```

**A2-20 · `modes/diagnose.md:16`, `briefs/phase-0-diagnosis.md:3` · P2** — the dispatch is fixed at six agents with no size rule; on a small project most measures have no input yet cost the full brief. Change: add § 0b above.

**A2-21 · `briefs/phase-3-performance.md:9`, `briefs/phase-5-tests.md:9,59` · P2** — "one agent per hot path / per rig / per process" has neither floor nor ceiling; on a 30-file project it is 1 agent per trivial subject, on a large one it is unbounded. Change: the fan-out rule line above.

---

## 4. Executable assets

The skill ships 28 Markdown files and one `.gitattributes`. It demands **18** mechanical artifacts. Two of the 18 ship their command verbatim (`briefs/phase-6-documentation.md:12`, `templates/decision-record.md:9`) — proof the format is possible; the other 16 are re-derived per project from one line of prose.

**Cost assumptions.** A repair agent producing a script + fixtures + wiring reads 10-25 project files to learn local conventions and iterates 2-4 times: **15-40k billed input + 3-10k output per artifact**, midpoint ≈ **30k tokens**.

| artifact | demanded at | inputs | outputs | re-derived per run | est. tokens | variance risk |
|---|---|---|---|---|---|---|
| static rule: guard on every public action | `briefs/phase-1-gates.md:25` (1) | actions glob, guard names | ERROR findings | yes | 30k | glob wrong ⇒ rule silent, and the brief itself warns of this (`:26`) |
| static rule: no PII in logs | `briefs/phase-1-gates.md:25` (2) | logger name, PII fields | findings | yes | 30k | field list differs per run |
| static rule: no service key outside the data layer | `briefs/phase-1-gates.md:25` (3) | env name, data-layer root | findings | yes | 25k | low |
| static rule: no server directive in the data layer | `briefs/phase-1-gates.md:25` (4) | data-layer root | findings | yes | 25k | Next.js-specific |
| static rule: no technical error to the client | `briefs/phase-4-interface.md:65`; `areas/user-communication.md:44` | components, actions | findings | yes | 30k | pattern set differs per run |
| `tests-declared` + frozen exemption list | `briefs/phase-1-gates.md:41,46`; `procedure.md:75`; `modes/maintain.md:12` | test glob, marker | undeclared files | yes | 30k | "frozen, can only shrink" needs a committed baseline nobody specifies |
| glossary check | `briefs/phase-4-interface.md:71,75`; `areas/user-communication.md:49`; `modes/maintain.md:13` | glossary table, search roots | forbidden terms | yes | 35k | high: glossary file format is undefined |
| routes ↔ skeletons | `areas/interface.md:60`; `briefs/phase-3-performance.md:69`; `templates/diagnosis-report.md:40` | routes glob, skeleton name | routes with reads and no skeleton | yes | 25k | "routes with reads" is undefined |
| checklist coverage / stale-words / register (3 scripts) | `briefs/phase-5-tests.md:26,28,29`; `modes/maintain.md:14` | checklist, surface globs, dictionary | gaps, phantoms, orphans | yes | 60k | highest: "partition of the surface" is undefined |
| guide coverage | `briefs/phase-6-documentation.md:30,32,34`; `modes/maintain.md:14`; `procedure.md:140` | guide source, routes | uncovered routes | yes | 30k | high |
| debt markers ↔ register | `briefs/phase-6-documentation.md:41`; `modes/maintain.md:15` | markers, register | unmatched both ways | yes | 25k | marker list differs |
| permission-verification SQL | `briefs/phase-2-data.md:19,22,24`; `areas/data-security.md:47-54`; `briefs/phase-7-handover.md:23` | schema name, expected roles | acl rows, policy rows | yes (query text retyped in 3 files) | 20k | medium; the query text already diverges across files |
| canary harness `CANARY=<n>` | `briefs/phase-5-tests.md:12`; `briefs/verifier.md:24-30`; `modes/maintain.md:16` | per-rig invariant list | invariant \| break \| red \| `cmp` | yes, per rig | 40k | high: touches the tree |
| label / `aria-label` at zero | `briefs/phase-4-interface.md:75`; `areas/user-communication.md:46-47`; `procedure.md:116` | components root | fields, icons | yes | 30k | high: a correct check needs `<label for>` resolution, not a grep |
| colors/spacing outside tokens | `briefs/phase-4-interface.md:14`; `areas/interface.md:42` | components, token file | hits | yes | 15k | low |
| cache tags ↔ invalidation, no empty `catch {}` | `modes/maintain.md:18`; `areas/performance.md:40-41` | services root | tags with no co-located invalidation | yes | 35k | high |
| duplicate numbers across documents | `briefs/phase-6-documentation.md:18`; `procedure.md:140` | docs root | number, files | yes | 20k | medium |
| "where it lives" / "guaranteed by" links | `briefs/phase-6-documentation.md:26`; `briefs/verifier.md:36` | decisions folder | dead references | yes | 20k | low |
| docs index count | `briefs/phase-6-documentation.md:12` | — | counts | **no — command shipped** | 0 | none |
| decision-record numbering | `templates/decision-record.md:9` | — | next number | **no — command shipped** | 0 | none |

**Total: ≈ 495k tokens per full run**, concentrated in phases 1, 4, 5 and 6, plus partial re-derivation on every rejection round (`procedure.md:164`) — and the same cost again on the next project, with a different result each time. Against the Phase 0 estimate of ~1.4M, this is roughly a third of a diagnosis, paid to rebuild things that do not vary by project.

**A2-22 · `briefs/phase-1-gates.md:25`, `phase-4-interface.md:71`, `phase-5-tests.md:26`, `phase-6-documentation.md:41`, `modes/maintain.md:9-18` · P1** — the skill describes a guard set it does not ship; `modes/maintain.md:22` then asks an agent to "check each guard's presence with its command" when no command exists anywhere in the corpus, making the maintain mode's first step unexecutable. Change: ship `rules/`, `scripts/`, `sql/` per `audit/specs/executable-assets.md`; every brief line becomes "copy, configure, run" instead of "invent".

**A2-23 · `areas/performance.md:29` vs `briefs/phase-0-diagnosis.md:87` · P3** — the caps grep diverges: `grep -rnE "limit: [0-9]{3,}"` vs `grep -rnE "limit: ?[0-9]{3,}"`. The area version misses `limit:500`. Change: align on the brief's pattern in all three places (`templates/diagnosis-report.md:39` already has it right).

Spec written: `audit/specs/executable-assets.md` — the injection hook (`stack-map.json`, one added line to D0), a shared contract (Node ESM, zero deps, exit 0/1/2 so `maintain` can distinguish *failing* from *not installed*), 5 rule files with fixtures, 16 scripts, 3 SQL files, the fixture self-test, and the rewritten R1.2 brief as a worked instance. Host-agnostic throughout except the three places named in § 4 of that spec (Postgres catalogs, `loading.tsx`, `'use server'`), each degrading to "not measured" rather than to a false zero, as `briefs/phase-0-diagnosis.md:9` already requires.

---

## 5. The worked example

**Verdict: write it.** Estimate both sides.

*Cost.* 335 words ≈ 440 tokens, loaded once per `run <N>` and once in `diagnose` § 2. Against a `run <N>` load list of ~28k tokens, **≈1.6%**.

*Benefit.* The chain measure → brief → repair report → verifier verdict → ledger line is the skill's whole method, and it is specified in five separate files: the measure in `modes/diagnose.md` and `templates/diagnosis-report.md`, the brief shape in `templates/agent-brief.md` and the phase brief, the report contract in `briefs/phase-1-gates.md:6`, the verdict in `briefs/verifier.md:38`, the ledger row in `templates/status.md:19-28`. A cold orchestrator assembles it from five documents at the moment it is most loaded, and the traces above show the assembly failing in three places (A2-05 filenames, A2-12 missing header, A2-13 question timing). One malformed brief costs a repair round plus a verifier round: **30-60k tokens**. The example pays for itself the first time it prevents one.

**A2-24 · corpus-wide (no worked example in any of the 28 files) · P2** — Change: add `examples/one-defect.md` and name it in the `run <N>` load row of `SKILL.md:20`.

Draft: `audit/specs/worked-example.md`, 335 words, in the skill's voice, on the `disabled`-editor defect from `areas/interface.md:64` — the corpus's own canonical defect (`SKILL.md:66`, `GLOSSARY.md:57`, `templates/decision-record.md:64`), so it introduces no new concept.

---

## 6. Failure and recovery

| scenario | what the corpus says | verdict |
|---|---|---|
| DB unreachable, Phase 0 | `modes/diagnose.md:10`: "The database is reachable read-only, or every database measure will read "not measured", never zero." `briefs/phase-0-diagnosis.md:62`: "If the DB is unreachable: "not measured"." | covered |
| DB unreachable, Phase 2 | `procedure.md:83`: "**Entry.** Diagnosis queries already run (policies, grants, environments)". Nothing on the entry being unmet. `procedure.md:89` requires "policy and grant queries come back clean **after** applying the migration". | **not covered** (A2-25) |
| `git status` dirty at the start of a phase | Only Phase 0: `modes/diagnose.md:9`: "`git status --short` is empty. If not, stop and say so: repairs land in the working tree." No phase-N rule. And Phase 0 itself dirties the tree (`:12` creates `status.md`), while `briefs/verifier.md:34` flags "files touched outside the phase's authorized list". | **not covered** (A2-26) |
| user abandons mid-phase | `modes/status.md:25-26`: "Find the first row without evidence. That is the next action… If the row is a dispatch, re-fill the briefs from the synthesis (do not trust memory of the previous session)." Nothing about repairs already landed in the tree by the abandoned agents. | partial (A2-27) |
| a subagent dies silently or returns nothing | `modes/diagnose.md:20`: "After dispatch, stop: no polling." `modes/diagnose.md:24`: "When all reports are in". `procedure.md:14`: "Once all reports are in". | **not covered** (A2-28) |
| tree carries uncommitted repairs from a previous session | Nearest: `modes/status.md:27` ("If the evidence looks stale… mark the row "stale""), which is about evidence, not the tree; `procedure.md:26` "never `git stash` on a shared tree". | **not covered** (A2-29) |
| two sessions on the same repo | `templates/decision-record.md:9`: "two parallel sessions produce two records with the same number" (numbering only). `areas/quality.md:56`: "Never `git stash` on a tree shared with another session." Nothing about the ledger. | partial (A2-30) |
| verifier cannot run the build (no env vars) | `briefs/verifier.md:16` requires the real build and `$?`. Nearest: `briefs/phase-5-tests.md:21` ("don't 'run against the build' if the env's guards prevent it"), `areas/quality.md:88`. No verifier rule — and R2.1 (`briefs/phase-2-data.md:12`) deliberately makes the app refuse to start without secrets, so this phase creates the condition. | **not covered** (A2-31) |
| the stack map cannot translate a name | `briefs/phase-0-diagnosis.md:9` covers the agent's own writing ("If you can't find something, write "not found""). Nothing covers the orchestrator filling `<command>` at `briefs/verifier.md:13-18` from a "not found" row. | **not covered** (A2-32) |

**Proposed rules** (≤3 lines each; the file each belongs in is named):

| id | sev | lives in | text |
|---|---|---|---|
| A2-25 | P2 | `procedure.md:83`, appended to Phase 2 Entry | "If D2 reported "not measured" on policies or grants, R2.2 is not dispatched: the step is parked with a ruling line, and the ask-first question becomes "give read-only DB access, or accept Phase 2 without permissions". A migration written against an unread database is a guess." |
| A2-26 | P2 | `procedure.md:11`, before "Before every step" | "At the start of every phase: `git status --short`. Files under `docs/` written by this procedure are expected; anything else stops the phase until the user says whether it is theirs. The list goes in the ledger row." |
| A2-27 | P2 | `modes/status.md:26`, appended | "Before re-dispatching a repair row, `git diff --stat` on that brief's file list: if files are already modified, the brief is re-filled with what is there as the starting number, and the report says the previous attempt was partial." |
| A2-28 | P1 | `modes/diagnose.md:20` and `procedure.md:13`, appended to "no polling" | "An agent that returns nothing, or returns without its report file, is dead: re-dispatch it once with the identical brief; if it fails twice, its area is recorded "not measured — agent failed twice" and the plan says which measures are missing. Never infer its findings." |
| A2-29 | P2 | `modes/diagnose.md:9`, appended to the precondition | "Uncommitted changes that look like repairs (source files, not `docs/`) stop the run: ask whether to commit, stash to a branch, or discard. A diagnosis measured over someone else's unfinished work dates nothing." |
| A2-30 | P2 | `modes/status.md:13`, new bullet under Rules | "One session per repo. Before writing a ledger row, re-read `status.md`: a row ticked by someone else means a second session is running — stop and say so. The ledger is not merge-safe." |
| A2-31 | P2 | `briefs/verifier.md:16`, appended to the build line | "If the build fails because a required variable is missing (not a code error), report "gate not runnable — missing env" with the variable names, never a rejection: after R2.1 a refusal to start without secrets is the repair working." |
| A2-32 | P2 | `procedure.md:57`, appended to `<map>` | "A stack-map cell that reads "not found" makes the gate that needs it "not runnable", never "passed": the verifier line stays, with the cell quoted as its evidence, and the plan records the missing tool as a work item." |

---

## 7. Decision load

Every question the method puts to the human across a full run.

| # | question | file:line | mandatory? |
|---|---|---|---|
| 1 | notes reformulation confirmed before any dispatch | `modes/decision-qa.md:14`: "**Confirm.** Wait for the user's confirmation of the reformulation and the questions. Then dispatch." | only if the user brought notes |
| 2 | dirty tree: "stop and say so" | `modes/diagnose.md:9` | conditional, blocking |
| 3 | MCP points elsewhere: "say so and do not use it" | `modes/diagnose.md:11` | conditional |
| 4 | **the plan question** | `modes/diagnose.md:50-57`; `modes/decision-qa.md:54-67` | **always** |
| 5 | Phase 1: a lint rule the project does not want → decision record | `briefs/phase-1-gates.md:17` | conditional |
| 6 | Phase 2: applying the permissions migration | `procedure.md:87`; `briefs/phase-2-data.md:3,24` | whenever R2.2 finds anything |
| 7 | Phase 2: running the live channel tests | `procedure.md:87`; `briefs/phase-2-data.md:54` | whenever a channel exists |
| 8 | Phase 2: rate-limiting policy | `procedure.md:87` | conditional |
| 9 | Phase 3: applying the R3.2 counting-function migration | `procedure.md:99`; `briefs/phase-3-performance.md:24` | whenever R3.2 runs |
| 10 | Phase 3: applying the R3.6 generated-column migration | `procedure.md:99`; `briefs/phase-3-performance.md:5,55` | whenever R3.6 runs |
| 11 | Phase 4: removing an alternative view | `procedure.md:114`; `briefs/phase-4-interface.md:25` | whenever a list has two views |
| 12 | Phase 5: running the live channel checks | `procedure.md:126`; `briefs/phase-5-tests.md:5,53` | whenever a channel exists |
| 13 | Phase 7: the new environment | `procedure.md:150`; `briefs/phase-7-handover.md:5,15` | **always, if Phase 7 runs** |
| 14-16 | Phase 7: R7.3, R7.4, R7.5 — "every action on the new environment is "ask first"", run "in sequence" | `briefs/phase-7-handover.md:3,5` | always, and they cannot be batched: each depends on the previous one's outcome |
| — | the five recurring ask-first classes that can fire in any phase | `procedure.md:24`: "deleting surfaces or dead code; any write to the real database (migrations, grants, policies); removing an alternative view or changing visible behavior that no decision record covers; touching live external integrations (email, backup, sync); anything that contradicts a decision record in the registry" | conditional |
| — | drift check plan question | `modes/maintain.md:48`: "ask the plan question once: it is the drift check's own checkpoint" | per drift check |
| — | after rejection round 4 | `procedure.md:166`: the orchestrator decides alone, with a ruling line | **no question** — correctly |

**Is the claim true?** `SKILL.md:45`: "The plan question after Phase 0 is the only mandatory user checkpoint of a remediation run." Repeated at `procedure.md:63`, `modes/diagnose.md:3`, `modes/status.md:3`, `README.md:19`.

**No.** On the back-office the skill is sized for — the one in `README.md:35`, with migrations, channels, and a handover — items 6, 7, 9, 10, 11, 12, 13 all fire, and Phase 7 alone contributes four. That is **6-10 blocking rounds**, not one. Each is genuinely blocking: `briefs/phase-2-data.md:24` parks R2.2's output until a go-ahead, and Phase 7 cannot start without item 13. What *is* true is that the plan question is the only checkpoint that fires **unconditionally**: every other one exists only because the diagnosis found the corresponding thing. That distinction is real and worth keeping — it is the sentence that is wrong.

**A2-33 · `SKILL.md:45`, `procedure.md:63`, `modes/diagnose.md:3`, `modes/status.md:3`, `README.md:19` · P2** — Change, the honest sentence in all five places:

> The plan question after Phase 0 is the only checkpoint that always fires. Every ask-first item (`procedure.md` § Autonomy contract) is a blocking checkpoint too, whenever the diagnosis finds one: expect one batched question per phase from Phase 2 on, and one go-ahead per step in Phase 7.

**A2-34 · `briefs/phase-7-handover.md:3,5` vs `modes/decision-qa.md:45` · P2** — "every action on the new environment is "ask first"" with "`R7.3`, `R7.4`, `R7.5` in sequence" needs up to four go-aheads, against "Never more than one question round per phase, unless a P1 blocks the phase midway". Change: add to `modes/decision-qa.md:45` — "Phase 7 is the declared exception: one go-ahead per step, because each acts on a live environment the previous step created."

---

## 8. README and install

**Source.** `https://code.claude.com/docs/en/skills` (reached by a 301 from `https://docs.claude.com/en/docs/claude-code/skills`), accessed 2026-09-11. Verbatim: personal skills live at "`~/.claude/skills/<skill-name>/SKILL.md` — Available across all your projects"; project skills at "`.claude/skills/<skill-name>/SKILL.md`"; "**Filename**: `SKILL.md` (required)"; "The directory name becomes the command you type"; invocation "`/skill-name argument1 argument2`"; supporting files may include a `scripts/` folder, and "Reference supporting files from `SKILL.md` so Claude knows what each file contains and when to load it"; on the description: "The combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing".

**Verified, no finding.**
- `README.md:10` — `git clone … ~/.claude/skills/harden-codebase-properly` produces `~/.claude/skills/harden-codebase-properly/SKILL.md`. **Correct and current.**
- `README.md:16` — `/harden-codebase-properly diagnose` matches the documented argument form. **Correct.**
- `SKILL.md:3` — the `description` is 884 characters, inside the documented 1,536-character truncation. **Correct.**
- The docs explicitly bless a `scripts/` folder in a skill directory, which removes the last objection to A2-22.

**Findings.**

**A2-35 · `README.md:7-11` · P2** — the sibling skill is named **32 times** across the corpus and is scheduled *into this skill's own plan* ("the plan schedules that skill's phases before Phase 4 here", `modes/diagnose.md:41`; "the orchestrator switches skill for them", `SKILL.md:55`), yet the Install section installs only this one and never states the dependency. A first-time user who follows the README verbatim reaches a plan naming phases they cannot run. Change: a second line under `## Install` —

> Structural steps in the plan need the sibling skill; install it too:
> `git clone https://github.com/finzidev/design-software-properly.git ~/.claude/skills/design-software-properly`
> Without it, the diagnosis still runs: structural defects are listed and the plan marks them "sibling skill not installed".

**A2-36 · `README.md:37-39`, `SKILL.md` (absent) · P2** — the honest note ("The repair phases and the verifier have not yet been proven live: the first full run is also the skill's own acceptance test") sits in the README's last section. The orchestrator loads `SKILL.md` and the mode files; `README.md` is not in any load list (`SKILL.md:16-23`) and a user invoking `/harden-codebase-properly diagnose` never sees it. The caveat therefore explains a bad first run instead of preventing one. Change: one line at the end of `SKILL.md` § When not to use it —

> Status: Phase 0 is proven read-only on a second project; the repair phases and the verifier have never run live. Say so before Phase 1 and record what surprised you in `lessons.md`.

Placement matters more than wording: it must be read *before* the plan question, which is the last moment the user can choose a smaller scope.

---

## Findings index

| id | file:line | sev | finding | change | effort |
|---|---|---|---|---|---|
| A2-01 | `modes/diagnose.md:16` vs `:20` | P1 | all six agents in one message, yet five need D0's `<map>` | split the dispatch into two waves | S |
| A2-02 | `modes/diagnose.md:28`, `templates/diagnosis-report.md:82` | P1 | the multiplier table needs `copies` and `churn`; nothing here measures them | mark both as sibling-sourced, `—` when absent | S |
| A2-03 | `modes/diagnose.md:33` | P2 | `defect-register.md` created with no format in the load list | append the column line | S |
| A2-04 | `modes/diagnose.md:33` | P2 | `docs/decisions/README.md` created with no format in the load list | append "two tables, never merged" | S |
| A2-05 | `briefs/phase-0-diagnosis.md:19` | P2 | five report filenames never fixed | name them in the dispatch line | S |
| A2-06 | `modes/diagnose.md:11` | P2 | MCP identity check needs tables D0 has not produced | allow "deferred to D0" | S |
| A2-07 | `modes/diagnose.md:12`, `templates/status.md:3` | P2 | ledger header names artifacts created one step later | `<pending D0>` | S |
| A2-08 | `SKILL.md:42`, `procedure.md:13` | P2 | dispatch shape assumes a `run_in_background` parameter and names no agent type | one line in § Placeholders | S |
| A2-09 | `briefs/phase-0-diagnosis.md:18` | P3 | `Max <2200> words` — value inside placeholder brackets | drop the brackets | S |
| A2-10 | `modes/diagnose.md:27` vs `templates/diagnosis-report.md:61` | P3 | two definitions of P1 | use one | S |
| A2-11 | `procedure.md:13` | P2 | "all agents in a single message" contradicts six phase briefs | "the brief's order line wins" | S |
| A2-12 | `SKILL.md:20` | P2 | `run <N>` omits the file holding the common repair header | add `briefs/phase-1-gates.md` | S |
| A2-13 | `procedure.md:15`, `templates/status.md:24-25` | P2 | the go-ahead is scheduled before the artifact it approves exists | ledger row N.4b + one line in decision-qa | M |
| A2-14 | `modes/status.md:24` | P3 | `lessons.md` read on resume, created by nothing | add to the Phase 0 create list | S |
| A2-15 | `modes/maintain.md:22` | P2 | "check each guard with its command"; no row has a command | add a `command` column | M |
| A2-16 | `modes/maintain.md:47` | P2 | drift runs scripts that may never have been built | "not installed" ≠ "failing" | S |
| A2-17 | `modes/maintain.md:9-18` | P3 | `Enforces` column has bare digits, no key | rename the column | S |
| A2-18 | `SKILL.md:22` | P3 | `maintain` writes `status.md` but does not load its template | add `templates/status.md` | S |
| A2-19 | `modes/diagnose.md:16-20` | P2 | ~1.4M tokens and 20-45 min before the first word to the user | add a `triage` mode | M |
| A2-20 | `modes/diagnose.md:16` | P2 | six agents regardless of project size | § 0b Size band | M |
| A2-21 | `briefs/phase-3-performance.md:9`, `phase-5-tests.md:9,59` | P2 | "one agent per X" with no floor or ceiling | fan-out rule, threshold 3 | S |
| A2-22 | `briefs/phase-1-gates.md:25` + 5 files | P1 | 18 mechanical artifacts demanded as prose, ~495k tokens/run, different every time | ship `rules/`, `scripts/`, `sql/` | L |
| A2-23 | `areas/performance.md:29` | P3 | caps grep diverges from the brief's, misses `limit:500` | align the pattern | S |
| A2-24 | corpus-wide | P2 | no worked example; the chain is split across five files | `examples/one-defect.md`, 335 words | S |
| A2-25 | `procedure.md:83` | P2 | Phase 2 with an unreachable DB: not covered | park R2.2, make access the question | S |
| A2-26 | `procedure.md:11` | P2 | dirty tree at the start of phase N: not covered | `git status` per phase, `docs/` expected | S |
| A2-27 | `modes/status.md:26` | P2 | resume re-dispatches onto a half-repaired tree | `git diff --stat` before re-dispatch | S |
| A2-28 | `modes/diagnose.md:20`, `procedure.md:14` | P1 | a dead agent deadlocks "no polling" + "when all reports are in" | re-dispatch once, then "not measured" | S |
| A2-29 | `modes/diagnose.md:9` | P2 | uncommitted repairs from a previous session: not covered | stop and ask | S |
| A2-30 | `modes/status.md:13` | P2 | two sessions on one repo: only record numbering covered | "the ledger is not merge-safe" | S |
| A2-31 | `briefs/verifier.md:16` | P2 | a build blocked by missing env reads as a rejection — and R2.1 creates that condition | "gate not runnable", never a rejection | S |
| A2-32 | `procedure.md:57` | P2 | a "not found" stack-map cell leaves verifier commands unfillable | "not runnable", never "passed" | S |
| A2-33 | `SKILL.md:45` + 4 files | P2 | "the only mandatory user checkpoint" is false; 6-10 blocking rounds | replacement sentence given | S |
| A2-34 | `briefs/phase-7-handover.md:3,5` | P2 | Phase 7 needs four go-aheads against the one-round rule | declare Phase 7 the exception | S |
| A2-35 | `README.md:7-11` | P2 | the sibling skill is scheduled into the plan but never installed | second clone line | S |
| A2-36 | `README.md:37-39` | P2 | the "unproven" note is where it explains a bad run, not where it prevents one | one line in `SKILL.md` § When not to use it | S |

**By severity:** P1 = 4 (A2-01, A2-02, A2-22, A2-28) · P2 = 26 · P3 = 6 (A2-09, A2-10, A2-14, A2-17, A2-18, A2-23).

---

## Files read

All 28 Markdown files. `.gitattributes` is the only non-Markdown file in the repo; no scripts, no rule files, confirming § 4.

| file | lines | words | findings |
|---|---|---|---|
| `SKILL.md` | 105 | 1705 | A2-08, A2-12, A2-18, A2-33, A2-36 |
| `README.md` | 39 | 571 | A2-33, A2-35, A2-36 |
| `procedure.md` | 168 | 2436 | A2-08, A2-11, A2-13, A2-25, A2-26, A2-28, A2-32, A2-33 |
| `GLOSSARY.md` | 86 | 1684 | no findings |
| `modes/diagnose.md` | 67 | 965 | A2-01, A2-02, A2-03, A2-04, A2-06, A2-07, A2-08, A2-10, A2-14, A2-19, A2-20, A2-28, A2-29, A2-33 |
| `modes/decision-qa.md` | 71 | 759 | A2-13, A2-34 |
| `modes/status.md` | 31 | 440 | A2-14, A2-27, A2-30, A2-33 |
| `modes/review.md` | 24 | 433 | no findings |
| `modes/maintain.md` | 56 | 843 | A2-15, A2-16, A2-17, A2-22 |
| `areas/quality.md` | 88 | 1314 | no findings |
| `areas/data-security.md` | 93 | 1223 | A2-22 (permission SQL retyped, `:47-54`) |
| `areas/performance.md` | 56 | 852 | A2-22, A2-23 |
| `areas/interface.md` | 70 | 1107 | A2-22, A2-24 (source of the example) |
| `areas/user-communication.md` | 62 | 1007 | A2-22 |
| `areas/method-documentation.md` | 86 | 1074 | no findings |
| `briefs/phase-0-diagnosis.md` | 128 | 2078 | A2-02, A2-05, A2-09, A2-20, A2-23, A2-32 |
| `briefs/phase-1-gates.md` | 47 | 974 | A2-12, A2-22 |
| `briefs/phase-2-data.md` | 63 | 1107 | A2-12, A2-13, A2-25, A2-31 |
| `briefs/phase-3-performance.md` | 70 | 944 | A2-11, A2-13, A2-21, A2-22 |
| `briefs/phase-4-interface.md` | 84 | 1444 | A2-11, A2-13, A2-22 |
| `briefs/phase-5-tests.md` | 65 | 967 | A2-13, A2-21, A2-22 |
| `briefs/phase-6-documentation.md` | 60 | 722 | A2-22 (and the one command that is shipped, `:12`) |
| `briefs/phase-7-handover.md` | 39 | 374 | A2-13, A2-34 |
| `briefs/verifier.md` | 56 | 791 | A2-22, A2-26, A2-31, A2-32 |
| `templates/agent-brief.md` | 83 | 674 | no findings |
| `templates/decision-record.md` | 66 | 641 | A2-04, A2-30 (and the second shipped command, `:9`) |
| `templates/diagnosis-report.md` | 85 | 1245 | A2-02, A2-10, A2-23 |
| `templates/status.md` | 46 | 394 | A2-07, A2-13, A2-18 |

Total 28 files, 28,768 words (measured: `wc -w` over all `*.md`, 2026-09-11).

Files with no findings: `GLOSSARY.md`, `modes/review.md`, `areas/quality.md`, `areas/method-documentation.md`, `templates/agent-brief.md`. `modes/review.md` in particular is the cleanest file in the corpus for cold start: it names its own precondition (`:7` "If no stack map exists, run `diagnose` first: a review without the map guesses") — the pattern the other modes are missing.

## Sources fetched

| title | body | URL | date accessed |
|---|---|---|---|
| Skills — Claude Code documentation | Anthropic / Claude Code docs | `https://code.claude.com/docs/en/skills` (301 from `https://docs.claude.com/en/docs/claude-code/skills`) | 2026-09-11 |

Could not fetch: none. The redirect from the URL given in the audit brief was followed to its documented target and the target answered every question in § 8.
