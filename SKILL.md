---
name: harden-codebase-properly
description: Use when an existing web app or back-office (Next.js/Supabase or a similar stack with lists, tables, filters, forms, a database, external integrations) must go from "it works" to a production-grade, deliverable product on everything that is not code structure: quality gates and tests that tell the truth, database permissions and secrets, migrations and environments, slow lists and cache, interface behaviour and user-facing messages, documentation that is measured, client handover; and, once a project has docs/remediation/, whenever a change lands on it, a diff needs review against the target state, or drift must be checked. Structure, layers, coupling and duplication belong to the sibling skill design-software-properly. (anche: portare a top qualità, bonifica, hardening, sicurezza, performance, test veri, messaggi utente, documentazione, consegna al cliente)
argument-hint: [diagnose|plan|run <N>|review|maintain|status|triage]
compatibility: git, grep, ripgrep for `triage`, a Postgres client for the SQL checks, gitleaks, semgrep — or their equivalents from the stack map
---

# Harden codebase properly

A systematic procedure that measures a project, repairs it and keeps it at a defined, verifiable quality bar: gates, data and security, performance, interface behaviour, communication with the user, tests, documentation, handover. It runs through subagents: the orchestrator reasons, dispatches, reads, decides and verifies. **It never writes code.** Instructions are in English; every output (reports, decision records, commit messages, UI text) is written in the host project's language, detected in Phase 0.

Code **structure** (layers with an enforced dependency rule, one implementation per concept, deep modules, cross-module coupling, the table shell and the field registry) is the subject of the sibling skill `design-software-properly`. This skill assumes it, schedules it in the plan when the diagnosis shows it missing, and never redoes it.

## Modes

Pick the mode from the argument or the request. Load only what it lists; everything else stays on disk until a brief names it.

| Mode | When | Load |
|---|---|---|
| `triage` | A cheap first look, before a diagnosis | `modes/triage.md` |
| `diagnose` | First contact with a project, or no `docs/remediation/status.md` yet | `modes/diagnose.md`, `modes/decision-qa.md`, `briefs/phase-0-diagnosis.md`, `templates/status.md`, `templates/diagnosis-report.md`, `templates/decision-record.md`, `sql/verify-permissions.sql`, `examples/one-defect.md`, `procedure.md` § Autonomy contract; each diagnosis agent receives its own `areas/*.md` |
| `plan` | The diagnosis exists, or the user brings notes and goals | `modes/diagnose.md` § Plan, `modes/decision-qa.md`, `templates/status.md`, `templates/decision-record.md`, `procedure.md` § Autonomy contract |
| `run <N>` | Execute phase N of the approved plan | `procedure.md`, `modes/status.md`, `templates/status.md`, `briefs/phase-1-gates.md` § Common repair header, `briefs/phase-N-*.md`, the areas that phase names, `briefs/verifier.md`, `modes/decision-qa.md`, `templates/decision-record.md`, `examples/one-defect.md`, `sql/verify-permissions.sql` |
| `review` | A diff, branch or pull request must be checked against the target state | `modes/review.md` and the areas the diff touches, `modes/decision-qa.md`, `templates/decision-record.md`, `procedure.md` § Autonomy contract and § Convergence, `briefs/verifier.md` § Diff mode |
| `maintain` | The project already has `docs/remediation/`: a change is about to land, or a periodic drift check is due | `modes/maintain.md`, `modes/review.md`, `modes/status.md`, `briefs/verifier.md`, `templates/agent-brief.md`, `templates/status.md`, `modes/decision-qa.md`, `sql/verify-permissions.sql`, `procedure.md` § Autonomy contract and § Convergence; for the drift check `modes/diagnose.md` § Delta mode and `briefs/phase-0-diagnosis.md`; to install a missing guard, the source brief its table names |
| `status` | Resume a session, or "where are we" | `modes/status.md`, `templates/status.md`, `briefs/verifier.md`, `modes/decision-qa.md`, `procedure.md` § Autonomy contract |

`triage` is not a diagnosis: it grep-measures, returns three findings, ticks nothing, and ends by offering `diagnose`.

No argument: if `docs/remediation/status.md` exists, read it and continue from the first step without an evidence line; otherwise `diagnose`.

## What a production-grade product is

