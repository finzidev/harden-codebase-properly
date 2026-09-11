# Spec: `rules/`, `scripts/`, `sql/` — the artifacts the skill describes but does not ship

The skill demands 18 mechanical artifacts and ships 2 commands (`briefs/phase-6-documentation.md:12`, `templates/decision-record.md:9`). Every other one is re-derived per project by a repair agent from one line of prose. Cost and variance are estimated in `audit/02-usability.md` § 4.

Principle, unchanged from the skill: **a guard that is re-invented per project is not a guard.** The rule ships with its fixture; the fixture ships with the rule.

## 0. The injection hook: `stack-map.json`

Host-project naming is already collected by D0 (`briefs/phase-0-diagnosis.md:31-32`) as a Markdown table. One added line makes it machine-readable, and every script below reads that one file.

Add to `briefs/phase-0-diagnosis.md` D0, after line 35:

```
ALSO WRITE <remediation>/00-diagnosis/stack-map.json with the same rows as keys (the schema is
skills/harden-codebase-properly/scripts/stack-map.schema.json). A row you could not fill is null,
never a guess. The guard scripts read this file; a null key makes the guard report "not installed",
not "passing".
```

Schema (`scripts/stack-map.schema.json`), all keys nullable:

| key | example | consumed by |
|---|---|---|
| `roots.src` `roots.components` `roots.actions` `roots.dataLayer` `roots.services` `roots.tests` `roots.e2e` `roots.routes` `roots.migrations` `roots.docs` | `"src/app"` | every script |
| `globs.testFiles` `globs.actionFiles` `globs.routeFiles` `globs.skeletonFiles` `globs.componentFiles` `globs.migrationFiles` | `"**/*.test.ts"` | most |
| `commands.typecheck` `.lint` `.unit` `.build` `.e2e` `.staticRules` `.verify` | `"npm run build"` | `briefs/verifier.md:13-18` |
| `conventions.testedAgainstMarker` | `"tested against:"` | `check-tests-declared` |
| `conventions.skeletonBasename` | `"loading.tsx"` | `check-skeletons` |
| `conventions.debtMarkers` | `["TODO","FIXME"]` | `check-debt-markers` |
| `paths.glossary` `.guideSource` `.guideCoverage` `.checklist` `.debtRegister` `.decisions` | `"docs/conventions/glossary.md"` | docs guards |
| `db.dialect` | `"postgres"` | `sql/` |
| `language` | `"it"` | report language |

## 1. Contract shared by every script

- **Runtime**: Node ≥ 18, ESM, zero dependencies (`node:fs`, `node:path`, `node:child_process` only). Reason: it must run offline (`areas/quality.md:10`, `briefs/phase-1-gates.md:26` "Never `--config auto` (it hits the network)") and must not add a dependency to the host project.
- **Invocation**: `node scripts/<name>.mjs [--config <path>] [--json]`. Default config `docs/remediation/00-diagnosis/stack-map.json`.
- **Exit codes**, identical everywhere:

| code | meaning | what `maintain` does with it |
|---|---|---|
| 0 | ran, no findings | guard present and green |
| 1 | ran, findings printed as `file:line — <what> — <rule>` | guard present and failing: a work item |
| 2 | cannot run: a config key is null or a path is absent | guard **not installed**; the drift report lists it as missing (fixes `modes/maintain.md:47`) |

- **Output**: findings on stdout, one per line, plus a last line `<name>: N findings`. `--json` emits `{name, exit, findings:[{file,line,what,rule}]}` so the orchestrator can paste counts into a report without re-counting.
- **Fixtures**: `fixtures/<name>/pass/` and `fixtures/<name>/fail/`, each with its own `stack-map.json`. `node scripts/selftest.mjs` runs every script against both and asserts 0 and 1. That is the canary on the guards themselves (`areas/quality.md:11`), and it is what `briefs/phase-1-gates.md:28` currently asks each agent to build from scratch.
- **Host-agnostic** by construction: every path, glob and command comes from `stack-map.json`. Where that is impossible it is marked below.

## 2. `rules/` — the five static rules with their fixtures

Semgrep YAML, one file per rule, plus `rules/tests/` fixtures in the `ruleid:` / `ok:` form `briefs/phase-1-gates.md:29` requires. `scripts/run-static-rules.mjs` runs `semgrep --config rules --test rules/tests` offline, or reports exit 2 when semgrep is absent.

