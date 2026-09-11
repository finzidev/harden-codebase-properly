## Audit-and-evolution round 01: the skill's own method, run against the skill

**Is this skill effective at hardening, today, as written? Not yet, and the reasons are specific.** The method is stronger than any standard it was checked against on the part no standard covers (the canary as an admission criterion, "tested against" per test, an evidence ledger that refuses prose, an exit code never read through a pipe, a verifier never told what to ignore, a capped rejection cycle ending in a written ruling). But as written at `c32367a`, a cold orchestrator following the text would run a permission check that reads the most permissive state as clean, run a canary that reverts the phase's own uncommitted repair and reports the restore as verified, dispatch Phase 0 in a way the text contradicts two lines later, accept a ledger line for a file that does not exist, dispatch three Phase 4 agents onto the same action files "in parallel on distinct files", and ship a product with no object-level authorization, no rollback and no supply-chain control. More than half of its normative lines are one project's habits in the same voice as a WCAG clause; nothing in the corpus verifies itself. This PR fixes what was false, makes the protocol that destroyed work safe, adds the four missing controls to the checklists that already own the subject, and labels the craft. What remains unproven is what was unproven before: a live run on a host project. The skill now says so before the plan question, not after.

Full summary: `audit/SUMMARY.md`. Evidence: `audit/01`–`06`, `audit/03-evidence.md` (321 traced claims), `audit/sources.md`. Verdict of the verifier: `audit/verification.md`. Decisions: `docs/decisions/001`–`009`. One line per change: `CHANGELOG.md`.

### Counts by severity

| pass | P1 | P2 | P3 |
|---|---|---|---|
| 01 integrity | 2 | 26 | 18 |
| 02 usability | 4 | 26 | 6 |
| 04 coverage | 6 (A6-01, 04, 05, 11, 14 + input) | 16 | 7 |
| 05 failure modes | 12 | 17 | 1 |
| 03 evidence (a/b/c) | 6 claims false or unsafe as written | ~20 overstated | — |

Load-bearing claims: 1 FALSE · 5 TRUE-WITH-CAVEAT · 1 VERSION-STALE · 1 COULD NOT VERIFY. Hypotheses: 6 CONFIRMED · 4 PARTIALLY CONFIRMED · 0 REFUTED. Evidence classes over 321 rows: S 13.7 % · P 15.6 % · V 15.0 % · M 4.4 % (all described, none shipped) · **C 51.4 %**.

### Deliberately not done

- The eighteen executable guards (`scripts/`, `rules/`, fixtures, `stack-map.json`): specified in `audit/specs/executable-assets.md`, not applied. Untested tooling contradicts the skill's own rule that a rig must have failed once before it counts; this run had no host project to fail it on (decision 002). Only `sql/verify-permissions.sql` ships, because it closes a P1.
- Splitting `procedure.md` § Phases per phase (about 1,200 tokens saved per `run`): structural; left as an issue (backlog X-05).
- Nothing in the sibling skill's territory. No phase added. A `triage` mode was added (decision 003).
- `disallowed-tools: Edit Write` on the frontmatter, though documented: the orchestrator writes `synthesis.md`, the ledger and decision records in person (backlog U-03).

### Corpus size against the +15 % budget

| | words |
|---|---|
| before, 28 files at `c32367a` | 28,768 |
| budget (+15 %) | 33,083 |
| after, 31 loadable files (28 + `modes/triage.md`, `examples/one-defect.md`, `sql/verify-permissions.sql`) | 33,699 (+17.1 %) |

Over by 616 words. Kept, per decision 009: the overage sits in the three files carrying the P1 repairs and the P1 coverage classes (`areas/data-security.md` +849, `briefs/verifier.md` +248, `modes/diagnose.md` +304); about 600 words of restatements were removed in exchange (named in the record). Per-mode loads rose more than the corpus did because hidden dependencies are now explicit in the Load cells; the record lists them and points at the next round's split of `procedure.md`.

### Verifier residuals

Round 1: RESIDUAL, 2 P1 (both in the new `modes/triage.md`: `rg -E` is `--encoding`, and `rg -Lc` counted the inverse), 4 P2, 14 P3. All 20 resolved by resuming the same patch authors with the rejections quoted verbatim. Round 2: 3 new P3 (a changelog heading name, a stale figure, one guard-row digit), all resolved. **Final verdict: CLOSED** (`audit/verification.md`, 218 lines, three passes). No residual carries a ruling because none remains.

### Placeholders as resolved

`<WORK>` = this clone · `<LANG>` = English (decision 001) · `<FORK>` = not needed: the session had push access to `finzidev/harden-codebase-properly`; the branch is pushed. The GitHub CLI was not authenticated, so the PR itself is opened by the maintainer from this description, and the two deferred issues are drafted in `audit/specs/issues-to-open.md`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01C8iHHzWGyGoSLx4H8zpE2o
