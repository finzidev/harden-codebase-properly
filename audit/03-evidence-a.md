# 03a — Evidence: quality + performance

Slice: `areas/quality.md` (88 lines), `areas/performance.md` (56 lines), plus the rows of
`SKILL.md` § *Excuses and reality* and § *Red flags* whose subject is tests, gates, builds,
static rules, caching or loads (marked `-S`, restatement), plus the four load-bearing lines of
`briefs/verifier.md`. Repo `C:\Users\Utente\Desktop\harden-codebase-properly`, branch
`evolve/audit-01`, commit `c32367a`. All source accesses: **2026-09-11**.
Full citations in `audit/sources-a.md`. Primary sources only; nothing cited from memory.

---

## Count by class

| class | count | % |
|---|---|---|
| **S** — Standard / spec, cited at clause level | 6 | 5.0 % |
| **P** — Published evidence (peer-reviewed / industrial-empirical) | 25 | 20.7 % |
| **V** — Vendor primary, with version range | 28 | 23.1 % |
| **M** — Mechanically self-verifying (a check the skill ships) | **0** | **0.0 %** |
| **C** — Craft, n=1 | 62 | 51.2 % |
| **Total** | **121** | 100 % |

**What that count implies, plainly:** *half of this slice is craft, n=1, and it is not labelled
as craft anywhere an agent will read it.* Sixty-two of 121 normative claims rest on one
back-office application — `README.md:35` names it (Next.js 14, Supabase, ~52k contacts, 426
commits, June–September 2026) — and `README.md` is **not loaded by any mode**: the `SKILL.md`
Modes table (`SKILL.md:16–23`) loads `modes/`, `briefs/`, `areas/` and `templates/`, never
`README.md`. So the one place the provenance is stated is the one place the working agent never
opens. The zero in the M row is the second half of the sentence: the skill describes ten
"rules with mechanical verification" in `quality.md:52–61` and seven in `performance.md:39–45`,
and ships **not one** of them — no `semgrep` rule file, no `tests-declared` test, no `verify`
script. Every one is *described, not shipped*. A quarter of the slice (V, 28 rows) is true only
of a pinned vendor version, and the pinned version the corpus assumes (Next.js 14) is two majors
behind the current release (16.3.4): three rows are outright version-stale today.

---

## Load-bearing claims d, e, f

### (d) "Only the real build prerenders and catches a non-serializable value crossing to the client"