| file | rule | inputs | fixtures | invoked by |
|---|---|---|---|---|
| `rules/guard-on-public-action.yaml` | every `export async function` under `globs.actionFiles` textually contains one of `conventions.guardNames` | actions glob, guard names | `tests/guard-on-public-action.ts` (1 `ruleid:`, 1 `ok:`) | `briefs/phase-1-gates.md:25` (1) |
| `rules/no-pii-in-logs.yaml` | no `email`/`phone`/`name`-shaped identifier inside `console.*` or the project logger | logger name | `tests/no-pii-in-logs.ts` | `briefs/phase-1-gates.md:25` (2) |
| `rules/no-service-key-outside-data-layer.yaml` | the service-key env name appears only under `roots.dataLayer` | env name, data-layer root | `tests/no-service-key.ts` | `briefs/phase-1-gates.md:25` (3) |
| `rules/no-server-directive-in-data-layer.yaml` | no `'use server'` under `roots.dataLayer` | data-layer root | `tests/no-server-directive.ts` | `briefs/phase-1-gates.md:25` (4) |
| `rules/no-technical-error-to-client.yaml` | `error.message`, `String(err`, `.digest`, `JSON.stringify(err` never reach a return value or component under `roots.components`/`roots.actions` | components, actions | `tests/no-technical-error.tsx` | `briefs/phase-4-interface.md:65` |

Each YAML carries in its own comment the line `briefs/phase-1-gates.md:26` demands: "a file outside this glob makes the rule go SILENT". Severity `ERROR` on all five (`briefs/phase-1-gates.md:27`).

Unavoidable stack assumption: `'use server'` is Next.js. The rule is a no-op (exit 0, "directive not applicable") when `roots.dataLayer` is set and the directive string is null in config.

## 3. `scripts/` — the guards

| file | what it checks | inputs | outputs | brief line that invokes it |
|---|---|---|---|---|
| `check-tests-declared.mjs` | every file matching `globs.testFiles` contains `conventions.testedAgainstMarker` with a value in `fake\|real adapter\|both\|none`; exemptions read from `tests/_tests-undeclared.txt` and the list may shrink, never grow (compares against its own committed copy) | test glob, marker, exemption file | undeclared files; exemption count | `briefs/phase-1-gates.md:43,46`; `procedure.md:75`; `modes/maintain.md:12` |
| `check-skeletons.mjs` | every route under `globs.routeFiles` that performs a read (matches `conventions.readMarkers`, default `await` + a `roots.services` import) has a sibling `conventions.skeletonBasename` | routes glob, skeleton basename | routes with reads and no skeleton | `areas/interface.md:60`; `briefs/phase-3-performance.md:69`; `templates/diagnosis-report.md:40` |
| `check-labels.mjs` | every `<input>`, `<select>`, `<textarea>` under `roots.components` has an `id` bound to a `<label for>` in the same file, or `aria-label`/`aria-labelledby`; every icon-only `<button>` has `aria-label` or `title` | components root | fields and icons without a label | `briefs/phase-4-interface.md:75`; `areas/user-communication.md:46-47`; `procedure.md:116` |
| `check-glossary.mjs` | terms listed as forbidden in `paths.glossary` do not appear in sources, the guide source, or email templates | glossary file (`term \| canonical \| forbidden` table), search roots | each forbidden term with file:line | `briefs/phase-4-interface.md:71,75`; `areas/user-communication.md:49`; `modes/maintain.md:13` |
| `check-tokens.mjs` | no hex color or bracketed px outside the token file: `#[0-9a-f]{6}` and `\[[0-9]+px\]` under `roots.components`, minus `paths.tokens` and lines carrying `conventions.exceptionMarker` | components root, token file | each hit | `briefs/phase-4-interface.md:14`; `areas/interface.md:42` |
| `check-cache-invalidation.mjs` | every cache tag declared under `roots.services` has an invalidation in the same file; no empty `catch {}` within 5 lines of an invalidation call | services root, tag/invalidate function names | tags with no co-located invalidation; empty catches | `modes/maintain.md:18`; `areas/performance.md:40-41`; `briefs/phase-3-performance.md:38` |
| `check-checklist.mjs` | three checks in one, selected by `--coverage`, `--stale-words`, `--register`: the checklist `covers` fields are a partition of pages+routes+actions; no entry names a gesture in the stale-word dictionary; every phrase from the round is found again in the register | checklist, surface globs, stale-word dictionary, register | uncovered surface items, phantom entries, stale wording, orphan phrases | `briefs/phase-5-tests.md:26,28,29`; `modes/maintain.md:14` |
| `check-guide-coverage.mjs` | every route in `globs.routeFiles` appears in `paths.guideSource`; every screen or command named in the guide still exists; writes `paths.guideCoverage` | guide source, routes glob | uncovered routes, vanished commands | `briefs/phase-6-documentation.md:32,34`; `modes/maintain.md:14`; `procedure.md:140` |
| `check-debt-markers.mjs` | every `conventions.debtMarkers` occurrence in the code has a line in `paths.debtRegister`, and every register line has a marker or a named file | markers, debt register, src root | unmatched in both directions | `briefs/phase-6-documentation.md:41`; `modes/maintain.md:15`; `procedure.md:140` |
| `check-duplicate-numbers.mjs` | no integer ≥ 3 digits appears in two documents under `roots.docs` unless the second occurrence is inside a link to the first | docs root | number, files, line numbers | `briefs/phase-6-documentation.md:18`; `procedure.md:140` |
| `check-guaranteed-by.mjs` | every "where it lives" / "guaranteed by" path in `paths.decisions` points to a file that exists | decisions folder | dead references | `briefs/phase-6-documentation.md:26`; `briefs/verifier.md:36` |
| `check-channels.mjs` | every row of the live-channel table has a date within `conventions.channelMaxAgeDays` (default 90) and a named observation point | channel table path | stale or undated channels | `modes/maintain.md:17`; `briefs/phase-5-tests.md:57` |
| `canary.mjs` | harness canary driver: reads `CANARY=<n>`, applies break `n` from the harness's own `canary.json` manifest, runs only the named test, asserts red, restores, `cmp` | harness manifest | table invariant \| break \| red seen \| restore verified | `briefs/phase-5-tests.md:12-13`; `briefs/verifier.md:24-30`; `modes/maintain.md:16` |
| `guards.mjs` | runs every script above, prints one table, exits 1 if any exited 1, exits 2 only if all exited 2 | — | the guard table `modes/maintain.md:9-18` asks for, with a real command per row | `modes/maintain.md:22` ("check each guard's presence with its command") |
| `stack-map-check.mjs` | reports which config keys are null and therefore which guards are unavailable | config | the missing-key list | `modes/diagnose.md` step 0.2 evidence |
| `selftest.mjs` | runs all of the above against `fixtures/*/pass` and `fixtures/*/fail` | fixtures | pass/fail per script | CI of this skill; `briefs/phase-1-gates.md:28` |

