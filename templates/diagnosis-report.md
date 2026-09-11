# Diagnosis report template (Phase 0)

One report per area, written by a read-only agent; the orchestrator writes the synthesis. Every value carries the command that reproduces it and the date: a number without a date is true only on the day it was written.

Structural measures (import directions, layer cycles, files over the threshold, dead exports, clone clusters, writers per table, effect map, co-change) are not in this template: they are the sibling skill `design-software-properly`'s diagnosis. If its reports exist under `docs/design/00-diagnosis/`, the synthesis links to them instead of repeating them.

```markdown
# Diagnosis: <area>  (<repo>, <date>)

## Measures

| measure | value | date | command that reproduces it | note |
|---|---|---|---|---|
| verify script | typecheck ✓/✗ lint ✓/✗ unit ✓/✗ build ✓/✗ | | `npm run ...` | |
| lint Errors today | N | | `<lint command from the stack map>` | |
| CI or hook that runs the gates | yes/no | | `.github/`, `.husky/`, pipeline config | a comment is not a gate |
| custom static rules / with fixtures | N / M | | `semgrep --test` | |
| suppressions without a reason | N | | grep `nosemgrep`, `eslint-disable` | |
| red e2e / for how many days | N / days | | file report, not `| tail` | |
| tests that declare "tested against" | N / total | | grep | |
| harnesses that have never been red | N (list) | | reading the probes, corpus, checklists | canary expected |
| env fail-fast | yes/no | | reading the config module | |
| public variables containing keys / tracked `.env*` | N / M | | grep, gitleaks | |
| dependency audit: High/Critical count | N | | `<command>` | |
| entry points parsing input against a schema | n / total | | `<command>` | |
| tables with active policies / policies for anon | N / M | | query on `pg_tables`, `pg_policies` | from the DB, not from the repo |
| sensitive functions executable by anon | N | | query on `pg_proc.proacl` | |
| non-idempotent migrations / functions rewritten from an old definition | N / M | | reading the migrations | |
| CLI and app on the same DB | yes/no | | compare project-ref with env | |
| token check with three separated causes / embedded expiry wins online | yes/no | | reading the verify function | |
| timestamp comparisons as strings | N | | grep `!==`/`===` on re-read dates | |
| live-tested channels | email ✓ alerts ✗ backup ? | | date of the last test | |
| backup success read from the last link | yes/no | | reading the run row | |
| webhooks without dedupe / external calls without a key | N / M | | reading the handler | P1 |
| "load everything" pattern | N occurrences | | `grep -rn "\.all()" src/features` | |
| reads per page (3 hot pages) | 12 / 9 / 4 | | reading the adapter | |
| ms on real data (3 pages) | ... | | measurement, with cardinality | |
| in-memory counts in services | N | | grep `length`, `reduce`, `filter(...).length` | |
| cache / invalidation | present? tags? next to the write? | | reading | |
| loops inside a single-request timeout guard | N | | reading the resilience helpers | |
| undeclared caps | N | | `grep -rnE "\.limit\(|limit:\s*[0-9]{3,}" <src>` | |
| skeletons per route | N / routes with reads | | `find app -name loading.tsx` | |
| alternative renderings of the same list | N | | reading | |
| filters with an "apply" button | N | | grep | |
| editors with `disabled` | N | | `grep -rn "disabled" src/components` | |
| bulk actions exposed as a row button / irreversible action on the entity page | N / M | | reading | |
| commands without feedback / `{ok:true}` for different outcomes | N / M | | reading the actions and links | |
| colors outside tokens | N | | `grep -rnE "#[0-9a-fA-F]{3,8}|\[[0-9]+px\]" src` | |
| technical errors sent to the client | N | | `grep -rn "error\.message\|String(err\|digest" src/components src/app` | |
| lists that render an error as "empty" | N / M | | reading the list components | five states expected |
| fields without a label / icons without aria-label | N / M | | grep `<input` without a label; icon-only `<button` without `aria-label` | |
| actions with no outcome or a generic "Done" | N | | reading the actions and toasts | |
| synonyms for the same concept | N terms | | table term \| where (UI, guide, email) | |
| visible error paths with a test on the wording | N / M | | list | |
| multi-module processes with a flow test | N / M | | list of processes ↔ tests | |
| decision register / index / debt register | yes/no | | | |
| numbers repeated across multiple documents | N | | grep the number | |
| guide sections naming commands that no longer exist / routes not covered | N / M | | compare against the real routes | |
| runbooks present / executed | N / M | | reading `docs/operations/` | |

## Defects found while reading (NOT repaired)

- `file:line`: <symptom> | <why it is a defect> | <class: fake≠real, missing guard, cap passed off as a total, ...> | severity P1 (one step from irreversible damage or data loss; blocks handover) / P2 (must be fixed) / P3 (fix when touched) | effort S/M/L | where it lands (file, component, layer) | if there is a previous report: RESOLVED / UNCHANGED / NEW

## Looks wrong but is fine

- <what you evaluated as a possible defect> | <why you concluded it is intentional or harmless> | <what would make it a defect>

Mandatory section: a report that doesn't say what it ruled out cannot be judged. When in doubt between a defect and a deliberate choice: an open question in "Proposals", not an assertion.

## Proposals (they remain proposals)

- <proposal> | estimated cost | risk | what it unblocks

## Limits of this inventory

- <what the method doesn't see>
```

## Synthesis (written by the orchestrator)

1. The unified table of measures.
2. The defect queue: for each one, class, **where it lands** (file, component, module), and whether it is one step from irreversible damage.
3. The table of **places**: place | copies (how many implementations exist) | churn | defects that land there. `copies`, `churn`: from the sibling's diagnosis, `—` if absent. Places with more copies and more defects are the multipliers; the structural ones (table shell, field registry, layers, single writer, domain events) are named and handed to the sibling skill.
4. **The ordered plan** (rules in `modes/diagnose.md` § Plan): step | what | brief | multiplier | depends on | ask-first?. Quality gates first, then what is one step from irreversible damage, then the multipliers this skill owns, then improvements once each, then tests and documentation; the sibling skill's steps are scheduled where the plan needs them.
5. The first three decision records to open.
6. The briefs for the first step, already filled in.
