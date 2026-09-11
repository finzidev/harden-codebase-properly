# Verification — round `evolve/audit-01`, against `c32367a`

Verifier: independent pass, 2026-09-11. Object: the skill corpus (28 Markdown files + 3 new). Nothing repaired here.

## 1. Quality gates

| check | command | result | evidence |
|---|---|---|---|
| Cross-references, paths | `grep -rnoE '(modes\|briefs\|areas\|templates\|examples\|sql\|docs)/…\.(md\|sql)'` over the loadable set, then `[ -f ]` on each | **PASS** | 30 distinct paths, all exist; the only miss is `areas/components.md`, cited once in `areas/interface.md:5` as the sibling skill's file (deliberate) |
| Cross-references, `§` headings | all 28 `§` references resolved against `grep -n '^#\+ '` per file | **PASS with 2 prefixes** | `SKILL.md` § Non-negotiables / § Modes / § What a production-grade product is, `procedure.md` § Autonomy contract / § Convergence, `briefs/phase-1-gates.md` § Common repair header (new, line 5), `briefs/verifier.md` § Diff mode, `modes/diagnose.md` § Plan / § Delta mode / § 2 all resolve. `procedure.md:20` cites "§ Artifacts", the heading is "Artifacts in the project"; `docs/decisions/008` cites `areas/quality.md` § Gate chain, the heading is "The gate chain". No `§ Placeholders` reference exists anywhere |
| Load-list closure | Load cells vs references of every loaded file, compared with `01-integrity.md` § 2 | **PASS, 2 new residues** | A2-01…A2-08 and A2-10 closed (`templates/status.md`, `phase-1-gates.md` § Common repair header, `procedure.md` § Autonomy contract/§ Convergence, `templates/decision-record.md`, `briefs/verifier.md`+`decision-qa` in `status`, the areas for `diagnose`, README named in § File map). A2-09 accepted per U-01 (GLOSSARY still loaded by nobody, claim softened). **New:** `sql/verify-permissions.sql` is named by `areas/data-security.md:22,64,79`, `briefs/phase-0-diagnosis.md:62`, `briefs/phase-2-data.md:19`, `modes/maintain.md:19` and is in **no** Load cell (P2). `examples/one-defect.md` is named in `modes/diagnose.md:46` but is only in the `run <N>` cell (P3) |
| Placeholder closure | `grep -rnoE '<[a-zA-Z][a-zA-Z0-9_:/-]*>'` over `briefs/ templates/ modes/ areas/ SKILL.md examples/` | **FAIL (6 new undeclared)** | `procedure.md:63` now declares 25 tokens and states "Only declared tokens are slots". Six tokens introduced this round are undeclared: `<src>` (7×, old 0), `<actions>` (2×), `<services>`, `<tests>`, `<migrations>`, `<routes>` (1× each, all `modes/triage.md` + `briefs/phase-0-diagnosis.md` + `areas/performance.md:29` + `templates/diagnosis-report.md:41`). `<src>` self-describes only in the phase-0 header, not in the area/template that use it. `<words>`, `<url>` self-describe in their sentence; `<label>`/`<Suspense>` are correctly excluded |
| Fixtures: caps regex | `grep -rnE "\.limit\(\|limit:\s*[0-9]{3,}" src` on the A6-03 fixture | **PASS** | 4/4 hits incl. `.limit(1000)` and `limit:  1000`; exit 0 |
| Fixtures: hex regex | `grep -rnE "#[0-9a-fA-F]{3,8}\|\[[0-9]+px\]" src` | **PASS** | `#A1B2C3` now matched (A6-06 closed) |
| Fixtures: `error\.message` | `grep -rn "error\.message\|String(err\|digest" src/components` | **PASS** | `errorXmessage` no longer a false positive |
| Fixtures: `disabled` | `grep -rn "disabled" src/components` | **PASS** | 1 hit, exit 0; no stdin read (A6-04 closed). All 16 recursive greps in the corpus now carry a path (A6-08 closed) |
| Fixtures: decision numbering | `ls docs/decisions/[0-9]*.md 2>/dev/null` on an empty register | **PASS** | exit **2** (was exit 0 behind `\| sort`) — the failure is now visible |
| Fixtures: evidence one-liner | built `status.md` with one existing + one missing path in scratchpad | **PASS** | prints `MISSING EVIDENCE: docs/remediation/01-gates/missing.md` only |
| Fixtures: `modes/triage.md` | `rg -nE "…" src` and `rg -Lc "if not exists" mig` | **FAIL** | `rg: error parsing flag -E: unknown encoding`, **exit 2** (ripgrep 14.1.1: `-E` is `--encoding`, not `--extended-regexp`). `rg -Lc` is `--follow --count`, it lists files **with** matches — the inverse of the "non-idempotent migrations" count the line asks for (`--files-without-match` has no short flag) |
| `sql/verify-permissions.sql` columns | fetched catalog-pg-proc, catalog-pg-class, view-pg-policies, view-pg-tables (postgresql.org/docs/current) | **PASS** | `proname/pronamespace/proacl`, `relname/relnamespace/relkind/relrowsecurity/relforcerowsecurity`, `schemaname/tablename/policyname/permissive/roles/cmd/qual/with_check`, `schemaname/tablename/rowsecurity` — all exist, `relkind in ('r','p')` = ordinary + partitioned, correct |
| Frontmatter | `diff` of lines 1–5 at `c32367a` vs now; fetched code.claude.com/docs/en/skills and agentskills.io/specification | **PASS** | `name`, `description` byte-identical. Claude Code docs: *"`argument-hint` — Hint shown during autocomplete to indicate expected arguments. Example: `[issue-number]`"*; *"`compatibility` — Environment requirements for the skill … Accepts a string of up to 500 characters."* agentskills spec: `compatibility` *"Max 500 characters"*, optional. String is 118 chars. No undocumented field added |
| Line endings | `grep -rlI $'\r' …` | **PASS** | no output, exit 1 |
| `audit/` isolation | `grep -rn 'audit/' SKILL.md README.md procedure.md GLOSSARY.md modes areas briefs templates examples sql` | **PASS** | no output, exit 1 |
| Counts in prose | `grep -c` on `templates/status.md`, `briefs/phase-5-tests.md`, `SKILL.md` | **PASS** | Phase 0 = 4 rows, Phase N = 8 rows, re-diagnosis = 3 rows (C-17 true). R5.1–R5.8 present, area file says R5.1–R5.8. Six conditions = 6. Seven mode rows = 7 = the seven `argument-hint` values |
| Contradictions (01 § 5 re-run) | targeted greps | **PASS, 1 residue** | `git stash` absolute at all 6 sites. "Only checkpoint" stated once (`SKILL.md:50`), 4 sites are pointers. Actor named ("The run does alone (through agents)"). Commit in the ask-first list. Evidence rule, verifier model, rejection cap, language rule (16 → 8 occurrences, 6 files) consistent. **Residue:** `briefs/phase-0-diagnosis.md:3` still reads "Six agents … **all in one message**" against `modes/diagnose.md:32` ("Two waves in two messages; `D0` alone") and § 0b Size band ("small → `D0`,`D1`,`D2`,`D4` only") — the two files load together in `diagnose` |
| Shared names | side-by-side | **PASS, 1 residue** | The two `status.md` header lines are byte-identical in `templates/status.md:5-6`, `procedure.md:32`, `modes/status.md:26`. The evidence one-liner is byte-identical in `templates/status.md:8` and `modes/status.md:19`. The five report filenames agree in `modes/diagnose.md:34` and `briefs/phase-0-diagnosis.md:19`. `<allocation>` in `procedure.md:15,63`, `briefs/verifier.md:35`, `templates/agent-brief.md:38`; `briefs/phase-4-interface.md:5` names the owner in words, not the token (fine). Canary protocol: same steps, same order, same RED (`$?` non-zero **and** the assertion named) in verifier/quality/R5.1; the mirrors omit 2 of 6 steps (0-byte `.orig` abort, re-run the unit gate). **Residue:** `examples/one-defect.md:23` still reports the restore as "`cmp` silent" |

