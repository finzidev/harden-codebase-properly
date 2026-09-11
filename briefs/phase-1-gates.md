# Phase 1 Brief: Gates and Safety Net

Common repair header (prepended to every brief):

```
Repo: <repo>. Stack: <stack>. Map: <map>. Work ONLY in the listed files; if you need to touch others, stop and say so in the report. Do not commit. Do not use `git stash`. Do not open lint exceptions (`eslint-disable`) or suppress a static rule without a reason written next to it. Every new test carries `// tested against: fake | real adapter | both | none` at the top and must have been RED once: break the invariant, see the red, restore it, report it. Do not launch other agents. For every closed defect: search for the same shape elsewhere in the repo (grep or a static rule) and report it; if the shape is mechanical, propose a static rule with a fixture. Final report, max 15 lines: files touched, before/after counts, canary outcome, variants found, what was left out and why, new decisions to record (title + rejected alternatives). Reports, decision records, commit messages, UI text and documents are written in the host project's language (see <map>); these instructions are in English.
```

Order: `R1.1` first (it touches the config and the verify script); then `R1.2`, `R1.3`, `R1.4` in parallel. The dependency rule in lint (layer and bounded-context boundaries) is not here: it is brief R1.2 of the sibling skill `design-software-properly`, which assumes this phase's verify script exists.

---

### R1.1 Single verify script, lint at zero Error
`model: sonnet` · files: `package.json`, lint config, the files with lint Errors (from diagnosis D1)
CONTEXT: Lint Errors today: <before>. Existing scripts: <map>. Real build: <command>.
GOAL: one `verify` script (or the host project's equivalent name) = typecheck && lint && unit && build, green start to finish; lint at zero Error.
HOW: add the script; fix every lint Error at the root cause (never with a disable); if an Error is a rule the project does not want, propose the decision record in the report instead of turning it off. Run the real build with logging to a file and read `$?`.
DON'T: pipe the build through `| tail`; downgrade rules to `warn` to make it pass; touch logic.
TEST: `npm run verify` (or equivalent) exits 0.
DONE: exit code 0 read from `$?`; Error = 0; Warnings reported.

### R1.2 Custom static rules with fixtures
`model: sonnet` · files: static-rule config (semgrep or equivalent), `semgrep/tests/` folder (or the host project's equivalent), `package.json` (script)
CONTEXT: existing rules: <before>; without a fixture: <n>. Public actions folder: <map>. Role-guard function names: <list>.
GOAL: at least these rules, each with `ruleid:`/`ok:` fixtures and a script that tests them offline: (1) every function exported from an actions file textually contains a role guard; (2) no personal data in logs (email, phone, name in `console.*`/logger); (3) no service key outside the data layer; (4) no server directive in the data layer.
HOW: pattern on the text (`export async function $F` with a guard inside); glob on the action file names, and in the rule's comment state that a file outside the glob makes the rule go SILENT. `semgrep:test` script (or the host project's equivalent) that copies the rules into the tests folder and runs `--test`. Never `--config auto` (it hits the network).
DON'T: ship a rule without a fixture; set severity below ERROR for the guard rule.
TEST: remove a guard in a fixture: the rule fires; `--test` green.
DONE: script green offline; every rule has at least one `ruleid:` and one `ok:`.

### R1.3 Red e2e tests: fixed on the property, or `fixme` with a reason
`model: sonnet` · files: the red e2e tests (from D1), the e2e config (warm-up only if missing: see R5.2)
CONTEXT: red e2e tests: <list>, red since <date>. For each one, D1 states whether the product changed on purpose (find the commit) or it is a real defect.
GOAL: no background red.
HOW: product changed on purpose → rewrite the assertion on the PROPERTY that must stay true ("the count next to each entry tells the truth"), not on today's new number. Real defect → `test.fixme('<reason, defect #id in the register>')` and a line in `<remediation>/defect-register.md` (these are defaults: if the host project already has a docs language and folder convention, use it — the stack map records it). `mode: 'serial'` on long files: remove it or split the file.
DON'T: delete tests; widen timeouts to make them pass; assert today's value.
TEST: run ONLY the touched tests, with warm-up; outcome from the file report.
DONE: every touched e2e test green or `fixme` with a reason; list in the report.

### R1.4 "Tested against" declaration on tests
`model: sonnet` · files: `tests/unit/**` (or equivalent), a new test `tests-declared.test.ts` (or the host project's equivalent), a file `_tests-undeclared.ts` (or the host project's equivalent)
CONTEXT: unit tests: <n>; declared: <before>. Adapters present: <fake / real>. Known divergence points (from the sibling skill `design-software-properly`, diagnosis D1, when it exists; otherwise list them by reading the two adapters): <list>.
GOAL: every test file carries `// tested against: fake | real adapter | both | none`; a mechanical test enforces this; the exemption list is frozen (it can shrink, never grow); if the helper that intercepts the transport to the real database without touching the network is missing, add it.
HOW: read every test and declare the world it actually exercises (if it uses only pure functions: `none`). For tests that cross a fake/real divergence while running only against the fake: flag them in the report (the sibling skill `design-software-properly` fixes them in brief R2.5), do not rewrite them here.
DON'T: declare `both` without the test actually running against both.
TEST: remove the header line from a test: `tests-declared` must fail.
DONE: mechanical test green; exemption list with a count; list of suspected fake/real tests, handed to the sibling skill `design-software-properly` (brief R2.5).
