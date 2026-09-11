# Phase 0 brief: read-only diagnosis

Six agents, `model: sonnet`, all `run_in_background`, all in one message. Every brief starts with the common header and ends with the common closing. Fill in `<…>`.

## Common header

```
You are READ-ONLY. Do not modify any project file and do not run commands that write (no install, no build that writes into the repo, no migrations, no push). Repo: <repo>. Stack: <stack>. Map of local names: <map>.
Today's date: <date>. Every number you write carries the date and the command that reproduces it. If you can't find something, write "not found"; if you can't measure it, write "not measured" — never zero.
Do not report secrets, keys, real project URLs, or personal data.
Write the report in the host project's language (see <map>); if unknown yet (D0), use the language of the project's README and commits.
If the session has an MCP server or a database CLI, verify BEFORE using it that it points to THIS repo's project (compare the project reference or the expected tables against the repo's schema). If they don't match, state so in the report and don't use it: a tool with the right name can be wired to a different project.
```

## Common closing

```
Report format: `templates/diagnosis-report.md` (sections: Measures | Defects found while reading, NOT repaired, each with severity P1/P2/P3, effort S/M/L, and where it lands | Looks wrong but is fine: what you evaluated and ruled out as a defect, and why | Proposals with cost and risk | Limits of the method). When in doubt between a defect and a deliberate choice: an open question, not an assertion. If a previous report for the same area exists in <remediation>, read it first and mark every one of its defects RESOLVED / UNCHANGED / NEW. Max <2200> words.
WRITE the report to <remediation>/00-diagnosis/<area>.md and reply here with ONLY 5 lines: file written, number of measures, number of defects, top 3 findings.
```

These are defaults: if the host project already has a docs language and folder convention, use it (the stack map records it).

---

## D0: stack map

```
GOAL: state what the things the procedure names generically are called HERE, so the other agents don't guess.
READ: package.json (scripts, dependencies), the linter config, the test runner config, the framework config, the migrations folder, the CI config if any, the README, any CLAUDE.md or docs/conventions.
PRODUCE a table "generic name | name here | command | notes" for: real production build; typecheck; lint; unit tests; e2e tests; custom static analysis; single verify script (does it exist?); public actions / endpoints folder; domain folder; adapters / data-access folder; infrastructure folder; components folder; database (type, how to reach it read-only, CLI, MCP); migrations (folder, tool, how they're applied); cache (mechanism, tags, invalidation); skeletons per route (mechanism); decision register; docs index; acceptance checklist; user guide.
Add: the three most-visited pages (from the main navigation) and the main entity (the largest table).
LAYERS: not classified here. If the sibling skill `design-software-properly` has produced a stack map (`docs/design/00-diagnosis/stack-map.md`), copy its table and its layer map and add only what is missing; the folders named above are enough for the static rules of Phase 1.
PROCESSES: list the three to five processes that cross the most modules (e.g. enrollment → external payment → member area → accounting → seats taken; order → warehouse → invoice), each with the modules touched in order, the tables written, and the external calls. This is the list Phase 2 (webhooks, idempotency) and Phase 5 (one flow test each) work on; the sibling skill `design-software-properly` measures their coupling (its diagnosis D3).
WRITE to <remediation>/00-diagnosis/stack-map.md.
```

## D1: quality gates

```
GOAL: know what today's verification setup does and doesn't see. Reference: areas/quality.md.
MEASURE:
1. Existing scripts and what they actually run (read package.json: `test` might be e2e). Is there a single typecheck+lint+unit+build script? Is there a CI or a hook that runs them (`.github/` folder, `.husky/`, pipeline config)? Every comment in the code or docs claiming "CI runs X" must be checked against the config actually existing: a declared quality gate with no configuration is a defect.
2. Run ONLY what doesn't write into the repo: typecheck and lint (result from `$?`, never from a pipe). Report the number of Errors and Warnings. Do NOT run build, e2e, install.
3. Unit tests: number of files; how many declare which world they run against; is there a helper for the real adapter without network access?
4. Custom static rules: how many, at what severity, how many have a fixture (`--test`), how many suppressions and how many without a reason.
5. e2e: count; red for how long (git log on the files, notes in the repo); `mode: 'serial'` on long files; is there a warm-up?
6. Canary: is there a way to deliberately break an invariant? "Green" setups that have never produced a red (probes, fixture corpus, checklists).
7. Acceptance checklist: does it exist? is it generated from the code? does it have automated checks?
8. Fixture corpus: does it contain deliberately injected defects with an oracle?
9. Mutation testing: configured? latest score with a date?
DEFECTS: e2e red for days; undeclared tests that cross fake/real; suppressions without a reason; `npm test` that doesn't do what its name says.
```

## D2: data and security