## 2. Measures

| measure | before (`c32367a`) | after | note |
|---|---|---|---|
| Corpus, loadable files (`wc -w`) | 28,768 | **33,622** | budget 33,083 → **+539 over (+16.9 %)**. Decision 009 says 33,619 / +536: off by 3 |
| `sql/verify-permissions.sql` | — | 160 | corpus without it: 33,462 |
| `modes/triage.md` | — | 427 | cap was ≤ 550 ✓ |
| `examples/one-defect.md` | — | 335 | spec said 335 ✓ |
| Load, `status` | 834 | 5,722 | whole files named by the cell; +2,182 if `SKILL.md` is counted |
| Load, `diagnose` | 5,441 | 9,509 | 17,496 if the six `areas/*.md` the cell hands to the agents are included |
| Load, `run 2` | 7,397 | 11,060 | |
| Load, `run 4` | 8,625 | 11,566 | |
| Load, `maintain` | 3,500 (6,543 with the drift files) | 7,844 (11,363 with them) | |
| "These are defaults…" | 11 files | 3 (`procedure.md:57`, `briefs/verifier.md:7`, `briefs/phase-1-gates.md:39`) | cut from the 8 named files; decision 009 says "nine of ten" — it is eight of ten |
| "host project's language" | 16 | 8, in 6 files | X-02 target met |
| Retyped permission SQL | 3 copies | 0 | X-04 met |

