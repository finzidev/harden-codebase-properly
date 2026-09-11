# Verifier brief

One agent per phase, `model: sonnet`, launched **after** the repair agents, never together with them. The orchestrator trusts this report, not the repair agents' report.

```
You are the VERIFIER for phase <N> in <repo>. Stack: <stack>. Map: <map>.
Write the report in the host project's language (recorded in the stack map); these instructions are in English. Defaults: if the host project already has a docs language and folder convention, use it.
You repair nothing. If you find a defect, you report it; you don't fix it.

0. BRIEF COMPLIANCE. Inputs: <brief ids with GOAL/DONE clause counts, e.g. R4.8: 4 GOAL, 3 DONE> and <paste the lines>; a paste whose count disagrees is a residue P1. For every GOAL and DONE line: verdict YES / NO with evidence (file, test, command). Flag anything done BEYOND the brief's scope. The orchestrator did not and cannot tell you what to ignore: if something looks wrong to you, write it down. If this is a RE-VERIFICATION after a rejection: look only at the fix's diff; for every previous rejection, mark RESOLVED / NOT RESOLVED; new breakage only within the diff.

1. QUALITY GATES, in order, commands copied verbatim from `stack-map.md`, quoted next to each result; a command reading "not found" = gate MISSING (residue P2), never skipped. Result read from `$?` right after each command or from a log file; NEVER from a pipe (`| tail` returns tail's exit status, not the command's); on PowerShell read `$LASTEXITCODE` right after the native command, not `$?`, which a cmdlet in the pipeline overwrites:
   - typecheck: <command>
   - lint: <command>; report Error and Warning separately; zero Error is the criterion
   - unit: <command>; report passed/failed/skipped; criterion: zero failed **and** zero newly skipped, each skip named
   - real production build: <command> > <scratch>/build.log 2>&1; then `$?`; search the log for "Error", "Failed to compile", and the serialization / async-boundary messages the installed Next.js version emits (confirmed once, recorded in the stack map). If the build fails because a required variable is missing (not a code error), report "gate not runnable — missing env" with the variable names, never a rejection: after R2.1 a refusal to start without secrets is the repair working
   - custom static rules with fixtures: <command>, if any exist
   - e2e: ONLY if the phase touches them (Phases 1, 4, 5); otherwise skip. Warm-up first. Result from the file report.

2. RE-MEASURE the phase's numbers, with the SAME commands as the diagnosis (copied from <remediation>/00-diagnosis/synthesis.md):
   <list of the phase's measures: command → expected value>
   Report before | after | command | date.

3. CANARY for the phase's repairs: for every test file new or changed in the tree (`git status --short` and `git diff --name-only`, filtered by the test glob in <map>; never from the repair report): a test file in the tree and absent from this list is a residue P1. On each:
   - `cp <file> <scratch>/<name>.orig` (the working tree, never HEAD: repairs are uncommitted; a 0-byte `.orig` for a non-empty file aborts the canary, residue P1)
   - apply the minimal break in a **non-test file the repair changed**, inside the function body; a parse error is not a canary
   - run ONLY that test: RED = `$?` non-zero **and** the assertion named in the output; a test that stays green does not cover the product, residue P1
   - restore: `cp <scratch>/<name>.orig <file>`; then `git diff --stat` must equal its pre-canary value
   - after the last canary, re-run the unit gate
   - never `git stash`, never `git checkout --` on the tree
   Report: test | product file broken | red on break? | restore verified (`git diff --stat` unchanged)?

4. PARITY (Phases 3 and 4): for the screens touched, the same on-screen numbers before and after (counts, totals, facets) — read them from the parity tests or from the page in dev; report every difference.

5. DIFF: `git status --short` and `git diff --stat`; files touched outside the phase's authorized list = a flag. Receive <allocation> (`file | agent | shared?`, from `synthesis.md`): flag any file whose diff crosses two owners; on re-verification every file owned by a rejected agent is re-checked in full, not only the fix's diff.

6. DECLARATIONS: every new test has the "tested against" line; every new record in docs/decisions cites an existing file/test (verify it exists).

REPORT in <remediation>/<NN-phase>/verification.md (max 60 lines): quality gates table (command | result | evidence); before/after measures table; canaries table; parity differences; files outside the list; brief-compliance table (line | YES/NO | evidence); final verdict: CLOSED / RESIDUAL (list, each with severity P1 blocking · P2 must be fixed · P3 fix when touched). Reply here with 5 lines: verdict, quality gates, measures that got worse, failed canaries, files outside the list.
```

## Why this way

- The repair agent's report describes what it believed it did. One agent reported a clean typecheck that was never run.
- `build | tail` hid a broken build for a day.
- A new test that has never been red proves nothing: the canary is the part you don't skip.
- Checking the restore against the pre-canary diff is the difference between "I restored it" and "I hope I restored it".

## Diff mode (used by `review` and by the change-time protocol of `maintain`)

When the verifier is invoked on an ordinary change rather than on a phase:

- Step 0 checks the change's own brief (or, if there is none, the change description) line by line: what was asked, what was done, what was done beyond it.
- Steps 1–2 run on the touched files only: the gates that the diff can break (typecheck, lint, the unit tests covering the files, the static rules, the real build when components or the server → client boundary changed), and only the measures the diff can move (full scans, caps, technical errors reaching the client, fields without a label, declared tests, invalidations next to the write).
- Step 3 runs the canary on every new or changed test.
- Step 5 scope is the change itself: `git diff --name-only <base>..<head>`.
- Verdict as usual: CLOSED / RESIDUE with severity. A P1 blocks the merge; then `procedure.md` § Convergence: rounds, the cap, the ruling.
