# 03b — Evidence: data-security + method-documentation

Scope: `areas/data-security.md` (93 lines) and `areas/method-documentation.md` (86 lines), in full, plus eleven rows of `SKILL.md` (Excuses and reality; Red flags) whose subject is permissions, secrets, migrations, databases, channels, decision records, documentation or debt. Briefs `phase-2-data.md`, `phase-6-documentation.md`, `phase-7-handover.md` and `templates/decision-record.md` were read for context only and are not tabled.

Commit audited: `c32367a`, branch `evolve/audit-01`. All sources fetched **2026-09-11**; full citations in `audit/sources-b.md`.

**Classification rule applied** (stated so the reader can re-derive every cell): a row is **S**, **P** or **V** only when a source fetched *in this session* states the **same obligation or the same fact** as the row. A source that merely shares the row's topic leaves the row at **C** and is recorded instead in § ASVS mapping summary. Partial matches are marked `partial` in the verification cell and explained there. The skill ships prose only, so **no row can be M**: every "rule with mechanical verification" is a *described* check — no script, no fixture, no test file exists in the corpus. The nearest thing to a shipped check is the SQL at `areas/data-security.md:49-53`, which is a runnable query embedded in prose; it is still "described, not shipped" (nothing executes it, nothing asserts on its output), and § Wrong or overstated shows it would pass the very state it exists to catch.

---

## Count by class

| class | count | % |
|---|---|---|
| S — Standard, cited at clause level | 19 | 16.4% |
| P — Published evidence | 6 | 5.2% |
| V — Vendor primary, with version range | 19 | 16.4% |
| M — Mechanically self-verifying | 0 | 0.0% |
| C — Craft, n=1 | 72 | 62.1% |
| **total rows** | **116** | 100% |

Of the 72 C rows, **1** is labelled as craft inside the file that carries it (`method-documentation.md:85`, "tried and dropped"). The other 71 are not.

**The sentence that count implies, plainly:** *Nearly two of every three normative claims in these two files are one project's working habits stated as general law, and only one of them says so; nothing in the two files verifies itself — every "rule with mechanical verification" is a description of a check the skill does not ship.* The security half is the better-sourced half (36 of 63 rows reach S, P or V, because databases and standards both write things down); the documentation half is almost entirely craft (2 of 42 rows reach S or V), which is defensible — documentation method is a craft — but it is currently indistinguishable, to a reader or an agent, from the rows that rest on OWASP ASVS and the PostgreSQL manual.

---

## Load-bearing claims a, b, g, h

### (a) "`create or replace function` resets grants"

**Claim, verbatim.** `areas/data-security.md:71`: "`create or replace function` **resets grants**: reassert them in every migration that touches the function, and verify afterward." Restated at `areas/data-security.md:82`: "**`create or replace`** resetting grants: the same function closed off, over and over." Restated at `SKILL.md:67`: "`create or replace` resets grants."

**Verdict: FALSE as written.**

**Evidence.** PostgreSQL 18.6 manual, CREATE FUNCTION, Notes:

> "When `CREATE OR REPLACE FUNCTION` is used to replace an existing function, the ownership and permissions of the function do not change."
> — https://www.postgresql.org/docs/current/sql-createfunction.html (accessed 2026-09-11)