`audit/SUMMARY.md` § Numbers still reads `28,768 / *measured in verification.md* / 33,083`: the after cell is **33,622**.

## 3. Citations

43 distinct keys, 51 occurrences. Every key resolves to an entry in `audit/sources.md` (or a wave-1 report's Sources section) with a URL fetched 2026-09-11. Fetched and checked by me this session:

| key | fetched? | says what the line claims? | evidence |
|---|---|---|---|
| `[PostgreSQL 12–18]` (CREATE FUNCTION notes) | yes | **yes** | *"the ownership and permissions of the function do not change"*; *"It is not possible to change the name or argument types … you would actually be creating a new, distinct function"* |
| `[PostgreSQL ddl-priv]` | yes | **yes** | *"If the 'Access privileges' column is empty … the object has default privileges (that is, its privileges entry in the relevant system catalog is null)"*; Table 5.2: FUNCTION → `X` (EXECUTE) to PUBLIC |
| `[HTML § 4.10.22.4]` | yes | **yes** | § 4.10.22.4 is "Constructing the entry list"; disabled controls are excluded, hidden controls are submitted; `readonly` is submitted and barred from constraint validation |
| `[WAI-ARIA 1.2]` `aria-busy` | yes | **yes** | AT is told to wait until `aria-busy="false"` before exposing the change — it withholds, it does not announce; `role="status"` / SC 4.1.3 is what announces |
| `[POSIX Issue 8 § 2.9.2]` | yes | **yes** | *"the exit status of a command shall be that of the last simple command executed"* |
| `[Next.js 16.3.4]` `updateTag` | yes | **yes** | *"`updateTag` can **only** be called from within Server Actions"*; *"Error: updateTag can only be called from within a Server Action"*. `revalidateTag(tag, { expire: 0 })` is the documented substitute outside a Server Action — the corpus's wording is exactly right |
| `[Next.js 16 upgrade guide]` | yes | **yes** | *"The `next lint` command has been removed. Use Biome or ESLint directly. `next build` no longer runs linting."* |
| `[ASVS 5.0 V9.2.1]` | yes | **yes** | *"if a validity time span is present in the token data, the token and its content are accepted only if the verification time is within this validity time span"* |
| `[WCAG 2.2 SC 1.4.1]` | yes | **yes** | *"Color is not used as the only visual means of conveying information…"* — matches "the verb is always in the label too" |
| also checked | | **yes** | SC 1.3.1/1.3.5/1.4.11/1.4.13/2.4.3/2.5.3/2.5.8/3.2.4/3.3.2/3.3.4/4.1.3 titles and levels; ASVS V8.2.1, V9.1.1, V6.1.1, V16.2.5, **V16.5.3** (*"fails gracefully and securely … preventing fail-open conditions"*); V2 "Validation and Business Logic", V3 "Web Frontend Security", V16 "Security Logging and Error Handling"; RFC 9111 § 4.4 = "Invalidating Stored Responses"; PostgREST v12 count (exact is slow on large tables, planned/estimated are approximate) |

**No failed citation.** One style residue: `[SC 3.2.4]`, `[SC 3.3.4]`, `[SC 1.3.1]`, `[SC 1.3.5]`, `[SC 1.4.11]`, `[SC 2.4.3]`, `[SC 2.5.3]`, `[SC 2.5.8]`, `[SC 3.3.2]` use a bare `[SC …]` form that is not one of the four families `SKILL.md` § Note on the stack names (`[HTML § …]`, `[PostgreSQL 12–18]`, `[ASVS 5.0 V…]`, `[WCAG 2.2 SC …]`), so the default-provenance rule does not visibly cover them.

## 4. Parity — not applicable (no screens). Skipped.

## 5. Files outside the lists

`git status --short`: 27 modified + `CHANGELOG.md`, `audit/`, `docs/`, `examples/`, `modes/triage.md`, `sql/` untracked. `git diff c32367a --stat`: 28 files, +313/−231. **Every touched file is inside one of the six groups**, plus `audit/`, `docs/decisions/`, `CHANGELOG.md` and the one declared in-person edit (`areas/interface.md`, skeleton trap line). No file outside. No file changed that no backlog row names.

Beyond a row's scope, done anyway (all three P3, two declared in decision 009, none harmful):
- `GLOSSARY.md:8` drops "single writer" and "one implementation per concept" from the sibling-vocabulary list — no row asks for this.
- `procedure.md:7` (sibling paragraph), `:19` (variant-search tail and `lessons.md` description), `:82` (Phase 1 "Typical repairs" sibling sentence), `:108` — compressions declared in decision 009 but named by no backlog row.

## 6. Brief compliance — every `W3` row

**YES (77):** C-01, C-02, C-03, C-04, C-05, C-06, C-07, C-08, C-09, C-10, C-11, C-12, C-13, C-14, C-15, C-17, C-19, C-20, C-21, C-22, C-23, C-24, C-25, C-26, C-27, C-28, C-29, C-30, C-31, C-32, C-33, C-34, C-35, C-36, C-37, C-38, C-39 · E-01, E-02, E-03 · U-01, U-02, U-03, U-04, U-05, U-06, U-07, U-08, U-09, U-10, U-11 · V-01, V-02, V-03, V-04, V-05, V-07, V-08, V-09, V-10, V-11, V-12, V-13 · X-02, X-03, X-04 · F-01, F-02, F-04, F-05, F-06, F-07, F-08, F-09, F-10, F-11, F-12, F-13, F-14, F-15. Each verified at the file:line the row names, in the diff; none exceeded its scope.

**NO / PARTIAL (5):**

| row | verdict | evidence |
|---|---|---|
| C-07 | **YES, residue** | `modes/diagnose.md:32` two waves ✓. But `briefs/phase-0-diagnosis.md:3` — outside the row's file list — still says "Six agents … all in one message"; the mode loads both |
| C-16 | **NO** | The row asked for "(if the file is new, copy the current file)" at `areas/quality.md:56`. `grep -rn 'file is new'` over the corpus = 0. F-03 replaced the `git show HEAD:` baseline with `cp` from the working tree, which makes the caveat unnecessary — but `CHANGELOG.md` line C-16 asserts "The A/B recipe carries the new-file caveat", which is false |
| C-18 | **PARTIAL** | `areas/quality.md:50` now reads `R5.1–R5.8` ✓. The row also said "number the parts in `templates/decision-record.md`": the heading became "The parts of a record: the title line, `When`, `Status`, and five sections" — counted, not numbered. Ambiguity resolved; letter of the row not met |
| V-06 | **PARTIAL** | Request id, the must-log event list, retention/routing in `areas/data-security.md:55-57` ✓; `MONITORING.md` content in R6.7 ✓. The row's third file, "`modes/maintain.md` guard row", has **no** observability row — the only guard row added is "Permissions true on the database" (U-07's) |
| X-01 | **PARTIAL** | Deleted from the 8 named files ✓, kept in `procedure.md:57` ✓. The row's second keep site — `briefs/phase-1-gates.md:6`, the common repair header "which every brief now loads" — does **not** carry it; the surviving copy in that file sits at `:39`, inside R1.3 only. `CHANGELOG.md` X-01 asserts it is in the common repair header |
| F-03 | **YES, partial mirror** | Full six-step protocol at `briefs/verifier.md:24-31` ✓. The mirrors at `areas/quality.md:58` and `briefs/phase-5-tests.md:13` omit 2 of 6 steps: the 0-byte `.orig` abort and "after the last canary, re-run the unit gate" |

