# 03c — Evidence: interface + user-communication

Slice: `areas/interface.md` (71 lines), `areas/user-communication.md` (62 lines), plus the
`SKILL.md` rows whose subject is interface behaviour, forms, feedback, messages, states or naming
(§ *What a production-grade product is* items 4–5, two *Excuses and reality* rows, one *Red flag*).
Every restatement carries the id of the area claim it echoes with the suffix `-S`.
Corpus at `evolve/audit-01` / `c32367a`. All fetches accessed **2026-09-11**.
Full citations: `audit/sources-c.md`.

**Classification rule used when one checklist line bundles several claims** (many do): the row takes
the class of the warrant that makes the *operative instruction* true or binding; any secondary
warrant is named in the `source` cell. Where a line's operative instruction is a product policy that
no external authority mandates, the row is **C**, even when its *mechanism* is spec-verified —
those cases are marked `mech: <source>` so the coverage pass can see them.

## Count by class

| class | count | % |
|---|---|---|
| S — Standard (clause-level) | 19 | 22.6% |
| P — Published evidence | 19 | 22.6% |
| V — Vendor primary | 1 | 1.2% |
| M — Mechanically checkable (described, **not shipped**) | 14 | 16.7% |
| C — Craft, n=1 | 31 | 36.9% |
| **total rows** | **84** | 100% |

Area rows only (67, excluding the 17 `-S` restatements): S 13 · P 13 · V 1 · M 14 · C 26.

**The sentence that count implies, plainly:** fewer than half of these instructions can be traced to
anything outside the author's own project — 31 of 84 rows are one team's practice, 14 more are
checks the skill describes but does not ship, and only 20 rest on a named standard or a vendor's own
documentation — yet all 84 are written in the same flat imperative, so a reader cannot tell the
clause of WCAG from the habit of one back-office.

## Load-bearing claim c

**Claim, verbatim** — `areas/interface.md:64`:
> **`disabled` on a read-only editor**: the field never enters `FormData`, and save reads it as cleared. Hide it with CSS instead.

restated at `SKILL.md:66`:
> A `disabled` field is omitted from `FormData`: the save reads it as cleared. Mounted and hidden.

**Verdict: TRUE-WITH-CAVEAT.** The first half is exactly the HTML Living Standard. The second half
("the save reads it as cleared") is not a spec consequence: the spec makes the entry *absent*; what
the server then does with an absent key is the handler's behaviour, not the platform's.

**Evidence.**

1. Disabled controls are excluded from the entry list — HTML Living Standard § 4.10.22.4
   *Constructing the entry list*, step 3 (last updated 8 September 2026),
   <https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#constructing-form-data-set>:
   > "For each element `field` in `controls` … If any of the following are true: `field` has a `datalist` element ancestor; **`field` is disabled**; … then continue."

   The same step defines `controls` as "a list of all the **submittable elements whose form owner is
   form**" — so an *unmounted* editor is absent for the same reason. The skill's "never unmounted"
   is correct and has the same source.

2. `new FormData(form)` runs that very algorithm — XMLHttpRequest Standard § 5 *Interface FormData*
   (Living Standard, last updated 18 August 2026), <https://xhr.spec.whatwg.org/#dom-formdata>:
   > "Let `list` be the result of **constructing the entry list** for `form` and `submitter`."

   So a client-side `new FormData(form)` and a native submit agree. The skill's claim is not a React
   behaviour; React is not involved.

3. Definition of "disabled" — HTML LS § 4.10.19.5:
   > "A form control is **disabled** if … the element is a `button`, `input`, `select`, `textarea`, or form-associated custom element, and the `disabled` attribute is specified on this element (regardless of its value)"

   and (important for the "or a `fieldset`" case the skill never mentions) "the element is a
   descendant of a `fieldset` element whose `disabled` attribute is specified".

4. The contrasting case, `readonly` — HTML LS § 4.10.5.3.3 *The readonly attribute*:
   > "The difference between `disabled` and `readonly` is that read-only controls can still function, whereas disabled controls generally do not function as controls until they are enabled. This is spelled out … elsewhere … (for example … **when constructing the entry list**)."

   `readonly` controls **are** submitted: they are not in the exclusion list. `readonly` is also the
   attribute whose name matches the skill's own intent ("read-only editor") and it is never
   mentioned in either area file.

5. The skill's remedy is sound but incomplete. A control hidden with CSS is still in `controls`,
   still not disabled, still has a name — so it is still submitted; the spec's exclusion list has no
   rendering condition. But HTML LS § 4.10.21.2 *Constraint validation*, "interactively validate the
   constraints":
   > "If one of the controls is **not being rendered** (e.g. it has the `hidden` attribute set), then user agents **may report a script error**."

   A hidden field that is `required` (or otherwise invalid) therefore blocks submission with no
   user-visible message. "Hide it with CSS" needs "and drop client-side constraints on hidden
   fields, or server-validate them".

**Exact text change proposed** (`areas/interface.md:64`, replacing the current bullet):

