# Glossary

Canonical software-design terms used throughout this skill, with the meaning they carry here and the Italian word used in the original. Instructions use these terms exactly; outputs (reports, decision records, commit messages) use the host project's language.

## Architecture (terms borrowed from the sibling skill `design-software-properly`)

The architecture vocabulary (layers, dependency rule, bounded context, single writer, deep module, one implementation per concept, effect map) lives in the sibling skill's glossary. Only the two terms this skill uses on its own are kept here.

| Term | Meaning here | Italian |
|---|---|---|
| **Fake adapter / real adapter** | In-memory implementation used by tests vs the production one; both implement the same port; known divergences live in one module (built by the sibling skill, brief R2.5) | adapter mock / reale |
| **Hotspot** | Intersection of largest files and most-changed files over six months; measured by the sibling skill, read here to weigh the plan | punto caldo |

## Quality and verification

| Term | Meaning here | Italian |
|---|---|---|
| **Quality gate** | typecheck, lint at zero errors, unit tests, real production build, static rules with their own tests; each sees a different error class | cancello |
| **Real build** | The only gate that prerenders and catches non-serializable values crossing the server → client boundary | build reale |
| **Custom static rule** | A semgrep-style rule on a domain invariant, shipped with `ruleid:`/`ok:` fixtures and run offline | regola statica |
| **Tested against** | Header on every unit test: `fake | real adapter | both | none`; a green test on the fake certifies the fake | prova contro |
| **Canary** | Deliberately breaking an invariant to prove the test turns red; no test is trusted before it has failed once | canarino |
| **Characterization test** | A test that pins current behavior before refactoring; the safety net required before splitting | rete di prove |
| **Property-based / model-based test** | Generated sequences over a state machine, with a seed corpus and a canary switch | modelli |
| **Warm-up** | Visiting every route once before end-to-end tests so on-demand compilation does not masquerade as failures | riscaldamento |
| **Stale test** | A test asserting behavior the product changed on purpose; rewritten on the property, not on today's value | prova stantia |
| **Dirty fixture corpus** | Test data with deliberately injected defects plus a manifest (oracle) stating how many of each | corpus sporco |
| **Flow test** | One test per cross-module process asserting every landing point, plus one per failing step with its compensation | test di flusso |
| **Mutation testing** | Measures how much tests are worth; replaced by targeted sabotage per invariant when the machine cannot sustain it | sabotaggio mirato |
| **Adversarial bug hunt** | Rounds of hunters with different lenses, a skeptic, referees; nothing reported without an executed reproduction | caccia a giri |
| **Verifier** | A separate subagent that checks brief compliance line by line, then quality (gates, re-measurement, canary, diff scope); the orchestrator trusts it, not the implementer | verificatore |
| **Ruling** | `Ruling: <decision> — <why> — <cost if wrong>` recorded when a finding is parked; nothing disappears silently | ruling |
| **Re-diagnosis** | Phase 0 rerun with the same commands at the end; every measure compared before/after | prova del nove |

## Data and security

| Term | Meaning here | Italian |
|---|---|---|
| **Fail-fast configuration** | The app refuses to start in production if a required secret is missing, equals the example placeholder, or two secrets coincide | env fail-fast |
| **Row-level security (RLS)** | Deny-all policies on every table; verified with a query on the database, never assumed from the repository | policy di riga |
| **Grants** | Function privileges verified on `pg_proc.proacl`; `revoke from public` does not cover `anon`/`authenticated`; `create or replace` resets grants | grant |
| **Idempotent migration** | Rerunnable (`if not exists`), never squashed, applied and verified before the code that uses it ships | migrazione idempotente |
| **Single source database** | CLI, MCP and app point to the same project, verified before every write | un solo database di verità |
| **Fail closed** | When a guard, rate limiter or token check errors, it denies; never "let it through when unsure" | fallisce chiusa |
| **Signed token with separated rejection causes** | unreadable / invalid signature / expired; online the database decides, offline the token does | token con causa di rifiuto |
| **Live channel check** | Every channel (email, alerts, backup, dead-letter, sync) exercised at least once with an injected failure and seen arriving | canale percorso dal vivo |

## Interface and user-facing communication