**Where:** `SKILL.md:62` (Excuses table); `areas/quality.md:24` (typecheck row, "does NOT see …
non-serializable values crossing the server to client boundary"); `areas/quality.md:27` (real
build row, "**the only gate that prerenders**"); `areas/quality.md:67` (error class, "only the
build"); `GLOSSARY.md` § Quality — "**Real build** | The only gate that prerenders and catches
non-serializable values crossing the server → client boundary".

**Verdict: TRUE-WITH-CAVEAT** (and the *typecheck* half is **overstated**).

**Evidence.**

1. Serialization across the boundary is real and vendor-documented.
   Next.js 16.3.4, *The Server and Client Boundary*: "**Data** crosses through props, and it
   must be serializable, so functions like event handlers cannot cross." And: "Passing a
   function as a prop from a Server Component to a Client Component throws."
   *Server and Client Components*: "Props passed to Client Components need to be serializable
   by React."
2. `next build` does prerender the whole static surface without a visit.
   *next CLI* (16.3.4): "`next build` creates an optimized production build of your
   application" and its output legend reads "`○  (Static)   prerendered as static content`".
   `next dev` is described only as "starts the application in development mode with Hot Module
   Reloading" — it renders a route when you visit it, not the surface.
3. **Caveat 1 — dev catches it too, just not everywhere.** Nothing in the Next.js docs says the
   serialization throw is build-only. It is a render-time React error; `next dev` raises it on
   any route you actually open. What only `next build` gives is *coverage of every prerendered
   route without anyone visiting it*. That is the true and defensible claim; "only the build
   catches it" is not.
4. **Caveat 2 — typecheck is not blind to it.** *The Server and Client Boundary* (16.3.4): "The
   TypeScript plugin allows a Client Component prop typed as a function when its name is
   `action` or ends in `Action`. The plugin flags other function props." So with the Next.js TS
   plugin enabled, the type checker **does** catch the commonest non-serializable prop (a
   function). `areas/quality.md:24` and `:67` assert the opposite.
5. **Caveat 3 — the build is not a ceiling either.** *use cache* (16.3.4), on request-time APIs
   inside a cached scope: "On a dynamically rendered route this surfaces when the route runs, so
   it can pass `next build` and fail under `next start`." A green build is not proof.

**Version range:** the serialization rule holds for Next.js **13.4 – 16.x, App Router**
(unchanged across the range as far as the fetched 16.3.4 docs state). The TS-plugin function-prop
check is documented in 16.3.4; earlier behaviour not verified this session.

**Exact text change proposed.**

- `areas/quality.md:24` — replace `non-serializable values crossing the server to client boundary`
  with `most non-serializable values crossing the server to client boundary (the Next.js TS plugin does flag function props not named action/*Action)`.
- `areas/quality.md:27` — replace `**the only gate that prerenders**` with
  `**the only gate that prerenders every route without visiting it**`.
- `areas/quality.md:67` — replace `only the build` with `dev, on the routes you open; the build, on every prerendered route`.
- `SKILL.md:62` — replace `Only the real build prerenders and catches a non-serializable value crossing to the client.`
  with `Dev catches it only on the routes you open. Only the real build prerenders every route, so only it catches the one nobody visited.`
- `GLOSSARY.md` § Quality, **Real build** — same substitution as `quality.md:27`.

---

### (e) "`build | tail` returns tail's exit status, masking a broken build"

**Where:** `briefs/verifier.md:12` ("NEVER from a pipe (`| tail` returns tail's exit status, not
the command's)"); `briefs/verifier.md:44` ("`build | tail` hid a broken build for a day");
`areas/quality.md:7`, `:55`, `:81`; `SKILL.md:84`; `briefs/phase-1-gates.md:18`.

**Verdict: TRUE** on POSIX shells — **TRUE-WITH-CAVEAT on this host**, where the prescribed
remedy (`read the outcome from `$?``) is itself unsafe.

**Evidence.**

1. POSIX Base Specifications Issue 8 (IEEE Std 1003.1-2024), *Shell Command Language* § 2.9.2
   Pipelines, "Exit Status" table, row `pipefail` = no / begins with `!` = no:
   > "The exit status of the last (rightmost) command specified in the pipeline."

   And on `pipefail` (§ 2.13, `set -o`):
   > "Derive the exit status of a pipeline from the exit statuses of all of the commands in the pipeline, not just the last (rightmost) command"

   So `next build | tail` exits with `tail`'s status unless `pipefail` is on. The claim is
   exactly right. (`pipefail` is standardised only as of Issue 8, 2024; before that it was a
   bash/ksh/zsh extension — one more reason not to rely on it.)
2. **Windows/PowerShell caveat (this session's host is Windows 11, primary shell PowerShell).**
   Microsoft, *about_Automatic_Variables*, PowerShell 7.6:
   > "`$?` — Contains the execution status of the last command."
   > "`$LASTEXITCODE` — Contains the exit code of the last native program or PowerShell script that ran."

   In `npm run build | Tee-Object build.log`, the last command is the cmdlet, so `$?` reports the
   **cmdlet's** success — the mask the skill warns about still bites. But `$LASTEXITCODE` is not
   set by cmdlets, so it still holds `npm`'s code and *does* survive the pipe. The consequence:
   `briefs/verifier.md:12` and `areas/quality.md:55` prescribe `$?`, which is the *wrong*
   variable on PowerShell for a native command — and is wrong even without a pipe if any cmdlet
   runs in between. The skill has no stack-map entry for the shell.

**Exact text change proposed.**

- `briefs/verifier.md:12` — after `NEVER from a pipe (\`| tail\` returns tail's exit status, not the command's)`
  add `; on PowerShell read \`$LASTEXITCODE\` immediately after the native command, not \`$?\`, which a cmdlet in the pipeline overwrites`.
- `areas/quality.md:55` — replace `outcome read from \`$?\` or a file` with
  `outcome read from \`$?\` (POSIX) or \`$LASTEXITCODE\` (PowerShell), immediately, or from a file`.
- `areas/quality.md:81` — append `On PowerShell the same pipe masks \`$?\` but not \`$LASTEXITCODE\`.`
- `briefs/phase-0-diagnosis.md` / stack map: add a `shell` field so the map records which
  exit-status idiom the host uses. (Out of slice; noted, not tabled.)

---

### (f) "TTL-only caching turns a delay into stale data; tags plus co-located invalidation is the fix"

**Where:** `areas/performance.md:12` ("Cache only the **stable periphery**, with a short TTL
**and** tag invalidation co-located with the write inside the service (never in the action)");
`areas/performance.md:40`; `SKILL.md:31`, `SKILL.md:65`; `briefs/phase-3-performance.md:37`.

**Verdict: TRUE in substance, VERSION-STALE in API and in one prescription.**

**Evidence — the substance is right.**

1. RFC 9111 (IETF, June 2022, Standards Track) defines exactly the failure mode the skill names.
   "fresh": "A response whose age has not yet exceeded its freshness lifetime." "stale": "A
   response where [age] has exceeded its freshness lifetime." A TTL is a *promise about age*,
   not about correctness: the spec's only guard is § 4.2.4, "A cache MUST NOT generate a stale
   response unless it is disconnected or doing so is explicitly permitted by the client or
   origin server." Nothing in a TTL detects a write. § 4.4 *Invalidating Stored Responses* is
   the separate, write-triggered mechanism: "A cache MUST invalidate the target URI when it
   receives a non-error status code in response to an unsafe request method." TTL ≠
   invalidation; the skill's distinction is the spec's distinction.
2. The framework agrees. Next.js 16.3.4, *use cache* § Revalidation: "Cached functions revalidate
   based on the `revalidate` and `expire` times in their `cacheLife` profile, or on-demand
   through tags. **These two approaches are not mutually exclusive and are often paired.**"
   That is the skill's "short TTL **and** tag invalidation", verbatim in intent.
3. And the default TTL is long enough to make the point. *use cache*, `default` profile: "stale:
   5 minutes (client-side) · revalidate: 15 minutes (server-side) · **expire**: never expires by
   time." A TTL-only cache with the default profile shows a stale write for up to 15 minutes.

**Evidence — the API names are stale for the installed major.**

4. `unstable_cache` (the API `areas/performance.md` and the briefs assume) carries a banner in
   16.3.4: "**This API has been replaced by `use cache` in Next.js 16.** We recommend opting into
   Cache Components and replacing `unstable_cache` with the `use cache` directive." Its own
   version history lists only "`v14.0.0` `unstable_cache` introduced."
5. `revalidateTag` changed signature. *How to upgrade to version 16*: "`revalidateTag` now
   requires a second argument specifying a `cacheLife` profile. The single-argument form is
   deprecated and will produce a TypeScript error." Worse for a cache meant to be *correct*: the
   two-argument default is now stale-while-revalidate — "Calling `revalidateTag` marks the tagged
   data as stale. The next request … is served stale content while it runs". The skill's intent
   ("no stale data on screen") now requires `revalidateTag(tag, { expire: 0 })` or `updateTag`.
6. **The "never in the action, always in the service" rule collides with Next 16.**
   *updateTag* (16.3.4): "`updateTag` can **only** be called from within Server Actions. It
   cannot be used in Route Handlers, Client Components, or any other context." But
   `briefs/phase-3-performance.md:36` explicitly lists "different paths that call the same
   service: `<list: action, sync, import>`". A single invalidation call co-located in a service
   that is reached from a Route Handler (webhook / sync) **throws** if it uses `updateTag`. The
   only call that works from every path is `revalidateTag(tag, { expire: 0 })`.
   The architectural rule is sound; the API it implicitly assumes is not.

**Version range:** the skill's wording is correct for **Next.js 14.0 – 15.x, App Router**
(`unstable_cache` + single-argument `revalidateTag`). For **Next.js 16.0+** it is stale on all
three points above.

**Exact text change proposed.**

- `areas/performance.md:12` — append `; the invalidation call must be one that works from every path that reaches the service (in Next.js 16, \`revalidateTag(tag, { expire: 0 })\`, not \`updateTag\`, which throws outside a Server Action)`.
- `areas/performance.md:40` — append `; check the call, not only its location: a Server-Action-only API in a shared service is a latent throw on the webhook path`.
- `SKILL.md:65` — replace `Tags plus invalidation next to the write, and a list of what is never cached.`
  with `Tags plus invalidation next to the write — with an API callable from every path that reaches it — and a list of what is never cached.`
- `briefs/phase-3-performance.md:37` — add to GOAL: `verify the invalidation API against the installed major (R3.4 assumes \`unstable_cache\`/\`revalidateTag(tag)\`: Next.js 14–15 only)`.

---

## Traceability table

`class`: **S** standard · **P** published evidence · **V** vendor primary · **M** mechanically
self-verifying · **C** craft, n=1. `-S` suffix = restatement of the area claim of the same id.
"labelled?" for class C = does the skill mark the claim as n=1 **where an agent reads it**.

### `areas/quality.md`

| id | file:line | claim (verbatim, trimmed) | class | source | verification |
|---|---|---|---|---|---|
| Q-P1a | areas/quality.md:3 | "do not trust an anti-regression rig until it has proven it can turn red" | P | P1 Just et al., FSE 2014 | "The results show a statistically significant correlation between mutant detection and real fault detection, independently of code coverage." |
| Q-P1b | areas/quality.md:3 | "A green that cannot fail is decoration." | C (labelled? **no**) | — | rhetorical restatement of Q-P1a; no independent source |
| Q-P2 | areas/quality.md:3 | "Every gate sees a different error class — the chain is not redundant." | C (no) | — | could not verify: no source found that partitions gate coverage into disjoint error classes |
| Q-T1a | areas/quality.md:7 | "One single verification script: typecheck && lint at zero Error && unit && real production build" | C (no) | — (rationale for *zero Error* only: P4) | P4 Sadowski et al.: "enabled the new diagnostic as a compiler error (not a warning, which the Clang team found Google developers ignored)" — supports zero-Error, not the four-gate composition |
| Q-T1b | areas/quality.md:7 | "Read the outcome from the exit code or a file, never from a pipe." | S | S1 POSIX Issue 8 § 2.9.2 | "The exit status of the last (rightmost) command specified in the pipeline." |
| Q-T2 | areas/quality.md:8 | "Every unit test declares which world it runs against … a mechanical check enforces it" | C (no) | — | could not verify: no standard or study prescribes a per-test world declaration |
| Q-T3 | areas/quality.md:9 | "a way to test the **real** adapter without the network (by intercepting the transport)" | C (no) | — | could not verify |
| Q-T4 | areas/quality.md:10 | "Custom static rules … **each with its own fixtures** (`ruleid:` / `ok:`), run offline" | V | V10 Semgrep docs (current, 2026) | "`ruleid: <rule-id>` for protecting against false negatives / `ok: <rule-id>` for protecting against false positives" |
| Q-T5 | areas/quality.md:11 | "Every guarded invariant has produced a **red** at least once (canary…)" | P | P1 Just et al., FSE 2014 | "whether a test suite's ability to detect mutants is correlated with its ability to detect real faults that developers have fixed" |
| Q-T6 | areas/quality.md:12 | "One test file per domain invariant, named after the rule." | C (no) | — | could not verify |
| Q-T7a | areas/quality.md:13 | "End-to-end tests run only after a server **warm-up**" | V | V15 Playwright, `@playwright/test` 1.63.0 | "This function will be run once before running all tests." |
| Q-T7b | areas/quality.md:13 | "no 'background' red e2e test — either fixed or `fixme` with a reason" | P | P2 Luo et al., FSE 2014 | "if a flaky test fails frequently, developers tend to ignore its failures and, thus, could miss real bugs" |
| Q-T8 | areas/quality.md:14 | "An **acceptance checklist generated from the code surface** … with automated checks" | C (no) | — | could not verify |
| Q-T9 | areas/quality.md:15 | "A **dirty fixture corpus** … with a manifest declaring how many defects to expect" | C (no) | — | could not verify; the oracle idea is adjacent to metamorphic testing (Chen et al., CSUR 2018) — could not fetch |
| Q-T10 | areas/quality.md:16 | "Every channel … **seen arriving** live at least once, with a date." | P | P7 Basiri et al., IEEE Software 2016 | "Chaos Engineering is the discipline of experimenting on a distributed system in order to build confidence in its capability to withstand turbulent conditions in production" |
| Q-T11 | areas/quality.md:17 | "Every safeguard has a test that actually **invokes** it … and produces a readable rejection." | P | P3 Yuan et al., OSDI 2014, Finding 12 | "the incorrect error handling in these cases would be exposed by 100% statement coverage testing on the error handling logic" |
| Q-T12 | areas/quality.md:18 | "Every 'guaranteed by' reference points to an existing test file, verified mechanically." | C (no) | — | could not verify |
| Q-G1 | areas/quality.md:24 | typecheck "does NOT see … non-serializable values crossing the server to client boundary" | V | V2 Next.js 16.3.4 | **contradicted in part**: "The TypeScript plugin allows a Client Component prop typed as a function when its name is `action` or ends in `Action`. The plugin flags other function props." |
| Q-G2 | areas/quality.md:25 | "lint at zero Error | rules that would block the build on deploy" | V | V4 Next.js 16 upgrade guide | **version-stale**: "The `next lint` command has been removed. Use Biome or ESLint directly. `next build` no longer runs linting." |
| Q-G3 | areas/quality.md:26 | unit sees "isolated pure logic"; not "the fake/real difference, if it only runs against the fake" | C (no) | — | could not verify |
| Q-G4 | areas/quality.md:27 | real build "**the only gate that prerenders**: server to client serialization" | V | V1/V3 Next.js 16.3.4 | "○ (Static) prerendered as static content" (build output legend); `next dev` documented only as HMR dev mode — see claim (d) |
| Q-G5 | areas/quality.md:28 | custom static analysis "the project's syntactic patterns … must run offline" | V | V10 Semgrep docs | "The `--test` flag tells Semgrep to run tests in the specified directory." (offline: brief R1.2 bans `--config auto`) |
| Q-G6 | areas/quality.md:29 | property-based models "sequences no one would write by hand" | P | P6 Claessen & Hughes, ICFP 2000 | "Properties are described as Haskell functions, and can be automatically tested on random input" |
| Q-G7 | areas/quality.md:30 | e2e with warm-up: "real flows across multiple browsers"; blind to "whether a test has gone stale" | C (no) | — | could not verify |
| Q-G8 | areas/quality.md:31 | manual acceptance: "'all green' only means 'everything that could be checked from a screen'" | C (no) | — | could not verify |
| Q-G9 | areas/quality.md:32 | mutation testing sees "how much the tests are **worth**" | P | P1 Just et al. | "the mutation score, which measures a test suite's ability to distinguish a program under test, the original version, from many small syntactic variations" |
| Q-G10 | areas/quality.md:33 | adversarial bug-hunt: "nothing ships without an executed artifact" | C (no) | — | could not verify |
| Q-M1 | areas/quality.md:37 | "Which scripts exist, and what they actually run (`npm test` can be e2e, not unit)." | C (no) | — | could not verify |
| Q-M2 | areas/quality.md:38 | "is there `mode: serial` on long files (the first red aborts the rest of the queue)?" | V | V16 Playwright 1.63.0 | "If one of the serial tests fails, all subsequent tests are skipped. All tests in a group are retried together." |
| Q-M3 | areas/quality.md:39 | "how many have a fixture; how many suppressions have no stated reason" | P | P5 Bessey et al., CACM 2010 | "A misunderstood explanation means the error is ignored or, worse, transmuted into a false positive." |
| Q-M4 | areas/quality.md:40 | "How many tests declare their world; how many cross a point where fake and real diverge." | C (no) | — | could not verify |
| Q-M5 | areas/quality.md:41 | "Which 'green' rigs have never produced a red (probes, seed corpus, checklists)?" | P | P1 Just et al. | "there is little experimental evidence to support the use of mutants as a replacement for real faults" (the paper then supplies it) |
| Q-M6 | areas/quality.md:42 | "Does the acceptance checklist cover the code surface? Who verifies that?" | C (no) | — | could not verify |
| Q-M7 | areas/quality.md:43 | "Does the test corpus carry the defects a real export always brings…?" | C (no) | — | could not verify |
| Q-M8 | areas/quality.md:44 | "For every channel: the date someone last saw it arrive." | P | P7 Basiri et al. | "we also run Failure Injection Testing (FIT) exercises where we cause requests between Netflix services to fail and verify that the system degrades gracefully" |
| Q-R1 | areas/quality.md:52 | "Every test declares its world: enforced by a check in the unit suite." | C (no) | — | **described, not shipped**: no `tests-declared` check exists in the repo (prose only) |
| Q-R2 | areas/quality.md:53 | "Every rig knows how to turn red: `CANARY=<n>` comes out red for every `n`." | P | P1 Just et al. | as Q-T5. **Described, not shipped** — no canary harness in the repo |
| Q-R3 | areas/quality.md:54 | "Every static rule carries its own fixtures: `semgrep --test` (or equivalent)." | V | V10 Semgrep docs | "The `--test` flag tells Semgrep to run tests in the specified directory." **Described, not shipped** — no rule files, no fixtures |
| Q-R4 | areas/quality.md:55 | "outcome read from `$?` or a file" | S | S1 POSIX Issue 8 § 2.9.2; V19 PowerShell 7.6 | POSIX: "The exit status of the last (rightmost) command…"; PowerShell: "`$?` — Contains the execution status of the last command" — see claim (e), the `$?` prescription is unsafe on this host |
| Q-R5 | areas/quality.md:56 | "`git show HEAD:<file>` into a temp file, swap it in … restore, `cmp`. Never `git stash` on a tree shared with another session." | C (no) | — | **could not verify** (git-scm documentation not fetched this session) |
| Q-R6 | areas/quality.md:57 | "Whoever changes visible behavior updates the test in the same commit: grep `tests/` for the disappearing string" | C (no) | — | could not verify |
| Q-R7 | areas/quality.md:58 | "A stale test is fixed against the **property** … never against today's value." | C (no) | — | adjacent to P6 QuickCheck's property notion, but the *repair rule* itself could not be verified |
| Q-R8 | areas/quality.md:59 | "The guard covers one request; the round sits above it: tests that start from red." | C (no) | — | could not verify |
| Q-R9 | areas/quality.md:60 | "a static rule bans `error.message`, stack traces, and digests from reaching the client" | C (no) | — | mechanism verified (V10 Semgrep); the invariant's rationale lives in `user-communication.md`, out of slice |
| Q-R10 | areas/quality.md:61 | "every webhook has the 'twice, one effect' test" | C (no) | — | could not verify; idempotency is standard practice but no clause-level source was fetched |
| Q-E1 | areas/quality.md:67 | "A non-serializable value crossing server to client | only the build" | V | V2 Next.js 16.3.4 | **overstated** — see Q-G1 and claim (d): the TS plugin flags function props; dev throws on visited routes |
| Q-E2 | areas/quality.md:68 | "A blocking lint rule the type checker cannot see | lint at zero Error" | V | V4 Next.js 16 upgrade guide | **version-stale**: "`next build` no longer runs linting." |
| Q-E3 | areas/quality.md:69 | "A green test papering over the fake/real difference | 'tested against' plus an intercepted real adapter" | C (no) | — | could not verify |
| Q-E4 | areas/quality.md:70 | "A guard sitting inside a loop | tests starting from red plus a contract on the ports" | C (no) | — | could not verify |
| Q-E5 | areas/quality.md:71 | "Comparing different shapes of the same data (re-read dates) | a test on both literal forms" | C (no) | — | could not verify |
| Q-E6 | areas/quality.md:72 | "A stale e2e test | grep for the disappearing string" | C (no) | — | could not verify |
| Q-E7 | areas/quality.md:73 | "An uncalibrated rig | canary" | P | P1 Just et al. | as Q-T5 |
| Q-E8 | areas/quality.md:74 | "A corpus that is too clean | dirty corpus with a manifest (oracle)" | C (no) | — | could not verify (Chen et al. CSUR 2018 unfetchable) |
| Q-E9 | areas/quality.md:75 | "An action with no guard; personal data in logs | static rule" | V | V10 Semgrep docs | mechanism confirmed ("`ruleid:` … `ok:`"); the invariants themselves belong to `data-security.md`, out of slice |
| Q-E10 | areas/quality.md:76 | "An assumed safeguard | a test that actually invokes the action" | P | P3 Yuan et al., OSDI 2014 | "35% of the catastrophic failures are caused by trivial mistakes in error handling logic — ones that simply violate best programming practices" |
| Q-E11 | areas/quality.md:77 | "A channel never exercised | nothing — until you test it live: this is a lesson, not a gate" | P | P7 Basiri et al. | "we perform 'Chaos Kong' exercises that simulate the failure of an entire Amazon EC2 region" |
| Q-K1 | areas/quality.md:81 | "**`build | tail`**: the exit status is `tail`'s, not the build's." | S | S1 POSIX Issue 8 § 2.9.2 | "The exit status of the last (rightmost) command specified in the pipeline." |
| Q-K2 | areas/quality.md:82 | "**`npm test` running e2e** in place of unit tests." | C (no) | — | could not verify |
| Q-K3 | areas/quality.md:83 | "**The dev server lies** about some interactions: whatever shows red in dev gets re-tested against build plus start." | V | V3 Next.js 16.3.4 | supported obliquely: dev and build now even write to different directories — "Development builds output to `.next/dev` instead of `.next`"; no doc states dev *misreports* interactions |
| Q-K4 | areas/quality.md:84 | "**Repeated `--mutate`** does not accumulate: pass a comma-separated list" | V | V18 StrykerJS docs, `@stryker-mutator/core` 10.0.0 | partially: `mutate` is `string[]`, CLI examples show `--mutate "src/**/*.ts","!src/**/*.spec.ts"`; **could not verify** that a repeated flag overwrites rather than accumulates |
| Q-K5 | areas/quality.md:85 | "**A suppression with no stated reason**, or placed somewhere it does not actually suppress anything" | P | P5 Bessey et al., CACM 2010 | "a not-understood bug report is commonly labeled a false positive, rather than spurring the programmer to delve deeper" |
| Q-K6 | areas/quality.md:86 | "**Inferring a channel's health** from the channel next to it." | P | P7 Basiri et al. | "Chaos Engineering is the discipline of experimenting on a distributed system in order to build confidence in its capability to withstand turbulent conditions" |
| Q-K7 | areas/quality.md:87 | "**A red left red** for days: it turns into background noise, and a real regression stops standing out." | P | P2 Luo et al., FSE 2014 | "flaky tests may *hide* real bugs: if a flaky test fails frequently, developers tend to ignore its failures" |
| Q-K8 | areas/quality.md:88 | "**'Run e2e against the build'** as a substitute for warm-up: env guards can reject test endpoints" | C (no) | — | could not verify |

### `areas/performance.md`

| id | file:line | claim (verbatim, trimmed) | class | source | verification |
|---|---|---|---|---|---|
| F-P1 | areas/performance.md:3 | "slowness is almost always a shape problem, not a speed problem" | C (no) | — | could not verify: no study fetched quantifies "almost always" |
| F-P2 | areas/performance.md:3 | "Measure against real data, put the date next to every number" | C (no) | — | could not verify |
| F-P3 | areas/performance.md:3 | "verify the on-screen numbers match before and after" | C (no) | — | could not verify |
| F-T1 | areas/performance.md:7 | "No hot path loads a full table to filter it in memory; every occurrence of the `.all()` equivalent is justified." | C (no) | — | could not verify |
| F-T2 | areas/performance.md:8 | "Database-side pagination with an **exact** count, never estimated" | V | V14 PostgREST v12 | "To get the exact count, use `Prefer: count=exact`" — with the doc's own warning "the larger the table the slower this query runs" (see § wrong/overstated) |
| F-T3 | areas/performance.md:9 | "Counts and aggregations run in the database … never in memory after pulling down the join." | C (no) | — | could not verify |
| F-T4 | areas/performance.md:10 | "One read per thing being viewed: tabbed pages split into routes with their own reads." | C (no) | — | could not verify |
| F-T5 | areas/performance.md:11 | "Independent reads run in parallel; one `<Suspense>` per slow piece; a skeleton per route." | V | V9 Next.js 16.3.4 Caching | "wrap the component in `<Suspense>` and provide a fallback UI. The fallback ships with the prerendered shell while the async work runs at request time." |
| F-T6 | areas/performance.md:12 | "Cache only the **stable periphery**, with a short TTL **and** tag invalidation co-located with the write inside the service (never in the action)." | V | V6/V7/V8 Next.js 16.3.4 | substance confirmed ("These two approaches are not mutually exclusive and are often paired"); **version-stale** — `updateTag` "can **only** be called from within Server Actions" — see claim (f) |
| F-T7 | areas/performance.md:13 | "An explicit list of what **never enters cache**: consents and deletions, locks and revocations, counts that precede an irreversible action…" | C (no) | — | RFC 9111 states only that a cache "MUST NOT generate a stale response unless … explicitly permitted"; **could not verify** the specific never-cache list |
| F-T8 | areas/performance.md:14 | "Search and sort normalized on a **generated, indexed column**, never on a runtime expression; empty strings become real `NULL`s." | V | V11/V12/V13 PostgreSQL 17 | "A generated column is a special column that is always computed from other columns"; but "An index column need not be just a column … but can be a function or scalar expression" — "never" is overstated (see § wrong/overstated) |
| F-T9 | areas/performance.md:15 | "Every cap declares `truncated`, and the screen says so." | C (no) | — | could not verify |
| F-T10 | areas/performance.md:16 | "A round of paginated requests sits **above** the timeout guard (a per-request window, a batched parallel round…)" | C (no) | — | could not verify |
| F-T11 | areas/performance.md:17 | "Every volume number carries the date it was measured." | C (no) | — | could not verify |
| F-T12 | areas/performance.md:18 | "Framework configuration proposals are verified against the **installed** package, not against the latest version's documentation." | V | V4/V5 Next.js 16 upgrade guide | demonstrated by this audit: "`unstable_cache` … has been replaced by `use cache` in Next.js 16"; "`revalidateTag` now requires a second argument" |
| F-M1 | areas/performance.md:22 | "**Baseline on real data** … A dev sample lies — the shape of the defect changes with order of magnitude." | C (no) | — | could not verify |
| F-M2 | areas/performance.md:23 | "**Full-scan inventory**: `grep -rn \"\\.all()\" src/features`" | C (no) | — | could not verify |
| F-M3 | areas/performance.md:24 | "**Reads per page**: count adapter calls needed to open every hot page" | C (no) | — | could not verify |
| F-M4 | areas/performance.md:25 | "**In-memory counts**: search for `length`, `reduce`, `filter(...).length` on read results" | C (no) | — | could not verify |
| F-M5 | areas/performance.md:26 | "**Cache**: does one exist? with tags? who invalidates it, and where (service or action)?" | V | V6/V9 Next.js 16.3.4 | "`revalidateTag` can be called in Server Functions and Route Handlers" — the where-question is real and version-sensitive |
| F-M6 | areas/performance.md:27 | "**Timeout**: is there a request loop running inside a guard meant for a single request?" | C (no) | — | could not verify |
| F-M7 | areas/performance.md:28 | "**Hot columns with no index**; searches using `unaccent(`, `lower(`, `nullif(` inside `.order(` or `.eq(`" | V | V12 PostgreSQL 17; V14 PostgREST v12 | "Index expressions are relatively expensive to maintain, because the derived expression(s) must be computed for each row insertion and non-HOT update." |
| F-M8 | areas/performance.md:29 | "**Caps**: `grep -rnE \"limit: [0-9]{3,}\"` in bulk actions; does every occurrence declare truncation?" | C (no) | — | could not verify |
| F-M9 | areas/performance.md:31 | "no external profiler is needed … run the query in both forms for five rounds and take the median" | C (no) | — | could not verify: the choice of five rounds and the median is unsourced |
| F-R1 | areas/performance.md:39 | "Never `.all()` plus an in-memory filter on a hot path: grep for it, every occurrence justified." | C (no) | — | **described, not shipped**: no grep script in the repo |
| F-R2 | areas/performance.md:40 | "Every cache invalidates next to the write inside the service: cross-check declared tags against invalidations in the same file; a two-path test." | V | V7 Next.js 16.3.4 updateTag | "`updateTag` can **only** be called from within Server Actions. It cannot be used in Route Handlers" — the two-path test is exactly what would catch this. **Described, not shipped** |
| F-R3 | areas/performance.md:41 | "Never an empty `catch {}` around an invalidation: swallow exactly one recognized condition … rethrow everything else." | P | P3 Yuan et al., OSDI 2014 | "25% of the catastrophic failures were caused by ignoring explicit errors (an error handler that only logs the error is also considered as ignoring the error)" |
| F-R4 | areas/performance.md:42 | "Normalizations run on a generated column: grep for SQL functions inside `.order(` / `.eq(` returns empty." | V | V11/V12 PostgreSQL 17 | "PostgreSQL currently implements only stored generated columns." **Described, not shipped** |
| F-R5 | areas/performance.md:43 | "Every fixed bulk `limit` declares `truncated`." | C (no) | — | could not verify. **Described, not shipped** |
| F-R6 | areas/performance.md:44 | "Every paginated loop goes through a batched-round helper above the guard, never a `while` inside the timeout window." | C (no) | — | could not verify. **Described, not shipped** |
| F-R7 | areas/performance.md:45 | "A configuration proposal is verified inside `node_modules`, and the default found there is written as a comment next to the line **not** added." | C (no) | — | could not verify. **Described, not shipped** |
| F-K1 | areas/performance.md:49 | "**Advice from the latest version's docs** applied to an older one … sounds measured, cites a precise default, and is wrong" | V | V4 Next.js 16 upgrade guide | "The default value for `images.minimumCacheTTL` has changed from `60 seconds` to `4 hours`" — a precise default that flipped between majors |
| F-K2 | areas/performance.md:50 | "**A broad `catch {}` around an invalidation**: passes the tests, silently kills the update in production." | P | P3 Yuan et al., OSDI 2014 | "Ignoring errors and allowing them to propagate is known to be bad programming practice, yet we observed this lead to many catastrophic failures." |
| F-K3 | areas/performance.md:51 | "**Caching decision-critical data** that 'looks peripheral.'" | S | S2 RFC 9111 § 4.2.4 | "A cache MUST NOT generate a stale response unless it is disconnected or doing so is explicitly permitted by the client or origin server." |
| F-K4 | areas/performance.md:52 | "**A timeout guard wrapped around the whole round**: looks like a flaky network, is actually deterministic and tied to data growth." | C (no) | — | could not verify |
| F-K5 | areas/performance.md:53 | "**An estimate instead of a count**, 'close enough anyway': measure the real difference … before sacrificing correctness." | V | V14 PostgREST v12 | planned count accuracy "depends on how current the PostgreSQL statistics are, recommending running `ANALYZE`" |
| F-K6 | areas/performance.md:54 | "**A volume number with no date**: true only on the day it was written." | C (no) | — | could not verify |
| F-K7 | areas/performance.md:55 | "**`NOT NULL` with an empty string** instead of `NULL`: sorting 'works by coincidence' in one direction only." | V | V13 PostgreSQL 17 | "By default, null values sort as if larger than any non-null value; that is, `NULLS FIRST` is the default for `DESC` order, and `NULLS LAST` otherwise." |
| F-K8 | areas/performance.md:56 | "**Eagerly loading everything that might be needed** on a tabbed page: you always pay for it, and only one tab ever gets looked at." | C (no) | — | could not verify |

### `SKILL.md` restatements (`-S`)

| id | file:line | claim (verbatim, trimmed) | class | source | verification |
|---|---|---|---|---|---|
| Q-P2-S | SKILL.md:32 | "every harness has failed once on purpose; … static rules ship with their fixtures; the real production build is in the mandatory path" | P | P1 Just et al. | restates Q-T5/Q-T4/Q-T1a; "statistically significant correlation between mutant detection and real fault detection" |
| F-T1-S | SKILL.md:31 | "No 'load everything and filter in memory'; counts in the database; one read for what is on screen; cache only on the periphery, with tags" | C (no) | — | restates F-T1/F-T3/F-T4/F-T6; could not verify |
| Q-G4-S | SKILL.md:62 | "Only the real build prerenders and catches a non-serializable value crossing to the client." | V | V1/V2/V3 Next.js 16.3.4 | restates Q-G4/Q-E1 — **overstated**, see claim (d) |
| Q-T2-S | SKILL.md:63 | "Green on the fake certifies the fake. Every test declares what it is tested against." | C (no) | — | restates Q-T2; could not verify |
| F-T6-S | SKILL.md:65 | "TTL-only turns a delay into stale data on screen. Tags plus invalidation next to the write…" | V | V6/V8/V9 Next.js 16.3.4; S2 RFC 9111 | restates F-T6 — "These two approaches are not mutually exclusive and are often paired" — **version-stale**, see claim (f) |
| Q-K6-S | SKILL.md:68 | "A channel nobody exercises is not proven by the channel next to it." | P | P7 Basiri et al. | restates Q-K6 |
| F-M1-S | SKILL.md:69 | "The shape of a defect changes with the order of magnitude. Measure on real data, with the date." | C (no) | — | restates F-M1; could not verify |
| F-T2-S | SKILL.md:75 | "Here: the shape of the reads, the count in the database, the cap declared." | C (no) | — | restates F-T1/F-T2/F-T9; could not verify |
| F-P2-S | SKILL.md:79 | "A repair without a number before and after." | C (no) | — | restates F-P2/F-P3; could not verify |
| Q-T5-S | SKILL.md:80 | "A new test that has never been red." | P | P1 Just et al. | restates Q-T5 |
| Q-K5-S | SKILL.md:81 | "A `warn` that stays `warn`; a suppression without a reason next to it." | P | P4 Sadowski et al., CACM 2018 | "the Clang team enabled the new diagnostic as a compiler error (not a warning, which the Clang team found Google developers ignored) to break the build" |
| F-R3-S | SKILL.md:82 | "An empty `catch {}` around a cache invalidation." | P | P3 Yuan et al., OSDI 2014 | "25% of the catastrophic failures were caused by ignoring explicit errors" |
| Q-T1b-S | SKILL.md:84 | "'Done' said without the command that proves it, or read through a pipe." | S | S1 POSIX Issue 8 § 2.9.2 | "The exit status of the last (rightmost) command specified in the pipeline." |
| Q-M1-S | SKILL.md:87 | "A comment claiming 'CI runs this' with no CI configuration in the repository." | C (no) | — | restates Q-M1; could not verify |

### `briefs/verifier.md`

| id | file:line | claim (verbatim, trimmed) | class | source | verification |
|---|---|---|---|---|---|
| V-e1 | briefs/verifier.md:12 | "NEVER from a pipe (`| tail` returns tail's exit status, not the command's)" | S | S1 POSIX Issue 8 § 2.9.2; V19 PowerShell 7.6 | "The exit status of the last (rightmost) command specified in the pipeline." Host caveat in claim (e) |
| V-e2 | briefs/verifier.md:16 | "search the log for 'Error', 'not serializable', 'Only async functions'" | V | V1/V2 Next.js 16.3.4 | **could not verify** the literal strings: no Next.js 16.3.4 page fetched emits "not serializable" or "Only async functions" verbatim; the boundary rule is stated as "it must be serializable" |
| V-e3 | briefs/verifier.md:45 | "A new test that has never been red proves nothing: the canary is the part you don't skip." | P | P1 Just et al. | as Q-T5 |
| V-e4 | briefs/verifier.md:44 | "`build | tail` hid a broken build for a day." | C (labelled? **yes**) | — | self-labelled anecdote: the § heading is "Why this way" and the sentence is a dated past incident |

---

## Claims that are wrong or overstated

| id | severity | why | evidence | proposed minimal text change |
|---|---|---|---|---|
| Q-G2, Q-E2 | **P1** | The skill instructs something false for the installed major: it tells the agent that lint Errors are "rules that would block the build on deploy". In Next.js 16 lint does not run in the build at all, so a project that follows this row can ship with lint Errors and still see a green build — the exact failure the skill exists to prevent. | V4 Next.js 16 upgrade guide: "The `next lint` command has been removed. Use Biome or ESLint directly. **`next build` no longer runs linting.**" True only for Next.js 13–15. | `quality.md:25` → `lint at zero Error \| rules the type checker cannot see; on Next.js ≤15 these also break \`next build\`, on Next.js 16+ lint must be a separate step in the verify script`. `quality.md:68` → same qualification. |
| F-T6, F-R2, F-T6-S | **P1** | The skill instructs that the invalidation live "inside the service" shared by action, sync and import paths (`briefs/phase-3-performance.md:36`). Under Next.js 16 the natural API for immediate invalidation, `updateTag`, throws outside a Server Action — so following the rule literally produces a runtime error on the webhook path, in production, on the write path. | V7 Next.js 16.3.4: "`updateTag` can **only** be called from within Server Actions. It cannot be used in Route Handlers, Client Components, or any other context." | See claim (f) § Exact text change proposed. |
| Q-G1, Q-E1, Q-G4-S, `GLOSSARY.md` | **P2** | Overstated three ways: (a) the type checker is not blind to non-serializable props — the Next.js TS plugin flags function props; (b) `next dev` also throws on a visited route; (c) `next build` is not a ceiling — a cached scope reading request APIs "can pass `next build` and fail under `next start`". The true claim is about *route coverage without a visit*, not about being the only detector. | V2 Next.js 16.3.4: "The plugin flags other function props." V8: "it can pass `next build` and fail under `next start`." | See claim (d) § Exact text change proposed. |
| F-T8, F-R4 | **P2** | "**never** on a runtime expression" is false as a SQL claim: PostgreSQL indexes expressions. The real constraint is client-side — a PostgREST/Supabase `.order()`/`.eq()` cannot reliably emit the exact expression the index was built on — but the skill states the general form, which will read as wrong to anyone who knows Postgres and will get the rule argued away. | V12 PostgreSQL 17: "An index column need not be just a column of the underlying table, but can be a function or scalar expression computed from one or more columns"; the trade-off is "Index expressions are relatively expensive to maintain". | `performance.md:14` → `…on a **generated, indexed column**, never on a runtime expression built in application code (an expression index exists in Postgres but the client cannot be trusted to emit the matching expression)`. |
| F-T2 | **P2** | "an **exact** count, never estimated" is stated as absolute, but the vendor documents the cost and offers a designed middle (`count=estimated`) that is exact below a threshold. The skill's own trap F-K5 says "measure the real difference … before sacrificing correctness" — which concedes a trade-off the target-state line denies. | V14 PostgREST v12: exact count "guarantees accuracy by performing a full table scan", and "the larger the table the slower this query runs in the database"; `count=estimated` gets "the exact count up until a threshold and … the planned count when that threshold is surpassed". | `performance.md:8` → `…with an **exact** count wherever a number is shown to a user or gates an action; an estimate only where no one reads it as truth. Never estimated for a number that must match elsewhere.` |
| Q-R4, V-e1, Q-T1b-S | **P2** | The remedy is shell-specific and the skill never says which shell. On PowerShell — the primary shell of the host this audit ran on — `$?` after `native \| cmdlet` reports the *cmdlet's* status, so the prescribed fix reproduces the very bug it fixes. `$LASTEXITCODE` is the correct variable there. | V19 PowerShell 7.6: "`$?` — Contains the execution status of the last command"; "`$LASTEXITCODE` — Contains the exit code of the last native program or PowerShell script that ran." | See claim (e) § Exact text change proposed. |
| F-T12 vs. the corpus itself | **P2** | `performance.md:18` tells the agent to verify configuration against the *installed* package, while the corpus's own Next.js API vocabulary (`unstable_cache`, single-argument `revalidateTag`) is pinned to the 2026 origin project's Next.js 14 and is stale for 16. The rule is right; the file does not obey it. | V5 Next.js 16.3.4: "This API has been replaced by `use cache` in Next.js 16." V4: "`revalidateTag` now requires a second argument." | Add one line to `SKILL.md:96` (§ Note on the stack): `The API names in this skill were written against Next.js 14 (see README § Origin). Phase 0 must re-verify every named API against the installed major before any brief quotes it.` |
| Q-K4 | **P2** | Ambiguous and unverified: "Repeated `--mutate` does not accumulate" states a behaviour the StrykerJS docs do not document either way, and the tool version is not named. | V18 StrykerJS (`@stryker-mutator/core` 10.0.0): `mutate` is `string[]` with glob patterns and comma-separated CLI examples; nothing about repeated-flag semantics. **Could not verify.** | `quality.md:84` → `**Repeated \`--mutate\`**: do not assume repeated flags accumulate — pass one comma-separated list (verified against the installed Stryker version)`. |
| V-e2 | **P2** | The verifier is told to grep the build log for three literal strings; none was confirmed in the current Next.js docs, so a verifier that finds none of them may report a clean build it never checked. | No Next.js 16.3.4 page fetched contains "not serializable" or "Only async functions". **Could not verify.** | `briefs/verifier.md:16` → `search the log for \`Error\`, \`Failed to compile\`, and the serialization / async-boundary messages the installed Next.js version actually emits (confirm them once, record them in the stack map)`. |
| Q-K3 | **P2** | "The dev server **lies** about some interactions" is unsourced as stated. What is documented is weaker and different: dev and build are now separate builds writing to separate directories. | V3 Next.js 16.3.4: "Development builds output to `.next/dev` instead of `.next`." Nothing documents misreporting. | `quality.md:83` → `**The dev server is a different build** (`.next/dev` vs `.next`, different bundler defaults): whatever shows red in dev gets re-tested against build plus start.` |

---

## Class-C items not labelled as craft

All 62 class-C rows except one (`V-e4`, which self-labels as a dated incident under
`briefs/verifier.md` § "Why this way") carry **no craft marker at the point of use**. In the two
area files the count is **55 of 55** unlabelled:

`Q-P1b, Q-P2, Q-T1a, Q-T2, Q-T3, Q-T6, Q-T8, Q-T9, Q-T12, Q-G3, Q-G7, Q-G8, Q-G10, Q-M1, Q-M4,
Q-M6, Q-M7, Q-R1, Q-R5, Q-R6, Q-R7, Q-R8, Q-R9, Q-R10, Q-E3, Q-E4, Q-E5, Q-E6, Q-E8, Q-K2, Q-K8,
F-P1, F-P2, F-P3, F-T1, F-T3, F-T4, F-T7, F-T9, F-T10, F-T11, F-M1, F-M2, F-M3, F-M4, F-M6, F-M8,
F-M9, F-R1, F-R5, F-R6, F-R7, F-K4, F-K6, F-K8`

plus the six unlabelled `-S` restatements in `SKILL.md`:
`F-T1-S, Q-T2-S, F-M1-S, F-T2-S, F-P2-S, Q-M1-S`.

`README.md:35` does state the n=1 provenance ("Distilled from the path of a real back-office
application (Next.js 14, Supabase, ~52k contacts, 426 commits … June-September 2026)") and
`README.md:39` states the skill is unproven live — but `README.md` appears in **no** row of the
`SKILL.md` Modes table (`SKILL.md:16–23`), so no agent executing a phase ever reads it.

**Proposed labelling mechanism, one line:** put a trailing evidence marker on every normative
line — `· [n=1]` for craft, `· [std]`, `· [pub]`, `· [vendor:<pkg>@<range>]` otherwise — and add
one sentence to `SKILL.md` § Non-negotiables: *"A line marked `[n=1]` is one project's experience:
it may be adopted, but it may not be cited as evidence in a verifier report or a decision record."*

---

## Better sources found (not in the candidate list)

1. **The Open Group Base Specifications Issue 8, IEEE Std 1003.1-2024 — *Shell Command Language*,
   § 2.9.2 Pipelines.** Better than the bash manual for claim (e) because Issue 8 (2024) is the
   first edition to **standardise `pipefail`** and to give the exit status as a four-row table
   over (pipefail × leading `!`). It settles the claim at clause level for every POSIX shell,
   not just bash. https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html
2. **Microsoft, *about_Automatic_Variables*, PowerShell 7.6 (2026-04-02).** Not in the candidate
   list and load-bearing: it shows the skill's remedy for (e) is shell-specific and wrong on the
   host OS. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables
3. **Next.js *How to upgrade to version 16*** — the single highest-yield page for this slice: it
   alone kills two P1s (`next lint` removed / build no longer lints; `revalidateTag` signature
   change) and proves the skill's own trap F-K1 against the skill.
   https://nextjs.org/docs/app/guides/upgrading/version-16
4. **Next.js *updateTag*** — establishes the Server-Action-only constraint that collides with the
   "invalidate inside the service" rule. https://nextjs.org/docs/app/api-reference/functions/updateTag
5. **PostgreSQL 17 § 11.7 *Indexes on Expressions*** — the counter-source for F-T8's "never":
   Postgres does index expressions; the skill's rule needs the client-side reason, not a blanket ban.
   https://www.postgresql.org/docs/17/indexes-expressional.html
6. **PostgREST v12 *Pagination and Count*** — gives the three-way `exact / planned / estimated`
   vocabulary the skill's F-T2 and F-K5 are groping for, with the vendor's own cost warning.
   https://postgrest.org/en/v12/references/api/pagination_count.html
7. **Yuan et al., OSDI 2014, § 4.1 and Finding 12** — stronger than the abstract for this slice:
   Finding 12 ("the incorrect error handling in these cases would be exposed by 100% statement
   coverage testing on the error handling logic") is the direct empirical warrant for Q-T11
   ("a test that actually **invokes** it"), a claim the skill currently supports with nothing.
8. **Sadowski et al., CACM 2018, § "Make It a Compiler Workflow"** — the sentence "enabled the new
   diagnostic as a compiler error (not a warning, which the Clang team found Google developers
   ignored) to break the build" is the single best industrial warrant for "lint at zero **Error**"
   and for the red flag "a `warn` that stays `warn`". Neither is cited in the skill.

---

## Could not verify

| source | what it was needed for | why |
|---|---|---|
| **ISO/IEC 25010:2023**, *Systems and software engineering — SQuaRE — Product quality model*, 2nd ed. | testing whether `SKILL.md:31–36` "six conditions" form a coherent partition | iso.org returns HTTP 403 (Cloudflare challenge) to both WebFetch and curl; the ISO OBP viewer is JS-only; IEC webstore has no matching record. No primary text obtained. See the paragraph below, written without it. |
| **Papadakis, Kintis, Zhang, Jia, Le Traon, Harman**, *Mutation Testing Advances: An Analysis and Survey*, Advances in Computers 112:275–378, 2019 (DOI 10.1016/bs.adcom.2018.03.015) | second pillar of the canary doctrine (Q-P1a, Q-T5, Q-R2, Q-E7) | ScienceDirect 403; UCL Discovery and ORBilu candidate PDF URLs 404. The canary rows rest on Just et al. alone. |
| **Chen, Kuo, Liu, Poon, Towey, Tse, Zhou**, *Metamorphic Testing: A Review of Challenges and Opportunities*, ACM CSUR 51(1), 2018 | Q-T9 / Q-E8 (dirty corpus with a manifest as an oracle) | ACM DL 403; repository PDF 404. Both rows remain class C. |
| **git-scm documentation** (`git show`, `git stash`, `cmp`) | Q-R5 (the A/B counter-test protocol) | not fetched this session. Row remains class C, unverified. |
| **StrykerJS repeated-`--mutate` semantics** | Q-K4 | the Configuration page documents `mutate` as `string[]` with comma-separated CLI examples but says nothing about whether a repeated flag accumulates or overwrites. |
| **Next.js literal build-log strings** "not serializable", "Only async functions" | V-e2 | absent from every Next.js 16.3.4 page fetched. |
| **Playwright docs version stamp** | Q-T7a, Q-T7b, Q-M2 | playwright.dev serves unversioned pages. Pinned instead to the current release line via the npm registry: `@playwright/test` **1.63.0** (accessed 2026-09-11). |
| **CACM canonical HTML** (cacm.acm.org) for P4 and P5 | Sadowski 2018, Bessey 2010 | 403. Both verified instead from publisher-hosted (`storage.googleapis.com/gweb-research2023-media`) and author (`web.stanford.edu/~engler`) PDFs of the same articles, each carrying the CACM masthead, volume/issue and DOI. |

### On ISO/IEC 25010 and the "six conditions" (written without the standard — treat as unverified)

The ISO clause text could not be fetched, so the comparison the brief asked for cannot be made
against a primary source, and I will not make it from memory. What can be said from the corpus
alone: `SKILL.md:31–36` is **not a partition**, it is an ad-hoc list, and its own wording shows
why. Conditions 1, 3, 4 and 5 name properties *of the product* (load shape, database permissions,
one path per action, what the user reads). Conditions 2 and 6 name properties *of the evidence
about* the product (tests that have been red, decision records, measured documentation) — a
different kind of thing, and one that ISO-style product-quality models place outside the product
model. The categories also overlap at the edges: cache appears in 1 and again as behaviour under
4; "every defense fails closed" (3) and "no technical error on screen" (5) both govern the same
rejection path; "feedback on every command" (4) and "worded outcomes" (5) are the same event seen
twice. The list is defensible as a *checklist of what this skill repairs* — it maps one-to-one
onto the six `areas/` files — but it should not be presented as "what a production-grade product
is", which is a claim about products in general and would need a standard behind it. Minimal
change: `SKILL.md:29` → `Six conditions **this skill measures**, each measured, never asserted —
one per area file; they are this skill's scope, not a complete quality model.`

---

## Files read

- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\quality.md` (full, 88 lines)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\performance.md` (full, 56 lines)
- `C:\Users\Utente\Desktop\harden-codebase-properly\SKILL.md` (full, 105 lines)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\verifier.md` (full, 56 lines)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-1-gates.md` (context only)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-3-performance.md` (context only)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-5-tests.md` (context only)
- `C:\Users\Utente\Desktop\harden-codebase-properly\GLOSSARY.md` (§ Quality and verification)
- `C:\Users\Utente\Desktop\harden-codebase-properly\README.md` (§ Origin, § Status)
- `C:\Users\Utente\Desktop\harden-codebase-properly\procedure.md` (grep only)

External sources: 28 primary documents fetched and read this session — see
`C:\Users\Utente\Desktop\harden-codebase-properly\audit\sources-a.md`.
