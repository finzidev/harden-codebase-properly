# Mode `diagnose`: Phase 0, read-only diagnosis, then the ordered plan

Goal: know where the project stands, with dated numbers, without changing a file. Then compute the work order and get it confirmed. The plan question at the end is the only mandatory user checkpoint of a remediation run; `status.md` is the evidence ledger, not a user checkpoint.

## 0. Entry

1. If the user brought notes or goals, run the notes protocol in `modes/decision-qa.md` § Notes first. Do not dispatch anything before the reformulation is confirmed.
2. Preconditions, checked and written down:
   - `git status --short` is empty. If not, stop and say so: repairs land in the working tree.
   - The database is reachable read-only, or every database measure will read "not measured", never zero.
   - Any database MCP or CLI present in the session points to **this** project (compare the project reference or the expected tables). If not, say so and do not use it.
3. Create `docs/remediation/status.md` from `templates/status.md` (host project's docs language and folder convention win if one exists; record it in the stack map). Tick step 0.1 with the evidence of the three checks.

## 1. Dispatch

Six agents, `model: sonnet`, `run_in_background`, all in one message, briefs in `briefs/phase-0-diagnosis.md`:

`D0` stack map and processes · `D1` quality gates · `D2` data and security · `D3` performance · `D4` interface and user communication · `D5` documentation and method. Architecture and cross-module coupling are measured by the sibling skill `design-software-properly` (its D1 and D3): if its reports exist, read them; if not, the plan says so.

`D0` goes first when the stack is unknown; the other five receive `<map>` in their brief. After dispatch, stop: no polling. Tick step 0.2 with the agent list.

## 2. Synthesis

When all reports are in, write `docs/remediation/00-diagnosis/synthesis.md` following `templates/diagnosis-report.md` § Synthesis:

1. The unified measures table (measure | value | date | reproducing command).
2. The defect queue: for each defect, class, severity (P1 one step from irreversible damage or data loss · P2 must be fixed · P3 fix when touched), effort (S/M/L), and **where it lands** (file, component, layer).
3. The places table: place | copies (how many implementations exist) | defects landing there | churn. Places with many copies and many defects are the **multipliers**.
4. The ordered plan (below).
5. The first decision records to open, as questions (`modes/decision-qa.md` § Decisions).
6. The briefs of the first step, already filled in.

Create `docs/remediation/defect-register.md` and `docs/decisions/README.md` if missing. Tick step 0.3.

## 3. Plan

The work order is computed, not inherited. Phase numbering is the default skeleton; it names briefs and reports. The real sequence comes from the diagnosis, with these rules in order of precedence:

1. **First, what makes work verifiable.** Quality gates and enforcement (Phase 1): work without a gate cannot be declared finished.
2. **Then what is one step from irreversible damage.** Database permissions, caps shown as totals, destructive actions reachable from the detail page, silent alert channels, dates compared as strings, non-idempotent webhooks.
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