> - **`disabled` on a read-only editor**: a disabled control is excluded from the form's entry list
>   (HTML § 4.10.22.4), so the field is **absent** from `FormData` — not empty, absent — and a save
>   that writes every submitted key, or reads the missing key as `""`, clears it. Unmounting the
>   field does the same. Hide it with CSS instead (a hidden control is still submitted), and make
>   sure no hidden field carries `required`: an unrendered invalid control blocks submission with no
>   visible error (HTML § 4.10.21.2). If the field must stay editable-looking but uneditable, the
>   attribute is `readonly` — read-only controls are still submitted.

The same two-word fix applies to `SKILL.md:66`: "A `disabled` field is **absent from** `FormData`:
a save that writes every submitted key reads it as cleared. Mounted and hidden."

## Traceability table

`(labeled: no)` on a C row = the skill does not mark that item as craft anywhere at the point of use.

| id | file:line | claim (verbatim, trimmed) | class | source | verification |
|---|---|---|---|---|---|
| I-P1 | areas/interface.md:3 | "one path to do a thing — never two screens that answer the same question differently" | C | adjacent: NN/g H4 (labeled: no) | could not verify — no standard or study mandates a single path per task |
| I-TS1 | areas/interface.md:11 | "Every list has **one** view. No alternative rendering (list / grid / grouped) of the same data." | C | adjacent: NN/g H4, H8 (labeled: no) | could not verify — no primary source forbids alternative renderings |
| I-TS2 | areas/interface.md:12 | "Filters sit on the left and **apply themselves** after a short debounce. No \"Apply\" button." | C | adjacent: WCAG 3.2.2 (A), 4.1.3 (AA) (labeled: no) | could not verify — no source for left placement or for a debounce threshold; see Accessibility posture |
| I-TS3 | areas/interface.md:13 | "Facets are counted **on the population the table is showing**" | C | (labeled: no) | could not verify — correctness convention, no external source |
| I-TS4 | areas/interface.md:14 | "Sorting covers every scalar column; multi-value fields are excluded on purpose." | C | (labeled: no) | could not verify — no external source |
| I-TS5 | areas/interface.md:15 | "Entity pages open **read-only**; \"Edit\" is URL state (`replaceState`, never a navigation)" | C | mech: HTML LS § 7.2.5 (labeled: no) | "Updates the classic history API state of the active session history entry … and its URL to `url`." |
| I-TS6 | areas/interface.md:16 | "Read-only editors stay **mounted and hidden**, never `disabled`, never unmounted." | S | HTML LS § 4.10.22.4; § 4.10.19.5 | "field is disabled … then continue"; `controls` = "all the submittable elements whose form owner is form" |
| I-TS7 | areas/interface.md:17 | "Creation happens in **navigable sections**, not a forced step-by-step wizard" | C | adjacent: NN/g H3, H7 (labeled: no) | could not verify — no primary source ranks sections over wizards |
| I-TS8 | areas/interface.md:18 | "Actions have **two tracks**: bulk via selection + toolbar; row-level via hover/focus." | C | adjacent: WCAG 2.5.8, 1.4.13 (labeled: no) | could not verify — no source; the hover/focus track raises the SCs named |
| I-TS9 | areas/interface.md:19 | "Button color follows the **verb** (create / send / destroy / archive / navigate), never the section." | S | WCAG 2.2 SC 3.2.4 (AA); caveat SC 1.4.1 (A) | "Components that have the same functionality within a set of web pages are identified consistently." |
| I-TS10 | areas/interface.md:20 | "No color or spacing outside the tokens." | C | adjacent: WCAG 1.4.3 (AA) (labeled: no) | could not verify — design-system convention; tokens themselves are never contrast-tested |
| I-TS11 | areas/interface.md:21 | "Every command gives **feedback** (dimming and `aria-busy`; skeletons only on navigations…)" | P | NN/g Heuristic 1; NN/g *Response Time Limits* (1993); ARIA 1.2 `aria-busy` | "The design should always keep users informed about what is going on, through appropriate feedback within a reasonable amount of time." |
| I-TS12 | areas/interface.md:22 | "Every route with reads has a **skeleton** that mirrors the real layout." | V | Next.js docs, `loading.js` (App Router, v14.2.35 → v16.3.4) | "An instant loading state is fallback UI that is shown immediately upon navigation." |
| I-TS13 | areas/interface.md:23 | "Every ambiguous outcome is a **discriminated outcome**, never `{ok:true}` for different cases." | C | adjacent: NN/g H1 (labeled: no) | could not verify — code-shape convention; the user-facing half is U-TS4 |
| I-TS14 | areas/interface.md:24 | "The irreversible action is **physically isolated** (only from the trash), with a typed confirmation word." | S | WCAG 2.2 SC 3.3.4 (AA); NN/g H5 | "Confirmed: A mechanism is available for reviewing, confirming, and correcting information before finalizing the submission." |
| I-TS15 | areas/interface.md:25 | "Previews read the live `FormData`, not the database." | C | mech: XHR LS § 5 (labeled: no) | "Let `list` be the result of constructing the entry list for `form` and `submitter`." |
| I-TS16 | areas/interface.md:26 | "Country icons … are **local SVGs** next to the text, `aria-hidden`; never emoji, never a CDN." | C | mech: WCAG 1.1.1 (A), ARIA 1.2 `aria-hidden`, UTS #51 § Flags (labeled: no) | "The actual flag displayed for the pair may be different on different platforms" — variance, not a prohibition |
| I-TS17 | areas/interface.md:27 | "Side navigation collapses **as an overlay** (never a push), with three persisted states." | C | (labeled: no) | could not verify — no external source |
| I-TS18 | areas/interface.md:28 | "The breadcrumb carries the **full path**; its resolution lives in a single function." | C | adjacent: WCAG 2.4.8 (AAA) (labeled: no) | "Information about the user's location within a set of web pages is available." — AAA, and silent on "full path" |
| I-TS19 | areas/interface.md:29 | "The home page is a **difference** (+N in 30 days), not a static total" | C | (labeled: no) | could not verify — no external source |
| I-TS20 | areas/interface.md:30 | "Every shared component forwards native ARIA attributes (e.g. `aria-sort` on headers)." | S | WAI-ARIA 1.2 § `aria-sort`; ARIA APG *Table Pattern*; React 19.3 docs | "Indicates if items in a table or grid are sorted in ascending or descending order. Authors SHOULD only apply this property to table headers" |
| I-TS21 | areas/interface.md:31 | "Every exception to the items above has its reason written in the code" | C | (labeled: no) | could not verify — ISO 9241-110 clause text not obtainable (paywalled) |
| I-R1 | areas/interface.md:54 | "A vocabulary's coverage … is verified by reading the **source of truth** (the icon package's CSS…)" | M | — | described, not shipped: the corpus is 33 Markdown files, no script or fixture |
| I-R2 | areas/interface.md:55 | "An unrecognized value is rejected identically on create and on edit: same function, same message, two tests." | M | — | described, not shipped |
| I-R3 | areas/interface.md:56 | "Hyphenated ARIA props aren't checked by the type system: declare them explicitly and test them" | M | premise contradicted by `@types/react` — see P2-2 | described, not shipped; `"aria-sort"?: "none" \| "ascending" \| "descending" \| "other"` is declared in `interface AriaAttributes` |
| I-R4 | areas/interface.md:57 | "Colors and spacing outside tokens: verified by grep, or by a lint rule." | M | — | described, not shipped |
| I-R5 | areas/interface.md:58 | "No \"Apply\" button: grep on the filter components returns empty, or every hit has a reason" | M | — | described, not shipped |
| I-R6 | areas/interface.md:59 | "No `disabled` on an editor: grep returns empty …; the read → Edit → Cancel → Edit cycle is tested" | M | — | described, not shipped; the underlying fact is S (see claim c) |
| I-R7 | areas/interface.md:60 | "Every route with reads has a skeleton file: a script compares routes against skeletons." | M | mech: Next.js `loading.js` file convention | described, not shipped |
| I-T1 | areas/interface.md:64 | "`disabled` on a read-only editor: the field never enters `FormData`, and save reads it as cleared." | S | HTML LS § 4.10.22.4, § 4.10.5.3.3, § 4.10.21.2 | "field is disabled … then continue" — TRUE-WITH-CAVEAT, see *Load-bearing claim c* |
| I-T2 | areas/interface.md:65 | "A shell that hides the panel at zero rows … Use two distinct \"empty\" states" | C | adjacent: NN/g H1 (labeled: no) | could not verify — same content as U-TS2's fifth state |
| I-T3 | areas/interface.md:66 | "Unifying three selection policies (clear / intersect / keep) silently changes the intended behavior" | C | (labeled: no) | could not verify — n=1 observation |
| I-T4 | areas/interface.md:67 | "A \"data-driven\" threshold that still produces different behavior page by page: remove it, don't narrow it." | C | (labeled: no) | could not verify — n=1 observation |
| I-T5 | areas/interface.md:68 | "Two buttons landing on the same place because of a `redirect()` born somewhere else: the tests stay green." | C | (labeled: no) | could not verify — n=1 observation |
| I-T6 | areas/interface.md:69 | "A \"promised\" count left in front of a button that no longer exists: remove it together with the button." | C | (labeled: no) | could not verify — n=1 observation |
| I-T7 | areas/interface.md:70 | "A skeleton on a frequent command: the layout jumps at every click" | P | NN/g *Response Time Limits* (1993), display inertia | "putting one up would violate the principle of display inertia (flashing changes on the screen so rapidly that the user cannot keep pace…)" |
| U-P1 | areas/user-communication.md:3 | "the person using the product doesn't have your logs." | P | NN/g Heuristic 9; Heuristic 1 | "Error messages should be expressed in plain language (no error codes), precisely indicate the problem, and constructively suggest a solution." |
| U-P2 | areas/user-communication.md:5 | "user-facing text … is written in the host project's language. These instructions are in English." | C | adjacent: WCAG 3.1.1 (A) (labeled: no) | could not verify — product policy; 3.1.1 requires the language be *programmatically determinable*, not which language |
| U-TS1 | areas/user-communication.md:9 | "**No technical error on screen**: never `error.message`, a stack trace, a digest, a raw HTTP code" | P | NN/g Heuristic 9; WCAG 3.3.1 (A) for the text-description half | "expressed in plain language (no error codes) … avoid technical jargon" |
| U-TS2 | areas/user-communication.md:10 | "**Error ≠ empty.** An error state never disguises itself as \"no results.\" Five states…" | P | NN/g Heuristic 1, Heuristic 9 | "The design should always keep users informed about what is going on" — the *number five* is craft |
| U-TS3 | areas/user-communication.md:11 | "An unknown value renders as \"—\" or \"not recorded\", never as 0 or an empty string." | C | (labeled: no) | could not verify — no external source |
| U-TS4 | areas/user-communication.md:12 | "**Every action responds** with a worded outcome: what was done, on how many, what wasn't, and why." | P | NN/g Heuristic 1; exposure half: WCAG 4.1.3 (AA) | "keep users informed about what is going on, through appropriate feedback within a reasonable amount of time" |
| U-TS5 | areas/user-communication.md:13 | "**Every field has a real label** (a placeholder is not a label); every non-obvious field has a hint" | S | WCAG 3.3.2 (A), 1.3.1 (A), 3.3.1 (A); HTML LS § 4.10.5.3.10 | "Labels or instructions are provided when content requires user input."; "The placeholder attribute should not be used as an alternative to a label." |
| U-TS6 | areas/user-communication.md:14 | "**Every icon-only control has a tooltip and an `aria-label`**" | S | WCAG 1.1.1 (A), 4.1.2 (A); HTML LS § 3.2.6.1; ARIA 1.2 `aria-label` | "If non-text content is a control … then it has a name that describes its purpose." |
| U-TS7 | areas/user-communication.md:15 | "**Irreversible actions** ask for confirmation with a quantity … and a typed word" | S | WCAG 2.2 SC 3.3.4 (AA) | "For web pages that … modify or delete user-controllable data … Confirmed: A mechanism is available for reviewing, confirming, and correcting information" |
| U-TS8 | areas/user-communication.md:16 | "**Long-running actions** show progress; an **expiry** … is announced beforehand" | S | WCAG 2.2.1 (A), 2.2.6 (AAA), 4.1.3 (AA); NN/g Response Times | "The user is warned before time expires and given at least 20 seconds to extend the time limit" |
| U-TS9 | areas/user-communication.md:17 | "**Reports** … explain themselves: accepted, rejected and why, a downloadable file of rejects" | C | adjacent: NN/g H9 (labeled: no) | could not verify — no external source for report structure |
| U-TS10 | areas/user-communication.md:18 | "A **glossary**: the same thing has the same name everywhere … no synonyms" | S | WCAG 2.2 SC 3.2.4 (AA); NN/g H2, H4 | "Components that have the same functionality within a set of web pages are identified consistently." |
| U-TS11 | areas/user-communication.md:19 | "The **guide** is reachable from where it's needed (a contextual link), searchable by intent" | P | NN/g Heuristic 10; adjacent WCAG 3.2.6 (A) | "Help and documentation content should be easy to search and focused on the user's task." |
| U-TS12 | areas/user-communication.md:20 | "**Baseline accessibility**: visible focus, sufficient contrast, `role=\"status\"` or `aria-live` …, `aria-busy`" | S | WCAG 2.4.7 (AA), 1.4.3 (AA), 4.1.3 (AA), 2.1.1 (A); ARIA 1.2 `status`, `aria-live` | "status messages can be programmatically determined through role or properties such that they can be presented … without receiving focus" |
| U-TS13 | areas/user-communication.md:21 | "Every **visible error path has a test** on the displayed text (or on the message class)." | C | (labeled: no) | could not verify — process convention; its check is U-R7 |
| U-R1 | areas/user-communication.md:44 | "No technical message reaches the client: a custom static rule on action return values and components." | M | — | described, not shipped: no rule file, no fixture in the corpus |
| U-R2 | areas/user-communication.md:45 | "Every list component renders the five states: a test on the shell." | M | — | described, not shipped |
| U-R3 | areas/user-communication.md:46 | "Every input has a label: grep `<input` … with no `id` bound to a `<label>` and no `aria-label` = 0" | M | mech: HTML LS § 4.10.4 | described, not shipped; "The `label` element represents a caption in a user interface … associated with a specific form control" |
| U-R4 | areas/user-communication.md:47 | "Every icon-only button has `aria-label`: grep = 0." | M | mech: ARIA 1.2 `aria-label` | described, not shipped |
| U-R5 | areas/user-communication.md:48 | "Same validation wording on every entry point: a test that compares the strings." | M | — | described, not shipped |
| U-R6 | areas/user-communication.md:49 | "Forbidden terms: a script checks the glossary against sources, the guide, and email templates." | M | — | described, not shipped |
| U-R7 | areas/user-communication.md:50 | "Every visible error path has a test: a path/test list, verified." | M | — | described, not shipped |
| U-T1 | areas/user-communication.md:54 | "A read error falling into the \"no results\" branch: whoever looks believes there's nothing there." | P | NN/g Heuristic 1, Heuristic 9 | "keep users informed about what is going on" / "precisely indicate the problem" |
| U-T2 | areas/user-communication.md:55 | "0 instead of \"not recorded\": a false number read as a true one." | C | (labeled: no) | could not verify — no external source |
| U-T3 | areas/user-communication.md:56 | "\"Operation complete\" on an action that skipped half the rows." | P | NN/g Heuristic 1 | "When users know the current system status, they learn the outcome of their prior interactions" |
| U-T4 | areas/user-communication.md:57 | "A placeholder used as a label: it disappears the moment someone starts typing." | S | HTML LS § 4.10.5.3.10 | "the hint given by the control's label is shown at all times; the … placeholder … is shown before the user enters a value" |
| U-T5 | areas/user-communication.md:58 | "A tooltip that only fires on mouse hover: it doesn't exist on keyboard or touch" | S | HTML LS § 3.2.6.1; WCAG 1.4.13 (AA), 2.1.1 (A) | "requiring a pointing device such as a mouse to cause a tooltip to appear, which excludes keyboard-only users and touch-only users" |
| U-T6 | areas/user-communication.md:59 | "An expiry rendered as a technical error: the person thinks the product is broken" | P | NN/g Heuristic 9; adjacent WCAG 2.2.1 (A) | "Tell users what went wrong in language they will understand — avoid technical jargon." |
| U-T7 | areas/user-communication.md:60 | "A confirmation with no quantity: \"delete?\" gives nothing to count." | P | NN/g Heuristic 5 | "present users with a confirmation option before they commit to the action" — the *quantity* is craft |
| U-T8 | areas/user-communication.md:61 | "Messages written by someone who knows the code: they name tables, fields, exceptions." | P | NN/g Heuristic 2, Heuristic 9 | "Use words, phrases, and concepts familiar to the user, rather than internal jargon." |
| U-T9 | areas/user-communication.md:62 | "Synonyms born by accident: \"client\" on one page, \"contact\" on another, \"person\" in the email" | P | NN/g Heuristic 4; S half: WCAG 3.2.4 (AA) | "Users should not have to wonder whether different words, situations, or actions mean the same thing." |
| I-P1-S | SKILL.md:34 | "One path to do a thing." | C | restatement of I-P1 (labeled: no) | restatement; see I-P1 |
| I-TS1-S | SKILL.md:34 | "one view per list" | C | restatement of I-TS1 (labeled: no) | restatement; see I-TS1 |
| I-TS2-S | SKILL.md:34 | "filters that apply themselves" | C | restatement of I-TS2 (labeled: no) | restatement; see I-TS2 |
| I-TS6-S | SKILL.md:34 | "read-only pages with mounted, hidden editors" | S | restatement of I-TS6 — HTML LS § 4.10.22.4 | restatement; see I-TS6 |
| I-TS9-S | SKILL.md:34 | "Color by verb" | S | restatement of I-TS9 — WCAG 3.2.4 (AA) | restatement; see I-TS9 |
| I-TS11-S | SKILL.md:34 | "feedback on every command" | P | restatement of I-TS11 — NN/g H1 | restatement; see I-TS11 |
| I-TS14-S | SKILL.md:34 | "irreversible actions physically isolated" | S | restatement of I-TS14 — WCAG 3.3.4 (AA) | restatement; see I-TS14 |
| I-TS21-S | SKILL.md:34 | "every exception has its reason written" | C | restatement of I-TS21 (labeled: no) | restatement; see I-TS21 |
| U-P1-S | SKILL.md:35 | "Users read what happened and what to do." | P | restatement of U-P1 — NN/g H9 | restatement; see U-P1 |
| U-TS1-S | SKILL.md:35 | "No technical error on screen" | P | restatement of U-TS1 — NN/g H9 | restatement; see U-TS1 |
| U-TS2-S | SKILL.md:35 | "five distinct states" | P | restatement of U-TS2 — NN/g H1 | restatement; see U-TS2 |
| U-TS4-S | SKILL.md:35 | "worded outcomes" | P | restatement of U-TS4 — NN/g H1 | restatement; see U-TS4 |
| U-TS5-S | SKILL.md:35 | "labels, hints, tooltips" | S | restatement of U-TS5 — WCAG 3.3.2 (A) | restatement; see U-TS5 |
| U-TS10-S | SKILL.md:35 | "one name per concept" | S | restatement of U-TS10 — WCAG 3.2.4 (AA) | restatement; see U-TS10 |
| I-T1-S | SKILL.md:66 | "A `disabled` field is omitted from `FormData`: the save reads it as cleared. Mounted and hidden." | S | restatement of I-T1 — HTML LS § 4.10.22.4 | "field is disabled … then continue" — TRUE-WITH-CAVEAT, see *Load-bearing claim c* |
| U-TS1-S2 | SKILL.md:73 | "Users have no logs. On screen: what happened, what to do, an id for support." | P | restatement of U-TS1 — NN/g H9 | restatement; see U-TS1 |
| I-TS13-S | SKILL.md:83 | "A single outcome (`{ok:true}`) for different results." | C | restatement of I-TS13 (labeled: no) | restatement; see I-TS13 |