**Rows marked `spec` / `issue` / `no` — nothing applied:** U-12 — only `sql/verify-permissions.sql` ships; no `scripts/`, `rules/`, fixtures or `stack-map.json` anywhere in the tree; `audit/specs/executable-assets.md` exists. X-05 — `procedure.md` still holds all eight phase sections, unsplit. U-03's rejected half — no `disallowed-tools` in the frontmatter. ✓

**CHANGELOG id set:** all 85 `W3` ids present, none missing. Two extra ids appear — U-12 and X-05 — each explicitly marked "not applied / issue to open"; benign, but they are not `W3`.

## 7. Declarations

- `docs/decisions/001`–`009` all carry a "Where it lives in the code" section; every path named exists, except `audit/verification.md` (005, 009), which this file now supplies.
- `docs/decisions/README.md` lists all nine, statuses in force. ✓
- `CHANGELOG.md`: one line per applied id, grouped. ✓ (three claims in it are inaccurate — see residues 6, 7, 8.)
- `audit/SUMMARY.md` § Numbers placeholder still unfilled: **33,622**.

## Verdict: **RESIDUAL**

| # | residue | sev | one-line fix |
|---|---|---|---|
| 1 | `modes/triage.md` brief, item 3: `rg -nE "…"` exits 2 (`-E` is `--encoding` in ripgrep), so the caps measure silently returns nothing | **P1** | drop the `-E`: `rg -n "\.limit\(\|limit:\s*[0-9]{3,}" <src>` |
| 2 | `modes/triage.md` brief, item 8: `rg -Lc "if not exists" <migrations>` counts files **with** the string, the inverse of the non-idempotent count it claims | **P1** | `rg --files-without-match "if not exists" <migrations> \| wc -l` |
| 3 | `briefs/phase-0-diagnosis.md:3` "Six agents … all in one message" contradicts `modes/diagnose.md` § 1 (two waves) and § 0b (small band = four agents), both loaded by `diagnose` | **P2** | replace with "Dispatched in two waves (`modes/diagnose.md` § 1); the size band may drop D3/D5." |
| 4 | `sql/verify-permissions.sql` is named by four loadable files and appears in no Load cell | **P2** | add `sql/verify-permissions.sql` to the `diagnose`, `run <N>` and `maintain` Load cells |
| 5 | Six placeholders introduced this round are undeclared, against the new rule "Only declared tokens are slots": `<src>`, `<actions>`, `<services>`, `<tests>`, `<migrations>`, `<routes>` | **P2** | add the six to `procedure.md` § Placeholders |
| 6 | V-06 PARTIAL: no observability guard row in `modes/maintain.md` | **P2** | add a row: request id end-to-end + the must-log event list, command = the grep from R6.7, source brief R6.7 |
| 7 | X-01 PARTIAL: the sentence survives at `briefs/phase-1-gates.md:39` (R1.3 only), not in the common repair header the row names | **P3** | move it into the header block at `:10` and delete it from R1.3 |
| 8 | C-16 not applied and `CHANGELOG.md` says it was; F-03 makes it moot | **P3** | rewrite the C-16 changelog line as "superseded by F-03: the canary baseline is the working-tree file, so the caveat is unnecessary" |
| 9 | `CHANGELOG.md` X-01 asserts the sentence is in the common repair header | **P3** | fix with residue 7 |
| 10 | `areas/interface.md:64` reads "…is **absent** from `FormData`, not empty, absent, and a save…" — the word is duplicated, the clause is garbled (orchestrator's file) | **P3** | "…is **absent** from `FormData`, not empty, and a save…" |
| 11 | `examples/one-defect.md:23` reports the canary restore as "`cmp` silent"; the shipped protocol verifies it with `git diff --stat` | **P3** | "canary red on `disabled`, restored, `git diff --stat` unchanged" |
| 12 | F-03 mirrors omit the 0-byte `.orig` abort and the post-canary unit-gate re-run | **P3** | append both clauses to `areas/quality.md:58` and `briefs/phase-5-tests.md:13` |
| 13 | Decision 009 states 33,619 / +536; measured **33,622 / +539**. It also says "nine of ten files" for X-01; it is eight of ten | **P3** | correct the three numbers in 009 and in `CHANGELOG.md`'s header line |
| 14 | Decision 009's per-mode table compares "before" **without** `SKILL.md` against "after" **with** it (+2,182 in every after cell), overstating each mode's growth | **P3** | restate the five pairs on one convention (this report's § 2 gives both) |
| 15 | Bare `[SC …]` citation keys are outside the four families `SKILL.md` names | **P3** | spell them `[WCAG 2.2 SC …]`, or add the short form to the § Note on the stack list |
| 16 | `compatibility` omits ripgrep, which `modes/triage.md` requires | **P3** | add "ripgrep for `triage`" to the field |
| 17 | `examples/one-defect.md` is cited by `modes/diagnose.md:46` but is only in the `run <N>` Load cell | **P3** | add it to the `diagnose` cell, or make the mention a "see `run <N>`" pointer |
| 18 | `procedure.md:20` cites "§ Artifacts" (heading: "Artifacts in the project"); `docs/decisions/008` cites `areas/quality.md` § Gate chain (heading: "The gate chain") | **P3** | quote the headings exactly |
| 19 | Beyond scope, no row: `GLOSSARY.md:8` drops "single writer" and "one implementation per concept" from the sibling-vocabulary list | **P3** | restore, or record the cut |
| 20 | `audit/SUMMARY.md` § Numbers "Corpus before / after" still a placeholder | **P3** | fill with 33,622 |

No residue invalidates a P1 repair: the permission check, the canary protocol, the ledger guards, the allocation table, the token/grant/lint/cache corrections and the object-level, rollback, supply-chain and validation coverage are all present, correctly worded, and correctly cited.