Six conditions **this skill measures**, each measured, never asserted; one per area file, whose "Target state" section holds the full checklist. They are this skill's scope, not a complete quality model.

1. **Loads are shaped for real data.** No "load everything and filter in memory"; counts in the database; one read for what is on screen; cache only on the periphery, with tags and invalidation next to the write; every cap declared. (`areas/performance.md`)
2. **Green is calibrated against red.** Every test declares which world it runs against; every harness has failed once on purpose; every channel has been exercised live; static rules ship with their fixtures; the real production build is in the mandatory path. (`areas/quality.md`)
3. **Permissions are true on the database**, not in the repository; fail-fast configuration; migrations before the code that uses them; one database of truth; every defense fails closed. (`areas/data-security.md`)
4. **One path to do a thing.** Color by verb; filters that apply themselves; one view per list; read-only pages with mounted, hidden editors; irreversible actions physically isolated; feedback on every command; every exception has its reason written. (`areas/interface.md`)
5. **Users read what happened and what to do.** No technical error on screen; five distinct states; labels, hints, tooltips; worded outcomes; one name per concept. (`areas/user-communication.md`)
6. **Choices have a decision record** with the rejected alternatives; documentation is measured against the product; debt has a trigger; client questions live in one place. (`areas/method-documentation.md`)

Above all: **measure before asserting.** Every round starts from dated numbers and ends with the same numbers re-measured. An audit's value is the defects it finds, not the lines it saves.

## Non-negotiables

- The orchestrator never writes code. One agent, one area, explicit `model`. Agents receive only their brief and never spawn agents.
- Read-only rounds never repair. Proposals stay proposals until approved.
- Every reversible choice becomes a decision record through the Q&A protocol in `modes/decision-qa.md`.
- The verifier closes a phase, never the implementer. `docs/remediation/status.md` is the evidence ledger: a step without an evidence line is not done, and phase N+1 does not start while phase N has one. The plan question after Phase 0 is the only checkpoint that always fires. Every ask-first item (`procedure.md` § Autonomy contract) is a blocking checkpoint too, whenever the diagnosis finds one: expect one batched question per phase from Phase 2 on — unless a P1 blocks the phase midway — and one go-ahead per step in Phase 7.
- Every closed defect triggers a variant search. Every phase leaves a line in `lessons.md`.
- Never commit without a mandate. Never touch production. Never put secrets in reports.

Full contract: `procedure.md` § Autonomy contract.

## When not to use it

- Requirements still in flux: build first, harden later.
- A single bug or feature: `systematic-debugging` / `test-driven-development`.
- Code structure: broken layers, cross-module imports, clone clusters, files to split, a table shell or a field registry to build — the sibling skill's (intro above); the plan names its phases and the orchestrator switches skill for them.
- Platform and perimeter: TLS, WAF, DNS, network policy, hosting. The client's, named in the minutes.
- Identity infrastructure: OAuth/OIDC flows, credential storage, MFA, directory sync. How the product uses a session, yes; the provider, no.
- Repository and release governance: branch protection, code owners, commit signing, SLSA levels. Guards go into CI; who may push is policy.
- Running the product after handover: on-call, SLOs, error budgets, incident command. Runbooks and a drift check are left, not an operation.
- Memory safety, native code, binary deserialization, command execution: absent by construction on a managed runtime. A shell-out or native extension is a separate audit.
- It is not a mandate to rewrite. It is a mandate to make every claim about the product measurable: a permission verified on the database, a test that has been red, a channel seen arriving, a number with a date.

Status: Phase 0 is proven read-only on a second project; the repair phases and the verifier have never run live. Say so before the plan question, and record what surprised you in `lessons.md`.

## Excuses and reality

