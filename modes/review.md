# Mode `review`: a diff against the target state

Input: a diff, a branch, a pull request, or "what I changed today". Output: findings with severity, file:line and the rule they violate. Report-only; applying fixes is a separate, explicit request that goes through the repair cycle.

## Steps

1. **Scope.** `git diff --name-only <base>..<head>`. Map every touched file to its layer and area using the stack map. If no stack map exists, run `diagnose` first: a review without the map guesses.
2. **Blast radius.** For every touched table, component or command: who writes it (owners), what the effect map says it touches, which files co-change with it. A touched process gets its flow test named. The owners and effect-map files are produced by the sibling skill `design-software-properly`; when they are missing, the review says so as a note and reviews what it can.
3. **Applicable rules.** From the areas the diff touches, take only the target-state items and the rules the diff can violate. Do not paste whole checklists; a review that lists forty irrelevant items is not read.
4. **Gates on the diff.** typecheck, lint (zero errors), the unit tests that cover the touched files, the static rules; the real build when components or anything crossing the server → client boundary changed. Exit codes read from `$?`, never from a pipe.
5. **Findings.** One line each: `file:line — P1|P2|P3 — <rule id or area § item> — <what is wrong> — <what to do>`. P1 = data loss, double writes, security, a guard that fails open, an irreversible action reachable; P2 = a target-state item broken; P3 = style within the rules. Every finding cites the rule; a finding without a rule is an opinion and is labeled "note".
6. **Decisions.** A change that contradicts a decision record is a P1 until the record is superseded through the Q&A. A change that introduces a new reversible choice gets a decision question, not a silent approval.
7. **Report.** `docs/remediation/reviews/<date>-<branch-or-pr>.md`: scope, blast radius, findings, gates table, decision questions. Inline summary: counts by severity and the top three findings.

## What the reviewer does not do

- Fix anything.
- Re-review unchanged code.
- Skip a finding because "the plan required it": record it, let the ruling decide.
- Judge the diff against taste: only against the areas' target state and rules.

## Use inside `maintain`

The change-time protocol runs this mode after every change and before the verifier. A P1 blocks the merge; P2 goes to the defect register with the change's commit; P3 is a lessons line if it repeats.
