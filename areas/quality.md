# Quality: tests, gates, anti-regression

Principle: **do not trust an anti-regression rig until it has proven it can turn red.** A green that cannot fail is decoration. Every gate sees a different error class — the chain is not redundant.

## Target state

- [ ] One single verification script: typecheck && lint at zero **Error** `[Sadowski et al., CACM 2018]` && unit && **real production build**. Read the outcome from the exit code or a file, never from a pipe.
- [ ] Every unit test declares which world it runs against (`// tested against: fake | real adapter | both | none`); a mechanical check enforces it; the exemption list keeps shrinking.
- [ ] There is a way to test the **real** adapter without the network (by intercepting the transport), because the fake and the real one diverge.
- [ ] Custom static rules on domain invariants (a guard on every public action, no personal data in logs, no service key outside the data layer, no server directive inside the data layer), **each with its own fixtures** (`ruleid:` / `ok:`), run offline.
- [ ] Every guarded invariant has produced a **red** at least once (canary: a variable that breaks invariant *n*).
- [ ] One test file per domain invariant, named after the rule.
- [ ] End-to-end tests run only after a server **warm-up** (visiting every route outside the test budget); no "background" red e2e test — either fixed or `fixme` with a reason.
- [ ] An **acceptance checklist generated from the code surface** (pages, routes, actions), with automated checks: two-way coverage, entries describing gestures that no longer exist, phrases from a round found again in the register.
- [ ] A **dirty fixture corpus**, built on purpose, with a manifest declaring how many defects to expect per category.
- [ ] Every channel (email, alerts, backup, dead-letter, sync) **seen arriving** live at least once, with a date.
- [ ] Every safeguard has a test that actually **invokes** it (not a disabled button) and produces a readable rejection `[Yuan et al., OSDI 2014]`.
- [ ] Every "guaranteed by" reference points to an existing test file, verified mechanically.

## The gate chain

| Gate | Sees | Does NOT see |
|---|---|---|
| typecheck | type errors | style; runtime behavior; most non-serializable values crossing the server → client boundary (the Next.js TS plugin flags function props not named `action`/`*Action`) |
| lint at zero Error | rules the type checker cannot see; on Next.js ≤ 15 these also break `next build`, on 16+ lint is its own step in the verify script `[Next.js 16 upgrade guide]` | whatever the type checker already sees |
| unit | isolated pure logic | the fake/real difference, if it only runs against the fake |
| real build | **the only gate that prerenders every route without visiting it**: server to client serialization; interactions the dev server reports differently | business logic |
| custom static analysis with fixtures | the project's syntactic patterns | logic; must run offline |
| property-based models with a canary | sequences no one would write by hand | the real branch, if it only runs against the fake |
| e2e with warm-up | real flows across multiple browsers | whether a test has gone stale |
| manual acceptance testing from a generated checklist | what no machine can see: email that arrived, a backup that restored | "all green" only means "everything that could be checked from a screen" |
| mutation testing | how much the tests are **worth** | switched off if the machine cannot sustain it |
| adversarial bug-hunt rounds with mandatory reproduction | whatever survives the deterministic filters | nothing ships without an executed artifact |

Two rows are framework-specific (real build, e2e warm-up). On a stack with no build the chain loses a row; the stack map's *absent here; replaced by* column names what stands in, or the plan says the step is dropped.

## What to measure

1. Which scripts exist, and what they actually run (`npm test` can be e2e, not unit).
2. Which pass today; how many e2e tests are red, and for how many days; is there `mode: serial` on long files (the first red aborts the rest of the queue)?
3. How many custom static rules exist; how many have a fixture; how many suppressions have no stated reason.
4. How many tests declare their world; how many cross a point where fake and real diverge.
5. Is there a canary? Which "green" rigs have never produced a red (probes, seed corpus, checklists)?
6. Does the acceptance checklist cover the code surface? Who verifies that?
7. Does the test corpus carry the defects a real export always brings (out-of-vocabulary values, malformed formats, duplicates)?
8. For every channel: the date someone last saw it arrive.

