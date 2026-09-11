# Communication with the person using the product

Principle: **the person using the product doesn't have your logs.** Everything that goes wrong, every ambiguous state, every non-obvious field gets explained on screen, in the reader's language, with the next step. A message is written for someone who didn't write the code.

Note: user-facing text — messages, labels, the glossary, reports, the in-app guide — is written in the host project's language. These instructions are in English.

## Target state

- [ ] **No technical error on screen**: never `error.message`, a stack trace, a digest, a raw HTTP code, or a table/field name. On screen: what happened, what the person can do, a short correlation id for support. The technical detail goes to the server log under the same id.
- [ ] **Error ≠ empty.** An error state never disguises itself as "no results." Five states, each rendered distinguishably: loading; empty; empty-after-filter (with the search box that produced it still visible); error (with "retry"); partial or truncated ("at least N", "the first N of M").
- [ ] An unknown value renders as "—" or "not recorded", never as 0 or an empty string.
- [ ] **Every action responds** with a worded outcome: what was done, on how many, what wasn't, and why. Discriminated outcomes, never `{ok:true}` rendered as "Done" for different cases. An action with no visible response is a lost click.
- [ ] **Every field has a real label** (a placeholder is not a label); every non-obvious field has a hint (expected format, example, effect); required fields are marked; validation errors sit next to the field, with **the same wording on every entry point** (create, edit, import).
- [ ] **Every icon-only control has a tooltip and an `aria-label`**; every non-obvious command says what it does beforehand (tooltip) and what it did afterward (outcome).
- [ ] **Irreversible actions** ask for confirmation with a quantity ("delete 43 contacts?") and a typed word, and state what will be lost.
- [ ] **Long-running actions** show progress; an **expiry** (session, lock, token) is announced beforehand, and the rejection afterward is a readable request (password, new link), not an error.
- [ ] **Reports** (import, sync, bulk send) explain themselves: accepted, rejected and why, a downloadable file of rejects, the same terminology as the interface.
- [ ] A **glossary**: the same thing has the same name everywhere (interface, guide, email, reports, messages); no synonyms; internal code terms never surface.
- [ ] The **guide** is reachable from where it's needed (a contextual link), searchable by intent, with real screenshots.
- [ ] **Baseline accessibility**: visible focus, sufficient contrast, `role="status"` or `aria-live` on outcome messages, `aria-busy` during waits, commands reachable by keyboard.
- [ ] Every **visible error path has a test** on the displayed text (or on the message class).

## What to measure

1. Technical errors on screen: grep `error.message`, `String(err`, `digest`, `JSON.stringify(err` in components and in server-action return values reaching the client; `catch` blocks that forward the raw message.
2. Indistinct states: for every list component, which of the five states does it render, and does the error branch fall into "empty"?
3. False zeros: counts that show 0 when the data is actually absent or the read failed.
4. Actions without an outcome: actions that return with no message; a generic "Done" for different outcomes.
5. Fields: inputs with no `<label>` or `aria-label`; a placeholder used as a label; non-obvious fields with no hint; unmarked required fields; validation wording that differs between create, edit, and import for the same field.
6. Icons and commands: icon-only buttons with no `title` and no `aria-label`; commands whose effect can't be guessed from the name.
7. Irreversible actions: confirmations with no quantity; with no typed word.
8. Expiry: what does someone see when they come back with an expired session or lock (a stack trace, a blank page, a password prompt)?
9. Reports: sample one real report — is it understandable without opening the code? do the rejects state why?
10. Glossary: list the terms used for the same concept across the interface, the guide, email, and reports.
11. Accessibility: tab through a page (is focus visible?); token contrast; `aria-live` on messages.
12. Tests: how many visible error paths have a test on their text.

## Repairs

The path is the briefs: `briefs/phase-4-interface.md` R4.8–R4.10; the static rule for readable errors is built in R4.8 (R1.2 covers guards, PII in logs, service keys, server directives). Diagnosis measures: D4 items 8–11.

## Rules with mechanical verification

- No technical message reaches the client: a custom static rule on action return values and components.
- Every list component renders the five states: a test on the shell.
- Every input has a label: grep `<input`, `<select`, `<textarea` with no `id` bound to a `<label>` and no `aria-label` = 0.
- Every icon-only button has `aria-label`: grep = 0.
- Same validation wording on every entry point: a test that compares the strings.
- Forbidden terms: a script checks the glossary against sources, the guide, and email templates.
- Every visible error path has a test: a path/test list, verified.

## Known traps

- **A read error falling into the "no results" branch**: whoever looks believes there's nothing there.
- **0 instead of "not recorded"**: a false number read as a true one.
- **"Operation complete"** on an action that skipped half the rows.
- **A placeholder used as a label**: it disappears the moment someone starts typing.
- **A tooltip that only fires on mouse hover**: it doesn't exist on keyboard or touch; you need `aria-label` too.
- **An expiry rendered as a technical error**: the person thinks the product is broken, not that they need to log in again.
- **A confirmation with no quantity**: "delete?" gives nothing to count.
- **Messages written by someone who knows the code**: they name tables, fields, exceptions.
- **Synonyms born by accident**: "client" on one page, "contact" on another, "person" in the email; the reader thinks these are three different things.