`canary.mjs` is the one script that touches the working tree. It follows `briefs/verifier.md:25-29` exactly: `git show HEAD:<file>` into `<scratch>`, minimal break, run one test, restore, `cmp`, never `git stash`, never `git checkout --` on the tree.

## 4. `sql/` — the database checks

| file | what it returns | dialect |
|---|---|---|
| `sql/verify-permissions.sql` | `pg_proc.proacl` for `public`, one row per function, with an `expected` column filled from a `\set expected_roles` variable; and `pg_tables.rowsecurity` + `pg_policies` per table | Postgres only |
| `sql/verify-policies.sql` | tables with `rowsecurity = false`, and policies whose roles include `anon`/`authenticated` | Postgres only |
| `sql/verify-after-migration.sql` | the same two, plus counts of tables, functions and policies, for `briefs/phase-7-handover.md:23` | Postgres only |

These replace the query text currently retyped at `areas/data-security.md:47-54`, `briefs/phase-0-diagnosis.md:62-63` and `briefs/phase-2-data.md:22`, and give R2.2's `verify-permissions.sql` (`briefs/phase-2-data.md:19`) a source to copy instead of an invention.

**Unavoidable assumption.** `pg_proc`, `pg_policies`, `pg_tables` are Postgres. Nothing in the skill's security target state (`areas/data-security.md:22-23`) is meaningful without a database that has row-level policies and function grants. The honest handling is a header line in each file — "Postgres. On another engine, the target state item stands; the query does not" — and `db.dialect != "postgres"` making the Phase 2 measure read "not measured" rather than zero, which `briefs/phase-0-diagnosis.md:9` already requires.

Also near-unavoidable, and marked as such in the config rather than in the code: `conventions.skeletonBasename` (`loading.tsx` is a Next.js convention; the check degrades to "routes with reads: N, skeleton convention: not declared" when null) and the `'use server'` directive rule above.

## 5. Brief lines that change

Each becomes one line instead of a build order. Example, `briefs/phase-1-gates.md:23-29` R1.2:

```
`model: sonnet` · files: static-rule config, `package.json` (script)
CONTEXT: existing rules: <before>; without a fixture: <n>. Config: <remediation>/00-diagnosis/stack-map.json.
GOAL: the five rules in skills/harden-codebase-properly/rules/ running offline in `verify`, with their fixtures green.
HOW: copy rules/ and rules/tests/ into the project's static-rule folder; fill the config keys the rules read;
run `node scripts/run-static-rules.mjs`. Rules the project already has that overlap: keep one, note which.
DON'T: edit a shipped rule to make it pass; ship a rule without its fixture; use `--config auto`.
DONE: `node scripts/selftest.mjs` exit 0; the five rules wired into `verify` with their command.
```

The agent still adapts, reports and is verified. It no longer invents the artifact, and two runs on two projects produce the same guard.
