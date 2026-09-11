# Phase 4 Brief: Interface

Common header: as in `phase-1-gates.md`, plus: **the table shell and the field registry are built by the sibling skill `design-software-properly` (Phase 3)**: repairs here land on the shell when it exists, on the existing list components otherwise, and are repeated once the shell arrives; never add a per-caller parameter to a shared component to make a repair fit. Reference: `areas/interface.md`, `areas/user-communication.md`.

**In stages.** Stage A: `R4.1` alone (tokens: everything else renders through them). Stage B: `R4.2`–`R4.10` in parallel on distinct files. Between stages: the verifier.

---

### R4.1 Color tokens and color-by-verb language
`model: sonnet` · files: CSS tokens, button classes, `docs/conventions/color-language.md` (these are defaults: if the host project already has a docs language and folder convention, use it — the stack map records it)
CONTEXT: button variants today: <list>; colors outside the tokens: <n> (from D4); color by section? <yes/no>.
GOAL: variants = verbs (create / send / destroy filled / revoke outlined / archive / go-back neutral / navigate transparent); one page that states the meaning of every variant; no color or spacing value outside the tokens; the section color stays a separate variable.
HOW: replace arbitrary colors with tokens; map every existing button onto its verb; the transparent variant never carries a destructive action.
TEST: grep `#[0-9a-f]{6}|\[[0-9]+px\]` on the components = 0 or documented; build green.
DONE: table variant | verb | where used.