Rows considered and excluded, with the reason:
`SKILL.md:84` ("\"Done\" said without the command that proves it, or read through a pipe") reads as
orchestration evidence, not a user-facing outcome — it belongs to the method slice.
The *What to measure* numbered lists (`areas/interface.md:37–44`, `areas/user-communication.md:25–36`)
are measurement procedure; their normative content is already carried by the Target-state and Rules
rows above, and no measure item states an obligation the table misses.

## Claims that are wrong or overstated

**P1 — the skill instructs something false**

*None found.* Every instruction in these two files is either true, or true with a caveat the skill
omits. The one factual statement that is false as written (I-R3) does not make its instruction wrong
— see P2-2.

**P2 — overstated, imprecise, or ambiguous**

| # | id | why | evidence | minimal text change |
|---|---|---|---|---|
| P2-1 | I-T1, I-T1-S | "the save reads it as cleared" states as a platform fact what is a handler's behaviour; the platform fact is *absence*. `readonly`, the contrasting attribute, is never named, and the CSS-hiding remedy can dead-lock a `required` field. | HTML LS § 4.10.22.4 (exclusion), § 4.10.5.3.3 (readonly is submitted), § 4.10.21.2 ("If one of the controls is not being rendered … user agents may report a script error") | see *Load-bearing claim c* for the full replacement bullet |
| P2-2 | I-R3 | "Hyphenated ARIA props aren't checked by the type system" is false: `@types/react` declares every `aria-*` prop, with literal value unions, on every DOM element. The real gap is a *shared component* that types the props but never spreads them onto the element — which is exactly what the prescribed test catches. | `@types/react` `index.d.ts`, `interface AriaAttributes`: `"aria-sort"?: "none" \| "ascending" \| "descending" \| "other" \| undefined;` | "A shared component only forwards `aria-*` if it both declares them (`React.ComponentProps<'th'>`) **and** spreads them onto the element; the type system cannot see the second half. Test it (`toHaveAttribute('aria-sort', …)`)." |
| P2-3 | I-TS11, I-TS11-S, U-TS12 | `aria-busy` is presented as the feedback for a command. In ARIA 1.2 it tells assistive technology to *defer* exposing changes; it is not an announcement. A dimmed control plus `aria-busy` leaves a screen-reader user with no status message, and WCAG's definition of a status message explicitly covers "the waiting state of an application". | WAI-ARIA 1.2 § `aria-busy`: "Indicates an element is being modified and that assistive technologies MAY want to wait until the modifications are complete before exposing them"; WCAG 2.2 § status message; SC 4.1.3 (AA) | "…feedback (dimming, `aria-busy` on the region being replaced, **and a `role=\"status\"` message naming the pending and the finished state** — `aria-busy` suppresses announcements, it does not make one)" |
| P2-4 | I-TS9, I-TS9-S | "Button color follows the verb" is sound consistency (3.2.4) but is stated without the constraint that makes it conformant: the verb must also be in the text or the accessible name, because color alone cannot carry it. | WCAG 2.2 SC 1.4.1 (A): "Color is not used as the only visual means of conveying information, indicating an action, prompting a response, or distinguishing a visual element." | append: "…never the section; the verb is always in the label too — color may reinforce it, never carry it alone." |
| P2-5 | I-TS14, U-TS7 | "physically isolated (only from the trash)" and the typed word are craft; the *binding* part — a confirmation step before a destructive write — is WCAG 3.3.4 at AA and is never cited, so a reader cannot tell which half is negotiable. | WCAG 2.2 SC 3.3.4 (AA), "Confirmed" | add after the bullet: "(the confirmation itself is WCAG 2.2 SC 3.3.4 AA for any screen that deletes user data; the trash-only placement and the typed word are this project's convention)" |
| P2-6 | U-TS2, U-TS2-S | "Five states" is presented as a closed set; the five are a good set but no source makes the number five normative, and the list omits the *stale/refreshing* state a back-office with cache invalidation actually needs. | NN/g H1 (visibility of system status) — no source enumerates five | "Distinct states, each rendered distinguishably — at least: loading; empty; empty-after-filter…; error (with retry); partial or truncated" |
| P2-7 | I-TS2 | "after a short debounce" has no number in the area file, while the brief fixes ~300 ms (`briefs/phase-4-interface.md:20`); no source is offered for either, and the auto-apply is not paired with the status message that makes the result count perceivable. | NN/g *Response Time Limits*: "1.0 second is about the limit for the user's flow of thought to stay uninterrupted"; WCAG 4.1.3 (AA) | "…apply themselves after a short debounce (the project's value, not a standard; keep the whole round-trip under one second) and announce the new result count in a `role=\"status\"`" |
| P2-8 | U-TS6, U-T5 | Requiring "a tooltip **and** an `aria-label`" is right, but leaves the tooltip itself unconstrained; a hover/focus tooltip must be dismissible, hoverable and persistent, and a tooltip whose text differs from the `aria-label` breaks voice control. | WCAG 2.2 SC 1.4.13 (AA); SC 2.5.3 (A): "the name contains the text that is presented visually" | append: "…`aria-label`; the tooltip is dismissible, hoverable and persistent (1.4.13) and its text is contained in the accessible name (2.5.3)." |
| P2-9 | I-TS16 | "never emoji" is right for a different reason than the file implies: the spec does not forbid flag emoji, it states that the glyph varies by platform and changes over time. "never a CDN" has no stated reason at all here. | Unicode UTS #51 v17.0 § Flags: "The actual flag displayed for the pair may be different on different platforms … The displayed flag may change over time" | "…never emoji (the flag glyph for a region varies by platform and changes over time — UTS #51), never a CDN (a third-party request on every screen)" |
| P2-10 | I-R1–I-R7, U-R1–U-R7 | The heading "Rules with **mechanical** verification" promises checks; the corpus ships none — 33 Markdown files, one `.gitattributes`, no script, no lint rule, no fixture. Each rule is a specification for a check someone else must write. | `find . -type f -not -path "./.git/*"` = 34 files, 33 of them `.md` | retitle "Rules that can be verified mechanically (the check is specified here, not shipped)" |