Identical wording in the PostgreSQL 12 manual (https://www.postgresql.org/docs/12/sql-createfunction.html), so the behaviour is stable across **PostgreSQL 12–18**: `create or replace` resets **neither** the ACL **nor** the owner. Nothing in ALTER FUNCTION or GRANT contradicts it.

The trap the sentence is reaching for is real, but has a different mechanism, and the same page names it:

> "It is not possible to change the name or argument types of a function this way (if you tried, you would actually be creating a new, distinct function)."
> — ibid.

A *new* function starts from default privileges:

> "For other types of objects, the default privileges granted to `PUBLIC` are as follows: … `EXECUTE` privilege for functions and procedures"
> — https://www.postgresql.org/docs/current/ddl-priv.html (PostgreSQL 18.6; identical in 12)

and, on Supabase, also from the project's default-privilege grants (see (b)). So grants are lost when a migration **drops and recreates** the function (the usual way to change a return type, which `create or replace` refuses), or when the argument list changes and a second, wide-open function appears beside the locked-down one. `create or replace` of an identical signature keeps the ACL.

**Exact minimal text change.**

- `areas/data-security.md:71` → "- **A function recreated with a new signature, or dropped and recreated, starts from default privileges** (`create or replace` of the *same* signature keeps the ACL): reassert the grants in every migration that touches the function, and verify afterward."
- `areas/data-security.md:82` → "- **`drop function` + `create`, or a changed argument list**: a new function appears with default privileges — the same function closed off, over and over."
- `SKILL.md:67` → "… `revoke from public` does not remove the grants `anon` and `authenticated` hold; a function dropped and recreated comes back with default privileges."

### (b) "`revoke … from public` is insufficient" / "does not cover public roles"

**Claim, verbatim.** `areas/data-security.md:70`: "`revoke … from public` **is not enough**: revoke explicitly from `public, anon, authenticated`, plus `alter default privileges … revoke execute on functions`." `areas/data-security.md:81`: "**`revoke from public`** that leaves public roles holding default privileges." `SKILL.md:67`: "`revoke from public` does not cover public roles."

**Verdict: TRUE-WITH-CAVEAT** — the instruction is right, the explanation is imprecise, and "public roles" is undefined jargon that collides with PostgreSQL's `PUBLIC`.

**Evidence.** In PostgreSQL, `PUBLIC` is a pseudo-role, not a role name:

> "The key word `PUBLIC` indicates that the privileges are to be granted to all roles, including those that might be created later."
> — https://www.postgresql.org/docs/current/sql-grant.html (18.6)

So `revoke execute … from public` *does* remove the PUBLIC default grant on an existing function. What it cannot remove is a grant held **explicitly** by `anon` and `authenticated` — and on Supabase they hold one, created by the project's own default privileges:

> `alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;`
> — supabase/postgres, `migrations/db/init-scripts/00000000000000-initial-schema.sql`, branch `develop` (accessed 2026-09-11)

Supabase's own RLS guide states the table-side equivalent plainly:

> "On existing projects, a new table in `public` starts with every privilege already granted to all three roles."
> — https://supabase.com/docs/guides/database/postgres/row-level-security (accessed 2026-09-11)

Two caveats the skill does not state, both load-bearing for the repair it prescribes:

1. `ALTER DEFAULT PRIVILEGES` entries are **per grantor role**: "Change default privileges for objects created by the *target_role*, or the current role if unspecified." The Supabase image sets entries both for the current role *and* `for user supabase_admin`, so a single `alter default privileges in schema public revoke execute on functions from anon, authenticated` run as `postgres` leaves the `supabase_admin` entry standing.
2. A per-schema `ALTER DEFAULT PRIVILEGES … REVOKE … FROM PUBLIC` is a no-op: "Per-schema `REVOKE` is only useful to reverse the effects of a previous per-schema `GRANT`." Revoking from `anon`/`authenticated` per-schema *does* work, because it reverses a matching per-schema grant; revoking from `PUBLIC` per-schema does not. — https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html (18.6)

**Exact minimal text change.**

- `areas/data-security.md:70` → "- `revoke … from public` **is not enough on Supabase**: `anon` and `authenticated` hold their own grant (the project grants all on functions to them by default privileges). Revoke from `public, anon, authenticated`, and `alter default privileges … revoke execute on functions from anon, authenticated` — once per grantor role, because a default-privileges entry belongs to the role that created it."
- `areas/data-security.md:81` → "- **`revoke from public`** that leaves `anon` and `authenticated` holding their own explicit grant."
- `SKILL.md:67` → replace "does not cover public roles" with "does not remove the grants `anon` and `authenticated` hold".
- Everywhere: drop the phrase "public roles" or define it once in `GLOSSARY.md` as "the API roles `anon` and `authenticated`, which are ordinary roles — not PostgreSQL's `PUBLIC`".

### (g) "Timestamps re-read in a different literal form (`+00:00` vs `Z`) make `!==` always true"

**Claim, verbatim.** `areas/data-security.md:87`: "**A timestamp re-read in a different form**: `!==` is always true." Supported by `:16` ("Dates are compared as **instants**, never as re-read strings"), `:61` and `:75`.

**Verdict: TRUE-WITH-CAVEAT.** The claim holds for *string* comparison of two values serialized in different forms. It is false as an unconditional statement: two strings serialized the same way compare equal, and the same two instants compared as instants are equal in every form.

**Evidence.** The two forms denote the same instant:

> "This differs semantically from an offset of 'Z' or '+00:00', which imply that UTC is the preferred reference point for the specified time."
> — RFC 3339 §4.3, Klyne & Newman, 2002, https://www.rfc-editor.org/rfc/rfc3339

They are nonetheless different strings, and the two ends of a typical Next.js/Postgres comparison produce different ones. ECMAScript pins one end:

> "Return a String representation of tv in the Date Time String Format on the UTC time scale, including all format elements and the UTC offset representation `"Z"`."
> — ECMA-262, §21.4.4.36 `Date.prototype.toISOString`, https://tc39.es/ecma262/multipage/numbers-and-dates.html

> "`Z` is the UTC offset representation specified as `"Z"` (for UTC with no offset) or as either `"+"` or `"-"` followed by a time expression HH:mm"
> — ECMA-262, §21.4.1.32 Date Time String Format

PostgreSQL pins the other end — it never emits `Z`:

> "In the ISO style, the time zone is always shown as a signed numeric offset from UTC, with positive sign used for zones east of Greenwich."
> — https://www.postgresql.org/docs/current/datatype-datetime.html (PostgreSQL 18), ISO output style example `1997-12-17 07:37:16-08`

So `dbRow.updated_at !== new Date(x).toISOString()` is true for equal instants — not because `!==` is magic, but because the two producers disagree on the literal. `Date.parse` resolves both to the same time value ("The function first attempts to parse the String according to the format described in Date Time String Format", §21.4.3.2), which is why the skill's fix (compare instants) is correct.

**When it does not hold:** both sides produced by the same serializer; a `timestamptz` compared in SQL; two `Date` objects compared with `getTime()` or `valueOf()`; and note that a naive string comparison is *sometimes* right — RFC 3339 §5.1 observes that conforming strings "may be sorted as strings … and a time-ordered sequence will result" — which is exactly why the defect survives review.

**Exact minimal text change.** `areas/data-security.md:87` → "- **A timestamp re-read in a different form**: `!==` between the database's `+00:00` and JavaScript's `Z` is true for the same instant." And `:75` is already right; leave it.

### (h) "An email provider rejecting `tags: []` silently kills one message family"

**Claim, verbatim.** `areas/data-security.md:86`: "**An email provider that rejects an empty array** (`tags: []`): only the message family missing that field fails — the alerts — while real emails hide the failure. Omit the field when empty; test the alert channel live."

**Verdict: COULD NOT VERIFY → class C, and it is not labelled as craft.**

The skill names no provider. Resend is the likely referent (it is the Next.js-stack default and the only mainstream provider with a `tags: [{name, value}]` parameter of that shape). Its API reference documents the parameter's type, character set and per-email limit, and says nothing about empty arrays:

> "It can only contain ASCII letters (a–z, A–Z), numbers (0–9), underscores (_), or dashes (-)." … "up to 75 tags per email"
> — https://resend.com/docs/api-reference/emails/send-email and https://resend.com/docs/dashboard/emails/tags (accessed 2026-09-11)

Its error reference lists every documented failure. `tags` appears in none of them; the only candidate is the generic `validation_error` (400), "An error was found with one or more fields in the request." — https://resend.com/docs/api-reference/errors (accessed 2026-09-11). No version or dated changelog entry documents a rejection of `tags: []`, so the behaviour can be neither confirmed nor dated, and may have changed since it was observed.

The *instruction* ("omit the field when empty; test the alert channel live") is sound regardless and costs nothing. Only the causal story is unverifiable.

**Exact minimal text change.** `areas/data-security.md:86` → "- **An email provider that rejected an empty array** (`tags: []`) *(seen once, on one provider, in the origin project; not in any vendor doc — treat as a shape of bug, not a known behaviour)*: only the message family missing that field fails — the alerts — while real emails hide the failure. Omit the field when empty; test the alert channel live."

---

## Traceability table

`file:line` is relative to the repository root. `DS-` ids are `areas/data-security.md`; `MD-` ids are `areas/method-documentation.md`; a `-S` suffix marks a `SKILL.md` restatement of the id it hangs from. Source keys expand in `audit/sources-b.md`.

| id | file:line | claim (verbatim, ≤20 words) | class | source | verification |
|---|---|---|---|---|---|
| DS-P0 | areas/data-security.md:3 | "verify permissions on the database, not in the repository; exercise channels live — never infer one from the channel next to it" | C | — (near: [ASVS5] V8.3.1) | not labelled as craft; ASVS mandates server-side enforcement, not database-side verification of grants |
| DS-M1 | areas/data-security.md:8 | "An **external source** flows in one direction only; the reverse direction is removed from the code, not switched off…" | C | — | not labelled as craft |
| DS-M2 | areas/data-security.md:9 | "Unsubscribe ≠ deletion ≠ \"removed at the source\": three events, three effects." | C | — (near: GDPR Art. 17) | not labelled; GDPR could not be fetched this session |
| DS-M3 | areas/data-security.md:10 | "Consent is **read**, never inferred: an absent state means \"we don't know,\" never a no." | C | — (near: GDPR Art. 4(11), Rec. 32) | could not verify; see § Wrong or overstated (GDPR reads absence as *no consent* for lawfulness) |
| DS-M4 | areas/data-security.md:11 | "Personal-data deletion suppresses durably via a **hash**, anonymizes dependencies, and re-admits only on confirmation…" | C | — (near: [ASVS5] V14.2.7) | not labelled; V14.2.7 mandates scheduled deletion, not hash suppression |
| DS-M5 | areas/data-security.md:12 | "Tombstones and a trash bin: permanent deletion **only from the trash**." | C | — | not labelled as craft |
| DS-M6 | areas/data-security.md:13 | "\"Not a duplicate\" is a fact (who, when), and it is revocable." | C | — | not labelled as craft |
| DS-M7 | areas/data-security.md:14 | "Numbers get counted; write \"—\" when unknown, never 0; a cap declares `truncated`." | C | — | not labelled as craft |
| DS-M8 | areas/data-security.md:15 | "Attributes get promoted to real columns once something filters or sorts on them." | C | — | not labelled as craft |
| DS-M9 | areas/data-security.md:16 | "Dates are compared as **instants**, never as re-read strings." | S | [RFC3339] §4.3; [ECMA] §21.4.1.32 | "an offset of 'Z' or '+00:00', which imply that UTC is the preferred reference point for the specified time" |
| DS-S1 | areas/data-security.md:19 | "An env module with **fail-fast** startup in production: presence, \"not the placeholder,\" mutual consistency." | S | [ASVS5] V13.2.3 (L2) | partial — "the credential being used by the consumer is not a default credential (e.g., root/root or admin/admin)"; fail-fast startup is the skill's mechanism |
| DS-S2 | areas/data-security.md:20 | "Secrets are **distinct per purpose** (data signing, session), required, and different from one another." | C | — (near: [ASVS5] V11.1.1) | V11.1.1 requires keys "not overshared" between entities, not separation by purpose; not the same obligation |
| DS-S3 | areas/data-security.md:21 | "Secrets stay server-side only; a clean secrets scan." | S | [ASVS5] V13.3.1 (L2); [NDSS19] | "Secrets must not be included in application source code or included in build artifacts." |
| DS-S4 | areas/data-security.md:22 | "**Deny-all row-level security** on every table, no policy for public roles until real database identities exist; verified with a query." | V | [PG-RLS] 18.6; [SB-RLS] | "If no policy exists for the table, a default-deny policy is used, meaning that no rows are visible or can be modified." + "Enable RLS on every table in an exposed schema." |
| DS-S5 | areas/data-security.md:23 | "Grants on every sensitive function **verified on the database** after every schema deploy." | V | [PG-PRIV] 12–18; [SB-INIT] | partial — the need is vendor behaviour ("`EXECUTE` privilege for functions and procedures" to PUBLIC by default); the per-deploy cadence is craft |
| DS-S6 | areas/data-security.md:24 | "Signed tokens with a **separated rejection cause** (unreadable / invalid signature / expired), signature verified before every query." | S | [ASVS5] V9.1.1 (L1) | "self-contained tokens are validated using their digital signature or MAC to protect against tampering before accepting the token's contents" |
| DS-S7 | areas/data-security.md:25 | "Online, the entity read from the database decides; offline, the token decides." | S | [ASVS5] V8.3.2 (L3) | "changes to values on which authorization decisions are made are applied immediately"; but see § Wrong or overstated — the offline half collides with V9.2.1 |
| DS-S8 | areas/data-security.md:26 | "Test and reset endpoints disabled by default, with a check that they are absent in production." | S | [ASVS5] V15.2.3 (L2) | "the production environment … does not expose extraneous functionality such as test code, sample snippets, and development functionality" |
| DS-S9 | areas/data-security.md:27 | "Every defense **fails closed**: if the guard, the rate limiter, or the token check errors, it denies" | S | [ASVS5] V16.5.3 (L2); [CWE-636]; [T10-25] A10 | "the application fails gracefully and securely … preventing fail-open conditions such as processing a transaction despite errors" |
| DS-S10 | areas/data-security.md:27 | "One test per defense that simulates the failure and verifies the rejection." | C | — | not labelled as craft; no shipped test |
| DS-S11 | areas/data-security.md:28 | "Rate limiting on every authentication endpoint, or any endpoint that enumerates identities, with the policy **decided and written down**" | S | [ASVS5] V6.1.1 (L1) | "application documentation defines how controls such as rate limiting, anti-automation, and adaptive response, are used" |
| DS-S12 | areas/data-security.md:29 | "An access-revocation runbook with a \"what it hits, what it doesn't\" table (changing a password does not revoke…)" | C | — (near: [ASVS5] V7.4.2, V13.1.4) | V7.4.2 mandates the capability, not the runbook; the runbook is craft, not labelled |
| DS-G1 | areas/data-security.md:32 | "**Idempotent migrations**, never squashed; replay proven on an empty project." | C | — (near: [EVODB]) | "All database changes are migrations" supports migrations-as-artifacts, not idempotency or the no-squash rule |
| DS-G2 | areas/data-security.md:33 | "Migrations applied and verified on the database **before** pushing the code that uses them." | P | [EVODB] | partial — "the database supports both the old access pattern and the new ones simultaneously" (expand/contract); the ordering rule itself is not stated verbatim |
| DS-G3 | areas/data-security.md:34 | "**A single source-of-truth database**: CLI, MCP, and app point to the same project, verified before every write command." | V | [SB-CLI] | "Pushes all local migrations to a remote database" with `--linked` / `--db-url` / `--local` selecting the target |
| DS-G4 | areas/data-security.md:35 | "Every function rewrite starts from the **latest** definition and **reasserts the grants**." | V | [PG-CF] 12–18; [PG-PRIV] | "the ownership and permissions of the function do not change" — reasserting is still correct, for the drop/recreate case; see (a) |
| DS-I1 | areas/data-security.md:38 | "Automated backup with verification of **arrival** (one row per run, written by the last link in the chain), not of departure." | P | [SRE-DI] | "you only know that you can recover your recent state if you actually do so" |
| DS-I2 | areas/data-security.md:39 | "Restore tested end-to-end at least once with a count comparison; if not done, **declared** as tech debt." | P | [SRE-DI] | "No one really *wants* to make backups; what people *really* want are *restores*." |
| DS-I3 | areas/data-security.md:40 | "Every channel (email, alerts, dead-letter, sync) exercised live with an **injected failure**." | C | — | not labelled as craft; fault injection is published practice but no fetched source states this obligation |
| DS-I4 | areas/data-security.md:41 | "Structured logs with no personal data; alerts guarded against an alert that stays permanently stuck on." | S | [ASVS5] V16.2.5 (L2); [SRE-MON] | "it may not be allowed to log certain data, such as credentials or payment details" + "Every page should be actionable." |
| DS-I5 | areas/data-security.md:42 | "Post-write navigation happens server-side (`redirect()` inside the action, after invalidations), never a client push after a server action." | V | [NEXT] 16.3.4 | "In a Server Action, `redirect` performs a client-side navigation when JavaScript is available. For progressive enhancement form submissions, it serves a 303" — the `router.push` half is unsourced |
| DS-W1 | areas/data-security.md:46 | "**Env**: is there a single module? What happens in production with a missing variable, or one equal to the example placeholder?" | C | — (near: [ASVS5] V13.2.3) | measurement procedure; not labelled as craft |
| DS-W2 | areas/data-security.md:47 | "`select tablename, rowsecurity from pg_tables…`; `select * from pg_policies`. From the database, not from the repository." | V | [PG-RLS] 18.6 | catalogs `pg_tables`/`pg_policies` are PostgreSQL's; "If no policy exists for the table, a default-deny policy is used" |
| DS-W3 | areas/data-security.md:48-54 | "Only the expected roles should appear (normally `postgres` / `service_role`)." | V | [PG-PRIV] 18.6 | FALSE-NEGATIVE — "If the 'Access privileges' column is empty … the object has default privileges"; a NULL `proacl` prints nothing and passes |
| DS-W4 | areas/data-security.md:55 | "did a function rewritten several times start each time from the latest definition?" | C | — | measurement procedure; not labelled as craft |
| DS-W5 | areas/data-security.md:56 | "**Environments**: compare the CLI's project reference against the app's env host." | V | [SB-CLI] | `--linked` "Pushes to the linked project"; `--db-url` overrides — the two can differ |
| DS-W6 | areas/data-security.md:57 | "**Secrets**: run a scan (gitleaks or equivalent); check for public variables that contain keys." | S | [ASVS5] V13.3.1; [CS-SECRETS] §8.1; [GITLEAKS] | "Consider enabling secrets detection at the developer level to avoid checking secrets into code before commit/PR" |
| DS-W7 | areas/data-security.md:58 | "Does the expiry baked into the token win even when the database is reachable?" | S | [ASVS5] V9.2.1 (L1) | CONTRADICTED — "the token and its content are accepted only if the verification time is within this validity time span" |
| DS-W8 | areas/data-security.md:59 | "**Channels**: for each one, the date of the last live test and how arrival was confirmed." | C | — | not labelled as craft |
| DS-W9 | areas/data-security.md:60 | "**Backup**: how is success determined — from the last link in the chain, or from the first HTTP 200?" | P | [SRE-DI] | "a system of out-of-band checks and balances is needed within and between its datastores" |
| DS-W10 | areas/data-security.md:61 | "**Dates**: where are re-read strings from the database being compared (`!==` between timestamps)?" | S | [RFC3339] §4.3; [PG-DT] | "In the ISO style, the time zone is always shown as a signed numeric offset from UTC" |
| DS-R1 | areas/data-security.md:69 | "No sensitive function is executable by public roles: query `pg_proc.proacl`." | V | [PG-PRIV] 18.6 | partial — the catalog is right, the reading is not: an empty ACL "means the object has default privileges", i.e. `EXECUTE` to PUBLIC |
| DS-R2 | areas/data-security.md:70 | "`revoke … from public` **is not enough**: revoke explicitly from `public, anon, authenticated`, plus `alter default privileges…`" | V | [SB-INIT]; [PG-ADP] 18.6 | "alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;" — see (b) |
| DS-R3 | areas/data-security.md:71 | "`create or replace function` **resets grants**: reassert them in every migration that touches the function…" | V | [PG-CF] 12–18 | FALSE — "the ownership and permissions of the function do not change" — see (a) |
| DS-R4 | areas/data-security.md:72 | "Rewrite from the latest definition: grep every migration that touches the function, diff against the most recent one." | C | — | described, not shipped; no grep or script exists in the corpus |
| DS-R5 | areas/data-security.md:73 | "The app refuses to start without secrets: a test that boots with `NODE_ENV=production` and a missing variable." | C | — (near: [ASVS5] V13.2.3) | described, not shipped |
| DS-R6 | areas/data-security.md:74 | "A migration run twice does not fail: an idempotency test." | C | — | described, not shipped |
| DS-R7 | areas/data-security.md:75 | "Dates as instants: dedicated helpers, a test on both literal forms (`+00:00` and `Z`)" | S | [RFC3339] §4.3; [ECMA] §21.4.4.36 | "including all format elements and the UTC offset representation `\"Z\"`" — the two forms are the right fixture; test described, not shipped |
| DS-R8 | areas/data-security.md:76 | "Backup success read from the run row (`finished_at`, `complete`, `errors` empty)." | C | — (near: [SRE-DI]) | described, not shipped |
| DS-R9 | areas/data-security.md:77 | "CLI on the same database as the app: compare before every write command." | V | [SB-CLI] | `--linked`, `--db-url`, `--local` are separate targets of the same command; comparison described, not shipped |
| DS-K1 | areas/data-security.md:81 | "**`revoke from public`** that leaves public roles holding default privileges." | V | [SB-INIT]; [SB-RLS] | TRUE-WITH-CAVEAT — "a new table in `public` starts with every privilege already granted to all three roles" — see (b) |
| DS-K2 | areas/data-security.md:82 | "**`create or replace`** resetting grants: the same function closed off, over and over." | V | [PG-CF] 12–18 | FALSE — "the ownership and permissions of the function do not change" — see (a) |
| DS-K3 | areas/data-security.md:83 | "**Rebuilding from an old version**: a silent regression, a column goes back to NULL with no error." | C | — | not labelled as craft |
| DS-K4 | areas/data-security.md:84 | "**Code deployed before the migration**: the adapter sends every field, the database rejects the whole write." | P | [EVODB] | partial — "the database supports both the old access pattern and the new ones simultaneously" is the stated remedy; this failure shape is not in the source |
| DS-K5 | areas/data-security.md:85 | "**CLI connected to the wrong project**: `db push` succeeds and reports success." | V | [SB-CLI] | partial — the command "Pushes all local migrations to a remote database" chosen by `--linked`/`--db-url`; the silent-success observation is craft |
| DS-K6 | areas/data-security.md:86 | "**An email provider that rejects an empty array** (`tags: []`): only the message family missing that field fails" | C | — ([RESEND-API], [RESEND-ERR] checked) | could not verify — no provider named; Resend documents no empty-array rejection — see (h) |
| DS-K7 | areas/data-security.md:87 | "**A timestamp re-read in a different form**: `!==` is always true." | S | [RFC3339] §4.3; [ECMA]; [PG-DT] | TRUE-WITH-CAVEAT — holds for string comparison of differently serialized values only — see (g) |
| DS-K8 | areas/data-security.md:88 | "**A token's baked-in expiry applied even online**: the copy inside the QR code becomes more authoritative than the real entity." | S | [ASVS5] V8.3.2 (L3), V9.2.1 (L1) | "there must be mitigating controls to alert when a consumer performs an action when they are no longer authorized" — but V9.2.1 still requires honouring `exp` |
| DS-K9 | areas/data-security.md:89 | "**Changing a password, expecting it to revoke sessions**: the cookie is signed, not checked against the password." | S | [ASVS5] V7.4.2 (L1) | "the application terminates all active sessions when a user account is disabled or deleted" |
| DS-K10 | areas/data-security.md:90 | "**`router.push()` after a server action**: navigation lost, intermittently." | C | — ([NEXT] checked) | could not verify — the Next.js 16.3.4 docs describe `redirect` in Server Actions but document no loss with `router.push` |
| DS-K11 | areas/data-security.md:91 | "**An unexpected foreign-key cascade** during a remediation pass: stop and ask." | C | — | not labelled as craft |
| DS-K12 | areas/data-security.md:92 | "**A \"succeeded\" from the first link** in the backup chain, while the last one never arrives." | P | [SRE-DI] | "you only know that you can recover your recent state if you actually do so" |
| DS-K13 | areas/data-security.md:93 | "**A defense that fails open**: a `catch` around the rate limiter or guard that lets traffic through" | S | [ASVS5] V16.5.3; [CWE-636]; [T10-25] A10 | "Not Failing Securely ('Failing Open')" … "its design requires it to fall back to a state that is less secure" |
| MD-P0 | areas/method-documentation.md:3 | "documentation stays true because it is checked against the product, not against the writer's memory" | C | — | not labelled as craft |
| MD-T1 | areas/method-documentation.md:7 | "A **decision register** (`docs/decisions/`), one decision record per reversible choice, six parts, including rejected alternatives." | C | — (near: [ADR]) | Nygard's template has Title, Context, Decision, Status, Consequences — no rejected alternatives, no timing rule; the six parts and "first week" are craft |
| MD-T2 | areas/method-documentation.md:8 | "An **index** (`docs/INDEX.md`) as the single entry point, with counts regenerated by **counting files**." | C | — | not labelled as craft |
| MD-T3 | areas/method-documentation.md:9 | "**A number lives in one place**; every other document links to it." | C | — | not labelled as craft; DRY's primary statement (Hunt & Thomas) could not be fetched |
| MD-T4 | areas/method-documentation.md:10 | "An **acceptance checklist** … kept separate from the **work register** …, linked by one mechanical field" | C | — | not labelled as craft |
| MD-T5 | areas/method-documentation.md:11 | "Three lists in acceptance testing (to review / to recheck / closed), never a filter on the same list" | C | — | not labelled as craft |
| MD-T6 | areas/method-documentation.md:12 | "A **user guide** generated from a single source …, searchable **by intent** …, with **real screenshots**" | C | — (near: [DIATAXIS]) | Diátaxis defines four types; it does not mandate generation, intent-search or screenshots |
| MD-T7 | areas/method-documentation.md:13 | "**Feature** records (what a screen does today, with a freshness note) and **use-case** records" | C | — (near: [DIATAXIS] reference) | "Reference guides contain the technical description - facts" — related, not the same obligation |
| MD-T8 | areas/method-documentation.md:14 | "**Architecture** docs rewritten against the real code; **maintenance** docs carrying the measurements" | C | — | not labelled as craft |
| MD-T9 | areas/method-documentation.md:15 | "Operational **runbooks**: backup and restore, monitoring, access revocation." | C | — (near: [ASVS5] V13.1.4) | ASVS mandates documented secrets and a rotation schedule, not runbooks |
| MD-T10 | areas/method-documentation.md:16 | "A **tech-debt register** with origin, destination, priority, and trigger; every marker in the code has a matching line." | C | — | not labelled as craft; the SATD literature (Potdar & Shihab, ICSME 2014) could not be fetched |
| MD-T11 | areas/method-documentation.md:17 | "**Client questions** live in one place, split by audience … never merged" | C | — | not labelled as craft |
| MD-T12 | areas/method-documentation.md:18 | "**Handover minutes** as records that never get edited after the fact; an ownership-transfer plan." | C | — | not labelled as craft |
| MD-T13 | areas/method-documentation.md:19 | "Commits … stating the **effect** on the user or the data and the why, not the implementation." | C | — (near: [CC1]) | Conventional Commits fixes the shape, not the content rule |
| MD-RM1 | areas/method-documentation.md:23-40 | "Reference map" — fourteen folders with fixed roles; "These are defaults: if the host project already has a … convention, use it" | C | — | craft taxonomy; the "these are defaults" sentence is a scoping label, not a provenance label |
| MD-W1 | areas/method-documentation.md:44 | "Does a decision register exist? How many reversible choices from the last few months have no decision record?" | C | — | measurement procedure; not labelled as craft |
| MD-W2 | areas/method-documentation.md:45 | "Does the index count files, or just recall them? How long has it been stale?" | C | — | not labelled as craft |
| MD-W3 | areas/method-documentation.md:46 | "Which numbers appear in more than one document? (grep for the number.)" | C | — | described, not shipped |
| MD-W4 | areas/method-documentation.md:47 | "Is the acceptance checklist a partition of the code's surface, or an eyeballed list?" | C | — | not labelled as craft |
| MD-W5 | areas/method-documentation.md:48 | "Does the guide name screens or commands that no longer exist? Which routes does it not describe?" | C | — | not labelled as craft |
| MD-W6 | areas/method-documentation.md:49 | "Is the debt written down somewhere, with the condition that reopens it?" | C | — | not labelled as craft |
| MD-W7 | areas/method-documentation.md:50 | "Do client questions live in chat, scattered across files, or in one place?" | C | — | not labelled as craft |
| MD-W8 | areas/method-documentation.md:51 | "Do the last twenty commits state the effect, or the implementation?" | C | — | not labelled as craft |
| MD-N1 | areas/method-documentation.md:55 | "Reformulation, merging, ordering, distribution and confirmation before any dispatch" | C | — | not labelled as craft |
| MD-Y1 | areas/method-documentation.md:63 | "Documents, reports, decision records, and checklists are written in the host project's language" | C | — | not labelled as craft |
| MD-Y2 | areas/method-documentation.md:65 | "Impersonal voice; the subject is the effect on the user or the data" | C | — | not labelled as craft |
| MD-Y3 | areas/method-documentation.md:65 | "one sentence in two beats (what changes, then why or the flip side); no jargon in the title" | C | — | not labelled as craft |
| MD-Y4 | areas/method-documentation.md:65 | "documents quote the reporter's exact words, because a summary is already interpretation" | C | — | not labelled as craft |
| MD-Y5 | areas/method-documentation.md:67 | "the shape is `fix(area): <what changes for the user>, <why or the flip side>`" | S | [CC1] v1.0.0 | "`<type>[optional scope]: <description>`" and "The type `fix` MUST be used when a commit represents a bug fix" |
| MD-R1 | areas/method-documentation.md:71 | "Decision record number: the first free one, found by **listing the whole folder**, never `ls \| tail -1`" | C | — | described, not shipped |
| MD-R2 | areas/method-documentation.md:72 | "Counts printed into documents by a script, never typed by hand." | C | — | described, not shipped |
| MD-R3 | areas/method-documentation.md:73 | "Checklist as a partition of the surface: a coverage script at zero gaps and zero phantom entries." | C | — | described, not shipped |
| MD-R4 | areas/method-documentation.md:74 | "No entry describes a changed gesture: a stale-wording script catches it." | C | — | described, not shipped |
| MD-R5 | areas/method-documentation.md:75 | "Every phrase from an acceptance round is found again in the register: a script compares head and tail." | C | — | described, not shipped |
| MD-K1 | areas/method-documentation.md:79 | "**A decision register started too late**: weeks of reconstruction from commits and migrations." | C | — | not labelled as craft |
| MD-K2 | areas/method-documentation.md:80 | "**A stale index** lying about the folders: regenerate it by counting." | C | — | not labelled as craft |
| MD-K3 | areas/method-documentation.md:81 | "**A number in nine files**: wrong in all nine within a day." | C | — | not labelled as craft; the "nine"/"a day" figures are from one project |
| MD-K4 | areas/method-documentation.md:82 | "**An audit applied in the same round** it was written in." | C | — | not labelled as craft |
| MD-K5 | areas/method-documentation.md:83 | "**\"Not done\" claimed from memory** on a repository with multiple sessions." | C | — | not labelled as craft |
| MD-K6 | areas/method-documentation.md:84 | "**`git stash` used for A/B** on a shared tree: use one file with `cmp`, or a `git worktree`." | V | [GITWT] git 2.54.0 | "A git repository can support multiple working trees, allowing you to check out more than one branch at a time." |
| MD-K7 | areas/method-documentation.md:85 | "**An automated \"dead link\" check** …: tried and dropped — the debt stays declared, with its trigger." | C | — | **labelled** — "tried and dropped" is the corpus's only in-place craft label |
| MD-K8 | areas/method-documentation.md:86 | "**No decision record for a non-decision or a rejected proposal**: the register is the only place they don't get lost." | C | — (near: [ADR]) | not labelled; Nygard's template has no non-decision status |
| DS-R2-S | SKILL.md:67 | "`revoke from public` does not cover public roles" | V | [SB-INIT]; [PG-GRANT] | restatement of DS-R2/DS-K1; TRUE-WITH-CAVEAT and imprecise — see (b) |
| DS-R3-S | SKILL.md:67 | "`create or replace` resets grants" | V | [PG-CF] 12–18 | restatement of DS-R3/DS-K2; FALSE — see (a) |
| DS-I3-S | SKILL.md:68 | "A channel nobody exercises is not proven by the channel next to it." | C | — | restatement of DS-I3; not labelled as craft |
| OUT-PERF-S | SKILL.md:69 | "The shape of a defect changes with the order of magnitude. Measure on real data, with the date." | C | — | subject is databases, but the parent claim lives in `areas/performance.md` — outside this slice; not labelled |
| MD-K5-S | SKILL.md:70 | "On a repository with several sessions, \"what is missing\" is answered by grep." | C | — | restatement of MD-K5; not labelled as craft |
| MD-T3-S | SKILL.md:71 | "A number written in two places diverges. One place; the others link to it." | C | — | restatement of MD-T3/MD-K3; not labelled as craft |
| MD-K4-S | SKILL.md:72 | "An audit applied in the same round confuses measurement with repair." | C | — | restatement of MD-K4; not labelled as craft |
| MD-T1-S | SKILL.md:74 | "Obvious choices are the ones nobody wrote down. Present the options, ask once, record the answer." | C | — (near: [ADR]) | restatement of MD-T1; not labelled as craft |
| DS-G3-S | SKILL.md:86 | "A database MCP or CLI used without checking which project it points to." | V | [SB-CLI] | restatement of DS-G3/DS-R9/DS-K5; `--linked`/`--db-url`/`--local` are distinct targets |
| DS-S9-S | SKILL.md:90 | "A guard that lets traffic through when it fails." | S | [ASVS5] V16.5.3; [CWE-636] | restatement of DS-S9/DS-K13; "preventing fail-open conditions" |
| OUT-LEDGER-S | SKILL.md:92 | "A phase started while the previous one has a step without evidence." | C | — | evidence-ledger rule; parent lives in `procedure.md`/`modes/status.md` — outside this slice; not labelled |

**SKILL.md rows deliberately excluded**, with the reason, so the exclusion is auditable: `:62` (build/prerender → `areas/quality.md`), `:63` (green on the fake → quality), `:64` (verifier authority → `briefs/verifier.md`), `:65` (cache TTL → performance), `:66` (`disabled` fields → interface), `:73` (errors on screen → user-communication), `:75` (rebuilding the table → sibling skill), red flags `:79`–`:85`, `:87`–`:89`, `:91` (numbers, red tests, `warn`, empty `catch`, single outcome, "done" without a command, agent dispatch, CI comments, verifier rulings, agent spawning, structural defects — all quality/interface/procedure subjects outside the four named here).

---

## Claims that are wrong or overstated

**P1 — the skill instructs something false**

| id | why | evidence | minimal text change |
|---|---|---|---|
| DS-R3, DS-K2, DS-R3-S (`areas/data-security.md:71,82`; `SKILL.md:67`) | `create or replace function` does not reset grants. The false reason hides the true one (drop+create, or a changed signature creating a second function), so a reader who verifies the claim once and finds it false may discard the correct instruction with it. | PostgreSQL 12–18: "the ownership and permissions of the function do not change" | see § (a) — three one-line replacements |
| DS-W3 (`areas/data-security.md:48-54`) | The rule reads a `NULL` ACL as clean. `array_to_string(proacl,…)` on a function that has never been touched by GRANT/REVOKE returns NULL and prints an empty cell; "only the expected roles should appear" is then satisfied by the exact state the check exists to catch — default `EXECUTE` to `PUBLIC` plus the Supabase default-privilege grants to `anon`/`authenticated`. | "If the 'Access privileges' column is empty for a given object, it means the object has default privileges" + "`EXECUTE` privilege for functions and procedures" granted to `PUBLIC` by default | after line 54 add: "**A null `proacl` is the dangerous case, not the clean one**: it means default privileges — `execute` to `public`, and on Supabase to `anon` and `authenticated`. Treat `p.proacl is null` as a failure; expect an explicit ACL naming only `postgres` / `service_role`." |
| DS-R1 (`areas/data-security.md:69`) | Same hole, stated as the mechanical rule: "query `pg_proc.proacl`" without saying what a null means. | ibid. | `areas/data-security.md:69` → "- No sensitive function is executable by public roles: query `pg_proc.proacl` — **null means default privileges (world-executable), not clean**." |
| DS-W7, DS-S7, DS-K8 (`areas/data-security.md:58,25,88`) | The skill treats "the expiry baked into the token wins even when the database is reachable" as the defect, and brief `R2.4` makes the repair explicit: "with the DB reachable and a token expired-but-entity-still-valid, access is granted". That instructs accepting a self-contained token past its own validity — the opposite of an ASVS L1 control. The intent (a revoked entity must not be rescued by a still-valid token) is right; the wording inverts it. | ASVS 5.0.0 V9.2.1 (L1): "the token and its content are accepted only if the verification time is within this validity time span" | `areas/data-security.md:25` → "- Online, the entity read from the database decides — it can only **narrow** what the token allows, never extend it past the token's own expiry; offline, the token decides." And `:88` → "**A token's baked-in expiry treated as the whole truth online**: a revoked entity still admitted because the copy inside the QR code says yes." |

**P2 — overstated, imprecise or unverifiable**

| id | why | evidence | minimal text change |
|---|---|---|---|
| DS-R2, DS-K1, DS-R2-S | "public roles" is undefined and collides with PostgreSQL's `PUBLIC`; the true mechanism (Supabase's `alter default privileges … grant all on functions to … anon, authenticated`) is never stated, and two operational caveats are missing (default privileges are per grantor role; a per-schema revoke from `PUBLIC` is a no-op). | [SB-INIT]; [PG-ADP] | see § (b) |
| DS-K7 | "`!==` is always true" is true only when the two sides were serialized differently. | RFC 3339 §4.3; ECMA-262 §21.4.4.36; PostgreSQL ISO output | see § (g) |
| DS-K6 | No provider named; no vendor documentation of an empty-array rejection anywhere in Resend's API or error reference. Currently reads as a known provider behaviour. | [RESEND-API], [RESEND-ERR] | see § (h) — add the "seen once, one provider, not in any vendor doc" clause |
| DS-K10 | "navigation lost, intermittently" after `router.push()` following a server action is not documented by Next.js; the positive half (use `redirect()` in the action) is. | [NEXT] 16.3.4 | `areas/data-security.md:90` → "- **`router.push()` after a server action**: navigation lost, intermittently *(observed in the origin project; the documented path is `redirect()` inside the action)*." |
| DS-S4 | "Deny-all row-level security on every table" is exactly right for API roles and silently untrue for two others: the table owner and `BYPASSRLS` roles are not subject to it, and `service_role` is documented by Supabase as bypassing RLS. A verification query that connects as owner will see every row and conclude wrongly. | PostgreSQL 18.6: "Superusers and roles with the `BYPASSRLS` attribute always bypass the row security system"; "Table owners normally bypass row security as well … `FORCE ROW LEVEL SECURITY`" | `areas/data-security.md:22` append: "… verified with a query **run as `anon` and as `authenticated`, not as the owner** (owners and `bypassrls` roles are not subject to RLS)." |
| DS-M3 | "an absent state means 'we don't know,' never a no" is a sound modelling rule, but stated flatly it reads as a rule about lawfulness, where the opposite holds: absent consent is not consent. | GDPR Art. 4(11) / Recital 32 — **could not verify** (EUR-Lex unreachable this session); relied on for nothing | `areas/method-documentation.md` unaffected; `areas/data-security.md:10` → "Consent is **read**, never inferred: in the model an absent state means \"we don't know,\" never \"refused\" — while for lawfulness, absent still means no consent." |
| DS-G2, DS-K4 | Sound, but the ordering rule is asserted without the mechanism that makes it safe (expand/contract: the database tolerates both shapes during the transition). Without it, "migration first" is unsafe for a destructive change. | [EVODB]: "the database supports both the old access pattern and the new ones simultaneously" | `areas/data-security.md:33` append: "…; a destructive change is split in two (add and backfill before the code, drop after it)." |
| MD-T1 | The six-part record and the "first week" rule are the skill's own; the file's phrasing implies a general property of decision records. Harmless but unattributed. | [ADR]: Title, Context, Decision, Status, Consequences — no rejected alternatives | no wording change needed if the labelling mechanism below is adopted |

