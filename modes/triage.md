# Mode `triage`: three measured findings, read-only, one agent

Goal: in minutes, say whether this project has the defects this skill is for, with the proving command. Not the diagnosis: no database measure, no register, no ledger row, nothing ordered.

## Dispatch

One agent, `model: sonnet`, the brief below. No parallel agents, no background wait.

## Brief

    READ-ONLY: modify no file; no install, build, migration, test. Repo: <repo>. Date: <date>.
    Every number carries its command; "not found" if missing, never zero. Never report secrets,
    keys, real URLs or personal data.

    GOAL: run these greps, report what they return, read no further than the hits, propose
    nothing. Adapt paths to this repo; a missing folder is "not found".

    1. rg -n "error\.message|String\(err|\.digest|JSON\.stringify\(err" <components> <actions>
    2. rg -n "disabled=" <components> ; rg -n "#[0-9a-fA-F]{3,8}" <components>
    3. rg -n "\.limit\(|limit:\s*[0-9]{3,}" <src>
    4. rg -n "\.all\(\)|select\('\*'\)" <services>
    5. rg -n "catch\s*\{\s*\}" <src>
    6. rg -l "tested against" <tests> | wc -l vs the test file count
    7. rg -n "NEXT_PUBLIC_[A-Z_]*(KEY|SECRET|TOKEN)" <src> ; git ls-files | rg "^\.env"
    8. ls <migrations> | wc -l ; rg --files-without-match "if not exists" <migrations> | wc -l
    9. find <routes> -name "loading.tsx" | wc -l vs routes with reads
    10. ls docs/decisions docs/remediation 2>/dev/null

    WRITE <scratch>/triage.md, max 300 words, and reply:
    line 1: "TRIAGE - measured <date>, not a baseline; the diagnosis re-measures."
    then a table: measure | value | command
    then THREE findings, worst first: file:line | what it is | area (quality, data-security,
    performance, interface, user-communication, method-documentation)
    then one line: areas the greps could not reach.

## Output

`<scratch>/triage.md` and that reply; nothing in `docs/`.

## What it must not do

- Write outside `<scratch>`: no `docs/remediation/`, `status.md`, register, decision record.
- Tick a ledger row: its numbers are never evidence, never a re-diagnosis, never cited by `review`/`maintain`.
- Touch the database, an MCP or a CLI: answers stay repo-side.
- Order work, name phases, estimate effort, propose a plan or repair. Three findings, no sequence; a fix request gets the handover.

## Handover to `diagnose`

Ends exactly with:

> Triage only: <N> measures, 3 findings, nothing verified on the database and nothing ordered.
> To fix any of them the next step is `diagnose`: it re-measures these numbers with its own commands, adds the database, and returns an ordered plan for your confirmation. Repairs start only after that.

Asked to repair a finding directly: one line — a repair needs a brief, a starting number and a verifier, all three from `diagnose`; a triage number has no before/after.