## Class-C items not labeled as craft

All 31 C rows are unlabeled at the point of use:

`I-P1`, `I-TS1`, `I-TS2`, `I-TS3`, `I-TS4`, `I-TS5`, `I-TS7`, `I-TS8`, `I-TS10`, `I-TS13`, `I-TS15`,
`I-TS16`, `I-TS17`, `I-TS18`, `I-TS19`, `I-TS21`, `I-T2`, `I-T3`, `I-T4`, `I-T5`, `I-T6`,
`U-P2`, `U-TS3`, `U-TS9`, `U-TS13`, `U-T2`,
and the restatements `I-P1-S`, `I-TS1-S`, `I-TS2-S`, `I-TS21-S`, `I-TS13-S`.

The skill does label its provenance once — `README.md:35`, "Distilled from the path of a real
back-office application (Next.js 14, Supabase, ~52k contacts, 426 commits … June-September 2026)" —
but `README.md` appears in no row of the Modes table (`SKILL.md:16–24`), so no run ever loads it.

**Proposed labeling mechanism, one line:** mark every craft item inline with a trailing `(n=1)` and
add one line under each area's *Target state* heading — "Items marked `(n=1)` come from one
back-office and are conventions, not requirements: a project may replace them, with the reason
written next to the screen it spares" — which reuses the exception rule the skill already has at
`areas/interface.md:31`.

