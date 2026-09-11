# Data, security, migrations, integrations

Principle: **verify permissions on the database, not in the repository; exercise channels live — never infer one from the channel next to it.**

## Target state

### Modeling
- [ ] An **external source** flows in one direction only; the reverse direction is removed from the code, not switched off with a flag.
- [ ] Unsubscribe ≠ deletion ≠ "removed at the source": three events, three effects.
- [ ] Consent is **read**, never inferred: an absent state means "we don't know," never a no.
- [ ] Personal-data deletion suppresses durably via a **hash**, anonymizes dependencies, and re-admits only on confirmation; the export scope and the deletion scope must match.
- [ ] Tombstones and a trash bin: permanent deletion **only from the trash**.
- [ ] "Not a duplicate" is a fact (who, when), and it is revocable.
- [ ] Numbers get counted; write "—" when unknown, never 0; a cap declares `truncated`.
- [ ] Attributes get promoted to real columns once something filters or sorts on them.
- [ ] Dates are compared as **instants**, never as re-read strings.

### Security
- [ ] An env module with **fail-fast** startup in production: presence, "not the placeholder," mutual consistency.
- [ ] Secrets are **distinct per purpose** (data signing, session), required, and different from one another.
- [ ] Secrets stay server-side only; a clean secrets scan.
- [ ] **Deny-all row-level security** on every table, no policy for public roles until real database identities exist; verified with a query.
- [ ] Grants on every sensitive function **verified on the database** after every schema deploy.
- [ ] Signed tokens with a **separated rejection cause** (unreadable / invalid signature / expired), signature verified before every query.
- [ ] Online, the entity read from the database decides; offline, the token decides.
- [ ] Test and reset endpoints disabled by default, with a check that they are absent in production.
- [ ] Every defense **fails closed**: if the guard, the rate limiter, or the token check errors, it denies; never "let it through when unsure." One test per defense that simulates the failure and verifies the rejection.
- [ ] Rate limiting on every authentication endpoint, or any endpoint that enumerates identities, with the policy **decided and written down** (per IP or per person, grace allowance, threshold on a shared gate).
- [ ] An access-revocation runbook with a "what it hits, what it doesn't" table (changing a password does not revoke a signed cookie; rotating the session secret does).

### Migrations and environments
- [ ] **Idempotent migrations**, never squashed; replay proven on an empty project.
- [ ] Migrations applied and verified on the database **before** pushing the code that uses them.
- [ ] **A single source-of-truth database**: CLI, MCP, and app point to the same project, verified before every write command.
- [ ] Every function rewrite starts from the **latest** definition and **reasserts the grants**.

### Integrations and operations
- [ ] Automated backup with verification of **arrival** (one row per run, written by the last link in the chain), not of departure.
- [ ] Restore tested end-to-end at least once with a count comparison; if not done, **declared** as tech debt.
- [ ] Every channel (email, alerts, dead-letter, sync) exercised live with an **injected failure**.
- [ ] Structured logs with no personal data; alerts guarded against an alert that stays permanently stuck on.
- [ ] Post-write navigation happens server-side (`redirect()` inside the action, after invalidations), never a client push after a server action.

## What to measure

1. **Env**: is there a single module? What happens in production with a missing variable, or one equal to the example placeholder?
2. **Policies**: `select tablename, rowsecurity from pg_tables where schemaname='public'`; `select * from pg_policies`. From the database, not from the repository.
3. **Grants on sensitive functions**:
   ```sql
   select p.proname, array_to_string(p.proacl, ' | ')
   from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public';
   ```
   Only the expected roles should appear (normally `postgres` / `service_role`).
4. **Migrations**: headers read by family (policies, grants, indexes, functions, tombstones, promoted columns); did a function rewritten several times start each time from the latest definition?
5. **Environments**: compare the CLI's project reference against the app's env host.
6. **Secrets**: run a scan (gitleaks or equivalent); check for public variables that contain keys.
7. **Tokens**: does verification distinguish the three outcomes? Does the expiry baked into the token win even when the database is reachable?
8. **Channels**: for each one, the date of the last live test and how arrival was confirmed.
9. **Backup**: how is success determined — from the last link in the chain, or from the first HTTP 200?
10. **Dates**: where are re-read strings from the database being compared (`!==` between timestamps)?

## Repairs

The path is the briefs: `briefs/phase-2-data.md` R2.1–R2.7; `briefs/phase-7-handover.md` R7.1–R7.6. Diagnosis measures: D2.

## Rules with mechanical verification

- No sensitive function is executable by public roles: query `pg_proc.proacl`.
- `revoke … from public` **is not enough**: revoke explicitly from `public, anon, authenticated`, plus `alter default privileges … revoke execute on functions`.
- `create or replace function` **resets grants**: reassert them in every migration that touches the function, and verify afterward.
- Rewrite from the latest definition: grep every migration that touches the function, diff against the most recent one.
- The app refuses to start without secrets: a test that boots with `NODE_ENV=production` and a missing variable.
- A migration run twice does not fail: an idempotency test.
- Dates as instants: dedicated helpers, a test on both literal forms (`+00:00` and `Z`); the fake does not reproduce the defect because it has no real columns.
- Backup success read from the run row (`finished_at`, `complete`, `errors` empty).
- CLI on the same database as the app: compare before every write command.

## Known traps

- **`revoke from public`** that leaves public roles holding default privileges.
- **`create or replace`** resetting grants: the same function closed off, over and over.
- **Rebuilding from an old version**: a silent regression, a column goes back to NULL with no error.
- **Code deployed before the migration**: the adapter sends every field, the database rejects the whole write.
- **CLI connected to the wrong project**: `db push` succeeds and reports success.
- **An email provider that rejects an empty array** (`tags: []`): only the message family missing that field fails — the alerts — while real emails hide the failure. Omit the field when empty; test the alert channel live.
- **A timestamp re-read in a different form**: `!==` is always true.
- **A token's baked-in expiry applied even online**: the copy inside the QR code becomes more authoritative than the real entity.
- **Changing a password, expecting it to revoke sessions**: the cookie is signed, not checked against the password.
- **`router.push()` after a server action**: navigation lost, intermittently.
- **An unexpected foreign-key cascade** during a remediation pass: stop and ask.
- **A "succeeded" from the first link** in the backup chain, while the last one never arrives.
- **A defense that fails open**: a `catch` around the rate limiter or guard that lets traffic through on failure, "so as not to block users." On failure: deny, and alert.