```
GOAL: permissions, secrets, migrations, environments, channels. Reference: areas/data-security.md, "What to measure". SELECT queries ONLY.
MEASURE:
1. Env module: does it exist? fail-fast in production? check that it's "not the placeholder"? distinct secrets for distinct purposes?
2. Secrets: public variables that contain keys (grep `NEXT_PUBLIC_` or equivalent); tracked `.env*` files; scan with gitleaks if available (`npx gitleaks detect --no-git` or `--no-banner`; if unavailable, "not measured").
3. Row-level security: `select tablename, rowsecurity from pg_tables where schemaname='public'`; `select * from pg_policies` (or equivalent). If the DB is unreachable: "not measured".
4. Function grants: `select p.proname, array_to_string(p.proacl,' | ') from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public'`. List the ones executable by public roles.
5. Migrations: count; idempotent (`if not exists`)? squashed? functions rewritten more than once: does each rewrite start from the latest definition? does it reassert the grants?
6. Environments: do the CLI/MCP point to the same project as the app? (compare project reference / env host, without reporting the values).
7. Tokens and sessions: does the check distinguish unreadable / bad signature / expired? does the embedded expiry win even with the DB reachable? does changing the password revoke sessions?
8. Dates: grep for `!==`/`===` comparisons between timestamps re-read from the DB.
9. Channels (email, alerts, backup, dead-letter, sync): for each one, how you know it arrived, and the date of the last live test (search the docs, the logs, the run tables).
10. Backup: is success read from the last link in the chain, or from the first 200?
11. Navigation after a write: client `router.push` after a server action?
12. Test/reset endpoints: disabled in production, with verification?
DEFECTS: sensitive function executable by public roles; missing policies; public secret; date comparison as strings; channel never tested; backup read from the first link.
```

## D3: performance

```
GOAL: the shape of loads on the hot pages. Reference: areas/performance.md, "What to measure". Hot pages and main entity: from <map>.
MEASURE:
1. Full scans: grep for the local equivalent of `.all()` / unfiltered `select *` in the services, with file:line and the path that exercises it.
2. Reads per page: for each of the three hot pages, count the adapter calls needed to open it (read the page's code and the services it calls); separate "needed for what's shown" from "for security".
3. In-memory counting: `length`, `reduce`, `filter(...).length` on read results inside services.
4. Pagination: DB-side or in memory? exact count or estimated?
5. Cache: mechanism; tags; who invalidates and where (service or action); does it hold data something is decided on (consents, locks, pre-deletion counts)? empty `catch {}` around invalidations?
6. Timeouts: request loops inside a guard designed for a single request.
7. Hot columns without an index (read the migrations); SQL expressions (`unaccent(`, `lower(`, `nullif(`) inside `.order(`/`.eq(` in application code.
8. Caps: `grep -rnE "limit: ?[0-9]{3,}"` in bulk actions; do they declare the truncation?
9. Skeletons per route: how many routes with reads have one.
10. Baseline: IF the real database (or a bench of the same cardinality) is reachable read-only, measure ms and round-trips for the three hot pages, with the main table's cardinality and the date. Otherwise "not measured", and write what's needed to measure it.
DEFECTS: full scan on a hot path; cache on decision-critical data; empty `catch {}` on invalidation; loop inside the guard; undeclared cap; estimate instead of a count.
```

## D4: interface and user communication

```
GOAL: distance of the interface's behaviour and wording from the target state. Reference: areas/interface.md and areas/user-communication.md ("Target state" and "What to measure"). Component duplication, the field registry and the table shell are NOT measured here: they belong to the sibling skill `design-software-properly` (its diagnosis D2); if its report exists in the repo, read it and do not repeat it.
MEASURE:
1. Alternative renderings of the same list (list / grid / grouped views of the same data).
2. Filters: an "apply" button? on the left? facets counted on which population?
3. Editors: `grep -rn "disabled" <components>`; entities always in edit mode, or read-only by default?
4. Actions: bulk actions as a row button? an irreversible action reachable from the entity page?
5. Feedback: commands with no pending state; `{ok:true}` outcomes standing in for different outcomes.
6. Color: button variants and their meaning; `grep -rnE "#[0-9a-f]{6}|\[[0-9]+px\]"` outside the tokens; color by verb or by section?
7. Skeletons per route; ARIA on sortable headers; country icons (emoji? CDN?). Navigation: sidebar push or overlay; breadcrumb; home page as a total or a difference.
8. Communication with the user (areas/user-communication.md): technical errors sent to the client (`grep -rn "error.message\|String(err\|digest\|JSON.stringify(err"` in components and actions); lists that render an error down the "empty" branch; zeros standing in for "not recorded"; actions with no outcome or a generic "Done".
9. Fields: inputs with no `<label>` and no `aria-label`; placeholder used as a label; non-obvious fields with no hint; required fields not marked; validation copy that differs between create, edit, and import for the same field.
10. Icons and confirmations: icon-only buttons with no `title`/`aria-label`; confirmations of irreversible actions with no quantity shown; what a user sees on returning with an expired session or lock (a stack trace, a blank page, a password prompt?).
11. Glossary and accessibility: different terms for the same concept across the UI, guide, emails, reports (table: term | where); visible focus on tab; `aria-live` on messages; a real report (import, sync) read without the code: is it understandable? do the rejects say why?
Compare every item of "Target state" from `areas/interface.md` AND `areas/user-communication.md` against what actually exists: table item | status | evidence.
DEFECTS: `disabled` on an editor; an irreversible action next to a reversible one; facets on the wrong population; technical error on screen; error rendered as empty; field without a label; expiry rendered as an error.
```
## D5: documentation and method

```
GOAL: how much the documentation tells the truth, and how much the method leaves a trace. Reference: areas/method-documentation.md.
MEASURE:
1. Decision register: does it exist? how many records? format with rejected alternatives? From the last three months of commits, list the "was X, now Y" choices with no record (candidates).
2. Docs index: does it exist? does it count the files or just remember them? how stale is it (git log)?
3. Repeated numbers: look for counts (work items, tests, tables, entries) that appear in more than one document; do they match?
4. Acceptance checklist: a partition of the code surface, or a hand-picked list? automated checks?
5. User guide: does it exist? generated or hand-written? does it name screens/commands that no longer exist (compare against the real routes)? which routes does it not cover?
6. Debt: a register with a trigger condition? markers in the code (`TODO`, `FIXME`, `ponytail:`, etc.) with no matching entry?
7. Questions for the client: where do they live (chat, scattered files, one place)?
8. Runbooks: backup/restore, monitoring, access revocation: do they exist? have they been run?
9. Commits: last 20, do they describe the effect or the implementation?
DEFECTS: guide that sends you looking for commands that are gone; a number that diverges between documents; a decision applied halfway (record says X, code does Y).
```