## Accessibility posture

Taken together the two checklists would satisfy a real slice of WCAG 2.2 AA — labels and
instructions (3.3.2), error identification in text (3.3.1), confirmation before destructive writes
(3.3.4), consistent identification of the same command across pages (3.2.4), accessible names for
icon-only controls (1.1.1/4.1.2), visible focus and text contrast as *stated goals* (2.4.7, 1.4.3),
status messages for outcomes where `role="status"`/`aria-live` is actually used (4.1.3), and
`aria-sort` on sortable headers (4.1.2 + WAI-ARIA 1.2) — which is more than most back-office
checklists carry, and it maps one-to-one onto EN 301 549 V4.1.1 (2026-09) clause 9, whose every
requirement reads "Where ICT is, or includes, a web page, the web page shall satisfy WCAG 2.2
Success Criterion …". What it would **not** satisfy is conformance: WCAG conformance is per full
page against all Level A and AA criteria (§ 5.2), and the checklists have no measurement step for
contrast (the tokens are never tested, only required to exist), no reflow or zoom check, no focus
order or focus-appearance check, and — the sharpest gap — they treat `aria-busy` as the
announcement of a pending state when ARIA 1.2 defines it as an instruction to assistive technology
to *withhold* announcements, so a command's waiting state, which WCAG's own glossary calls a status
message, can end up perceivable only as a visual dimming. On the legal question: the European
Accessibility Act does **not** reach a B2B back-office. Article 2(2) opens "this Directive applies
to the following services **provided to consumers** after 28 June 2025" and lists a closed set
(electronic communications, access to audiovisual media, specified elements of passenger transport,
consumer banking, e-books and dedicated software, e-commerce services), while Article 3(20) defines
"'consumer' [as] any natural person who purchases the relevant product or is a recipient of the
relevant service for purposes which are **outside his trade, business, craft or profession**";
Article 31(2) sets application from 28 June 2025. A tool used by a client's own staff is therefore
out of scope — with two live exceptions the skill should state rather than assume: any screen of the
same system that a consumer reaches (an e-commerce or banking front end fed by this back-office) is
in scope on that date, and EN 301 549 becomes binding anyway through public procurement or through
Directive (EU) 2016/2102 if the client is a public-sector body (that directive's text could not be
fetched this session — see *Could not verify*). Criteria relevant to a back-office that **no**
checklist item in either file touches, for the coverage pass: **1.3.1** Info and Relationships (A) —
table header association, `fieldset`/`legend` grouping; **1.3.5** Identify Input Purpose (AA) —
`autocomplete` on personal-data fields, and this is a contacts product; **1.4.4** Resize Text and
**1.4.10** Reflow (AA) — dense tables at 320 px and 200 % zoom; **1.4.11** Non-text Contrast (AA) —
the contrast of the very tokens, icon-only buttons, input borders and the focus ring; **1.4.12**
Text Spacing (AA); **1.4.13** Content on Hover or Focus (AA) — the required tooltips must be
dismissible, hoverable, persistent; **2.1.2** No Keyboard Trap (A) — the typed-confirmation dialog;
**2.4.1** Bypass Blocks (A) — a skip link past the persistent sidebar; **2.4.2** Page Titled (A);
**2.4.3** Focus Order (A) — where focus lands when "Edit" mounts the hidden editors, and after an
auto-applied filter; **2.4.11** Focus Not Obscured (AA, new in 2.2) — the sticky bulk-action
toolbar over a focused row; **2.5.3** Label in Name (A); **2.5.8** Target Size Minimum (AA, new in
2.2) — the hover/focus row-action icons; **3.1.1** Language of Page (A); **3.2.2** On Input (A) — the
auto-applying filters must not move focus; **3.3.7** Redundant Entry and **3.3.8** Accessible
Authentication (A/AA, new in 2.2) — the re-login after the announced expiry; and, outside WCAG,
**EN 301 549 clause 12** (accessibility documentation and support), which a handover phase would
otherwise be the natural place to satisfy.

