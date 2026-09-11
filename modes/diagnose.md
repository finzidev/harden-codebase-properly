# Mode `diagnose`: Phase 0, read-only diagnosis, then the ordered plan

Goal: know where the project stands, with dated numbers, without changing a file. Then compute the work order and get it confirmed. The plan question at the end closes this mode (`SKILL.md` § Non-negotiables); `status.md` is the evidence ledger, not a user checkpoint.

## 0. Entry

1. If the user brought notes or goals, run the notes protocol in `modes/decision-qa.md` § Notes first. Do not dispatch anything before the reformulation is confirmed.
2. Preconditions, checked and written down:
   - `git status --short` is empty. If not, stop and say so: repairs land in the working tree. Uncommitted changes that look like repairs (source files, not `docs/`) stop the run: ask whether to commit, move to a branch, or discard.
   - The database is reachable read-only, or every database measure will read "not measured", never zero.
   - Any database MCP or CLI present in the session points to **this** project (compare the project reference or the expected tables). If not, say so and do not use it; if the expected tables are not known yet, defer to D0 and do not use the tool until it confirms.
3. Create `docs/remediation/status.md` from `templates/status.md` (host project's docs language and folder convention win if one exists; record it in the stack map). Leave stack map and language `<pending D0>`; fill at 0.3. Tick step 0.1 with the evidence of the three checks.

## 0b. Size band

Measured before wave two; numbers into `status.md` 0.1.

- source files: `git ls-files | grep -cE '\.(ts|tsx|js|jsx|py|go|rb|php)$'`
- routes: from D0's folder list
- commits: `git rev-list --count HEAD`

| band | condition (any) | dispatch | plan |
|---|---|---|---|
| small | files < 100 · routes < 15 · commits < 100 | `D0`, `D1`, `D2`, `D4` only; `D3`, `D5` recorded "not dispatched: `<measure>` = `<n>`" | no multiplier ordering (rule 3 has no input): severity, then dependency |
| standard | files 100–800 | all six | as written |
| large | files > 800 · routes > 120 | all six; `D4` split by route group | multipliers first |

Fan-out: "one agent per X" means one per X only when count(X) ≥ 3, else one agent for all. A step whose subject count is 0 is not dispatched and is recorded "skipped: `<measure>` = 0", which is its evidence line.

## 1. Dispatch

Two waves in two messages, `model: sonnet`, `run_in_background`, briefs in `briefs/phase-0-diagnosis.md`: `D0` alone; then `D1`–`D5` in one message, each with `<map>` and its own `areas/*.md`.

Reports under `<remediation>/00-diagnosis/`: `D0` stack map and processes (`stack-map.md`), `D1` quality gates (`quality.md`), `D2` data and security (`data-security.md`), `D3` performance (`performance.md`), `D4` interface and user communication (`interface.md`), `D5` documentation and method (`method-documentation.md`). Architecture and cross-module coupling are measured by the sibling skill `design-software-properly` (its D1 and D3): if its reports exist, read them; if not, the plan says so.

After dispatch, stop: no polling. Tick step 0.2 with the agent list.

## 2. Synthesis

When all reports are in, write `docs/remediation/00-diagnosis/synthesis.md` following `templates/diagnosis-report.md` § Synthesis:

1. The unified measures table (measure | value | date | reproducing command).
2. The defect queue: for each defect, class, severity (P1 one step from irreversible damage or data loss · P2 must be fixed · P3 fix when touched), effort (S/M/L), and **where it lands** (file, component, layer).
3. The places table: place | copies (how many implementations exist) | defects landing there | churn. Places with many copies and many defects are the **multipliers**. `copies` and `churn` come from `docs/design/00-diagnosis/` (the sibling skill); absent, both read `—` and ordering rule 3 uses defects-landing alone.
4. The ordered plan (below).
5. The first decision records to open, as questions (`modes/decision-qa.md` § Decisions).
6. The briefs of the first step, already filled in.

The shape of one defect end to end is `examples/one-defect.md`; the first briefs follow it.

Create if missing: `docs/remediation/defect-register.md` (columns: id | class | severity | effort | file:line | where it lands | phase | status (open · closed · parked) | proof | ruling), `docs/decisions/README.md` (two tables, client and internal, never merged), `docs/remediation/lessons.md` (empty, dated). Tick step 0.3.

## 3. Plan

The work order is computed, not inherited. Phase numbering is the default skeleton; it names briefs and reports. The real sequence comes from the diagnosis, with these rules in order of precedence:

1. **First, what makes work verifiable.** Quality gates and enforcement (Phase 1): work without a gate cannot be declared finished.
2. **Then what is one step from irreversible damage** (the list: data loss, a permission that widens, money moved, a channel silenced, a secret exposed). Database permissions, caps shown as totals, destructive actions reachable from the detail page, silent alert channels, dates compared as strings, non-idempotent webhooks.
3. **Then the multipliers this skill owns.** For every defect, where it lands; for every place, how many copies. A place with several defects and several copies is centralized **first**, so that each later repair is done once instead of N times: the user-error module (every error lands there), the form-field primitive (labels, hints, validation), the outcome component (every worded result lands there), the peripheral cache module (every invalidation lands there), the env module (every secret lands there). The **structural** multipliers (table shell and field registry, separated layers and enforced boundaries, the fake/real boundary module, a table with N writers, a process crossing N modules by direct import) belong to the sibling skill `design-software-properly`: when the diagnosis shows them missing, the plan schedules that skill's phases before Phase 4 here and says so in the plan table. Rule: if a repair would be done in N places, bring N to 1 first.
4. **Then the improvements that land in the centralized pieces.** Five states, feedback, hints, tooltips, skeletons, per-page performance, outcomes: once each.
5. **Then what calibrates and describes.** Tests (Phase 5), documentation (Phase 6).
6. **Within each group, by dependency.** What unblocks first, then the independent, last what waits for an answer from the user or the client.

Present the plan as a table: step | what | source brief | multiplier (place, copies, defects landing) | depends on | ask-first?. A Phase 4 step may precede a Phase 3 step when it is a multiplier; a step of the sibling skill may be scheduled between two steps here. A step is skipped only when the measure says it is already in place.

## 4. Checkpoint

Ask the user, with one multiple-choice question (`modes/decision-qa.md` § Plan question):

- the ordered plan and why (the multipliers with their numbers);
- the phases the measures say are already done;
- the ask-first items already visible;
- the decision questions of the first step.

Wait for the answer. Record the confirmed plan in `status.md` (step 0.4, with the date) and in `docs/remediation/00-diagnosis/synthesis.md`. From here on the phases proceed autonomously within the autonomy contract (`procedure.md`), one step at a time.

## Exit

- Every row of the measures table has a value, a reproducing command and a date.
- No project file changed except `docs/remediation/`, `docs/decisions/README.md`.
- Plan confirmed by the user; `status.md` shows Phase 0 closed with evidence.

## Delta mode (used by `maintain`)

Same briefs with one added paragraph in the common header: "DELTA MODE: limit the measures to the files changed since `<commit>` (`git diff --name-only <commit>..HEAD`) and their importers; read the previous report for this area and mark every previous defect RESOLVED / UNCHANGED / NEW; a defect marked closed in the register and found again is a P1." Output goes to `docs/remediation/drift-<date>/`.
