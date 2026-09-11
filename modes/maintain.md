# Mode `maintain`: keeping the target state after the remediation

A remediated codebase drifts the day after the handover unless three things exist: **guards** that fail mechanically, a **protocol at change time**, and a **periodic drift check**. This mode installs and runs them. It reuses the same areas, briefs and verifier; nothing here is a second rulebook.

## 1. The guard set (installed once, checked every run)

Guards are the target-state rules that a machine can enforce. They live in the project and run in `verify` and in CI or a pre-push hook.

| Guard | Enforces | Source brief |
|---|---|---|
| Custom static rules with fixtures (guard on every public action, no PII in logs, no service key outside the data layer, no technical error to the client) | 2, 3, 5 | R1.2, R4.8 |
| `tests-declared` (every test states its world) and the frozen exemption list | 2 | R1.4 |
| Five-states test on the list shell; label / `aria-label` greps; glossary check | 4, 5 | R4.8, R4.9 |
| Coverage, stale-words and register checks on the acceptance checklist; guide coverage | 6 | R5.3, R6.4 |
| Debt markers ↔ debt register alignment | 6 | R6.5 |
| Canary switches on every harness (`CANARY=<n>`) | 2 | R5.1 |
| Live channel table with the date of the last injected failure seen arriving | 3 | R2.6, R5.7 |
| Cache tags cross-checked against invalidations in the same service file; no empty `catch {}` around an invalidation | 1 | R3.4 |

The structural guards (dependency rule in lint, owners script and effect-map test, clone detection, registry alignment, co-change and hotspot scripts) belong to the sibling skill `design-software-properly` (its mode `maintain`). Run both guard sets from the same `verify` script; neither replaces the other.

First `maintain` run: check each guard's presence with its command; install the missing ones by dispatching the source brief; wire the whole set into the `verify` script and the CI configuration (a guard that only runs when someone remembers is not a guard). Record the set in `status.md` § Maintenance with the date.

## 2. Change-time protocol (every feature or fix on the project)

**Before**
1. Read `status.md`, `lessons.md`, and the decision records that name the touched area (`grep` the record titles, never memory).
2. Blast radius of the change: owners, effect map and co-change (from the sibling skill `design-software-properly`, when present), flow tests of the touched processes, channels and caches it touches. Write it in the task brief.
3. List the target-state items the change can violate (from the areas it touches). Only those.
4. If the change introduces a reversible choice, run the decision Q&A first (`modes/decision-qa.md`). If it contradicts a record, the contradiction is the question.

**During**
5. Same rules as a repair brief (`templates/agent-brief.md`): one agent per area, files listed, tests declared, one test red once, variant search, no commit.

**After**
6. `review` on the diff (`modes/review.md`), then the verifier (`briefs/verifier.md`) in diff mode.
7. Update: defect register (if the change closed or opened a defect), decision records, effect map and owners if a command or a writer changed, the guide if a screen changed, `lessons.md` if something surprised.
8. `status.md` § Maintenance: last change-time review, with the evidence.

The whole protocol is two extra dispatches per change (review, verifier). If it feels heavy, the guard set is incomplete: make the guards catch what the review keeps finding.

## 3. Drift check (periodic: before a release, or monthly)

1. Find the last synthesis or drift report; take its commit.
2. Run Phase 0 in **delta mode** (`modes/diagnose.md` § Delta mode): the diagnosis briefs limited to files changed since that commit and their importers; previous defects marked RESOLVED / UNCHANGED / NEW.
3. Compare every measure with `status.md` and the last report: a measure that got worse is a finding; a closed defect found again is a P1.
4. Run the read-only scripts (acceptance coverage, guide coverage, debt markers, the live channel table) and the guard set; if the sibling skill `design-software-properly` is installed on the project, run its drift check in the same round.
5. Write `docs/remediation/drift-<date>/report.md`: measures before/after, new multipliers (a place that grew copies), NEW defects with severity, guards that failed, new clone clusters. Feed the findings into the ordered plan (`modes/diagnose.md` § Plan) as a mini-plan; ask the plan question once: it is the drift check's own checkpoint.
6. `status.md` § Maintenance: last drift check, with the report path.

## 4. What maintenance never does

- Skip the verifier because the change is small. Small changes are where `disabled` fields and `catch {}` come back.
- Add an exception to a guard to let a change through. The exception is a decision record or a repair.
- Let the acceptance checklist, the guide or the effect map fall behind the code: the checks fail, and the failure is the work item.
- Trust that a channel still works because it worked at the handover: the drift check re-runs the live channel table with dates.