---

## Class-C items not labelled as craft

**Labelled (1):** `MD-K7`.

**Not labelled (71):** DS-P0, DS-M1, DS-M2, DS-M3, DS-M4, DS-M5, DS-M6, DS-M7, DS-M8, DS-S2, DS-S10, DS-S12, DS-G1, DS-I3, DS-W1, DS-W4, DS-W8, DS-R4, DS-R5, DS-R6, DS-R8, DS-K3, DS-K6, DS-K10, DS-K11; MD-P0, MD-T1, MD-T2, MD-T3, MD-T4, MD-T5, MD-T6, MD-T7, MD-T8, MD-T9, MD-T10, MD-T11, MD-T12, MD-T13, MD-RM1, MD-W1–MD-W8, MD-N1, MD-Y1, MD-Y2, MD-Y3, MD-Y4, MD-R1, MD-R2, MD-R3, MD-R4, MD-R5, MD-K1, MD-K2, MD-K3, MD-K4, MD-K5, MD-K8; DS-I3-S, OUT-PERF-S, MD-K5-S, MD-T3-S, MD-K4-S, MD-T1-S, OUT-LEDGER-S.

A global provenance label does exist — `README.md` § Origin ("Distilled from the path of a real back-office application … ~52k contacts, 426 commits, 104 decision records") — but `README.md` is not in any mode's load list, so no agent executing a phase ever reads it; and `SKILL.md` § Note on the stack labels only the *names*, not the *evidence*.

