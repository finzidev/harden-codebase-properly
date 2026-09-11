# Phase 5 Brief: Tests That Tell the Truth

Common header: as in `phase-1-gates.md`. Reference: `areas/quality.md`.

Parallel: `R5.1` (one agent per test rig), `R5.2`, `R5.3`, `R5.4`, `R5.5` with each other. `R5.6` after all of them. `R5.7` plan now, execution after the go-ahead.

---

### R5.1 Canary on one test rig (one agent per rig)
`model: sonnet` · files: rig `<I>` (property-based model, probe, corpus, checklist) and its test
CONTEXT: `<I>` has been green since <date>; it has never produced a red.
GOAL: a declared way to break every invariant `<I>` watches over (a `CANARY=<n>` variable, or the host project's equivalent), documented at the top of the file; for every `n`, a red recorded with its date.
HOW: list the invariants; for each, baseline `cp` of the working-tree file (a 0-byte `.orig` for a non-empty file aborts the canary); the break in the product file, inside the function body; RED = `$?` non-zero and the assertion named; restore with `cp`, `git diff --stat` unchanged; after the last canary, re-run the unit gate.
DON'T: claim "it can turn red" without having actually seen it.
DONE: table invariant | break | red seen on <date>.

### R5.2 Warm-up before the e2e tests
`model: sonnet` · files: e2e config, `tests/e2e/_warmup.ts` (new — or the host project's equivalent)
CONTEXT: first on-demand compilation: <s> s versus <s> warm (from D1); reds that change from run to run: <yes/no>.
GOAL: a `globalSetup` that visits every route once before the tests, outside their own time budget.
DON'T: raise the tests' timeouts; "run against the build" if the env's guards prevent it.
TEST: two back-to-back runs of the suite: same outcomes.
DONE: list of routes warmed up; observed stability.

### R5.3 Acceptance checklist generated from the code
`model: sonnet` · files: `docs/acceptance/` (or equivalent): generator, checklist, scripts `check-coverage`, `check-stale-words`, `check-register` (or the host project's equivalent names)
CONTEXT: checklist today: <eyeballed / absent>; surface: <n> pages, <n> actions.
GOAL: checklist as a partition of the surface (pages, routes, actions) with a `covers` field; three lists (to review / to recheck / closed); scripts that exit 1 when: a surface item is uncovered, an entry covers a nonexistent surface item, an entry describes a gesture that no longer exists (a dictionary of stale words), or a phrase from the round is not found in the register; each entry carries the rule it satisfies in one line, sourced from the client's material, and an empty rule cell fails the coverage check.
TEST: canary: add a fake route, `check-coverage` exits 1.
DONE: scripts green; counts printed by the script, never written by hand.

### R5.4 Dirty fixture corpus with a manifest
`model: sonnet` · files: `scripts/generate-corpus.mjs` (new — or the host project's equivalent), `manifest.json` (or the host project's equivalent), the comparison test
CONTEXT: current corpus: <rows>, injected defects: <none>.
GOAL: a generator that injects the defects a real export always carries (out-of-vocabulary values, malformed formats, duplicates with different casing, empty fields where they shouldn't be) and writes how many of each category; a test that compares the observed counts against the manifest.
TEST: canary: remove a category from the manifest, the test turns red.
DONE: categories and counts; result of the first run.

### R5.5 Presumed guards: a test that invokes the action
`model: sonnet` · files: a test for every action whose guard has never been invoked by a test (from D1), the three spots where a rejection reads as a technical error
CONTEXT: actions with an untested guard: <list>; unreadable rejections: <file:line>.
GOAL: for every action, a test that calls it for real without permission and checks the rejection; the on-screen rejection is readable (a request for a password, not a stack trace); and for every action taking an identifier, a second test that calls it as a legitimate user of the **wrong object**; canary: remove the ownership predicate, the test turns red `[OWASP API1:2023]`.
TEST: canary: remove the guard, the test turns red.
DONE: table action | test | readable rejection.

### R5.6 Adversarial bug hunt, in rounds
`model: sonnet` for the hunters; a top-tier model ONLY for a referee, if needed · files: <the surfaces from D0's process list>
CONTEXT: the defect queue's unresolved P2s: <list>; environment: <url>, two accounts with distinct roles, write access to a test database; a lens with no environment reports "not measured", never "nothing found". Use the `bugtcher` skill if available. Otherwise: three sonnet hunters with different lenses (user flows, data and concurrency, security), a skeptic whose job is to tear down every finding, a referee who decides only after the reproduction has been **executed**.
GOAL: no finding without an executed artifact; keep going until two rounds in a row find nothing new, at most four rounds.
DON'T: fix anything during a hunt round; accept a finding by consensus.
DONE: `defect-register.md` updated with id, reproduction, status.

### R5.7 Live channel checks (plan now, run after the go-ahead)
`model: sonnet` · files: `<remediation>/05-tests/channels.md`, the fixes proposed by R2.6
CONTEXT: R2.6 plan; approved fixes: <list>.
GOAL: every channel seen arriving at least once with an injected failure, with the date and where the arrival was observed.
DONE: table channel | injected failure | arrived? | observed where | date.

### R5.8 Flow test for one process (one agent per process)
`model: sonnet` · files: `tests/flows/<process>.test.ts` (new — or the host project's equivalent), any scenario helpers
CONTEXT: process `<P>` from <map>: modules in order <list>, tables written <list>, external calls <list>, expected landing points <list: e.g. payment recorded, member area updated, ledger line, seat occupied>; blast radius from the coupling diagnosis of the sibling skill `design-software-properly` (D3) when it exists, otherwise from the processes in the stack map.
GOAL: one test that walks the whole chain from the initial command and asserts EVERY landing point (not just the command's own outcome); plus one test per step that can fail, with its expected compensation (payment rejected → seat released and status "cancelled"; late webhook → status "pending," no ledger line); plus the test "event or webhook delivered twice, one effect only." Declare "tested against: both" if two adapters exist, otherwise the intercepted real world.
DON'T: cover only the happy path; assert the implementation (which function was called) instead of the final state in the tables.
TEST: canary: remove one landing point in the code (e.g. the ledger line), the test turns red; deliver the webhook twice, the test turns red if the effect doubles.
DONE: table step | expected outcome | test; canary for every landing point.
