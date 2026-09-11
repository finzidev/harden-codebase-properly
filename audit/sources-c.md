# Sources — 03c (interface + user-communication)

Every source below was fetched and read in this session; the quoted text in `audit/03-evidence-c.md`
was taken from the fetched bytes, never from memory. Primary sources only: specifications, the
standards bodies' own documents, the vendors' own documentation, the Official Journal text, and the
NN/g primary pages for the heuristics (expert-derived, not experimental — noted where cited).

Format: **title** | body/author | version or edition | year | URL | accessed | ids that rest on it.

---

## Specifications (S)

1. **HTML Living Standard — § 4.10.22.4 "Constructing the entry list"** | WHATWG | Living Standard,
   last updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#constructing-form-data-set>
   | accessed 2026-09-11 | `I-TS6`, `I-TS6-S`, `I-T1`, `I-T1-S`, `I-R6`, `I-TS15` (mechanism),
   load-bearing claim c.

2. **HTML Living Standard — § 4.10.19.5 "Enabling and disabling form controls: the `disabled`
   attribute"** | WHATWG | Living Standard, last updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#attr-fe-disabled> |
   accessed 2026-09-11 | `I-TS6`, `I-T1`, load-bearing claim c (definition of "disabled", including
   the `fieldset` case the skill omits).

3. **HTML Living Standard — § 4.10.21.2 "Constraint validation" (interactively validate the
   constraints)** | WHATWG | Living Standard, last updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#interactively-validate-the-constraints>
   | accessed 2026-09-11 | `I-T1` caveat, P2-1 (a `required` field hidden with CSS blocks submission;
   "user agents may report a script error").

4. **HTML Living Standard — § 4.10.5.3.3 "The `readonly` attribute"** | WHATWG | Living Standard,
   last updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/input.html#the-readonly-attribute> | accessed 2026-09-11 |
   load-bearing claim c (contrasting case: read-only controls *are* submitted), P2-1.

5. **HTML Living Standard — § 4.10.5.3.10 "The `placeholder` attribute"** | WHATWG | Living
   Standard, last updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/input.html#the-placeholder-attribute> | accessed
   2026-09-11 | `U-TS5`, `U-TS5-S`, `U-T4`.

6. **HTML Living Standard — § 4.10.4 "The `label` element"** | WHATWG | Living Standard, last
   updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/forms.html#the-label-element> | accessed 2026-09-11 |
   `U-TS5`, `U-R3`.

