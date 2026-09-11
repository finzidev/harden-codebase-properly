# 01 — Mechanical integrity

Repo: `C:\Users\Utente\Desktop\harden-codebase-properly` · branch `evolve/audit-01` · commit `c32367a` · audited 2026-09-11.
Corpus: 28 Markdown files + `.gitattributes`, 1 994 lines, 28 768 words (`find . -name "*.md" ... | xargs wc -lw`).
Every command quoted below was executed in this session; fixtures live in `…/scratchpad/fix`. Postgres was **not** reachable: SQL was checked against the current PostgreSQL documentation (column names and semantics), never executed.

## Summary

46 findings: **2 P1**, **26 P2**, **18 P3** (counted from the Findings index). No finding touches code structure (the sibling skill's territory).
**A6-01 (P1)** — `npx gitleaks detect --no-git` (briefs/phase-0-diagnosis.md:61) cannot run: the npm package `gitleaks` has no `bin`; npx answers "could not determine executable to run". The secrets measure silently becomes "not measured".
**A6-02 (P1)** — the `pg_proc.proacl` query (briefs/phase-0-diagnosis.md:63, areas/data-security.md:49-54) returns an **empty** privilege cell exactly for the most permissive case: a function that was never granted/revoked has `proacl` NULL, and PostgreSQL's default for functions is `EXECUTE` to `PUBLIC`. The prescribed verification reads "clean" on the defect it exists to catch.
**A2-02 (P2)** — `run <N>` for N=2…7 loads `briefs/phase-N-*.md`, but each of those briefs says "Common header: as in `phase-1-gates.md`": the entire repair header (no commit, no `git stash`, `tested against`, canary, variant search, report cap) is a hidden dependency the mode table never loads.

---

## 1. Frontmatter against the current spec

Sources fetched 2026-09-11 (full list at the end). `https://docs.claude.com/en/docs/claude-code/skills` 301s to `https://code.claude.com/docs/en/skills`; `https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview` 302s to `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`. Both redirects were followed and fetched. `https://agentskills.io/specification` was reachable.

### Measured

```
$ sed -n '1,4p' SKILL.md | grep -oE '^[a-zA-Z-]+:'
name:
description:
$ sed -n '2p' SKILL.md ; sed -n '2p' SKILL.md | sed 's/^name: //' | tr -d '\n' | wc -c
name: harden-codebase-properly
24
$ sed -n '2p' SKILL.md | sed 's/^name: //' | grep -cE '^[a-z0-9-]+$'   # charset
1
$ sed -n '2p' SKILL.md | grep -ciE 'anthropic|claude'                   # reserved words
0
$ basename "$PWD"
harden-codebase-properly
$ sed -n '3p' SKILL.md | sed 's/^description: //' | tr -d '\n' | wc -c  # description value
871
$ sed -n '3p' SKILL.md | tr -d '\n' | wc -c                             # whole line incl. key
884
```

### Against the documented constraints

| Requirement | Doc quote | Measured | Verdict |
|---|---|---|---|
| required fields | agentskills.io/specification: "`name` \| Yes \| Max 64 characters…"; "`description` \| Yes \| Max 1024 characters." platform.claude.com: "**Required fields:** `name` and `description`" | both present, nothing else | OK |
| `name` charset | agentskills.io: "May only contain unicode lowercase alphanumeric characters (`a-z`, `0-9`) and hyphens (`-`)"; "Must not start or end with a hyphen"; "Must not contain consecutive hyphens (`--`)" | `harden-codebase-properly` matches `^[a-z0-9-]+$`, no leading/trailing/double hyphen | OK |
| `name` length | agentskills.io: "Must be 1-64 characters"; platform.claude.com: "Maximum 64 characters" | 24 | OK |
| `name` = folder | agentskills.io: "Must match the parent directory name" | folder `harden-codebase-properly` = name | OK |
| `name` reserved words | platform.claude.com: "Cannot contain reserved words: \"anthropic\", \"claude\"" | 0 hits | OK |
| `description` length | agentskills.io: "Must be 1-1024 characters"; platform.claude.com: "Maximum 1024 characters"; code.claude.com: "**Max length:** 1,536 characters (combined with `when_to_use`)" | 871 (value) / 884 (line) | OK on all three limits |
| how `description` selects | platform.claude.com: "The `description` is what Claude matches your request against when determining whether to trigger the Skill, so it must say both what the Skill does and when to use it." code.claude.com: "Claude uses this to decide when to apply the skill." | states both what and when | OK |

**A1-01 · SKILL.md:3 · P3 · the Italian parenthetical trigger list is not a documented pattern.** None of the three fetched pages documents a bilingual or multi-language trigger list inside `description`. The documented home for trigger phrases is a separate field, Claude-Code-only: code.claude.com, `when_to_use` — "Additional context for when Claude should invoke the skill, such as trigger phrases or example requests. Appended to `description` in the skill listing and counts toward the 1,536-character cap." Verbatim tail of the current description: `(anche: portare a top qualità, bonifica, hardening, sicurezza, performance, test veri, messaggi utente, documentazione, consegna al cliente)`. Not found: any doc statement that this helps or hurts. → Minimal change: none required for correctness; if the skill is Claude-Code-only, move the parenthetical to `when_to_use:` — but note `when_to_use` is absent from the agentskills.io spec, so moving it loses the trigger on other clients (README.md:3 claims portability).

**A1-02 · SKILL.md:1-4 · P2 · `argument-hint` is absent although the skill is argument-driven.** SKILL.md:14 — "Pick the mode from the argument or from the request." — and the mode enum has six values. code.claude.com: "`argument-hint` | \"Hint shown during autocomplete to indicate expected arguments. Example: `[issue-number]` or `[filename] [format]`.\"" → Minimal change: add `argument-hint: [diagnose|plan|run <N>|review|maintain|status]`.

**A1-03 · SKILL.md:1-4 · P2 · the skill's central non-negotiable has no mechanical enforcement although a documented field provides it.** SKILL.md:8 — "**It never writes code.**"; SKILL.md:42 — "The orchestrator never writes code."; procedure.md:3 — "The orchestrator **does not write code**". code.claude.com: "`disallowed-tools` | \"Tools removed from Claude's available pool while this skill is active. Use for autonomous skills that should never call certain tools…\"" → Minimal change: add `disallowed-tools: Edit Write NotebookEdit`.

**A1-04 · SKILL.md:1-4 · P3 · no `license`, `compatibility` or `metadata`, though the skill is published.** README.md:10 gives a public clone URL. agentskills.io: "`license` | No | License name or reference to a bundled license file."; "`compatibility` | No | Max 500 characters. Indicates environment requirements (intended product, system packages, network access, etc.)." The skill requires git, grep, a reachable Postgres CLI and (per A6-01) a secrets scanner. → Minimal change: add `license:` and a `compatibility:` line naming the required tools.

Fields checked and **not** recommended, with the reason: `disable-model-invocation` (the description is written for automatic triggering, SKILL.md:3); `user-invocable` (default `true` is what README.md:16 documents); `context: fork` + `agent` (code.claude.com: "Set to `fork` to run in a forked subagent context" — the orchestrator must stay in the session to dispatch and to ask the Phase 0 plan question); `hooks`, `paths`, `shell`, `effort`, `background`, `arguments` (no use in this corpus); `model` (the orchestrator's model is deliberately left to the session; every subagent pins `model: sonnet`).

---

## 2. Load graph vs mode table

`SKILL.md` § Modes, lines 16-23 (six rows, verified: `sed -n '16,24p' SKILL.md | grep -c '^| \`'` → `6`).
Referenced-but-not-loaded = **hidden**. Loaded-but-unused-by-that-mode = **dead weight**.
Reference extraction: `grep -rnoE '(modes|briefs|areas|templates)/[a-zA-Z0-9._-]+\.md|procedure\.md|GLOSSARY\.md|README\.md' --include=*.md .` (full output retained; `README.md` hits inside `modes/decision-qa.md`, `modes/diagnose.md`, `briefs/phase-6-documentation.md`, `templates/decision-record.md` are `docs/decisions/README.md`, a project artifact, not the skill's README — excluded).

### `diagnose`

| Loaded (SKILL.md:18) | Referenced at runtime by the loaded files | Status |
|---|---|---|
| `modes/diagnose.md` | `modes/decision-qa.md`:7,30,50 · `templates/status.md`:12 · `briefs/phase-0-diagnosis.md`:16 · `templates/diagnosis-report.md`:24 · `procedure.md`:57 | last one **hidden** |
| `modes/decision-qa.md` | `templates/decision-record.md`:50 | **hidden** |
| `briefs/phase-0-diagnosis.md` | `templates/diagnosis-report.md`:18 · `areas/quality.md`:41 · `areas/data-security.md`:58 · `areas/performance.md`:78 · `areas/interface.md`:96,109 · `areas/user-communication.md`:105,109 · `areas/method-documentation.md`:115 | six areas **hidden** |
| `templates/status.md` | — | used |
| `templates/diagnosis-report.md` | `modes/diagnose.md`:83 | loaded |

Dead weight: none.

### `plan`

| Loaded (SKILL.md:19) | Referenced | Status |
|---|---|---|
| `modes/diagnose.md` § Plan | `modes/decision-qa.md` § Plan question · `templates/status.md` (diagnose.md:57 "Record the confirmed plan in `status.md`") · `procedure.md` (diagnose.md:57 "within the autonomy contract") | `templates/status.md`, `procedure.md` **hidden** |
| `modes/decision-qa.md` | `templates/decision-record.md`:50 | **hidden** |

Also hidden: the plan table column "source brief" (diagnose.md:46) needs `briefs/` names; none loaded.

### `run <N>` (SKILL.md:20 — `procedure.md`, `modes/status.md`, `briefs/phase-N-*.md`, the areas that phase names, `briefs/verifier.md`, `modes/decision-qa.md`, `templates/decision-record.md`)

Areas each phase names, measured from the briefs' `Reference:` lines and from `procedure.md`:

| N | areas the phase names | source | hidden dependencies | dead weight |
|---|---|---|---|---|
| 1 | **none** | `briefs/phase-1-gates.md` has **no** `Reference:` line; `procedure.md`:67-78 names no area | `templates/status.md` (procedure.md:42, status.md:7) | `briefs/verifier.md` used; nothing dead |
| 2 | `areas/data-security.md` | phase-2-data.md:3 | `briefs/phase-1-gates.md` (common header) · `templates/status.md` | — |
| 3 | `areas/performance.md` | phase-3-performance.md:3 | `briefs/phase-1-gates.md` · `templates/status.md` | — |
| 4 | `areas/interface.md`, `areas/user-communication.md` | phase-4-interface.md:3; procedure.md:118 | `briefs/phase-1-gates.md` · `templates/status.md` | — |
| 5 | `areas/quality.md` | phase-5-tests.md:3 | `briefs/phase-1-gates.md` · `templates/status.md` | — |
| 6 | `areas/method-documentation.md` | phase-6-documentation.md:3 (also names `templates/decision-record.md`, loaded) | `briefs/phase-1-gates.md` · `templates/status.md` | — |
| 7 | `areas/data-security.md`, `areas/method-documentation.md` | phase-7-handover.md:3 | `briefs/phase-1-gates.md` · `templates/status.md` | `briefs/verifier.md` — `procedure.md` § Phase 7 has no **Verification.** step (see A5-06) |

`procedure.md` itself additionally references `modes/diagnose.md`:3,63 (Phase 0 and the re-diagnosis) — hidden for every `run <N>`, and load-bearing for the re-diagnosis that `run 6 → 7` requires (procedure.md:148).

```
$ grep -rn 'as in `phase-1-gates.md`' briefs/*.md | cut -c1-60
briefs/phase-2-data.md:3:Common header: as in `phase-1-gates.md`
briefs/phase-3-performance.md:3:Common header: as in `phase-1-gates.md`
briefs/phase-4-interface.md:3:Common header: as in `phase-1-gates.md`
briefs/phase-5-tests.md:3:Common header: as in `phase-1-gates.md`
briefs/phase-6-documentation.md:3:Common header: as in `phase-1-gates.md`
briefs/phase-7-handover.md:3:Common header: as in `phase-1-gates.md`
```

### `review` (SKILL.md:21 — `modes/review.md` and the areas the diff touches)

| Referenced by `modes/review.md` | Line | Status |
|---|---|---|
| the areas' target state and rules | :3, :9, :20 | loaded (conditional) |
| a decision question / the Q&A protocol | :12 — "A change that introduces a new reversible choice gets a decision question, not a silent approval." | `modes/decision-qa.md`, `templates/decision-record.md` **hidden** |
| the verifier | :24 — "runs this mode after every change and before the verifier" | `briefs/verifier.md` **hidden** (loaded only when `review` is entered through `maintain`) |
| `<base>`/`<head>`/`<date>` placeholders | :7, :13 | `procedure.md` § Placeholders **hidden** |
| the stack map | :1 (step 1) | project artifact, fine |

Dead weight: none.

### `maintain` (SKILL.md:22)

| Loaded | Referenced by `modes/maintain.md` | Status |
|---|---|---|
| `modes/review.md` | :36 | used |
| `briefs/verifier.md` | :36 | used |
| `templates/agent-brief.md` | :33 | used |
| `modes/decision-qa.md` | :30 | used |
| `modes/diagnose.md` (drift) | :45, :48 | used |
| `briefs/phase-0-diagnosis.md` (drift) | :45 | used |
| — | :22 and :38, :49 — "Record the set in `status.md` § Maintenance"; "`status.md` § Maintenance: last drift check" | `templates/status.md` (the § Maintenance block is lines 40-46 there) and `modes/status.md` **hidden** |
| — | :11-18 source briefs R1.2, R1.4, R2.6, R3.4, R4.8, R4.9, R5.1, R5.3, R5.7, R6.4, R6.5 | covered by the Load cell's conditional "to install a missing guard, the source brief its table names" |
| — | the rejection cycle behind the verifier | `procedure.md` § Convergence **hidden** (see A5-05) |

Dead weight: none.

### `status` (SKILL.md:23 — `modes/status.md`, `templates/status.md`)

| Referenced by `modes/status.md` | Line | Status |
|---|---|---|
| `templates/status.md` | :7 | loaded |
| "If the row is a dispatch, re-fill the briefs from the synthesis" | :26 | `briefs/` **hidden** |
| "If it is a verification, dispatch the verifier" | :26 | `briefs/verifier.md` **hidden** |
| "If it is a decision, run the Q&A" | :26 | `modes/decision-qa.md` **hidden** |

This matters because `status` is also the no-argument default: SKILL.md:25 — "No argument: if `docs/remediation/status.md` exists, read it and continue from the first step without an evidence line".

### Findings

**A2-01 · SKILL.md:20,22,23 · P2 · `templates/status.md` is a hidden dependency of `run <N>` and `maintain`.** `procedure.md`:42 — "`status.md`  the evidence ledger: one row per step with evidence (`templates/status.md`)"; `modes/status.md`:7 — "Template in `templates/status.md`." Every `run <N>` must add that phase's eight-row block; `maintain` must write § Maintenance. → Add `templates/status.md` to the `run <N>` and `maintain` Load cells.

**A2-02 · SKILL.md:20 · P2 · `briefs/phase-1-gates.md` is a hidden dependency of `run 2`…`run 7`.** Six briefs delegate their whole common repair header to it (output above); that header carries "Do not commit. Do not use `git stash`.", the `// tested against:` rule, the RED-once rule, "Do not launch other agents", the variant search and the 15-line report cap. → Change the Load cell to `briefs/phase-N-*.md` **and** `briefs/phase-1-gates.md` § Common repair header.

**A2-03 · briefs/phase-1-gates.md:1-9 · P2 · `run 1` resolves "the areas that phase names" to nothing.** It is the only brief with no `Reference: areas/…` line (`grep -rn 'Reference: \`areas' briefs/*.md` returns phases 2-7 only), and `procedure.md`:67-78 names no area either, so `areas/quality.md` — which holds the target state Phase 1 must meet and the gate chain — never loads. → Add `Reference: \`areas/quality.md\`.` to briefs/phase-1-gates.md:3.

**A2-04 · SKILL.md:21 · P2 · `review` cannot execute its own step 6.** `modes/review.md`:12 requires a decision question and a superseding record; neither `modes/decision-qa.md` nor `templates/decision-record.md` is loaded. → Add both to the `review` Load cell.

**A2-05 · SKILL.md:23 · P2 · `status` (and the no-argument default) cannot execute resume step 3.** `modes/status.md`:26 dispatches the verifier or runs the Q&A; neither file is loaded. → Add `briefs/verifier.md` and `modes/decision-qa.md` to the `status` Load cell, or make step 3 an explicit mode switch.

**A2-06 · SKILL.md:16-23 · P2 · `procedure.md` § Autonomy contract loads only in `run <N>`.** SKILL.md:49 — "Full contract: `procedure.md` § Autonomy contract." `modes/diagnose.md`:57 — "From here on the phases proceed autonomously within the autonomy contract (`procedure.md`)." `diagnose`, `plan`, `review`, `maintain` and `status` all act without it. → Add `procedure.md` § Autonomy contract to those Load cells.

**A2-07 · SKILL.md:18,19 · P2 · `templates/decision-record.md` is a hidden dependency of `diagnose` and `plan`.** `modes/decision-qa.md`:50 — "**User answered**: write the decision record (`templates/decision-record.md`)"; `modes/diagnose.md`:30 makes "The first decision records to open" part of the synthesis. → Add it to both Load cells.

**A2-08 · SKILL.md:18 · P2 · the six `areas/*.md` are hidden dependencies of `diagnose`.** Each of D1-D5 names its area file as its reference, and `briefs/phase-0-diagnosis.md`:109 goes further — "Compare every item of \"Target state\" from `areas/interface.md` AND `areas/user-communication.md` against what actually exists". → State in the Load cell that each diagnosis agent must be given (or must read) its own `areas/*.md`.

**A2-09 · SKILL.md:16-23 · P3 · `GLOSSARY.md` (1 684 words) is loaded by no mode.** `sed -n '16,23p' SKILL.md | grep -c 'GLOSSARY'` → `0`. Yet GLOSSARY.md:3 — "Instructions use these terms exactly" — and SKILL.md:105 lists it in the file map. → Either name it in the modes that use its vocabulary, or drop the "use these terms exactly" claim.

**A2-10 · SKILL.md:98-105 · P3 · `README.md` is the only corpus file absent from § File map and from every Load cell.** `grep -n 'README' SKILL.md` → no output. Repo-facing by nature, but the map claims to be the file map. → Add one line marking it repo-facing, or leave as is.

---

## 3. Token cost per mode

`wc -w` per file; estimate = words × 1.3. `SKILL.md` (1 705 w / 2 217 tok) is loaded in every mode and is shown separately.

| Mode | files | words | est. tokens | + SKILL.md |
|---|---|---|---|---|
| `status` | 2 | 834 | 1 084 | 3 301 |
| `plan` | 2 | 1 724 | 2 241 | 4 458 |
| `review` (2 areas) | 3 | 2 547 | 3 311 | 5 528 |
| `maintain` (no drift) | 5 | 3 500 | 4 550 | 6 767 |
| `diagnose` | 5 | 5 441 | 7 073 | 9 290 |
| `run 1` | 6 | 6 041 | 7 853 | 10 070 |
| `run 3` | 7 | 6 863 | 8 922 | 11 139 |
| `run 6` | 7 | 6 863 | 8 922 | 11 139 |
| `maintain` (+ drift) | 7 | 6 543 | 8 506 | 10 723 |
| `review` (all 6 areas) | 7 | 7 010 | 9 113 | 11 330 |
| `run 5` | 7 | 7 348 | 9 552 | 11 769 |
| `run 2` | 7 | 7 397 | 9 616 | 11 833 |
| `run 7` | 8 | 7 738 | 10 059 | 12 276 |
| **`run 4` (worst case)** | **8** | **8 625** | **11 213** | **13 430** |
| `run 4` + its hidden deps (A2-01, A2-02) | 10 | 9 993 | 12 991 | 15 208 |
| **full corpus** | **28** | **28 768** | **37 398** | — |

`run 4` is the worst case: it is the only phase naming two areas (`areas/interface.md` 1 107 w + `areas/user-communication.md` 1 007 w) and carries the largest brief (`briefs/phase-4-interface.md` 1 444 w, ten repair briefs R4.1-R4.10).

**A3-01 · procedure.md:146-153 + SKILL.md:20 · P3 · `run 7` loads 7 738 words to dispatch a 374-word brief (20.7×), and 791 of those words have nothing to act on.** `briefs/phase-7-handover.md` is 374 words; `briefs/verifier.md` is 791 words, but `procedure.md` § Phase 7 has no **Verification.** section (measured in §5, A5-06), and the verifier's gate list (typecheck, lint, unit, real build, static rules, e2e) does not describe Phase 7's work (a fresh environment, a restore, signed minutes). → Either give Phase 7 a **Verification.** paragraph naming what the verifier checks there, or state in SKILL.md:20 that `briefs/verifier.md` is not loaded for N=7.

**A3-02 · procedure.md:61-153 + SKILL.md:20 · P3 · `run <N>` loads all eight phase sections when it needs one.** Measured: lines 61-153 (Phase 0-7) = 1 153 words of 2 436 (47 % of the file); the largest single phase block is 238 words (Phase 4), the smallest 73 (Phase 7). So 915-1 080 words (~1 190-1 400 tokens) of every `run <N>` load describe phases that are not being run. Not a defect — the ordering rules (`modes/diagnose.md`:37-46) allow phases to interleave, and `procedure.md`:110 has Phase 4 depend on Phase 3 — but it is the single largest avoidable block. → Optional: split `procedure.md` § Phases 1-7 into `briefs/`-adjacent headers, or accept the cost.

No mode's load is disproportionate to its work below `run 7`: `status` (1 084 tok) does a three-line report, `plan` (2 241 tok) produces a table and a question, `review` (3 311 tok for a two-area diff) produces a findings list — all proportionate.

---

## 4. Placeholder closure

`procedure.md`:55-57, § "Placeholders used in the briefs", is a single line with 15 bullets separated by `·`, carrying **16** distinct tokens (`<base>`/`<head>` share a bullet):

```
$ sed -n '57p' procedure.md | grep -oE '<[a-zA-Z][a-zA-Z0-9_-]*>' | sort -u | wc -l
16
```
Declared: `<repo> <stack> <map> <remediation> <files> <before> <record> <scratch> <N> <area> <date> <project> <language> <commit> <base> <head>`.

Used across `briefs/`, `templates/`, `modes/`, `areas/`, `SKILL.md`:
```
$ grep -rnoE '<[a-zA-Z][^<>]{0,60}>' --include=*.md briefs templates modes areas SKILL.md
```
(full output retained; 260 hits.)

### Declared but unused

**A4-01 · procedure.md:57 · P2 · `<files>` and `<record>` are declared and appear nowhere else.**
```
$ grep -rn '<files>' --include=*.md . | grep -v audit     → only procedure.md:57
$ grep -rn '<record>' --include=*.md . | grep -v audit    → only procedure.md:57
```
Both name real brief inputs — `templates/agent-brief.md`:40 writes `Work ONLY in: <list of files>` instead of `<files>`, and :44 writes `<binding decision record: docs/decisions/NNN, in one line>` instead of `<record>`. → Either use the declared tokens in `templates/agent-brief.md`:40,44 or delete the two bullets.

### Used but undeclared

**A4-02 · P2 · 30 placeholder tokens are used in briefs and templates without a declaration.** `procedure.md`:13 instructs "copy them and fill in the `<…>` placeholders with data from the diagnosis", so an agent filling only the declared 16 leaves these unresolved:

| token | file:line (first occurrences) |
|---|---|
| `<list>` (36 uses — the single most-used token in the corpus) | briefs/phase-1-gates.md:24,33,42 · briefs/phase-2-data.md:11,20,28,52,59 · briefs/phase-3-performance.md:36,51,66 · briefs/phase-4-interface.md:11,19,27,33,34,42,49,57,64,80 · briefs/phase-5-tests.md:41,55,61 · briefs/phase-6-documentation.md:23,31,39,52 · modes/decision-qa.md:63 |
| `<n>` (lowercase, "a count") | areas/quality.md:53 · briefs/phase-1-gates.md:24,42 · briefs/phase-2-data.md:28 · briefs/phase-3-performance.md:20,44 · briefs/phase-4-interface.md:11,72 · briefs/phase-5-tests.md:12,27 · briefs/phase-6-documentation.md:31,39 · modes/maintain.md:16 · templates/status.md:4 |
| `<file:line>` | briefs/phase-2-data.md:44,59 · briefs/phase-3-performance.md:11,44,51,59 · briefs/phase-4-interface.md:34,64,80 · briefs/phase-5-tests.md:41 |
| `<command>` | briefs/phase-1-gates.md:15 · briefs/verifier.md:13,14,15,16,17 |
| `<yes/no>` | briefs/phase-2-data.md:11,28,36 · briefs/phase-4-interface.md:11,57 · briefs/phase-5-tests.md:19 · briefs/phase-6-documentation.md:52 |
| `<file>` | areas/quality.md:56 · briefs/verifier.md:25,28 |
| `<name>` | briefs/verifier.md:25,28 · templates/status.md:17 |
| `<NN-phase>` | briefs/verifier.md:38 |
| `<path>` | templates/agent-brief.md:14,40 |
| `<step>` | templates/agent-brief.md:50,51 |
| `<service>` / `<service:function>` / `<adapter>` | briefs/phase-3-performance.md:10,19,36 |
| `<route>` | briefs/phase-3-performance.md:27,28 |
| `<page/action>`, `<cardinality>`, `<ms>`, `<which>`, `<k>`, `<s>`, `<t>` | briefs/phase-3-performance.md:11,20,28,44 · modes/decision-qa.md:62 |
| `<I>` (a test rig) | briefs/phase-5-tests.md:10,11,12 |
| `<P>` / `<process>` | briefs/phase-5-tests.md:60,61 |
| `<E>` | briefs/phase-4-interface.md:27 |
| `<population>`, `<pages>` | briefs/phase-4-interface.md:19,49 |
| `<rows>`, `<none>` | briefs/phase-5-tests.md:34 |
| `<numbers>` | templates/status.md:24 |
| `<branch-or-pr>` | modes/review.md:13 |
| `<letter>`, `<evidence>`, `<S/M/L>` | modes/decision-qa.md:33,36,63 |
| `<symptom>`, `<proposal>` | templates/diagnosis-report.md:61,71 |
| `<paste the lines>`, `<list of test files>` | briefs/verifier.md:10,24 |
| `<components>` | briefs/phase-0-diagnosis.md:100 |

→ Minimal change: add the recurring seven — `<list> <n> <file:line> <command> <file> <path> <route>` — to the procedure.md:57 line; the rest are self-describing inside their sentence.

### Same token, different meaning

**A4-03 · templates/agent-brief.md:23 vs procedure.md:57 · P2 · `<N>` means two different things.** Declared: "`<N>` phase number". Used as a phase number at SKILL.md:20, briefs/verifier.md:6, templates/status.md:4,17. Used as a **word cap** at templates/agent-brief.md:23 — "WHAT TO EXTRACT, in this exact format (Markdown, max `<N>` words)". An agent substituting the phase number produces "max 4 words". → Rename it `<words>` at templates/agent-brief.md:23.

**A4-04 · briefs/phase-0-diagnosis.md:18 · P3 · `<2200>` is a literal wearing placeholder syntax.** "Max `<2200>` words." Every other `<…>` in that file is a slot to fill. → Write `Max 2200 words.`

**A4-05 · templates/agent-brief.md:24 · P3 · `<Area>` is a capitalised variant of the declared `<area>`.** Used as a heading (`# <Area>`) alongside `<scratch>/<area>.md` on line 32 in the same block. → Lowercase it, or declare the casing rule.

**A4-06 · P3 · HTML/JSX text collides with placeholder syntax.** A mechanical `<…>` sweep hits `<label>` (areas/user-communication.md:29,46; briefs/phase-0-diagnosis.md:106), `<select` (areas/user-communication.md:46), `<input` (areas/user-communication.md:46; templates/diagnosis-report.md:49), `<button` (templates/diagnosis-report.md:49), `<Suspense>` (areas/performance.md:11; briefs/phase-3-performance.md:29), `<textarea` (areas/user-communication.md:46). → Note in procedure.md:55 that only the declared tokens are slots.

---

## 5. Contradictions

One row per statement of a rule that appears in more than one file.

### The autonomy contract — what the orchestrator may do alone

| file:line | verbatim | agrees? |
|---|---|---|
| procedure.md:22 | "**Does alone**: measurements and reports; database reads (`select` only); repairs in the working tree; tests, skeletons, lint, static rules; caches and invalidations; UI skeletons and feedback; writes to `docs/remediation/` and `docs/decisions/`." | — |
| SKILL.md:42 | "The orchestrator never writes code. One agent, one area, explicit `model`." | **diverges** |
| procedure.md:3 | "The orchestrator **does not write code**: it dispatches agents, reads reports, decides, verifies." | **diverges** |
| procedure.md:26 | "**Never**: … repair in person instead of resuming the agent." | **diverges** |
| GLOSSARY.md:72 | "**Orchestrator** … reasons, dispatches, reads reports, decides, verifies; never writes code" | agrees with SKILL.md:42 |

**A5-01 · procedure.md:22 · P2 · the "Does alone" column never names its actor, and read literally it contradicts the skill's first rule.** "repairs in the working tree", "tests, skeletons, lint, static rules", "caches and invalidations", "UI skeletons and feedback" are code changes; the same file says the orchestrator does not write code and must never "repair in person". The intended reading is presumably "the *run* does this without asking the user" — never stated. → Minimal change: open procedure.md:22 with "**The run does alone (through agents)**:".

### The ask-first list

| file:line | verbatim | agrees? |
|---|---|---|
| procedure.md:24 | "**Asks first**, collecting the points into one question per phase: deleting surfaces or dead code; any write to the real database (migrations, grants, policies); removing an alternative view or changing visible behavior that no decision record covers; touching live external integrations (email, backup, sync); anything that contradicts a decision record in the registry." | — |
| SKILL.md:44 | "Ask-first items are batched into one question per phase, unless a P1 blocks the phase midway." | agrees |
| procedure.md:15 | "Ask-first items and decision questions go to the user **once per phase**, in a single multiple-choice question that collects every point, unless a P1 blocks the phase midway." | agrees |
| modes/decision-qa.md:45 | "Never more than one question round per phase, unless a P1 blocks the phase midway." | agrees |

Per-brief ask-first markers (procedure.md:85 R2.2, :99 R3.2/R3.6, :114 R4.3, :126 R5.7, :150 R7.2; briefs/phase-2-data.md:3,54; briefs/phase-3-performance.md:5; briefs/phase-7-handover.md:3) all fall inside the five categories. No divergence. Duplication cost: the "unless a P1 blocks the phase midway" clause is restated verbatim three times (SKILL.md:44, procedure.md:15, modes/decision-qa.md:45) — 8 words × 3.

### The canary / A-B protocol

| file:line | verbatim | agrees? |
|---|---|---|
| briefs/verifier.md:25-29 | "`git show HEAD:<file>` into `<scratch>/<name>.orig` (if the file is new, copy the current file) · apply the minimal break … · run ONLY that test: it must be RED · restore the file; `cmp <scratch>/<name>.orig <file>` must be silent · never `git stash`, never `git checkout --` on the whole tree" | — |
| areas/quality.md:56 | "A/B comparisons and counter-tests on **one file**: `git show HEAD:<file>` into a temp file, swap it in, run the targeted test, restore, `cmp`. Never `git stash` on a tree shared with another session." | same protocol; **new-file caveat missing** (see A6-10) |
| areas/method-documentation.md:84 | "**`git stash` used for A/B** on a shared tree: use one file with `cmp`, or a `git worktree`." | adds `git worktree`, absent from the other two |
| briefs/phase-5-tests.md:13 | "list the invariants; for each one, the minimal break; run it and report the red; restore; `cmp`." | agrees |
| areas/quality.md:53 | "Every rig knows how to turn red: `CANARY=<n>` comes out red for every `n`." | agrees with briefs/phase-5-tests.md:12 |

### The no-`git stash` rule

| file:line | verbatim | agrees? |
|---|---|---|
| procedure.md:26 | "`git stash` on a shared tree" (under **Never**) | conditional |
| areas/quality.md:56 | "Never `git stash` on a tree shared with another session." | conditional |
| areas/method-documentation.md:84 | "**`git stash` used for A/B** on a shared tree" | conditional |
| briefs/phase-1-gates.md:6 | "Do not use `git stash`." | **absolute** |
| briefs/verifier.md:29 | "never `git stash`, never `git checkout --` on the whole tree" | **absolute** |

**A5-02 · briefs/phase-1-gates.md:6, briefs/verifier.md:29 vs procedure.md:26 · P2 · the rule is absolute in the two places an agent reads it and conditional in the three places the orchestrator reads it.** A repair agent told "Do not use `git stash`" has no way to know the rule is about a shared tree, and `briefs/phase-1-gates.md`:6 is the common header of six briefs (A2-02). Divergence changes meaning: an agent working alone in a private worktree is forbidden a legitimate tool. → Make the two agent-facing statements conditional, or drop the condition from the three orchestrator-facing ones.

### The evidence rule

| file:line | verbatim | agrees? |
|---|---|---|
| SKILL.md:45 | "a step without an evidence line is not done, and phase N+1 does not start while phase N has one" | — |
| procedure.md:11 | "A row without evidence is not done." | exact restatement |
| modes/status.md:11 | "A row without evidence is **not done**, whatever the conversation says." | exact restatement |
| modes/status.md:16 | "Phase N+1 does not start while phase N has a row without evidence, unless a ruling line in the defect register explains the parking." | adds the ruling exception |
| templates/status.md:6 | "Rules: a row without evidence is not done. … Phase N+1 does not start while phase N has an empty evidence cell (unless a ruling line in `defect-register.md` explains it)." | agrees with modes/status.md:16 |
| GLOSSARY.md:82 | "one row per step with evidence; a row without evidence is not done; the next phase cannot start over an empty cell" | no ruling exception |
| SKILL.md:92 | "A phase started while the previous one has a step without evidence." (red flag) | no ruling exception |

No meaning-changing divergence (the ruling exception is stated in 2 of 7 sites and contradicted by none). **Duplication cost**: 7 sites, ~95 words restating one rule.

### Who may apply migrations, and when

| file:line | verbatim | agrees? |
|---|---|---|
| procedure.md:24 | "any write to the real database (migrations, grants, policies)" — ask-first | — |
| briefs/phase-2-data.md:3 | "Migrations are written into the repo and applied only after the user's go-ahead, by a dedicated agent, with the verification query run immediately after." | agrees, adds "by a dedicated agent" |
| briefs/phase-2-data.md:24 | "note in the report: \"apply after the go-ahead, then run verify-permissions.sql.\"" | agrees |
| areas/data-security.md:33 | "Migrations applied and verified on the database **before** pushing the code that uses them." | agrees (ordering, not authority) |
| procedure.md:85 | "`R2.2` RLS policies and grants: **migration proposal** plus verification queries (applying it is ask-first)" | agrees |
| procedure.md:99 | "`R3.2` counts and aggregations moved into the database (functions: migration is ask-first) · … `R3.6` generated columns and indexes (migration: ask-first)" | agrees |
| briefs/phase-3-performance.md:22,53 | "DON'T: apply the migration" / "DON'T: apply it" | agrees |
| briefs/phase-7-handover.md:23 (R7.3) | "GOAL: all migrations applied on the new project" | agrees (R7.2 is post-go-ahead, phase-7-handover.md:3,15) |

Consistent.

### The language rule

| file:line | verbatim |
|---|---|
| SKILL.md:8 | "Instructions are in English; every output (reports, decision records, commit messages, UI text) is written in the host project's language, detected in Phase 0." |
| procedure.md:5 | "Instructions in this file are in English. All outputs (reports, decision records, defect register entries, lessons, commit messages) are written in the host project's language, detected in Phase 0 and recorded in the stack map." |
| GLOSSARY.md:3 | "Instructions use these terms exactly; outputs (reports, decision records, commit messages) use the host project's language." |
| areas/user-communication.md:5 | "user-facing text … is written in the host project's language. These instructions are in English." |
| areas/method-documentation.md:63 | "Documents, reports, decision records, and checklists are written in the host project's language; these instructions are in English." |
| briefs/phase-0-diagnosis.md:11 | "Write the report in the host project's language (see `<map>`); if unknown yet (D0), use the language of the project's README and commits." |
| briefs/phase-1-gates.md:6 | "Reports, decision records, commit messages, UI text and documents are written in the host project's language (see `<map>`); these instructions are in English." |
| briefs/verifier.md:7 | "Write the report in the host project's language (recorded in the stack map); these instructions are in English." |
| templates/agent-brief.md:7, templates/decision-record.md:7, templates/diagnosis-report.md:3, modes/decision-qa.md:71, modes/review.md:13 | same rule, same meaning |

No divergence. **Duplication cost**: 16 occurrences of "host project's language" across 13 files; 8 separate statements of "these instructions are in English"; ~210 words total. Related: the sentence "These are defaults: if the host project already has a docs language and folder convention, use it (the stack map records it)." (17 words) appears in **10** files — procedure.md:51, areas/method-documentation.md:40, briefs/phase-0-diagnosis.md:22, briefs/phase-1-gates.md:35, briefs/phase-2-data.md:19, briefs/phase-4-interface.md:10, briefs/phase-5-tests.md:26, briefs/phase-6-documentation.md:10, briefs/phase-7-handover.md:10, templates/decision-record.md:7 — ~170 words. Both are exact restatements, not divergences.

### The verifier's model

| file:line | verbatim | agrees? |
|---|---|---|
| briefs/verifier.md:3 | "One agent per phase, `model: sonnet`, launched **after** the repair agents" | — |
| templates/agent-brief.md:3 | "explicit `model` (`sonnet` for mechanical work and inventories; `haiku` for trivial transforms; the flagship model only for a single judgment call or synthesis)" | **tension** |
| procedure.md:165 | "**Round 4**: a **fresh agent on a more capable model**" | — |
| briefs/phase-5-tests.md:47 | "`model: sonnet` for the hunters; a top-tier model ONLY for a referee, if needed" | — |

**A5-03 · briefs/verifier.md:3 · P3 · the verifier runs on the same model as the agents it judges, while the brief template reserves the flagship model for exactly this kind of call.** Measured: every `model:` in the corpus is `sonnet` except the conditional referee at briefs/phase-5-tests.md:47. procedure.md:17 — "The orchestrator **does not trust the repair agent's own report**: it trusts the verifier." → Either raise briefs/verifier.md:3, or add one line saying why sonnet is sufficient for the verifier.

### The rejection-round cap

| file:line | verbatim | agrees? |
|---|---|---|
| procedure.md:164 | "**Rounds 1-3**: **resume the same agent** (its context is intact) with the rejections quoted verbatim, not summarized." | — |
| procedure.md:165 | "**Round 4**: a **fresh agent on a more capable model** … and the line \"an agent has tried three times, now it's yours\"." | — |
| procedure.md:166 | "**After round 4**, the orchestrator decides, for each residue: **parked** … or **structural**, which blocks and returns to the plan" | — |
| README.md:35 | "a rejection cycle with a cap and written rulings" | agrees, no number |
| SKILL.md:88 | "A verifier rejection dismissed without a ruling line." (red flag) | agrees, no cycle |
| briefs/verifier.md:10 | "If this is a RE-VERIFICATION after a rejection: look only at the fix's diff" | agrees, no cap |

**A5-04 · procedure.md:160-168 · P2 · the rejection cycle exists only in `procedure.md`, which `maintain` and `review` never load.** Both run the verifier (modes/maintain.md:36; modes/review.md:24, briefs/verifier.md:48-56 "Diff mode (used by `review` and by the change-time protocol of `maintain`)"), and briefs/verifier.md:56 ends at "A P1 blocks the merge" with no instruction for what happens next. A cold agent in `maintain` has no resume-the-same-agent rule, no round cap and no ruling requirement. → Add one line to briefs/verifier.md § Diff mode pointing at `procedure.md` § Convergence, or add `procedure.md` § Convergence to the `maintain`/`review` Load cells.

### "The only mandatory user checkpoint"

| file:line | verbatim | agrees? |
|---|---|---|
| SKILL.md:45 | "The plan question after Phase 0 is the only mandatory user checkpoint of a remediation run." | — |
| procedure.md:63 | "Its plan question is the only mandatory user checkpoint of a remediation run" | exact restatement |
| modes/diagnose.md:3 | "The plan question at the end is the only mandatory user checkpoint of a remediation run" | exact restatement |
| modes/status.md:3 | "It is not a user checkpoint: the only mandatory one is the plan question after Phase 0." | exact restatement |
| README.md:19 | "its plan question is the only mandatory user checkpoint of a remediation run" | exact restatement |
| modes/maintain.md:48 | "ask the plan question once: it is the drift check's own checkpoint." | **diverges** |
| modes/decision-qa.md:14 | "**Confirm.** Wait for the user's confirmation of the reformulation and the questions. Then dispatch." | **diverges** |
| procedure.md:15 | "Ask-first items and decision questions go to the user **once per phase**" | **diverges** in practice |

**A5-05 · SKILL.md:45 vs modes/maintain.md:48 and modes/decision-qa.md:14 · P2 · "the only mandatory user checkpoint" is true only inside a remediation run and only when there are no notes and no ask-first items.** The drift check has its own mandatory plan question; the notes protocol mandates a wait before any dispatch ("Do not dispatch anything before the reformulation is confirmed" — modes/diagnose.md:7); each phase with an ask-first item or a reversible choice produces a mandatory question. The qualifier "of a remediation run" carries the whole claim and is dropped at modes/status.md:3. → Reword to "the only checkpoint that is mandatory even when nothing needs asking", or list the other three.
**Duplication cost**: the exact phrase "the only mandatory user checkpoint of a remediation run" appears verbatim at 4 sites (`grep -rno`), ~10 words each.

### The commit rule

| file:line | verbatim | agrees? |
|---|---|---|
| SKILL.md:47 | "Never commit without a mandate." | — |
| procedure.md:26 | "**Never**: commit or push without explicit authorization" | agrees |
| briefs/phase-1-gates.md:6 | "Do not commit." | absolute (agent-facing) |
| templates/agent-brief.md:58 | "do not commit" | absolute (agent-facing) |
| modes/maintain.md:33 | "one agent per area, files listed, tests declared, one test red once, variant search, no commit." | absolute |
| areas/quality.md:57 | "Whoever changes visible behavior updates the test in the same commit: grep `tests/` for the disappearing string before committing." | **presupposes a committer** |
| areas/method-documentation.md:19 | "Commits written in the host project's language, stating the **effect** on the user or the data and the why, not the implementation." | **presupposes a committer** |
| areas/method-documentation.md:67 | "Commit messages follow the host project's language; the shape is `fix(area): <what changes for the user>, <why or the flip side>`." | **presupposes a committer** |
| briefs/phase-6-documentation.md:23-25 (R6.3) | "one record for every reversible choice made in the round, dated from the commit" | **presupposes commits exist** |

**A5-06 · SKILL.md:47, procedure.md:24-26 · P2 · nobody in the procedure is allowed to commit, no step requests the mandate, and no ledger row records it — yet three area files prescribe commit content.** Committing is not in the ask-first list (procedure.md:24); `templates/status.md` has no commit row (rows N.1-N.8 are briefs/dispatch/synthesis/decision/repairs/variants/verification/exit); `modes/decision-qa.md` never raises it. A phase can therefore close with every repair uncommitted and the next phase's `git status --short` precondition (modes/diagnose.md:9 "is empty. If not, stop") failing. → Add "commit of the phase's repairs" to the ask-first list at procedure.md:24, or add a ninth ledger row.

**A5-07 · procedure.md:146-153 · P2 · Phase 7 is the only phase with no Verification step, while the ledger demands one for every phase.**
```
$ sed -n '146,153p' procedure.md | grep -oE '\*\*[A-Za-z ]+\.\*\*'
**Entry.**  **Dispatch.**  **Exit.**
$ sed -n '134,143p' procedure.md | grep -oE '\*\*[A-Za-z ]+\.\*\*'   # Phase 6, for contrast
**Entry.**  **Dispatch.**  **Verification.**  **Exit.**
```
Phases 1-6 all carry **Verification.**; Phase 7 does not. `templates/status.md`:27 — "| N.7 Verification verdict | | | verifier | |" — and SKILL.md:45 — "The verifier closes a phase, never the implementer." → Add a **Verification.** paragraph to procedure.md § Phase 7 (the material exists: briefs/phase-7-handover.md:23,28,33,39 name the checks).

---

## 6. Executability of every printed command

Fixture at `…/scratchpad/fix` (`src/features/caps.ts`, `src/features/scan.ts`, `src/components/form.tsx`, `app/dashboard/loading.tsx`, `docs/decisions/`). Environment: `grep (GNU grep) 3.0`, `node v24.19.0`, `semgrep 1.176.0`, Git Bash on Windows 11. PostgreSQL: **not reachable** — SQL verified against documentation only.

| file:line | command | runs? | matches claim? | evidence |
|---|---|---|---|---|
| areas/performance.md:29 | `grep -rnE "limit: [0-9]{3,}"` | yes (GNU) | **no** | see A6-03 |
| briefs/phase-0-diagnosis.md:87, templates/diagnosis-report.md:39 | `grep -rnE "limit: ?[0-9]{3,}"` | yes (GNU) | **no** | see A6-03 |
| areas/performance.md:23, templates/diagnosis-report.md:33 | `grep -rn "\.all()" src/features` | yes | yes | matched `repo.all()` and `repo .all()`, 2 hits |
| areas/interface.md:39, briefs/phase-0-diagnosis.md:100, templates/diagnosis-report.md:43 | `grep -rn "disabled" src/components` | yes | yes, with noise | 3 hits incl. `aria-disabled` and a comment — the prose already says "empty or justified" |
| procedure.md:116, briefs/phase-4-interface.md:38 | `grep disabled` | **hangs / wrong input** | **no** | see A6-04 |
| areas/interface.md:42, briefs/phase-0-diagnosis.md:103, templates/diagnosis-report.md:46 | `grep -rnE "#[0-9a-f]{6}\|\[[0-9]+px\]" src` | yes | **partly** | see A6-06 |
| templates/diagnosis-report.md:47 | `grep -rn "error.message\|String(err\|digest" src/components src/app` | yes | **partly** | see A6-11 |
| briefs/phase-0-diagnosis.md:105 | `grep -rn "error.message\|String(err\|digest\|JSON.stringify(err"` | yes (GNU only, no path) | **partly** | see A6-08, A6-11 |
| briefs/phase-6-documentation.md:12 | `find docs -type f \| sed 's\|/[^/]*$\|\|' \| sort \| uniq -c` | yes | yes | output `      3 docs/decisions` — "one line per folder (role, file count from the command)" satisfied; empty folders absent |
| templates/diagnosis-report.md:40 | `find app -name loading.tsx` | yes | yes | `app/dashboard/loading.tsx` |
| templates/decision-record.md:9 | `ls docs/decisions/[0-9]*.md \| sort` | yes | **partly** | see A6-09 |
| areas/method-documentation.md:71 | `ls \| tail -1` (named as the anti-pattern) | n/a | yes | correct as a warning |
| briefs/verifier.md:25-28 | `git show HEAD:<file>` → `cmp` | yes | yes | `git show HEAD:SKILL.md > …orig` exit 0; `cmp …orig SKILL.md` exit 0, silent |
| areas/quality.md:56 | `git show HEAD:<file>` into a temp file | yes | **gap** | see A6-10 |
| modes/diagnose.md:9 | `git status --short` | yes | yes | ran on this repo |
| modes/diagnose.md:67, modes/review.md:7, briefs/verifier.md:55 | `git diff --name-only <base>..<head>` / `<commit>..HEAD` | yes | yes | standard syntax |
| briefs/verifier.md:34 | `git status --short` and `git diff --stat` | yes | yes | standard syntax |
| areas/quality.md:54, templates/diagnosis-report.md:17 | `semgrep --test` | yes | yes | see below |
| briefs/phase-1-gates.md:26,28 | `semgrep:test` script, `--test` green, `ruleid:`/`ok:` fixtures, "Never `--config auto`" | yes | yes | see below |
| briefs/phase-0-diagnosis.md:61 | `npx gitleaks detect --no-git` | **no** | **no** | see A6-01 |
| briefs/phase-0-diagnosis.md:63, areas/data-security.md:49-54,69 | `select p.proname, array_to_string(p.proacl,' \| ') from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public'` | syntax valid | **no** | see A6-02 |
| areas/data-security.md:47, briefs/phase-0-diagnosis.md:62 | `select tablename, rowsecurity from pg_tables where schemaname='public'`; `select * from pg_policies` | syntax valid, columns exist | **partly** | see A6-05 |
| briefs/phase-3-performance.md:54 | `explain` uses the index | valid SQL | yes | standard |
| briefs/phase-1-gates.md:19 | `npm run verify` exits 0 | yes | yes | script name is host-defined |
| templates/diagnosis-report.md:15 | `next lint` | **no (Next 16)** | **no** | see A6-12 |
| SKILL.md:96, README.md:35 | `next build`, `node --test` | yes | yes | `next build` present in the Next 16.3.4 CLI; `node --test` present in node v24.19.0 |

### Verified-good, with output

```
$ semgrep --test --config rules tests          # rules/no-eval.yaml + tests/no-eval.js with ruleid:/ok:
1/1: ✓ All tests passed
exit=0
```
The `ruleid:` / `ok:` fixture convention (areas/quality.md:10, briefs/phase-1-gates.md:25-29) and the `--test` flag (present in `semgrep scan --help`) are correct; "Never `--config auto` (it hits the network)" is correct — `auto` fetches the registry.

### Findings

**A6-01 · briefs/phase-0-diagnosis.md:61 · P1 · `npx gitleaks detect --no-git` cannot run.**
```
$ npx --yes gitleaks --version
npm error could not determine executable to run
```
`https://registry.npmjs.org/gitleaks` (fetched 2026-09-11): the npm package `gitleaks` is at version 1.0.0, described as "custom rules", `"main":"index.js"`, **no `bin` field** — it is a rules library, not the Go binary. The brief's own escape hatch ("if unavailable, \"not measured\"") means the secrets measure silently degrades to "not measured" on every project, and `templates/diagnosis-report.md`:23 still asks for a gitleaks number. The wording is also ambiguous: "`npx gitleaks detect --no-git` or `--no-banner`" reads as two alternatives where both are flags of the same command. → Minimal change: replace with `gitleaks dir . --no-banner` and add "install from https://github.com/gitleaks/gitleaks (a Go binary, not an npm package)".

**A6-02 · briefs/phase-0-diagnosis.md:63, areas/data-security.md:49-54,69 · P1 · the grants query reports the most permissive case as an empty cell.** Column names verified — `https://www.postgresql.org/docs/current/catalog-pg-proc.html`: `proname` `name` "Name of the function"; `pronamespace` `oid` "The OID of the namespace that contains this function"; `proacl` `aclitem[]` "Access privileges; see Section 5.8 for details". `array_to_string` accepts `anyarray` (`https://www.postgresql.org/docs/current/functions-array.html`: "`array_to_string ( array anyarray, delimiter text [, null_string text ] ) → text`"), so the SQL is syntactically fine. The semantics are not. `https://www.postgresql.org/docs/current/ddl-priv.html`: "If the \"Access privileges\" column is empty for a given object, it means the object has default privileges (that is, its privileges entry in the relevant system catalog is null)." and "For other types of objects, the default privileges granted to `PUBLIC` are as follows: … `EXECUTE` privilege for functions and procedures". A function that was never granted or revoked therefore has `proacl` NULL — `array_to_string(NULL, …)` yields NULL — and the row prints an empty second column, which reads exactly like "no grants, clean". The brief's instruction is "List the ones executable by public roles"; areas/data-security.md:54 is "Only the expected roles should appear (normally `postgres` / `service_role`)"; areas/data-security.md:69 is "No sensitive function is executable by public roles: query `pg_proc.proacl`." All three are satisfied by a function that PUBLIC can execute. This is the same trap the file warns about at :70 ("`revoke … from public` **is not enough**") and :81. Not executed here (no Postgres reachable). → Minimal change: add `coalesce(array_to_string(p.proacl,' | '), 'DEFAULT — PUBLIC CAN EXECUTE')` and a line stating that a null `proacl` is a P1, not a pass.

**A6-03 · areas/performance.md:29, briefs/phase-0-diagnosis.md:87, templates/diagnosis-report.md:39 · P2 · the cap regex misses the call form the stack actually uses.** Fixture `src/features/caps.ts`:
```
1 const a = await db.from('contacts').select('*').limit(1000);
2 const b = { limit: 1000 };
3 const c = { limit:1000 };
4 const d = { limit:  1000 };
8 const h = { pageSize: 1000 };
$ grep -rnE "limit: [0-9]{3,}" src         →  src/features/caps.ts:2   (1 hit)
$ grep -rnE "limit: ?[0-9]{3,}"            →  src/features/caps.ts:2,3 (2 hits)
```
Line 1 — `.limit(1000)`, the Supabase/query-builder form named throughout the corpus (briefs/phase-3-performance.md:12 "DB-filtered query", GLOSSARY.md:53) — is missed by both. So is `limit:  1000` (two spaces). The surrounding claim is areas/performance.md:29 — "**Caps**: `grep -rnE \"limit: [0-9]{3,}\"` in bulk actions; does every occurrence declare truncation?" and briefs/phase-3-performance.md:58 — "files: the bulk actions with a fixed `limit` (from D3)". A diagnosis that returns zero here sends R3.7 an empty file list. The two spellings also differ between three files (`limit: ` vs `limit: ?`). → Minimal change: one spelling everywhere, `grep -rnE "\.limit\(|limit:\s*[0-9]{3,}"`.

**A6-04 · procedure.md:116, briefs/phase-4-interface.md:38 · P2 · `grep disabled` has no `-r` and no path: it reads stdin.**
```
$ grep disabled < /dev/null ; echo exit=$?
exit=1
$ printf 'a disabled b\n' | grep disabled
a disabled b
```
With a terminal on stdin it blocks. The claims are procedure.md:116 — "`grep disabled` across components empty or justified" — and briefs/phase-4-interface.md:38 — "DONE: `grep disabled` on the components = 0 or documented". Both read "= 0" as success, and the command returns exit 1 / no output for the wrong reason: it searched nothing. The correct form exists two files away (areas/interface.md:39 `grep -rn "disabled" src/components`). → Minimal change: use `grep -rn "disabled" <components>` in both places.

**A6-05 · areas/data-security.md:22,47, briefs/phase-0-diagnosis.md:62 · P2 · the RLS queries cannot see the two things that decide whether RLS is actually enforced.** Columns verified — `https://www.postgresql.org/docs/current/view-pg-tables.html`: `schemaname`, `tablename`, `rowsecurity` `bool` "True if row security is enabled on the table" all exist; `https://www.postgresql.org/docs/current/view-pg-policies.html`: `schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check` — all eight exist. The gap is semantic. `https://www.postgresql.org/docs/current/ddl-rowsecurity.html`: "Superusers and roles with the `BYPASSRLS` attribute always bypass the row security system when accessing a table. Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with `ALTER TABLE … FORCE ROW LEVEL SECURITY`." The flag that proves it is `relforcerowsecurity` in `pg_class` (`https://www.postgresql.org/docs/current/catalog-pg-class.html`: "True if row-level security (when enabled) will also apply to table owner"), and `pg_class` is queried nowhere in the corpus (`grep -rn 'pg_class' --include=*.md .` → no output). Second gap: `select * from pg_policies` lists policies that exist, but the target state is deny-all — "If no policy exists for the table, a default-deny policy is used" — so a *correct* table produces **no row**, indistinguishable from a table the query simply did not reach. The claim is areas/data-security.md:22 — "**Deny-all row-level security** on every table, no policy for public roles until real database identities exist; verified with a query." → Minimal change: add `select relname, relrowsecurity, relforcerowsecurity from pg_class …` and state that the `pg_tables` result must be joined against the full table list, not read alone.

**A6-06 · areas/interface.md:42, briefs/phase-0-diagnosis.md:103, templates/diagnosis-report.md:46 · P2 · the token-escape regex is case-sensitive and misses uppercase hex.** Fixture:
```
4 <span className="text-[14px]" style={{color:'#a1b2c3'}} />
5 <span style={{color:'#A1B2C3'}} />
6 <span style={{color:'#aabbccdd'}} />
$ grep -rnE "#[0-9a-f]{6}|\[[0-9]+px\]" src
src/components/form.tsx:4
src/components/form.tsx:6
```
Line 5 (`#A1B2C3`) is not matched. The claim is areas/interface.md:42 — "colors and spacing outside the tokens" — and briefs/phase-4-interface.md:14 — "TEST: grep `#[0-9a-f]{6}|\[[0-9]+px\]` on the components = 0 or documented". A file using uppercase hex passes the gate. → Minimal change: add `-i`, or write `#[0-9a-fA-F]{3,8}`.

**A6-07 · P2 · no command in the corpus establishes a working directory, and every path is repo-relative.**
```
$ grep -rnoiE 'cd <repo>|working directory|from the repo root|repository root' --include=*.md .
(no output)
```
`briefs/phase-0-diagnosis.md`:8 and `briefs/phase-1-gates.md`:6 give the agent `Repo: <repo>.` as data, never as a `cd`. The commands that then fail from any other cwd: `find docs -type f …` (briefs/phase-6-documentation.md:12), `ls docs/decisions/[0-9]*.md` (templates/decision-record.md:9), `grep -rn "\.all()" src/features` (areas/performance.md:23), `grep -rn "disabled" src/components` (areas/interface.md:39), `find app -name loading.tsx` (templates/diagnosis-report.md:40), `git status --short` (modes/diagnose.md:9), `git show HEAD:<file>` (briefs/verifier.md:25). The verifier is the one place that gets it right by using an absolute-ish token: `<command> > <scratch>/build.log 2>&1` (briefs/verifier.md:16). → Minimal change: add "Run every command from `<repo>`." to the common header at briefs/phase-0-diagnosis.md:8 and briefs/phase-1-gates.md:6.

**A6-08 · areas/performance.md:29, briefs/phase-0-diagnosis.md:87,103,105 · P2 · four printed greps use `-r` with no path operand, which works on GNU grep only.** `grep --help` on GNU grep 3.0 documents `-r, --recursive   like --directories=recurse`; with no FILE operand GNU grep defaults to the working directory, and the four commands ran correctly here (outputs above). BSD/macOS `grep` requires a path and exits with a usage error. The corpus targets no OS; `README.md`:35 describes a real project but SKILL.md:96 says the names are translated per host. Nine other printed greps in the same files *do* carry a path, so the omission is inconsistent rather than deliberate. → Minimal change: append the path (`src`, or `.`) to the four.

**A6-09 · templates/decision-record.md:9 · P3 · the numbering command does not compute what the sentence claims, and hides its own failure behind a pipe.** Claim: "**Numbering.** The first free number, found by **listing the whole folder** (`ls docs/decisions/[0-9]*.md | sort`), never `ls | tail -1`". `ls` already sorts, so `| sort` adds nothing, and the command lists — it does not compute a first free number.
```
$ ( cd empty && ls docs/decisions/[0-9]*.md | sort ) ; echo exit=$?
ls: cannot access 'docs/decisions/[0-9]*.md': No such file or directory
exit=0
```
On an empty register (the first-week case the file itself insists on, areas/method-documentation.md:7 "Started **in the first week**") the pipeline reports **exit 0** while `ls` failed — the exact defect the skill forbids elsewhere: areas/quality.md:81 "**`build | tail`**: the exit status is `tail`'s, not the build's", briefs/verifier.md:12 "NEVER from a pipe". → Minimal change: `ls docs/decisions/[0-9]*.md 2>/dev/null` and drop `| sort`.

**A6-10 · areas/quality.md:56 · P3 · the A/B recipe omits the new-file caveat its sibling carries.**
```
$ git show HEAD:no-such-file.md ; echo exit=$?
fatal: path 'no-such-file.md' does not exist in 'HEAD'
exit=128
```
briefs/verifier.md:25 handles it — "`git show HEAD:<file>` into `<scratch>/<name>.orig` (if the file is new, copy the current file)". areas/quality.md:56 does not, and the canary is run precisely on tests the repair agent has just created (briefs/phase-1-gates.md:6 "Every new test … must have been RED once"). → Minimal change: add the same parenthesis to areas/quality.md:56.

**A6-11 · templates/diagnosis-report.md:47, briefs/phase-0-diagnosis.md:105, areas/user-communication.md:25 · P3 · `error.message` leaves the `.` unescaped.**
```
11 <p>{errorXmessage}</p>
$ grep -rn "error.message\|String(err\|digest" src/components src/app
… src/components/form.tsx:11:<p>{errorXmessage}</p>
```
A false positive, not a false negative; it inflates the count that feeds briefs/phase-4-interface.md:68 "DONE: grep `error.message` toward the client = 0". → Minimal change: `error\.message`.

**A6-12 · templates/diagnosis-report.md:15 · P3 · `next lint` is not a command in current Next.js.** `https://nextjs.org/docs/app/api-reference/cli/next` (version 16.3.4, fetched 2026-09-11) lists the commands `dev`, `build`, `start`, `info`, `telemetry`, `typegen`, `upgrade`, `experimental-analyze` — `lint` is absent. `next build` is present, so SKILL.md:96 and README.md:35 are fine. The template prints `next lint` in the "command that reproduces it" column for the lint-Errors row. → Minimal change: replace with `<lint command from the stack map>`, consistent with SKILL.md:96.

---

## 7. Counts asserted in prose

| claim | file:line | verified value | command | verdict |
|---|---|---|---|---|
| "The ledger has **eight rows per phase**" | procedure.md:11 | 8 rows in the `Phase <N>` block | `sed -n '17,31p' templates/status.md \| grep -c '^\| N\.'` → `8` | **OK** |
| "One block per phase; **eight rows per phase** following the cycle" | modes/status.md:7 | same 8, and the named order (briefs filled · dispatch · synthesis · decision · repairs · variant search · verification · exit) matches rows N.1-N.8 verbatim | as above | **OK** |
| — but for **Phase 0** | templates/status.md:8-15 | **4** rows (0.1-0.4) | `sed -n '8,16p' templates/status.md \| grep -c '^\| 0\.'` → `4` | **mismatch** (A7-01) |
| — and for **Re-diagnosis** | templates/status.md:32-38 | **3** rows (RD.1-RD.3) | `grep -c '^\| RD\.' templates/status.md` → `3` | **mismatch** (A7-01) |
| "**Six conditions**, each **measured**" | SKILL.md:29 | 6 numbered items, lines 31-36, one per area file | `sed -n '29,38p' SKILL.md \| grep -c '^[0-9]\. '` → `6` | **OK** |
| six areas | SKILL.md:103, README.md:29 | 6 files | `ls areas/ \| wc -l` → `6` | **OK** |
| "**Six agents**, `model: sonnet`" / D0-D5 | modes/diagnose.md:16, README.md:28 | D0…D5 = 6 | `grep -oE '^## D[0-5]' briefs/phase-0-diagnosis.md` → `## D0 ## D1 ## D2 ## D3 ## D4 ## D5` | **OK** |
| six modes | SKILL.md:16-23, GLOSSARY.md:81 | 6 table rows; `modes/` has 5 files (`plan` and `run <N>` share `diagnose.md`/`procedure.md`) | `sed -n '16,24p' SKILL.md \| grep -c '^\| \`'` → `6`; `ls modes/ \| wc -l` → `5` | **OK** (SKILL.md:100 lists the 5 files correctly) |
| briefs: "one file per phase, plus `verifier.md`" | SKILL.md:102, README.md:28 | 9 files (8 phases + verifier) | `ls briefs/ \| wc -l` → `9` | **OK** |
| templates: agent-brief, decision-record, diagnosis-report, status | SKILL.md:104 | 4 files | `ls templates/ \| wc -l` → `4` | **OK** |
| "**eight-phase** procedure" | README.md:3 | Phases 0-7 = 8 | `sed -n '61,153p' procedure.md` headings | **OK** |
| "**three to five processes** that cross the most modules" | briefs/phase-0-diagnosis.md:34 | instruction, not a corpus count; not contradicted elsewhere | `grep -rn 'three to five' --include=*.md .` → 1 hit | **OK** |
| "Max `<2200>` words" | briefs/phase-0-diagnosis.md:18 | the only word cap in the corpus; `templates/agent-brief.md`:23 leaves it as `<N>` | `grep -rnoE 'max [<]?[0-9]+[>]? (words\|lines)'` | **OK** (but see A4-03, A4-04) |
| "max 60 lines" (verifier report) | briefs/verifier.md:38 | 1 site, no contradiction | same grep | **OK** |
| "max 15 lines" (repair report) | briefs/phase-1-gates.md:6, templates/agent-brief.md:71 | 2 sites, identical | same grep | **OK** |
| "**four rounds**" rejection cap | procedure.md:164-166 | Rounds 1-3, Round 4, After round 4 — internally consistent; "an agent has tried three times" matches rounds 1-3 | read | **OK** (scope problem is A5-04) |
| "**five states**" | SKILL.md:35, GLOSSARY.md:62, areas/user-communication.md:10,26,45, briefs/phase-4-interface.md:65, procedure.md:114, templates/diagnosis-report.md:48 | 5 in every enumeration, same members (loading · empty · empty-after-filter · error · partial/truncated) | `grep -rn 'five states\|[Ff]ive distinct states'` → 8 sites | **OK** |
| brief ids per phase vs `procedure.md` dispatch lists | procedure.md:71,85,99,114,126,138,150 | R1.1-1.4 = 4 · R2.1-2.7 = 7 · R3.1-3.8 = 8 · R4.1-4.10 = 10 · R5.1-5.8 = 8 · R6.1-6.8 = 8 · R7.1-7.6 = 6 (51 total) | `for f in briefs/phase-*.md; do grep -cE '^### R[0-9]+\.[0-9]+' $f; done` → `0 4 7 8 10 8 8 6` | **OK** |
| "`briefs/phase-5-tests.md` **R5.1–R5.7**" | areas/quality.md:48 | the file has **R5.1–R5.8** | `grep -cE '^### R' briefs/phase-5-tests.md` → `8` | **mismatch** (A7-02) |
| "`briefs/phase-2-data.md` R2.1–R2.7", "R7.1–R7.6" | areas/data-security.md:65 | 7 and 6 | as above | **OK** |
| "R3.1–R3.8", "R4.1–R4.10", "R4.8–R4.10", "R6.1–R6.8" | areas/performance.md:35, areas/interface.md:50, areas/user-communication.md:40, areas/method-documentation.md:59 | 8, 10, 3, 8 | as above | **OK** |
| "Diagnosis measures: D4 **items 8–11**" | areas/user-communication.md:40 | D4 has 11 numbered items; 8-11 are the communication ones | read briefs/phase-0-diagnosis.md:105-108 | **OK** |
| "**The six parts** of a record" | templates/decision-record.md:11 | the template block carries **7** labelled items: title, `**When:**`, `**Status:**`, and 5 `##` sections | `sed -n '13,33p' templates/decision-record.md \| grep -c '^## '` → `5`; `… grep -cE '^\*\*(When\|Status):'` → `2` | **ambiguous** (A7-03) |
| "six parts, including rejected alternatives" | areas/method-documentation.md:7 | restates the same number | read | same ambiguity |
| "**Only the two terms** this skill uses on its own are kept here" | GLOSSARY.md:7 | 2 rows in the Architecture table | `sed -n '9,13p' GLOSSARY.md \| grep -c '^\| \*\*'` → `2` | **OK** |
| "**three lists** in acceptance testing" | areas/method-documentation.md:11, briefs/phase-5-tests.md:28 | both name (to review / to recheck / closed) | read | **OK** |
| "**two tables**, never merged" | templates/decision-record.md:46, modes/decision-qa.md:71 | client + internal, organizational elsewhere | read | **OK** |
| "**three stages**" (handover) | briefs/phase-7-handover.md:12, procedure.md:150 | 3 enumerated | read | **OK** |
| "the placeholder list" | procedure.md:57 | 15 bullets, **16** tokens | `sed -n '57p' procedure.md \| grep -oE '<[a-zA-Z][a-zA-Z0-9_-]*>' \| sort -u \| wc -l` → `16` | see A7-04 |
| "~52k contacts, 426 commits, 104 decision records" | README.md:35 | about the origin project, not this repo; nothing in the corpus to check against | `git log --oneline \| wc -l` on this repo → 1 | **unverifiable** (A7-05) |

### Findings

**A7-01 · procedure.md:11, modes/status.md:7 vs templates/status.md:8-15,32-38 · P2 · "eight rows per phase" is false for Phase 0 and for the re-diagnosis, and the exception is never declared.** Phase 0 is a phase — README.md:3 "eight-phase procedure", SKILL.md:18 "`diagnose` … `briefs/phase-0-diagnosis.md`" — and its block has 4 rows; the Re-diagnosis block has 3. modes/status.md:7 qualifies with "following the cycle", but Phase 0 does not follow the cycle and the qualifier does not say so. A cold agent resuming at Phase 0 (`modes/status.md`:25, "Find the first row without evidence") may add four phantom rows. → Minimal change: procedure.md:11 and modes/status.md:7 — "eight rows per repair phase (Phase 0 has four, the re-diagnosis three)".

**A7-02 · areas/quality.md:48 · P3 · the repairs pointer names R5.1–R5.7 while the brief file holds R5.1–R5.8.** Verbatim: "`briefs/phase-5-tests.md` R5.1–R5.7 (canary, warm-up, generated checklist, dirty corpus, presumed protections, bug hunt, live channels)". R5.8 (flow test per process) is missing from the range and from the parenthetical, although the same file cites it at :61 — "(briefs R5.8 and R2.7)". procedure.md:126 lists all eight. → Minimal change: `R5.1–R5.8` and add ", flow tests" to the parenthetical.

**A7-03 · templates/decision-record.md:11, areas/method-documentation.md:7 · P3 · "six parts" does not resolve against the template.** The block has a title line, `**When:**`, `**Status:**` and five `##` sections — 6 if the title counts and `When`/`Status` count as one, 7 if they are separate, 5 if only `##` headings count. R6.3 (briefs/phase-6-documentation.md:24) asks for records "with the rejected alternatives" but nothing counts parts. → Minimal change: number the parts in the template block, or say "five sections plus the header".

**A7-04 · procedure.md:55-57 · P3 · the placeholder list is not numbered anywhere, and its size is 16 tokens in 15 bullets.** No file in the corpus states a count (`grep -rn '17 placeholder' --include=*.md .` → no output), so any external count of 17 is unsupported. Two of the 16 are unused (A4-01) and ~30 more are used undeclared (A4-02), so the effective declared-and-used set is 14. → Minimal change: none required for the count itself; fix A4-01/A4-02 and the number follows.

**A7-05 · README.md:35 · P3 · the origin numbers cannot be verified from this repository.** "~52k contacts, 426 commits, 104 decision records, June-September 2026" describes the host project the skill was distilled from; this repo has one commit (`git log --oneline -1` → `c32367a skill: harden-codebase-properly, initial publication`) and no `docs/decisions/`. Consistent with README.md:39 ("The repair phases and the verifier have not yet been proven live"), but the numbers carry no date-stamped source the way the skill demands of everything else (SKILL.md:38 "measure before asserting"). → Minimal change: cite the repository or the report those numbers came from, or mark them "not reproducible here".

---

## Findings index

| id | file:line | sev | finding | minimal change |
|---|---|---|---|---|
| A1-01 | SKILL.md:3 | P3 | the Italian parenthetical trigger list is undocumented in every fetched spec; the documented home for trigger phrases is `when_to_use` (Claude Code only) | leave, or move to `when_to_use` accepting the portability loss |
| A1-02 | SKILL.md:1-4 | P2 | no `argument-hint` though the skill is driven by a six-value mode argument | add `argument-hint: [diagnose\|plan\|run <N>\|review\|maintain\|status]` |
| A1-03 | SKILL.md:1-4 | P2 | "It never writes code" has no mechanical enforcement although `disallowed-tools` is documented | add `disallowed-tools: Edit Write NotebookEdit` |
| A1-04 | SKILL.md:1-4 | P3 | no `license` / `compatibility` on a publicly cloned skill with tool prerequisites | add both |
| A2-01 | SKILL.md:20,22 | P2 | `templates/status.md` is a hidden dependency of `run <N>` and `maintain` | add it to both Load cells |
| A2-02 | SKILL.md:20 | P2 | `briefs/phase-1-gates.md` § Common repair header is a hidden dependency of `run 2`…`run 7` | name it in the `run <N>` Load cell |
| A2-03 | briefs/phase-1-gates.md:3 | P2 | `run 1` resolves "the areas that phase names" to nothing; `areas/quality.md` never loads | add `Reference: areas/quality.md.` |
| A2-04 | SKILL.md:21 | P2 | `review` cannot run its own step 6: Q&A and decision-record files not loaded | add `modes/decision-qa.md`, `templates/decision-record.md` |
| A2-05 | SKILL.md:23 | P2 | `status` (and the no-argument default) cannot run resume step 3 | add `briefs/verifier.md`, `modes/decision-qa.md` |
| A2-06 | SKILL.md:16-23 | P2 | `procedure.md` § Autonomy contract loads only in `run <N>` | add it to the other five Load cells |
| A2-07 | SKILL.md:18,19 | P2 | `templates/decision-record.md` hidden in `diagnose` and `plan` | add it to both |
| A2-08 | SKILL.md:18 | P2 | the six `areas/*.md` are hidden dependencies of `diagnose` | state that each D-agent gets its area file |
| A2-09 | SKILL.md:16-23 | P3 | `GLOSSARY.md` (1 684 w) is loaded by no mode despite "use these terms exactly" | name it where its vocabulary is used |
| A2-10 | SKILL.md:98-105 | P3 | `README.md` is the only file absent from § File map | one line, or leave |
| A3-01 | procedure.md:146-153 | P3 | `run 7` loads 7 738 words for a 374-word brief, incl. a 791-word verifier with no Verification step to serve | give Phase 7 a Verification paragraph |
| A3-02 | procedure.md:61-153 | P3 | `run <N>` loads all 8 phase sections (1 153 w) to run one (73-238 w) | optional split |
| A4-01 | procedure.md:57 | P2 | `<files>` and `<record>` declared, used nowhere | use them in templates/agent-brief.md:40,44 or delete |
| A4-02 | 30 tokens, see §4 | P2 | ~30 placeholders used without a declaration, incl. `<list>` (36 uses), `<n>`, `<file:line>`, `<command>` | declare the seven recurring ones |
| A4-03 | templates/agent-brief.md:23 | P2 | `<N>` = phase number (declared) but = word cap here | rename to `<words>` |
| A4-04 | briefs/phase-0-diagnosis.md:18 | P3 | `<2200>` is a literal in placeholder syntax | write `Max 2200 words.` |
| A4-05 | templates/agent-brief.md:24 | P3 | `<Area>` casing variant of `<area>` | lowercase |
| A4-06 | areas/user-communication.md:46 et al. | P3 | HTML/JSX (`<label>`, `<select`, `<Suspense>`) collides with placeholder syntax | note that only declared tokens are slots |
| A5-01 | procedure.md:22 | P2 | "Does alone" names no actor and reads as the orchestrator writing code | prefix "The run does alone (through agents)" |
| A5-02 | briefs/phase-1-gates.md:6, briefs/verifier.md:29 | P2 | `git stash` forbidden absolutely to agents, conditionally to the orchestrator | align the condition |
| A5-03 | briefs/verifier.md:3 | P3 | the verifier runs on the same model as the agents it judges, against templates/agent-brief.md:3 | raise it, or justify in one line |
| A5-04 | procedure.md:160-168 | P2 | the rejection cycle and its four-round cap exist only in a file `maintain`/`review` never load | point briefs/verifier.md § Diff mode at § Convergence |
| A5-05 | SKILL.md:45 | P2 | "the only mandatory user checkpoint" contradicted by modes/maintain.md:48 and modes/decision-qa.md:14 | reword, or list the other three |
| A5-06 | SKILL.md:47, procedure.md:24 | P2 | nobody may commit, no step asks for the mandate, no ledger row records it — yet three files prescribe commit content | add commit to the ask-first list |
| A5-07 | procedure.md:146-153 | P2 | Phase 7 is the only phase with no **Verification.** step while row N.7 demands one | add the paragraph |
| A6-01 | briefs/phase-0-diagnosis.md:61 | **P1** | `npx gitleaks detect --no-git` cannot run: the npm package has no `bin` | use the Go binary; state where to get it |
| A6-02 | briefs/phase-0-diagnosis.md:63 | **P1** | the `proacl` query prints an empty cell for the PUBLIC-EXECUTE default — reads as clean | `coalesce(...,'DEFAULT — PUBLIC CAN EXECUTE')` + a line calling null a P1 |
| A6-03 | areas/performance.md:29 | P2 | the cap regex misses `.limit(1000)`, the stack's own call form | `\.limit\(\|limit:\s*[0-9]{3,}`, one spelling everywhere |
| A6-04 | procedure.md:116, briefs/phase-4-interface.md:38 | P2 | `grep disabled` has no `-r` and no path: it reads stdin | use `grep -rn "disabled" <components>` |
| A6-05 | areas/data-security.md:22,47 | P2 | the RLS queries can't see `relforcerowsecurity` or the absent-policy = correct case | add the `pg_class` query and the join rule |
| A6-06 | areas/interface.md:42 | P2 | the hex regex is case-sensitive; `#A1B2C3` passes the gate | add `-i` or `A-F` |
| A6-07 | briefs/phase-0-diagnosis.md:8, briefs/phase-1-gates.md:6 | P2 | no brief establishes a working directory; every path is repo-relative | add "Run every command from `<repo>`." |
| A6-08 | areas/performance.md:29, briefs/phase-0-diagnosis.md:87,103,105 | P2 | four greps use `-r` with no path — GNU-only | append the path |
| A6-09 | templates/decision-record.md:9 | P3 | the numbering command doesn't compute a first free number and hides `ls`'s failure behind a pipe | `2>/dev/null`, drop `\| sort` |
| A6-10 | areas/quality.md:56 | P3 | the A/B recipe omits the new-file caveat briefs/verifier.md:25 carries | add the parenthesis |
| A6-11 | templates/diagnosis-report.md:47 | P3 | `error.message` leaves `.` unescaped → false positives | `error\.message` |
| A6-12 | templates/diagnosis-report.md:15 | P3 | `next lint` is not a Next.js 16 command | `<lint command from the stack map>` |
| A7-01 | procedure.md:11, modes/status.md:7 | P2 | "eight rows per phase" is false for Phase 0 (4) and Re-diagnosis (3) | declare the exception |
| A7-02 | areas/quality.md:48 | P3 | names R5.1–R5.7; the file has R5.1–R5.8 | `R5.1–R5.8`, add ", flow tests" |
| A7-03 | templates/decision-record.md:11 | P3 | "six parts" resolves to 5, 6 or 7 depending on the count | number the parts |
| A7-04 | procedure.md:55-57 | P3 | the list holds 16 tokens in 15 bullets and is nowhere numbered; 2 unused, ~30 undeclared | fix A4-01/A4-02 |
| A7-05 | README.md:35 | P3 | origin numbers not reproducible from this repo | cite the source or mark as such |

---

## Files read

All 28 Markdown files plus `.gitattributes`, in full.

| file | lines | words | findings |
|---|---|---|---|
| `SKILL.md` | 105 | 1 705 | A1-01, A1-02, A1-03, A1-04, A2-01…A2-10, A5-05, A5-06 |
| `README.md` | 39 | 571 | A2-10, A7-05 |
| `procedure.md` | 168 | 2 436 | A3-02, A4-01, A5-01, A5-04, A5-06, A5-07, A6-04, A7-01, A7-04 |
| `GLOSSARY.md` | 86 | 1 684 | A2-09 |
| `.gitattributes` | 1 | — | no findings (`* text=auto eol=lf`, LF-normalising, correct for a cross-platform skill) |
| `modes/diagnose.md` | 67 | 965 | no findings of its own (appears as a load-graph node in A2-01…A2-08) |
| `modes/decision-qa.md` | 71 | 759 | A5-05 |
| `modes/status.md` | 31 | 440 | A2-05, A7-01 |
| `modes/review.md` | 24 | 433 | A2-04 |
| `modes/maintain.md` | 56 | 843 | A2-01, A5-04, A5-05 |
| `areas/quality.md` | 88 | 1 314 | A5-06, A6-10, A7-02 |
| `areas/data-security.md` | 93 | 1 223 | A6-02, A6-05 |
| `areas/performance.md` | 56 | 852 | A6-03, A6-08 |
| `areas/interface.md` | 70 | 1 107 | A6-06 |
| `areas/user-communication.md` | 62 | 1 007 | A4-06 |
| `areas/method-documentation.md` | 86 | 1 074 | A5-06, A7-03 |
| `briefs/phase-0-diagnosis.md` | 128 | 2 078 | A4-04, A6-01, A6-02, A6-03, A6-07, A6-08 |
| `briefs/phase-1-gates.md` | 47 | 974 | A2-02, A2-03, A5-02, A6-07 |
| `briefs/phase-2-data.md` | 63 | 1 107 | no findings |
| `briefs/phase-3-performance.md` | 70 | 944 | no findings |
| `briefs/phase-4-interface.md` | 84 | 1 444 | A6-04 |
| `briefs/phase-5-tests.md` | 65 | 967 | no findings |
| `briefs/phase-6-documentation.md` | 60 | 722 | no findings |
| `briefs/phase-7-handover.md` | 39 | 374 | A3-01 (via procedure.md § Phase 7) |
| `briefs/verifier.md` | 56 | 791 | A5-02, A5-03, A5-04 |
| `templates/agent-brief.md` | 83 | 674 | A4-01, A4-03, A4-05 |
| `templates/decision-record.md` | 66 | 641 | A6-09, A7-03 |
| `templates/diagnosis-report.md` | 85 | 1 245 | A6-03, A6-11, A6-12 |
| `templates/status.md` | 46 | 394 | A7-01 |

Files with **no findings**: `briefs/phase-2-data.md`, `briefs/phase-3-performance.md`, `briefs/phase-5-tests.md`, `briefs/phase-6-documentation.md`, `modes/diagnose.md`, `.gitattributes`.

Also present in the working tree and **empty** (no files, therefore not read and not counted): `audit/patches/`, `audit/specs/`, `docs/decisions/`.

## Sources fetched

| title | body | URL | accessed |
|---|---|---|---|
| Extend Claude with skills — Frontmatter reference | Anthropic / Claude Code docs | https://code.claude.com/docs/en/skills (reached via a 301 from https://docs.claude.com/en/docs/claude-code/skills) | 2026-09-11 |
| Agent Skills — overview | Anthropic / Claude Platform docs | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview (reached via a 302 from https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) | 2026-09-11 |
| Agent Skills — Overview | agentskills.io (open standard) | https://agentskills.io | 2026-09-11 |
| Agent Skills — Specification | agentskills.io (open standard) | https://agentskills.io/specification | 2026-09-11 |
| 52.39. `pg_proc` | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/catalog-pg-proc.html | 2026-09-11 |
| 53.x `pg_policies` | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/view-pg-policies.html | 2026-09-11 |
| 53.x `pg_tables` | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/view-pg-tables.html | 2026-09-11 |
| 52.11. `pg_class` | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/catalog-pg-class.html | 2026-09-11 |
| 5.8. Privileges | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/ddl-priv.html | 2026-09-11 |
| 5.9. Row Security Policies | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/ddl-rowsecurity.html | 2026-09-11 |
| 9.19. Array Functions and Operators | PostgreSQL Global Development Group | https://www.postgresql.org/docs/current/functions-array.html | 2026-09-11 |
| `gitleaks` package metadata | npm registry | https://registry.npmjs.org/gitleaks | 2026-09-11 |
| `next` CLI (v16.3.4) | Vercel / Next.js docs | https://nextjs.org/docs/app/api-reference/cli/next | 2026-09-11 |

### Could not fetch

- `https://docs.claude.com/en/docs/claude-code/skills` — 301 Moved Permanently to `https://code.claude.com/docs/en/skills`; the redirect target was fetched and is the source used.
- `https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview` — 302 Found to `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`; the redirect target was fetched and is the source used.
- No page in the list above failed outright. No claim in this report is filled from memory: where a fact could not be established (PostgreSQL was not reachable, so no SQL was executed; the origin project's numbers in README.md:35 have no source in this repo), the report says so.
