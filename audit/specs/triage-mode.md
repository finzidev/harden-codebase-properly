# Spec: mode `triage`

Proposed addition to `harden-codebase-properly`. Written in the skill's voice, ready to paste.

Reason: Phase 0 dispatches six agents and returns nothing to the user for an estimated 25-40 minutes and ~1.4M billed tokens (assumptions in `audit/02-usability.md` § 2). A first contact that costs that much before the first sentence is a first contact many users abandon. `triage` returns three measured findings in 2-4 minutes and cannot be mistaken for the diagnosis.

## Why it does not weaken the evidence discipline

| Invariant | Where stated | How `triage` keeps it |
|---|---|---|
| Measure before asserting | `SKILL.md:38` | Every triage line carries the grep that produced it and the date. No line without a command. |
| Read-only rounds never repair | `SKILL.md:43`, `GLOSSARY.md:75` | `triage` is read-only, single agent, no write outside its own file. It proposes nothing and fixes nothing. |
| A step without an evidence line is not done | `SKILL.md:45` | `triage` ticks no row. It does not create `status.md`. Its output is not evidence and says so on line 1. |
| Numbers carry a date and a command | `templates/diagnosis-report.md:3` | Same rule, same format, fewer rows. |
| The plan question is the checkpoint | `modes/diagnose.md:3` | `triage` has no checkpoint of its own and no plan. Its only exits are "run `diagnose`" or "stop". |

The one real risk is anchoring: a user who hears "the three worst things" asks for those three to be fixed and skips the diagnosis. The mode closes that door explicitly (§ What it must not do), and the numbers are marked "triage, not a baseline" so the diagnosis re-measures with its own commands rather than inheriting them.

## Router row

Add to `SKILL.md` § Modes, above `diagnose`:

| Mode | When | Load |
|---|---|---|
| `triage` | Asked "is this project in trouble?", or before committing to a diagnosis | `modes/triage.md` |

And after the table, add: "`triage` is not a diagnosis: it grep-measures, returns three findings, ticks nothing. It ends by offering `diagnose`."

## `modes/triage.md`

```markdown
# Mode `triage`: three measured findings, read-only, one agent

Goal: in a few minutes, say whether this project has the defects this skill is for, with the command that proves each one. It is not the diagnosis: it measures nothing on the database, opens no register, writes no ledger row, and orders no work.

## Dispatch

One agent, `model: sonnet`, the brief below. Nothing else. No parallel agents, no background wait.

## Brief

    You are READ-ONLY. Do not modify any file, do not run install, build, migrations or tests. Repo: <repo>.
    Today's date: <date>. Every number carries the command that produced it. "not found" if missing, never zero.
    Do not report secrets, keys, real project URLs or personal data.

    GOAL: run these greps and report what they return. Do not read further than the hits. Do not propose repairs.
    Adapt the paths to this repo's layout; if a folder does not exist, write "not found".

    1. rg -n "error\.message|String\(err|\.digest|JSON\.stringify\(err" <components> <actions>
    2. rg -n "disabled=" <components>
    3. rg -nE "limit: ?[0-9]{3,}" <src>
    4. rg -n "\.all\(\)|select\('\*'\)" <services>
    5. rg -n "catch\s*\{\s*\}" <src>
    6. rg -c "tested against" <tests> against the test file count
    7. rg -n "NEXT_PUBLIC_[A-Z_]*(KEY|SECRET|TOKEN)" <src> ; git ls-files | rg "^\.env"
    8. ls <migrations> | wc -l ; rg -Lc "if not exists" <migrations> | wc -l
    9. find <routes> -name "loading.tsx" | wc -l against routes with reads
    10. ls docs/decisions 2>/dev/null | wc -l ; ls docs/remediation 2>/dev/null

    WRITE <scratch>/triage.md, max 300 words, and reply here with:
    line 1: "TRIAGE - measured <date>, not a baseline; the diagnosis re-measures."
    then a table: measure | value | command
    then THREE findings, worst first: file:line | what it is | which area (quality, data-security,
    performance, interface, user-communication, method-documentation)
    then one line: the areas the greps could not reach.
```

## Output

`<scratch>/triage.md` and the five-line reply. Nothing inside `docs/`.

## What it must not do

- Not create `docs/remediation/`, `status.md`, `defect-register.md`, or any decision record.
- Not tick a row in any ledger. Its numbers are never evidence for a step.
- Not touch the database, an MCP, or a CLI. Every data-and-security answer is repo-side only.
- Not order work, name phases, estimate effort, or propose a plan. Three findings, no sequence.
- Not repair, and not offer to repair. A user who asks for a fix here is answered with the handover below.
- Not be re-run in place of a re-diagnosis, and not be cited by `review` or `maintain`.

## Handover to `diagnose`

`triage` ends with exactly this, in the host project's language:

> Triage only: <N> measures, 3 findings, nothing verified on the database and nothing ordered.
> To fix any of them the next step is `diagnose`: it re-measures these numbers with its own commands, adds the database, and returns an ordered plan for your confirmation. Repairs start only after that.

If the user asks to repair a triage finding directly, the answer is one line: the repair needs a brief, a starting number and a verifier; `diagnose` produces all three. No exception, because a repair applied on a triage number is a repair with no before/after (`SKILL.md:79`).