**Proposed labelling mechanism, one line:** reuse the corpus's own "declare it" idiom (`briefs/phase-6-documentation.md` R6.7 "whatever has never been executed is **declared** as such at the top"; DS-I2 "if not done, **declared** as tech debt"; MD-K7 "tried and dropped") by adding to `SKILL.md` § Note on the stack — "Unless a checklist item cites a standard, a specification or a vendor's manual, it is distilled from one project (`README.md` § Origin): a default to confirm against the host project, not a law" — and marking the ~25 rows that *do* rest on a primary source with an inline citation key (`[ASVS 5.0 V16.5.3]`, `[PostgreSQL 12–18]`), so the unmarked rows become self-identifying without editing 71 lines.

---

## ASVS mapping summary

Standard: **OWASP ASVS 5.0.0**, released 30 May 2025 — 345 requirements, 17 chapters. Mapping is against `areas/data-security.md` only; `areas/method-documentation.md` has no security surface and maps to ASVS's *documentation* requirements only incidentally (V6.1.1, V8.1.1, V13.1.x, V16.1.1 all require documentation the skill's Phase 6 would produce, but no item in the file names them).

**Items that map to a control** (14): DS-S1→V13.2.3 · DS-S3→V13.3.1 (+V13.3.2, V13.3.4) · DS-S4→V8.2.1, V8.2.2 · DS-S6→V9.1.1 (+V9.1.2, V9.2.2) · DS-S7→V8.3.2 · DS-S8→V15.2.3 (+V13.4.2) · DS-S9/DS-K13→V16.5.3 (+V16.5.2) · DS-S11→V6.1.1 (+V2.4 anti-automation) · DS-I4→V16.2.5 (+V16.2.1, V16.3.4) · DS-W6→V13.3.1 · DS-W7/DS-K8→V9.2.1, V8.3.2 · DS-K9→V7.4.2 (+V7.4.1) · DS-M9/DS-W10→V16.2.2 (timestamps carry UTC or an explicit offset) · DS-M4→V14.2.7 (partial).

