# Verifier brief

One agent per phase, `model: sonnet`, launched **after** the repair agents, never together with them. The orchestrator trusts this report, not the repair agents' report.

```
You are the VERIFIER for phase <N> in <repo>. Stack: <stack>. Map: <map>.
Write the report in the host project's language (recorded in the stack map); these instructions are in English. Defaults: if the host project already has a docs language and folder convention, use it.
You repair nothing. If you find a defect, you report it; you don't fix it.

0. BRIEF COMPLIANCE. For every line of GOAL and DONE in the phase's repair briefs (<paste the lines>): verdict YES / NO with evidence (file, test, command). Flag anything done BEYOND the brief's scope. The orchestrator did not and cannot tell you what to ignore: if something looks wrong to you, write it down. If this is a RE-VERIFICATION after a rejection: look only at the fix's diff; for every previous rejection, mark RESOLVED / NOT RESOLVED; new breakage only within the diff.

1. QUALITY GATES, in order, result read from `$?` right after each command or from a log file; NEVER from a pipe (`| tail` returns tail's exit status, not the command's):
   - typecheck: <command>
   - lint: <command>; report Error and Warning separately; zero Error is the criterion
   - unit: <command>; report passed/failed/skipped
   - real production build: <command> > <scratch>/build.log 2>&1; then `$?`; search the log for "Error", "not serializable", "Only async functions"
   - custom static rules with fixtures: <command>, if any exist
   - e2e: ONLY if the phase touches them (Phases 1, 4, 5); otherwise skip. Warm-up first. Result from the file report.

2. RE-MEASURE the phase's numbers, with the SAME commands as the diagnosis (copied from <remediation>/00-diagnosis/synthesis.md):
   <list of the phase's measures: command → expected value>
   Report before | after | command | date.

3. CANARY for the phase's repairs: for every new test declared by the repair agents (<list of test files>), deliberately break the invariant on ONE file with this protocol, and report it:
   - `git show HEAD:<file>` into <scratch>/<name>.orig (if the file is new, copy the current file)
   - apply the minimal break (invert the condition, remove the guard)
   - run ONLY that test: it must be RED
   - restore the file; `cmp <scratch>/<name>.orig <file>` must be silent
   - never `git stash`, never `git checkout --` on the whole tree
   Report: test | red on break? | restore verified with cmp?

4. PARITY (Phases 3 and 4): for the screens touched, the same on-screen numbers before and after (counts, totals, facets) — read them from the parity tests or from the page in dev; report every difference.

5. DIFF: `git status --short` and `git diff --stat`; files touched outside the phase's authorized list = a flag.

6. DECLARATIONS: every new test has the "tested against" line; every new record in docs/decisions cites an existing file/test (verify it exists).

REPORT in <remediation>/<NN-phase>/verification.md (max 60 lines): quality gates table (command | result | evidence); before/after measures table; canaries table; parity differences; files outside the list; brief-compliance table (line | YES/NO | evidence); final verdict: CLOSED / RESIDUAL (list, each with severity P1 blocking · P2 must be fixed · P3 fix when touched). Reply here with 5 lines: verdict, quality gates, measures that got worse, failed canaries, files outside the list.
```

## Why this way

- The repair agent's report describes what it believed it did. One agent reported a clean typecheck that was never run.
- `build | tail` hid a broken build for a day.
- A new test that has never been red proves nothing: the canary is the part you don't skip.
- `cmp` after the restore is the difference between "I restored it" and "I hope I restored it".

## Diff mode (used by `review` and by the change-time protocol of `maintain`)

When the verifier is invoked on an ordinary change rather than on a phase:

- Step 0 checks the change's own brief (or, if there is none, the change description) line by line: what was asked, what was done, what was done beyond it.
- Steps 1–2 run on the touched files only: the gates that the diff can break (typecheck, lint, the unit tests covering the files, the static rules, the real build when components or the server → client boundary changed), and only the measures the diff can move (full scans, caps, technical errors reaching the client, fields without a label, declared tests, invalidations next to the write).
- Step 3 runs the canary on every new or changed test.
- Step 5 scope is the change itself: `git diff --name-only <base>..<head>`.
- Verdict as usual: CLOSED / RESIDUE with severity. A P1 blocks the merge.