### R4.2 Auto-apply filter panel
`model: sonnet` · files: `components/admin/filter-panel.tsx` (or the host project's equivalent), the pages with an "apply" button
CONTEXT: pages with an "apply" button: <list>; facets counted over: <population>.
GOAL: a state-agnostic panel (`fields`, `facets`, `applied`, `onApply`, `onReset`) that applies itself after ~300 ms, mounted next to the table shell built by the sibling skill `design-software-properly` when it exists (next to the existing list otherwise); chips showing the applied state; facets counted on the shown population (in memory if the rows are in memory, in the DB on the same set if paginated); filters on the left.
DON'T: use a confirm button; show a "promised" count before applying; count on the current page only.
TEST: debounce test (two quick toggles = one query); facets-on-population test.
DONE: list of pages without the button; exceptions with a reason written in the code.

### R4.3 Single view per list (deletion: ask first)
`model: sonnet` · files: the alternative views approved for deletion, the survivor
CONTEXT: alternative renderings of `<E>`: <list>; deletion approved for: <list>; what was true only in the deleted ones: <list>.
GOAL: one view; whatever was true of the others carried into the survivor.
TEST: grep of the removed views with no remaining callers, tests included; e2e green.
DONE: list of views removed; functions carried into the survivor.

### R4.4 Read-only by default, mounted and hidden editors
`model: sonnet` · files: `useEditMode` hook (new or existing — or the host project's equivalent), the entity records `<list>`, test on the `FormData`
CONTEXT: records always in edit mode: <list>; `disabled` on editors: <file:line>.
GOAL: record read-only by default; "Edit" as `?edit=1` with `history.replaceState`; editors **mounted and hidden** with CSS, never `disabled` and never unmounted; `beforeunload` only when dirty.
HOW: the submitted `FormData` must contain every field even after read → Edit → Cancel → Edit.
TEST: a test that reads the real `FormData` and counts the fields; canary: put `disabled` on one field, the test must turn red.
DONE: `grep disabled` on the components = 0 or documented; records converted.

### R4.5 Two tracks for actions
`model: sonnet` · files: the tables with bulk actions exposed as a row button, `useRowSelection` (or the host project's equivalent)
CONTEXT: bulk actions exposed as a row button: <list>.
GOAL: bulk = checkbox plus toolbar; row = appears on hover or focus; selection with a declared policy (`reset` / `intersect` / `keep`), never a boolean.
TEST: e2e green; no action applicable to multiple rows is exposed as a row button.
DONE: table action | track.

### R4.6 Command feedback, discriminated outcomes, isolated irreversible action
`model: sonnet` · files: `ViewLink`/`useViewNavigation` (or the host project's equivalents), the actions returning `{ok:true}` for different outcomes, the Trash page
CONTEXT: commands without feedback: <list>; ambiguous outcomes: <list>; permanent deletion reachable from: <pages>.
GOAL: every navigation command dims with `aria-busy` while waiting; every outcome is a closed enumeration; permanent deletion lives only in the trash, behind a typed confirmation word; every write invalidates what it changed (see R3.4).
DON'T: put a skeleton on frequent commands; use a single outcome for different cases.
TEST: enumeration test; test that the record does not expose permanent deletion.
DONE: list of commands with feedback; enumerated outcomes.

### R4.7 Per-route skeletons and navigation
`model: sonnet` · files: missing `loading.tsx` files, sidebar, breadcrumb
CONTEXT: routes without a skeleton: <list>; sidebar push? <yes/no>; breadcrumb: <one step / full path / absent>.
GOAL: per-route skeleton in the real metric; sidebar as a three-state, persisted overlay; breadcrumb with the full path resolved in a single function (never in the layout).
TEST: build green; test of the breadcrumb resolution function.
DONE: list of routes covered.

### R4.8 Readable errors and distinct states
`model: sonnet` · files: client-facing message module (`lib/user-error.ts` or the host project's equivalent), the list shell (the sibling skill `design-software-properly`'s table shell when it exists, the existing list components otherwise), the components that render errors, the actions that return to the client, a new static rule
CONTEXT: from D4: `error.message` or a digest sent to the client at <file:line>; lists that render the error inside their "empty" branch: <list>; false zeros: <list>.
GOAL: no technical message on screen: every error becomes `{title, whatToDo, id}`, and the detail goes to the server log under the same id; the list shell renders five distinct states (loading, empty, empty-after-filter with the search box still visible, error with "retry," truncated with "at least N"); unknown data = "—", never 0; static rule with a fixture that forbids `error.message`, stack traces and digests reaching the client.
DON'T: name tables, fields or exceptions in a message; use a generic "Done"; let a `catch` forward the raw message.
TEST: five-states test on the shell; test that a read error does not render "no results"; static rule with fixtures; canary.
DONE: grep `error.message` toward the client = 0; five-states test list; list of rewritten messages.

### R4.9 Labels, hints, tooltips, glossary
`model: sonnet` · files: form-field primitive, the forms with fields missing a label or hint (from D4), icon-only buttons, `docs/conventions/glossary.md` (new), script `check-glossary.mjs` (new — or the host project's equivalent)
CONTEXT: fields without a label: <n>; non-obvious ones without a hint: <n>; icons without a tooltip: <n>; synonyms found: <table term | where>.
GOAL: every field with a real label (the placeholder is not a label), required marked, a hint for format, example or effect where the field is not obvious, an error next to the field with the identical wording across every entry point (create, edit, import); every icon with no text carries a tooltip AND `aria-label`; a glossary with one name per concept and a script that hunts for forbidden synonyms in sources, the guide, and email templates.
DON'T: write a hint that repeats the label; use a mouse-only tooltip; use internal code terms in user-facing text.
TEST: grep of fields without a label = 0; grep of icons without `aria-label` = 0; glossary script at zero; test that the validation wording is identical across entry points.
DONE: before/after counts; glossary with the terms and the synonyms replaced.

### R4.10 Outcomes after every action, confirmations with quantities, announced expirations, self-explaining reports
`model: sonnet` · files: outcome component (toast or banner, with `aria-live`), actions with a generic outcome (from D4), confirmations for irreversible actions, the three expiry points (session, lock, token), the reports (import, sync, send)
CONTEXT: actions without an outcome or with a generic "Done": <list>; confirmations without a quantity: <list>; expirations rendered as a technical error: <file:line>; reports without the reason for discards: <list>.
GOAL: every action responds with the discriminated outcome rendered in words (how many succeeded, how many not, and why) in a component with `aria-live`; every irreversible action asks for confirmation with a quantity and a typed word, and states what will be lost; every expiry announces itself beforehand, and afterward shows a readable request (password, new link) instead of a technical error; every report lists accepted, discarded and why, with a discards file and glossary terminology.
DON'T: show "Operation completed" for a partial action; show a confirmation with no number.
TEST: discriminated-outcome → text test; test on the three expiry points; test that the report contains the reason for every discard.
DONE: list of actions with an outcome; confirmations with quantities; readable expirations; one sample report read without the code.