**Items with no ASVS control** (the skill is ahead of, or orthogonal to, the standard): DS-S5 and DS-R1/DS-R2/DS-R3 (grants verified *in the database catalog* — ASVS stops at "explicit permissions"), DS-G1/G2/G3/G4 and DS-K3/K4/K5 (migrations, environment identity — ASVS has no migration chapter), DS-I1/I2/W9/K12 (backup and restore — **ASVS 5.0 contains the word "backup" zero times**), DS-I3/W8 (live channel exercises), DS-M1/M2/M5/M6/M7/M8, DS-I5/K10 (framework navigation), DS-K11.

**ASVS chapters and sections relevant to data, permissions and secrets with no corresponding item anywhere in these two files** — these feed the coverage pass:

- **V1 Encoding and Sanitization** (V1.2 Injection Prevention, V1.5 Safe Deserialization) — nothing in the file covers parameterization or deserialization, yet the skill writes SQL migrations and server actions.
- **V2.2 Input Validation / V2.3 Business Logic Security** — no item requires server-side validation of writes.
- **V4 API and Web Service** (V4.1 generic web service security, V4.2 HTTP message structure) — no item at all.
- **V5 File Handling** (upload, storage, download) — no item at all; the stack has storage.
- **V6.2/V6.3 Password Security and General Authentication** — only rate limiting appears (DS-S11).
- **V7.2/V7.3 Fundamental Session Management and Session Timeout** — DS-S12 touches revocation only; no idle/absolute timeout item.
- **V8.2.3 field-level authorization (BOPLA)** and **V8.4.1 cross-tenant controls** — no item, although RLS is the file's centrepiece and multi-tenant leakage is the classic RLS failure.
- **V11 Cryptography** (V11.1 inventory/key lifecycle, V11.4 hashing) — DS-M4 prescribes a *hash* for deletion suppression with no algorithm requirement; V11.4.1 would apply.
- **V12 Secure Communication** (TLS) — no item at all.
- **V13.1 Configuration Documentation** and **V13.2.4/V13.2.5 outbound allowlists** — no item, although the file is about integrations and external calls.
- **V14.1 Data Protection Documentation** (classify sensitive data into protection levels) — no item; DS-I4's "no personal data in logs" presupposes a classification the skill never asks for.
- **V15.2 Security Architecture and Dependencies** beyond V15.2.3 — nothing about dependency provenance; **no item in either file touches the supply chain**, so SLSA, OpenSSF Scorecard and NIST SSDF have nothing to attach to (see § Better sources).
- **V16.1 Security Logging Documentation** (a log inventory) and **V16.4 Log Protection** — no item.