## Better sources found

- **Nielsen, *Response Time Limits*** (NN/g, 1993, from *Usability Engineering* ch. 5, citing Miller
  1968, Card et al. 1991, Myers 1985) — the 0.1 s / 1 s / 10 s limits, the "percent-done indicator
  above 10 seconds" rule, and the *display inertia* principle. Better than the ten heuristics for
  `I-TS11`, `I-T7`, `U-TS8`, and it gives `I-TS2`'s debounce a defensible ceiling.
- **HTML LS § 4.10.21.2** *interactively validate the constraints* — the failure mode of the skill's
  own CSS-hiding remedy (`I-T1`); not in the candidate corpus.
- **HTML LS § 4.10.5.3.3** *The readonly attribute* — the contrasting case for claim c, and the
  attribute the skill's own vocabulary ("read-only editor") implies but never names.
- **WCAG 2.2 SC 3.3.4 Error Prevention (Legal, Financial, Data), AA** — the real, binding basis for
  `I-TS14`/`U-TS7`; the candidate corpus listed only 3.3.1/3.3.3.
- **WCAG 2.2 SC 2.2.1 (A) and 2.2.6 (AAA)** — binding basis for `U-TS8`'s announced expiry.
- **WCAG 2.2 glossary, "status message"** — "…on the **waiting state of an application**, on the
  progress of a process…"; this is what converts `I-TS11` from craft into a 4.1.3 obligation.
