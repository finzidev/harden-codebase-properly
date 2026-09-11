# harden-codebase-properly

A skill for Claude Code (and agents compatible with the `SKILL.md` format) that takes an existing web app or back-office, measures it, repairs it, and brings it up to a defined, verifiable production bar on everything that is not code structure: quality gates and tests that tell the truth, database permissions and secrets, migrations and environments, fast database loads, interface behaviour, readable errors for the user, documentation that is measured, client handover. A systematic, eight-phase procedure run through subagents: the orchestrator reasons, dispatches, reads, decides, and verifies; it does not write code.

The structural half (layers with an enforced dependency rule, bounded contexts and domain events, one implementation per concept, deep modules, files split by invariant, dead code, the table shell and the field registry) lives in the sibling skill `design-software-properly`. The two skills share the same method (briefs, verifier, decision records, evidence ledger) and the same `docs/decisions/` register; this one writes `docs/remediation/`, the sibling writes `docs/design/`.

## Install

```bash
git clone https://github.com/finzidev/harden-codebase-properly.git ~/.claude/skills/harden-codebase-properly
```

Then, in a session open on the project you want to bring to production quality:

```
/harden-codebase-properly diagnose
```

Modes: `diagnose` (Phase 0 and the ordered plan; its plan question is the only mandatory user checkpoint of a remediation run), `plan`, `run <N>`, `review` (a diff against the target state), `maintain` (guard set, change-time protocol, drift check), `status` (resume). With no argument the skill reads `docs/remediation/status.md` and continues from the first step without evidence.

## Structure

| File | Role |
|---|---|
| `SKILL.md` | the router: modes, the six measurable conditions, non-negotiables, excuses and reality, red flags, file map |
| `modes/` | one file per mode: `diagnose` (Phase 0, the ordering rules, the plan question), `decision-qa` (notes reformulation, decision questions), `status` (the evidence ledger, how to resume), `review` (a diff against the target state), `maintain` (guard set, change-time protocol, drift check) |
| `procedure.md` | the per-phase cycle, the autonomy contract, artifacts in `docs/remediation/`, phases 1-7, re-diagnosis, convergence |
| `briefs/` | ready-to-fill briefs: six diagnosis agents (Phase 0), typed repairs for Phases 1-7 (gates, data and security, performance, interface, tests, documentation, handover), a two-stage verifier |
| `areas/` | for each area (quality, data and security, performance, interface, user communication, method and documentation): target state, what to measure, the briefs that repair it, rules with mechanical verification, known traps |
| `templates/` | agent brief, decision record, diagnosis report, status file |
| `GLOSSARY.md` | canonical terms used throughout the skill, with their Italian originals |

## Origin

Distilled from the path of a real back-office application (Next.js 14, Supabase, ~52k contacts, 426 commits, 104 decision records, June-September 2026) and from what is useful in public skills: two-stage verification, agent context isolation, a rejection cycle with a cap and written rulings, variant search, accumulating lessons. The names (`loading.tsx`, RLS, server action, `next build`, semgrep) come from that stack; Phase 0 produces the map that translates them into the host project. Until September 2026 this content and the structural half were one skill (`design-software-properly`, whose original Italian version is preserved at its git tag `v1-it`); they were split so that each could stay vertical.

## Status

Proven read-only (the stack-map brief of Phase 0) on a second Next.js project. The repair phases and the verifier have not yet been proven live: the first full run is also the skill's own acceptance test, and `docs/remediation/lessons.md` is where to note what needs fixing here.