| Term | Meaning here | Italian |
|---|---|---|
| **Single view per list** | One rendering of a list; no alternative list/grid/grouped views of the same data | vista unica |
| **Field registry** | One declaration per field from which column, filter, facet count, sort and export derive; built by the sibling skill `design-software-properly` (brief R3.1), fed here | registro dei campi |
| **Table shell** | The one generic table component (headers, body, column picker, sorting, empty states) fed by the field registry; built by the sibling skill `design-software-properly` (brief R3.2); the five states and the filter panel land on it here | guscio tabella |
| **Auto-apply filter panel** | Left-side filters applied after a short debounce; no "Apply" button; chips show applied state | filtri automatici |
| **Facets on the shown population** | Counts computed on exactly the rows the table is showing (in memory or in the database on the same set) | facette |
| **Read-only by default** | Entity pages open read-only; "Edit" is URL state (`replaceState`); editors stay mounted and hidden, never `disabled` (disabled fields are omitted from `FormData`) | sola lettura, editor montati |
| **Two tracks for actions** | Bulk actions via selection + toolbar; row actions on hover/focus; never both forms for the same gesture | due binari |
| **Color by verb** | Same command, same color everywhere (create, send, destroy, revoke, archive, back, navigate); section color is a separate variable | colore per verbo |
| **Command feedback** | Every command shows a pending state (`aria-busy`, dimming) and a worded outcome; skeletons only for route-level loads | segnale |
| **Discriminated outcome** | A closed enum of what happened, rendered in words (how many succeeded, how many not and why); never `{ok:true}` for different cases | esito enumerato |
| **Five distinct states** | loading · empty · empty-after-filter (search box still visible) · error (with retry) · partial/truncated ("at least N") | cinque stati |
| **Cap never shown as a total** | Any capped count carries `truncated: true` and the screen says so | tetto non spacciato per totale |
| **Readable error** | Never `error.message`, stack or digest on screen: what happened, what to do, a correlation id; details go to the server log under the same id | errore leggibile |
| **Physical isolation of irreversible actions** | Permanent deletion only from the trash, with a typed confirmation word and the quantity | irreversibile isolata |
| **Ubiquitous language / glossary** | One name per concept across UI, guide, emails, reports, messages | glossario |

## Method

| Term | Meaning here | Italian |
|---|---|---|
| **Orchestrator** | The session that runs the procedure: reasons, dispatches, reads reports, decides, verifies; never writes code | chi conduce |
| **Task brief** | The self-contained instruction a subagent receives: verified diagnosis, files, goal, how, don'ts, test, done criteria, report contract | brief |
| **Context isolation** | A subagent receives only its brief, the interfaces it needs and global constraints; never session history; it never spawns subagents | isolamento del contesto |
| **Read-only round / repair round** | Measuring and repairing never happen in the same round; proposals stay proposals until approved | giro di sola misura |
| **Autonomy contract** | What the orchestrator does alone, what it asks first, what it never does | contratto di autonomia |
| **Decision record** | One file per reversible choice: when, status, problem, choice, rejected alternatives and why, where it lives in code, what would reopen it (ADR-style) | scheda di decisione |
| **Lessons file** | One line per phase: what surprised, which brief was ambiguous, which traps; read by the next phase's briefs and by whoever maintains the skill | lezioni |
| **Ordered plan** | The work sequence computed from the diagnosis: gates first, irreversible risks next, then the multipliers this skill owns, then improvements once each, then tests and docs; structural steps are scheduled from the sibling skill | piano ordinato |
| **Handover** | Delivery to the client: new accounts, empty database, regenerated secrets, replayed migrations, proven backup and restore, signed minutes | consegna |
| **Mode** | The entry point chosen from the argument (`diagnose`, `plan`, `run <N>`, `review`, `maintain`, `status`); each loads only its own files | modalità |
| **Status file** | `docs/remediation/status.md`: one row per step with evidence; a row without evidence is not done; the next phase cannot start over an empty cell | file di stato |
| **Decision Q&A** | The one multiple-choice question per phase that turns reversible choices into decision records: problem, 2-4 options with cost and risk, recommendation, what happens if nobody decides | domande sulle decisioni |
| **Guard set** | The target-state rules a machine enforces, wired into `verify` and CI: static rules, declared tests, glossary and coverage checks, canaries, the live channel table; the structural guards are the sibling skill's | guardie |
| **Change-time protocol** | Before a change: blast radius, applicable rules, decision records; after: review and verifier; then registers updated | protocollo al cambiamento |
| **Drift check** | Periodic delta diagnosis on the files changed since the last synthesis; a closed defect found again is a P1 | controllo di deriva |
