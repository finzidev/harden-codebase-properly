# Issues to open on the repository

The GitHub CLI was not authenticated in the session that produced this PR, so the two issues the backlog defers are drafted here, ready to paste. Each names the backlog row, the decision record and the specification behind it.

---

## Issue 1 — Ship the executable guards the skill describes (`scripts/`, `rules/`, fixtures, `stack-map.json`)

**Backlog:** U-12 (P1, effort L). **Decision:** `docs/decisions/002-ship-sql-verify-permissions-only.md`. **Specification:** `audit/specs/executable-assets.md`.

The skill demands eighteen mechanical artifacts (five static rules with fixtures, `tests-declared` with a frozen exemption list, the glossary check, routes ↔ skeletons, checklist coverage / stale words / register, guide coverage, debt markers ↔ register, duplicate numbers, "guaranteed by" links, the live-channel table, the canary driver, the permission SQL) and ships one: `sql/verify-permissions.sql`, added in this PR. Every other one is re-derived per project by a repair agent from one line of prose, at an estimated 495k tokens per full run, with a different guard each time (`audit/02-usability.md` § 4).

The specification gives, file by file: the injection hook (`stack-map.json`, one added line to D0), a shared contract (Node ≥ 18, ESM, zero dependencies, exit 0 / 1 / 2 so `maintain` can tell *failing* from *not installed*), five semgrep rules with `ruleid:`/`ok:` fixtures, sixteen scripts, the fixture self-test, and the rewritten R1.2 brief as a worked instance.

Why it was not applied in this round: untested tooling contradicts the skill's own rule that a rig must have failed once before it counts, and the round had no host project to fail it on. The right order is: build against the fixtures, run on the first live Phase 1, then commit.

Acceptance: `node scripts/selftest.mjs` exit 0 on every fixture pair; `modes/maintain.md` guard table's `Command` column points at the scripts; `briefs/phase-1-gates.md` R1.2 becomes "copy, configure, run".

---

## Issue 2 — Split `procedure.md` so section-level loads cost section-level tokens

**Backlog:** X-05 (P3, effort M). **Decision:** `docs/decisions/009-growth-budget-exceeded.md` (last paragraph of "Why").

`run <N>` loads all eight phase sections of `procedure.md` (about 1,150 words) to run one (73–238 words); `status`, `review` and `maintain` now name `procedure.md` § Autonomy contract and § Convergence in their Load cells, and a cold orchestrator reads the whole file to find a section. Per-mode loads measured by the verifier (`audit/verification.md` § 2): `status` 834 → 5,722 words, `maintain` 3,500 → 7,844, mostly this file.

Proposal: `procedure.md` keeps the cycle, the autonomy contract, convergence and the placeholders; the seven phase sections move next to their briefs (one heading block at the top of each `briefs/phase-N-*.md`, or a `procedure/phase-N.md` set), and the Load cells name the section files. No text changes; only placement.

Acceptance: every mode's Load cell names files whose total is within 10 % of the words that mode actually uses; all cross-references resolve; the integrity pass's § 2 and § 3 tables re-run with the new numbers.