7. **HTML Living Standard — § 3.2.6.1 "The `title` attribute"** | WHATWG | Living Standard, last
   updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute> | accessed 2026-09-11 |
   `U-TS6`, `U-T5` ("Relying on the `title` attribute is currently discouraged … requiring a pointing
   device such as a mouse … excludes keyboard-only users and touch-only users").

8. **HTML Living Standard — § 7.2.5 "The `History` interface"** | WHATWG | Living Standard, last
   updated 8 September 2026 | 2026 |
   <https://html.spec.whatwg.org/multipage/nav-history-apis.html#the-history-interface> | accessed
   2026-09-11 | `I-TS5` (mechanism: `replaceState` updates the active session history entry and its
   URL; it is not a navigation).

9. **XMLHttpRequest Standard — § 5 "Interface `FormData`"** | WHATWG | Living Standard, last updated
   18 August 2026 | 2026 | <https://xhr.spec.whatwg.org/#interface-formdata> | accessed 2026-09-11 |
   load-bearing claim c, `I-TS15` (`new FormData(form)` runs the HTML entry-list algorithm — the
   claim is platform behaviour, not React behaviour).

10. **Web Content Accessibility Guidelines (WCAG) 2.2** | W3C (AG WG) | W3C Recommendation
    12 December 2024 (this version: REC-WCAG22-20241212) | 2024 |
    <https://www.w3.org/TR/WCAG22/> | accessed 2026-09-11 | SC 1.1.1 → `U-TS6`, `I-TS16`;
    SC 1.3.1 → `U-TS5`; SC 1.4.1 → `I-TS9`, P2-4; SC 1.4.3 → `U-TS12`, `I-TS10`; SC 1.4.13 → `U-T5`,
    P2-8; SC 2.1.1 → `U-TS12`; SC 2.2.1 / 2.2.6 → `U-TS8`, `U-T6`; SC 2.4.6 → `U-TS5`;
    SC 2.4.7 → `U-TS12`; SC 2.4.8 → `I-TS18`; SC 2.5.3 → P2-8; SC 3.2.2 → `I-TS2`;
    SC 3.2.4 → `I-TS9`, `I-TS9-S`, `U-TS10`, `U-TS10-S`, `U-T9`; SC 3.2.6 → `U-TS11`;
    SC 3.3.1 → `U-TS1`, `U-TS5`; SC 3.3.2 → `U-TS5`, `U-TS5-S`; SC 3.3.3 → `U-TS5`;
    SC 3.3.4 → `I-TS14`, `I-TS14-S`, `U-TS7`, P2-5; SC 4.1.2 → `U-TS6`, `I-TS20`;
    SC 4.1.3 + the glossary definition of "status message" → `U-TS4`, `U-TS12`, `I-TS11`, P2-3, P2-7;
    § 5.2 conformance requirements → Accessibility posture.

11. **Accessible Rich Internet Applications (WAI-ARIA) 1.2** | W3C (ARIA WG) | W3C Recommendation
    06 June 2023 (this version: REC-wai-aria-1.2-20230606) | 2023 |
    <https://www.w3.org/TR/wai-aria-1.2/> | accessed 2026-09-11 | `aria-busy` → `I-TS11`,
    `I-TS11-S`, `U-TS12`, P2-3; `aria-sort` → `I-TS20`; `aria-live` and role `status` → `U-TS12`,
    `U-TS4`; `aria-hidden` → `I-TS16`; `aria-label` → `U-TS6`, `U-R4`.

12. **ARIA Authoring Practices Guide — Table Pattern** | W3C Web Accessibility Initiative (WAI) |
    living document, © 2026 | 2026 | <https://www.w3.org/WAI/ARIA/apg/patterns/table/> | accessed
    2026-09-11 | `I-TS20` ("If the table contains sortable columns or rows, `aria-sort` is set to an
    appropriate value on the header cell element").

13. **ARIA Authoring Practices Guide — Alert Pattern** | W3C Web Accessibility Initiative (WAI) |
    living document, © 2026 | 2026 | <https://www.w3.org/WAI/ARIA/apg/patterns/alert/> | accessed
    2026-09-11 | Accessibility posture and *Better sources found* ("avoid designing alerts that
    disappear automatically") — bears on the auto-dismissing outcome toast in
    `briefs/phase-4-interface.md:79`.

14. **EN 301 549 V4.1.1 — Accessibility requirements for ICT products and services** | ETSI / CEN /
    CENELEC | V4.1.1 (2026-09), harmonised European standard | 2026 |
    <https://www.etsi.org/deliver/etsi_en/301500_301599/301549/04.01.01_60/en_301549v040101p.pdf> |
    accessed 2026-09-11 | Accessibility posture; clause 9 ("Where ICT is, or includes, a web page,
    the web page shall satisfy WCAG 2.2 Success Criterion …") backs every S row that cites a WCAG SC;
    clause 12 named as an untouched obligation. Confirms alignment with WCAG 2.2 and the mapping
    tables for Directive (EU) 2016/2102 and Directive (EU) 2019/882.

15. **EN 301 549 V3.2.1 — Accessibility requirements for ICT products and services** | ETSI / CEN /
    CENELEC | V3.2.1 (2021-03) | 2021 |
    <https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf> |
    accessed 2026-09-11 | fetched only to establish that it is superseded by V4.1.1 (V3.2.1 aligns
    with WCAG 2.1, V4.1.1 with WCAG 2.2) — see *Better sources found*.

16. **Directive (EU) 2019/882 of the European Parliament and of the Council of 17 April 2019 on the
    accessibility requirements for products and services (European Accessibility Act)** | European
    Parliament and Council of the European Union | OJ L 151, 7.6.2019, p. 70 (CELEX 32019L0882) |
    2019 | official OJ rendering served by the EU Publications Office:
    <https://publications.europa.eu/resource/celex/32019L0882> (`Accept: application/xhtml+xml`;
    EUR-Lex's own HTML endpoint is behind a bot challenge — see below) | accessed 2026-09-11 |
    Accessibility posture: Article 2(1)–(2) scope, Article 3(20) definition of "consumer",
    Article 3(30) "e-commerce services", Article 31(1)–(2) transposition and application from
    28 June 2025.

17. **Unicode Technical Standard #51: Unicode Emoji** | Unicode Consortium (eds. M. Davis,
    N. Holbrook) | Version 17.0, revision 29, dated 2025-09-04 | 2025 |
    <https://www.unicode.org/reports/tr51/> | accessed 2026-09-11 | `I-TS16`, P2-9 (§ Flags caveats:
    the glyph for a regional-indicator pair varies by platform and changes over time).

## Published evidence (P)

18. **10 Usability Heuristics for User Interface Design** | Jakob Nielsen, Nielsen Norman Group |
    original 1994, page last reviewed 30 January 2024 | 1994/2024 |
    <https://www.nngroup.com/articles/ten-usability-heuristics/> | accessed 2026-09-11 |
    **expert-derived, not experimental** (the page states the set was refined "based on a factor
    analysis of 249 usability problems [Nielsen 1994a]"). H1 → `I-TS11`, `I-TS11-S`, `U-TS2`,
    `U-TS2-S`, `U-TS4`, `U-TS4-S`, `U-T1`, `U-T3`; H2 → `U-T8`, `U-T9`; H3 → `I-TS7` (adjacent);
    H4 → `I-P1`, `I-TS1`, `U-T9`; H5 → `I-TS14`, `U-T7`; H9 → `U-P1`, `U-P1-S`, `U-TS1`, `U-TS1-S`,
    `U-TS1-S2`, `U-T1`, `U-T6`; H10 → `U-TS11`.

19. **Response Time Limits** (excerpt from *Usability Engineering*, ch. 5) | Jakob Nielsen, Nielsen
    Norman Group | article of 1 January 1993, citing Miller 1968, Card et al. 1991, Myers 1985 |
    1993 | <https://www.nngroup.com/articles/response-times-3-important-limits/> | accessed
    2026-09-11 | `I-TS11`, `I-T7` (display inertia), `U-TS8` (percent-done above ~10 s), P2-7
    (the one-second flow-of-thought limit as a ceiling for the debounce).

## Vendor primary (V)

20. **`loading.js` — File-system conventions** | Next.js (Vercel), official documentation | docs for
    version 16.3.4, page last updated 8 June 2026 | 2026 |
    <https://nextjs.org/docs/app/api-reference/file-conventions/loading> | accessed 2026-09-11 |
    `I-TS12`, `I-R7` ("An instant loading state is fallback UI that is shown immediately upon
    navigation").

21. **`loading.js` — File Conventions (version 14 documentation)** | Next.js (Vercel), official
    documentation | docs for version 14.2.35, page last updated 27 October 2023 | 2023 |
    <https://nextjs.org/docs/14/app/api-reference/file-conventions/loading> | accessed 2026-09-11 |
    `I-TS12` version range: the convention holds for the App Router from v14 (the stack
    `README.md:35` records) through v16.

22. **Common components (e.g. `<div>`)** | React, official documentation (react.dev) | react@19.3 |
    2026 | <https://react.dev/reference/react-dom/components/common> | accessed 2026-09-11 |
    `I-TS20` ("In React, all ARIA attribute names are exactly the same as in HTML").

23. **`@types/react` — `index.d.ts`, `interface AriaAttributes`** | DefinitelyTyped contributors
    (the published type definitions for React) | `master` branch as served 2026-09-11 | 2026 |
    <https://raw.githubusercontent.com/DefinitelyTyped/DefinitelyTyped/master/types/react/index.d.ts>
    | accessed 2026-09-11 | `I-R3`, P2-2 — `"aria-sort"?: "none" | "ascending" | "descending" |
    "other" | undefined;` is declared, which disproves "hyphenated ARIA props aren't checked by the
    type system".

## Fetched but usable only at catalogue level

24. **ISO 9241-110:2020 — Ergonomics of human-system interaction — Part 110: Interaction
    principles** | ISO | second edition (ed. 2) | 2020 |
    <https://www.iso.org/standard/75258.html> | accessed 2026-09-11 | scope and abstract confirmed
    ("This document describes principles for interaction between a user and a system that are
    formulated in general terms"); the normative clauses are paywalled, so **no row rests on it** —
    it is listed in *Could not verify* for `I-TS14`, `I-TS21`, `U-P1`.

## Fetches attempted and failed

- **EUR-Lex HTML/PDF/ELI endpoints for CELEX 32019L0882** — HTTP 202 with an AWS WAF JavaScript
  challenge on every attempt (three retries with a cookie jar); `WebFetch` returned an empty
  document. Worked around via the Publications Office cellar (entry 16), which serves the same
  official OJ rendering.
- **Directive (EU) 2016/2102 (CELEX 32016L2102)** — EUR-Lex blocked as above; the cellar endpoint
  returned HTTP 400. Not verified; recorded in *Could not verify*.
- **ETSI deliver directory listing** (`https://www.etsi.org/deliver/etsi_en/301500_301599/301549/`)
  — returned empty; individual version PDFs fetch correctly by direct URL (entries 14, 15).
