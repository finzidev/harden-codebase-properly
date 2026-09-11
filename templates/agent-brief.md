# Agent brief template

Rules: one agent = one area; self-contained task; explicit `model` (`sonnet` for mechanical work and inventories; `haiku` for trivial transforms; the flagship model only for a single judgment call or synthesis). Parallelize only across files that don't touch each other. The diagnosis already done goes **inside** the brief; the agent does not re-derive it.

Two variants: **read-only** (measurement, inventory, audit) and **repair**. Never mix them in the same agent.

---

## Variant A: read-only

```
You are READ-ONLY. Do not modify any file. Repo: <path> (<stack in one line>).

GOAL: <one sentence: what the orchestrator must know by the end>.

SOURCES TO READ (all of them, not a sample):
1. <file or folder> (<what to look for in it>)
2. ...
N. <exact measurement command, e.g. grep/jscpd/wc> (<what it produces>)

WHAT TO EXTRACT, in this exact format (Markdown, max <words> words):
# <area>
## Measures (table: measure | value | date | command that reproduces it)
## Defects found while reading (one per line: file:line, symptom, why it is a defect, DO NOT repair)
## Proposals (one per line, with estimated cost and risk; they remain proposals)
## Limits of the method (what this inventory does NOT see)

Rules: always cite the evidence (path or command); write "not found" if missing, never invent; numbers only if measured or written in the sources; never report secrets or personal data.

WRITE the report to <scratch>/<area>.md and reply here with ONLY 5 lines: file written, number of measures, number of defects, top 3 findings.
```

---

## Variant B: repair

```
Repo: <path> (<stack in one line>). Work ONLY in: <files> (from <allocation>). Do not touch anything else.

CONTEXT ALREADY VERIFIED (do not re-derive):
- <diagnosis: root cause, in 2-4 lines>
- <record>: the binding decision record, one line
- <starting number: e.g. "12 reads to open page X, measured on DD/MM">

GOAL: <one sentence verifiable in the code>.

HOW:
1. <step>
2. <step>
...

WHAT NOT TO DO:
- do not add lint boundary exceptions; if a boundary blocks an obvious placement, move the piece instead
- no `disabled` on read-only editors; no empty `catch {}`; no `nosemgrep` without a reason next to it
- do not touch files outside the list; if you need to, stop and say so in the report
- do not commit
- do not launch other agents

VARIANTS: once the defect is closed, search for the same pattern elsewhere in the repo (grep, static rule) and report it; if the pattern is mechanical, propose a static rule with fixtures.

TEST: <the test to write or update: one file per invariant, named by the rule; declare "// tested against: ...">.
It must turn RED if you deliberately break the invariant: do this once and report it.

DONE CRITERIA:
- `<verify command>` green end to end (typecheck, lint zero Error, unit, BUILD)
- <expected end number, e.g. "1 read to open page X">
- <the test red once, then green>

REPORT (max 15 lines): files touched, before/after number, canary result, what was left out and why, any new decisions to record (title + rejected alternatives).
```

---

## Brief mistakes seen in practice

- Multi-area task: the agent gets stuck. Two adjacent notes with a different root cause stay two separate briefs.
- Fan-out without `model`: it inherits the flagship model and burns the budget in minutes.
- "Go check it yourself" instead of a diagnosis: the agent re-derives it, gets it wrong, and reports a clean `tsc` that was never run. The orchestrator repeats the verification.
- Brief without a starting number: at the end nobody knows whether it improved.
- Session history inside the brief: the agent inherits dirty context and opinions. Only the brief, the interfaces it needs, the global constraints.
- Rejection summarized instead of quoted verbatim on resume: the agent fixes what it understood, not what was actually found.