Also absent from `areas/data-security.md` although brief `R2.7` requires it: **webhook idempotency, idempotency keys on external calls, the transactional outbox and reconciliation**. The brief prescribes them; the area file's Target state, Rules and Known traps never mention them, so a `review`- or `maintain`-mode run — which loads the *areas*, not the briefs — cannot check them. This is the single largest target-state gap found in the slice, and it is the one place where Helland and Richardson would attach.

---

## Better sources found

- **OWASP Top 10:2025 A10 — "Mishandling of Exceptional Conditions"** (released 2025) is a better anchor for DS-S9/DS-K13 than any generic reference, because it exists as a Top-10 category and maps CWE-636 explicitly. Cite it next to ASVS V16.5.3.
- **ASVS 5.0.0 V16.2.2** ("timestamps in security event metadata use UTC or include an explicit time zone offset") is a closer, more citable anchor for DS-M9/DS-W10 than RFC 3339 alone, and it is the only ASVS control that names the timestamp-form problem.
- **Supabase's own `00000000000000-initial-schema.sql`** is a stronger source than the Supabase prose docs for claim (b): the docs describe roles, the SQL *is* the grant. Cite the file, not the guide.
- **The task brief's "Sadalage & Fowler, *Refactoring Databases*" is a misattribution**: the book is *Refactoring Databases: Evolutionary Database Design*, **Ambler & Sadalage** (Addison-Wesley, 2006). The Fowler co-authored source is the article *Evolutionary Database Design* (Fowler & Sadalage), which is what I cited and could verify.
- **Nygard's ADR post** is the right origin citation for MD-T1 but shows the skill's template is an *extension*, not an instance; saying so in one clause would strengthen the skill rather than weaken it.
- **Diátaxis does not fit the skill's Phase 6 split.** Diátaxis names tutorials / how-to guides / reference / explanation; `areas/method-documentation.md` names decisions, features, use-cases, architecture, maintenance, acceptance, guide, operations, planning, client, handover, project, commercial, archive. There is no tutorial anywhere in the map, and "explanation" is scattered across `decisions/` and `architecture/`. The map is an *audience/lifecycle* taxonomy, not a *user-need* one. Worth a single sentence in the file saying so, rather than a silent divergence.
- **Not applicable, contrary to the candidate list:** DORA/*Accelerate* (no row in either file mentions lead time, deployment frequency or change-failure rate); SLSA, OpenSSF Scorecard, NIST SSDF (no row touches dependencies or CI); Google SRE postmortems (no row is about incident review — `lessons.md` lives in `SKILL.md`/`procedure.md`, outside this slice); Helland and the transactional-outbox pattern (they belong to brief `R2.7`, which has no area-file row — see the coverage gap above). These are recorded here so the next pass does not re-hunt them.

---

## Could not verify

| source | needed for |
|---|---|
| Regulation (EU) 2016/679 (GDPR) Art. 4(11), 7, 17, 20; Recital 32 — EUR-Lex returned an empty body on five attempts (HTML, ELI, consolidated, PDF, curl) | DS-M2, DS-M3, DS-M4 (consent, unsubscribe ≠ deletion, deletion/export scope). All three remain class C. |
| Resend API: behaviour on `tags: []` — parameter documented, error reference documented, empty array documented nowhere | DS-K6 (claim h). Remains C. |
| Next.js: any documented failure of `router.push()` after a Server Action | DS-K10. Remains C. |
| Potdar & Shihab, "An Exploratory Study on Self-Admitted Technical Debt" (ICSME 2014) — author copy 404, ACM DL paywalled | MD-T10 (code markers ↔ debt register). Would have made it P. |
| Hunt & Thomas, *The Pragmatic Programmer* (DRY) — book, not fetchable | MD-T3, MD-T3-S ("a number lives in one place"). Remains C. |
| NIST SP 800-218 (SSDF v1.1) practice-level text — metadata page fetched, practice statements are PDF-only and were not extracted | nothing in this slice depends on it; recorded for completeness. |
| ISO 8601-1:2019 — paywalled | superseded here by RFC 3339, which is free and normative for the claim in (g). |
| Google SRE, playbooks/MTTR claim — not present in the Being On-Call chapter as fetched | MD-T9 (runbooks). Remains C. |

---

## Files read

- `areas/data-security.md` (93 lines, in full)
- `areas/method-documentation.md` (86 lines, in full)
- `SKILL.md` (105 lines, in full; rows 62–75 and 79–92 assessed for inclusion)
- `briefs/phase-2-data.md` (63 lines, context only)
- `briefs/phase-6-documentation.md` (60 lines, context only)
- `briefs/phase-7-handover.md` (39 lines, context only)
- `templates/decision-record.md` (66 lines, context only)
- `README.md` lines 25–48 (context: the Origin and Status sections, for the provenance-label question)

Two context-only findings worth carrying forward, both outside the table: brief `R2.4`'s test ("with the DB reachable and a token expired-but-entity-still-valid, access is granted") is the operative form of the P1 above and needs the same correction; and brief `R6.7`'s "whatever has never been executed is declared as such at the top" is the labelling idiom the skill should extend to its own evidence.
