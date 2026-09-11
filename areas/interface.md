# Interface behaviour

Principle: **one path to do a thing — never two screens that answer the same question differently, never two gestures for the same command.**

This area is about what the interface *does*: how lists are viewed, filtered and sorted, how entities are opened and edited, how commands respond, which colors mean which verb, where the irreversible action lives. How the interface is *built* (one table shell fed by a field registry, shared components as deep modules, no per-caller parameter, the primitives catalogue) is the subject of the sibling skill `design-software-properly` (its `areas/components.md`, Phase 3). Repairs here land on the shell when it exists, on the existing list components otherwise, and are repeated once the shell arrives; they never add a per-caller parameter to a shared component to make a behaviour fit.

Communication with the person using the product (readable errors, distinct states, labels, hints, tooltips, outcomes, glossary) lives in `user-communication.md` and is part of the same phase.

## Target state

- [ ] Every list has **one** view. No alternative rendering (list / grid / grouped) of the same data.
- [ ] Filters sit on the left and **apply themselves** after a short debounce. No "Apply" button. Chips show the applied state, never the draft.
- [ ] Facets are counted **on the population the table is showing**: in-memory rows are counted there; paged rows are counted in the database on the same set.
- [ ] Sorting covers every scalar column; multi-value fields are excluded on purpose.
- [ ] Entity pages open **read-only**; "Edit" is URL state (`replaceState`, never a navigation); you never leave a dirty form silently.
- [ ] Read-only editors stay **mounted and hidden**, never `disabled`, never unmounted `[HTML § 4.10.22.4]`.
- [ ] Creation happens in **navigable sections**, not a forced step-by-step wizard; the first section is enough to save.
- [ ] Actions have **two tracks**: bulk via selection + toolbar; row-level via hover/focus. Never the same gesture in both forms.
- [ ] Button color follows the **verb** (create / send / destroy / revoke-reversible / archive / go back / navigate), never the section `[SC 3.2.4]`; the verb is always in the label too: color may reinforce it, never carry it alone `[WCAG 2.2 SC 1.4.1]`. One page alone documents the variants.
- [ ] No color or spacing outside the tokens.
- [ ] Every command gives **feedback** (dimming, `aria-busy` on the region being replaced, **and a `role="status"` message naming the pending and the finished state**: `aria-busy` suppresses announcements, it does not make one `[WAI-ARIA 1.2; SC 4.1.3]`; skeletons only on navigations, never on frequent commands).
- [ ] Every route with reads has a **skeleton** that mirrors the real layout.
- [ ] Every ambiguous outcome is a **discriminated outcome**, never `{ok:true}` for different cases.
- [ ] The irreversible action is **physically isolated** (only from the trash), with a typed confirmation word (the confirmation is `[SC 3.3.4]`; trash-only placement and the typed word are this project's convention).
- [ ] Previews read the live `FormData`, not the database.
- [ ] Country icons and the like are **local SVGs** next to the text, `aria-hidden`; never emoji, never a CDN.
- [ ] Side navigation collapses **as an overlay** (never a push), with three persisted states.
- [ ] The breadcrumb carries the **full path**; its resolution lives in a single function.
- [ ] The home page is a **difference** (+N in 30 days), not a static total; warning blocks don't render when they have nothing to say.
- [ ] Every shared component forwards native ARIA attributes (e.g. `aria-sort` on headers) `[WAI-ARIA 1.2]`.
- [ ] Every exception to the items above has its reason written in the code, next to the screen it spares.

## What to measure

Inventory to produce, with file:line for every hit:

1. Alternative renderings per list (list / grid / grouped views of the same data).
2. Filters with an "Apply" button; filters not on the left; facets counted on a population other than the one shown.
3. `grep -rn "disabled" src/components`: editors disabled instead of hidden; entities always open in edit mode.
4. Bulk actions exposed as a row button; irreversible actions reachable from the entity page; selection policies (clear / intersect / keep) implemented as a boolean.
5. Commands without a pending state; `{ok:true}` outcomes standing in for different outcomes.
6. `grep -rnE "#[0-9a-fA-F]{3,8}|\[[0-9]+px\]" src`: colors and spacing outside the tokens; button variants and their meaning (by verb or by section?).
7. Routes with reads and no skeleton; sortable headers with no `aria-sort`; country icons as emoji or from a CDN.
8. Sidebar push vs overlay; breadcrumb depth and where it is resolved; home page as a total or a difference.

Component duplication (hand-built tables, twin filter panels, missing registry) is not measured here: the sibling skill's diagnosis D2 does it. If its report exists, read it; do not repeat it.

## Repairs

The path is the briefs: stages A–B of `briefs/phase-4-interface.md` (R4.1–R4.10), in the order given there. Diagnosis measures: D4.

## Rules with mechanical verification (specified here; the brief builds the check)

- A vocabulary's coverage (flags, countries, languages) is verified by reading the **source of truth** (the icon package's CSS, not an images folder).
- An unrecognized value is rejected identically on create and on edit: same function, same message, two tests.
- A shared component forwards `aria-*` only if it both declares them (`React.ComponentProps<'th'>`) **and** spreads them onto the element; the type system cannot see the second half. Test it (`toHaveAttribute('aria-sort', …)`).
- Colors and spacing outside tokens: verified by grep, or by a lint rule.
- No "Apply" button: grep on the filter components returns empty, or every hit has a reason next to it.
- No `disabled` on an editor: grep returns empty, or every hit has a reason next to it; the read → Edit → Cancel → Edit cycle is tested against the real `FormData`.
- Every route with reads has a skeleton file: a script compares routes against skeletons.

## Known traps

- **`disabled` on a read-only editor**: a disabled control is excluded from the form's entry list `[HTML § 4.10.22.4]`, so the field is **absent** from `FormData`, not empty, and a save that writes every submitted key clears it; unmounting does the same. Hide it with CSS (a hidden control is still submitted) and make sure no hidden field carries `required`: an unrendered invalid control blocks submission with no visible error `[HTML § 4.10.21.2]`. Editable-looking but uneditable is `readonly`: read-only controls are still submitted.
- **A shell that hides the panel at zero rows**: if search lives inside the panel, zero results hides the very box that produced them. Use two distinct "empty" states, `empty` / `emptyAfterFilter` (or the host project's equivalent).
- **Unifying three selection policies** (clear / intersect / keep) silently changes the intended behavior: make the union an explicit discriminated choice, never a silent default.
- **A "data-driven" threshold** that still produces different behavior page by page: remove it, don't narrow it.
- **Two buttons landing on the same place** because of a `redirect()` born somewhere else: the tests stay green. You only see it by looking at the page the way a user would.
- **A "promised" count** left in front of a button that no longer exists: remove it together with the button.
- **A skeleton on a frequent command**: the layout jumps at every click; dimming, `aria-busy` and a `role="status"` message are the feedback for commands, skeletons are for navigations.
