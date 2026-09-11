# Mode `status`: the evidence ledger and how to resume

`docs/remediation/status.md` is the evidence ledger of the whole procedure. It exists so that "done" is a line with evidence, not a feeling, and so that a new session resumes exactly where the previous one stopped. It is not a user checkpoint: the only mandatory one is the plan question after Phase 0.

## The file

Template in `templates/status.md`. One block per phase; eight rows per phase following the cycle, with two steps split for evidence: briefs filled · dispatch · synthesis · decision · repairs · variant search · verification · exit (report, lessons line, numbers re-measured); plus the phase's own rows when it has them. Every row has: step | done | evidence | by | date.

- **Evidence** is a file path, a command with its exit code, a record number, a verifier verdict line, or an agent report path. Never "done", never "ok".
- **By** is the agent (D2, R3.2, verifier) or "orchestrator".
- A row without evidence is **not done**, whatever the conversation says.

## Rules

- The orchestrator updates the file at every cycle step, before moving to the next one. Dispatch → list of agents; synthesis → path of the synthesis; decision → record numbers or "no reversible choice"; repair → report paths; verification → verdict line; exit → report path and the lessons line.
- Phase N+1 does not start while phase N has a row without evidence, unless a ruling line in the defect register explains the parking.
- The header keeps: project, host language, stack map path, current phase, open ask-first items, parked rulings count, last re-diagnosis date, last drift check date.
- The numbers live in the phase reports; `status.md` links to them.

## Resume

When a session starts with `status` or with no argument on a project that has the file:

1. Read `status.md`. Read `lessons.md`. Read the last phase report.
2. Find the first row without evidence. That is the next action. Say it in one line.
3. If the row is a dispatch, re-fill the briefs from the synthesis (do not trust memory of the previous session). If it is a verification, dispatch the verifier. If it is a decision, run the Q&A.
4. Never redo a step that has evidence. If the evidence looks stale (a file that no longer exists, a command that now fails), mark the row "stale" with the date and treat it as not done.

## Reporting "where are we"

Answer with: current phase and step; steps done in this phase (count); open ask-first items; parked rulings; the next action. No narrative.