| Excuse | Reality |
|---|---|
| "Typecheck, lint and unit are green, that's enough" | Dev catches it only on the routes you open. Only the real build prerenders every route, so only it catches the one nobody visited. |
| "The test is green" | Green on the fake certifies the fake. Every test declares what it is tested against. |
| "The agent says it verified" | The implementer's report describes what it believes it did. The verifier decides. |
| "I'll add a cache with a TTL" | TTL-only turns a delay into stale data on screen. Tags plus invalidation next to the write, with an API callable from every path that reaches it, and a list of what is never cached. |
| "I'll disable the fields in read-only mode" | A `disabled` field is **absent from** `FormData`: a save that writes every submitted key reads it as cleared. Mounted and hidden. `[HTML § 4.10.22.4]` |
| "The revoke is in the migration" | Permissions are verified on the database: `revoke from public` does not remove the grants `anon` and `authenticated` hold; a function dropped and recreated, or recreated with a new signature, comes back with default privileges. `create or replace` of the same signature keeps the ACL `[PostgreSQL 12–18]`. |
| "Emails go out, so alerts work" | A channel nobody exercises is not proven by the channel next to it. |
| "I'll measure on the dev database" | The shape of a defect changes with the order of magnitude. Measure on real data, with the date. |
| "I remember, no need to grep" | On a repository with several sessions, "what is missing" is answered by grep. |
| "I'll update the number there too" | A number written in two places diverges. One place; the others link to it. |
| "The audit is clear, I'll apply it now" | An audit applied in the same round confuses measurement with repair. |
| "The user can see the error in the logs" | Users have no logs. On screen: what happened, what to do, an id for support. |
| "I'll skip the question, the answer is obvious" | Obvious choices are the ones nobody wrote down. Present the options, ask once, record the answer. |
| "The list is slow, I'll rebuild the table" | Rebuilding is the sibling skill's job. Here: the shape of the reads, the count in the database, the cap declared. |

## Red flags: stop and re-read

- A repair without a number before and after.
- A new test that has never been red.
- A `warn` that stays `warn`; a suppression without a reason next to it.
- An empty `catch {}` around a cache invalidation.
- A single outcome (`{ok:true}`) for different results.
- "Done" said without the command that proves it, or read through a pipe.
- Agents dispatched without `model`, or more than one area per agent.
- A database MCP or CLI used without checking which project it points to.
- A comment claiming "CI runs this" with no CI configuration in the repository.
- A verifier rejection dismissed without a ruling line.
- A repair agent that spawns agents, or that receives the session history.
- A guard that lets traffic through when it fails.
- A structural defect (a second writer on a table, a cross-module import, a clone cluster) repaired here "while we're at it" instead of being handed to the sibling skill.
- A phase started while the previous one has a step without evidence.

## Note on the stack

Names (`loading.tsx`, RLS, server action, `next build`, semgrep, `node --test`, Playwright) come from a Next.js 14 plus Postgres stack (README § Origin); Phase 0 re-verifies every named API against the installed major before a brief quotes it. Phase 0 produces `stack-map.md`, which translates every generic name into the host project's; every brief receives it as `<map>`. If the sibling skill has already produced a stack map (`docs/design/00-diagnosis/stack-map.md`), Phase 0 copies it and adds only what is missing.

Unless a line cites a standard, a specification or a vendor manual (`[HTML § …]`, `[PostgreSQL 12–18]`, `[ASVS 5.0 V…]`, `[WCAG 2.2 SC …]`, short form `[SC …]`), it is distilled from one project: a default to confirm against the host, not a law. It may be adopted; it may not be cited as evidence in a verifier report or a decision record. Where a control has no counterpart on the host stack (RLS on a database without it, a prerender gate with no build), the stack map says so in a fourth column, *absent here; replaced by*, naming the replacement or recording the step as dropped. "Not measured" is for a control that exists and could not be read, never for one that does not exist.

## File map

- `modes/`: one per mode — `triage.md`, `diagnose.md` (Phase 0 and the ordered plan), `decision-qa.md` (decision questions), `status.md` (the ledger, how to resume), `review.md`, `maintain.md` (guard set, change-time protocol, drift check).
- `procedure.md`: the cycle of a phase, the autonomy contract, artifacts, phases 1-7, re-diagnosis, convergence.
- `briefs/`: ready-to-fill briefs, one file per phase, plus `verifier.md`.
- `areas/`: one per area (quality, data and security, performance, interface, user communication, method and documentation): target state, what to measure, its briefs, rules with mechanical verification, traps.
- `templates/`: `agent-brief.md`, `decision-record.md`, `diagnosis-report.md`, `status.md`.
- `examples/`: `one-defect.md`, one worked defect.
- `sql/`: `verify-permissions.sql`, the permission queries.
- `GLOSSARY.md`: canonical terms with the Italian originals.
- `README.md`: repo-facing; no mode loads it.