## Repairs

The path is the briefs: `briefs/phase-1-gates.md` R1.1, R1.2–R1.4 (verify script, static rules with fixtures, stale e2e, tested-against); `briefs/phase-5-tests.md` R5.1–R5.8 (canary, warm-up, generated checklist, dirty corpus, presumed protections, bug hunt, live channels, flow tests). Diagnosis measures: D1.

## Rules with mechanical verification (specified here; `sql/` ships the queries, the brief builds the rest)

- Every test declares its world: enforced by a check in the unit suite.
- Every rig knows how to turn red: `CANARY=<n>` comes out red for every `n` `[Just et al., FSE 2014]`.
- Every static rule carries its own fixtures: `semgrep --test` (or equivalent).
- Releasable only with the verification script green start to finish, outcome read from `$?` (POSIX) or `$LASTEXITCODE` (PowerShell), immediately, or from a file.
- A/B comparisons, counter-tests and canaries on **one file**: baseline `cp <file> <scratch>/<name>.orig` (the working tree, never HEAD: repairs are uncommitted), and a 0-byte `.orig` for a non-empty file aborts the canary; the break goes in a **non-test file the repair changed**, inside the function body (a parse error is not a canary); RED = `$?` non-zero **and** the assertion named; restore with `cp`, then `git diff --stat` equals its pre-canary value; after the last canary, re-run the unit gate. Never `git stash` (the tree may be shared with another session), never `git checkout --` on the tree.
- Whoever changes visible behavior updates the test in the same commit: grep `tests/` for the disappearing string before committing.
- A stale test is fixed against the **property** ("the count next to each row tells the truth"), never against today's value.
- The guard covers one request; the round sits above it: tests that start from red.
- Every visible error path has a test on the displayed text (or the message class); a static rule bans `error.message`, stack traces, and digests from reaching the client (see `user-communication.md`).
- Every process that crosses more than one module has a flow test that walks the whole chain and asserts every landing point, plus one test per failing step; every webhook has the "twice, one effect" test (briefs R5.8 and R2.7).

## Error classes to catch

| Class | What stops it |
|---|---|
| A non-serializable value crossing server to client | dev, on the routes you open; the build, on every prerendered route |
| A blocking lint rule the type checker cannot see | lint at zero Error — its own verify step on Next.js 16+, which no longer lints in the build |
| A green test papering over the fake/real difference | "tested against" plus an intercepted real adapter |
| A guard sitting inside a loop | tests starting from red plus a contract on the ports |
| Comparing different shapes of the same data (re-read dates) | a test on both literal forms |
| A stale e2e test | grep for the disappearing string |
| An uncalibrated rig | canary |
| A corpus that is too clean | dirty corpus with a manifest (oracle) |
| An action with no guard; personal data in logs | static rule |
| An assumed safeguard | a test that actually invokes the action |
| A channel never exercised | nothing — until you test it live: this is a lesson, not a gate |

## Known traps

- **`build | tail`**: the exit status is `tail`'s, not the build's. On PowerShell the same pipe masks `$?` but not `$LASTEXITCODE` `[POSIX Issue 8 § 2.9.2]`.
- **`npm test` running e2e** in place of unit tests.
- **The dev server is a different build** (`.next/dev` vs `.next`): whatever shows red in dev is re-tested against build plus start.
- **Repeated `--mutate`**: do not assume repeated flags accumulate; pass one comma-separated list (verified against the installed Stryker); self-check modules that are unkillable by construction must be excluded.
- **A suppression with no stated reason**, or placed somewhere it does not actually suppress anything (JSDoc, a multi-line comment).
- **Inferring a channel's health** from the channel next to it.
- **A red left red** for days: it turns into background noise, and a real regression stops standing out.
- **"Run e2e against the build"** as a substitute for warm-up: env guards can reject test endpoints in a production build; warm-up remains the way.