- **EN 301 549 V4.1.1 (2026-09)** supersedes the V3.2.1 named in the candidate corpus and is aligned
  with WCAG 2.2 (V3.2.1 was aligned with WCAG 2.1); clause 9 maps SC-for-SC.
- **`@types/react` `interface AriaAttributes`** (DefinitelyTyped, the package's own source) —
  disproves `I-R3`'s premise.
- **Unicode UTS #51 v17.0 (rev. 29, 2025-09-04), § Flags** — the accurate reason for "never emoji".
- **ARIA APG, Alert Pattern** — "avoid designing alerts that disappear automatically"; bears on the
  auto-dismissing toast that `briefs/phase-4-interface.md:79` prescribes for outcomes.
- **Publications Office cellar** (`publications.europa.eu/resource/celex/…` with
  `Accept: application/xhtml+xml`) serves the official OJ text when EUR-Lex is behind its bot
  challenge — a working route to primary EU law for future passes.

## Could not verify

| source | needed for |
|---|---|
| ISO 9241-110:2020 clause text (abstract and scope fetched; body paywalled) | `I-TS14` (irreversible actions isolated), `I-TS21` (every exception has its reason written), `U-P1` (self-descriptiveness as a dialogue principle) |
| ISO 9241-171 (not fetchable) | software accessibility framing for `U-TS12` |
| Directive (EU) 2016/2102 (Web Accessibility Directive) full text — EUR-Lex behind an AWS WAF challenge, cellar returned HTTP 400 | whether a public-sector client's intranet/extranet back-office is in scope, and from which date |
| Miller (1968) and Card et al. (1991) primary papers (ACM paywall) | the empirical basis under NN/g *Response Time Limits*; cited here only through NN/g's own page |
| Any primary study on filter auto-apply vs. an "Apply" button, or on a 300 ms debounce | `I-TS2`, `I-R5` |
| Any primary source enumerating exactly five list states | `U-TS2`, `U-R2` |
| Platform evidence that Windows browsers do not render regional-indicator flag emoji | `I-TS16`'s "never emoji" (UTS #51 supports only the weaker "varies by platform") |
| A named standard or study for: one view per list, sidebar overlay vs. push, breadcrumb resolution in one function, home page as a difference, "—" for unknown values | `I-TS1`, `I-TS17`, `I-TS18`, `I-TS19`, `U-TS3` |

## Files read

- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\interface.md` (71 lines, in full)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\user-communication.md` (62 lines, in full)
- `C:\Users\Utente\Desktop\harden-codebase-properly\SKILL.md` (105 lines, in full; rows 34–35, 66, 73, 83 tabled)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-4-interface.md` (context only, not tabled)
- `C:\Users\Utente\Desktop\harden-codebase-properly\GLOSSARY.md` (context only, not tabled)
- `C:\Users\Utente\Desktop\harden-codebase-properly\README.md:35` (provenance line, quoted above)
- file inventory of the repository (`find`, 34 files: 33 `.md` + `.gitattributes`)
