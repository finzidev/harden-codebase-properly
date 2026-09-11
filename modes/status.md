# Mode `status`: the evidence ledger and how to resume

`docs/remediation/status.md` is the evidence ledger of the whole procedure. It exists so that "done" is a line with evidence, not a feeling, and so that a new session resumes exactly where the previous one stopped. It is not a user checkpoint (the plan question: `SKILL.md` § Non-negotiables).

## The file

Template in `templates/status.md`. One block per phase; eight rows per repair phase (Phase 0 has four, the re-diagnosis three) following the cycle, with two steps split for evidence: briefs filled · dispatch · synthesis · decision · repairs · variant search · verification · exit (report, lessons line, numbers re-measured); plus the phase's own rows when it has them. Every row has: step | done | evidence | by | date.

- **Evidence** is a file path, a command with its exit code, a record number, a verifier verdict line, or an agent report path. Never "done", never "ok".
- **By** is the agent (D2, R3.2, verifier) or "orchestrator".
- A row without evidence is **not done**, whatever the conversation says.

## Rules

- The orchestrator updates the file at every cycle step, before moving to the next one. Dispatch → list of agents; synthesis → path of the synthesis; decision → record numbers or "no reversible choice"; repair → report paths; verification → the report path **and** its verdict line copied byte-for-byte; exit → report path and the lessons line.
- Phase N+1 does not start while phase N has a row without evidence, unless a ruling line in the defect register explains the parking.
- The header keeps: project, host language, stack map path, current phase, open ask-first items, parked rulings count, last re-diagnosis date, last drift check date.
- The numbers live in the phase reports; `status.md` links to them.
- Before any dispatch and on every resume, every evidence path must exist: `grep -oE '[A-Za-z0-9_./-]+\.md' docs/remediation/status.md | sort -u | while read -r p; do [ -f "$p" ] || echo "MISSING EVIDENCE: $p"; done`. A missing path empties its cell; the step is not done.
- One session per repo. Before writing a row, re-read `status.md`: a row ticked by someone else means a second session is running: stop and say so. The ledger is not merge-safe.

## Resume

When a session starts with `status` or with no argument on a project that has the file:

1. Read `status.md`, its two header lines first: `Applied to the real database: …` and `Working tree: …`. Read `lessons.md`. Read the last phase report.
2. Find the first row without evidence. That is the next action. Say it in one line.
3. If the row is a dispatch, re-fill the briefs from the synthesis (do not trust memory of the previous session). If it is a verification, dispatch the verifier. If it is a decision, run the Q&A. Before re-dispatching a repair row, `git diff --stat` on that brief's file list: files already modified → the brief is re-filled with what is there as the starting number, and the report says the previous attempt was partial.
4. Never redo a step that has evidence. If the evidence looks stale (a file that no longer exists, a command that now fails), mark the row "stale" with the date and treat it as not done.

## Reporting "where are we"

Answer with: current phase and step; steps done in this phase (count); open ask-first items; parked rulings; the next action. No narrative.
