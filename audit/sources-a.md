# Sources — slice A (`areas/quality.md`, `areas/performance.md`)

Every entry below was **fetched and read in this session**. Nothing here is cited from memory.
Sources that could not be fetched are **not** in this file; they are listed in
`audit/03-evidence-a.md` § Could not verify.

All accesses: **2026-09-11**.

Installed-version anchors pinned this session from the npm registry (`registry.npmjs.org/<pkg>/latest`,
accessed 2026-09-11): `next` **16.3.4**, `@playwright/test` **1.63.0**, `@stryker-mutator/core` **10.0.0**.

---

## Standards and specifications (class S)

| # | Title | Body / author | Version or edition | Year | URL | Accessed | Ids resting on it |
|---|---|---|---|---|---|---|---|
| S1 | *Shell Command Language*, § 2.9.2 Pipelines ("Exit Status") and § 2.5.2 (`$?`), § 2.13 `set -o pipefail` | The Open Group / IEEE — Base Specifications **Issue 8**, IEEE Std 1003.1-2024 | Issue 8 | 2024 | https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html | 2026-09-11 | Q-T1b, Q-R4, Q-K1, Q-T1b-S, V-e1 |
| S2 | *RFC 9111 — HTTP Caching* | IETF (Fielding, Nottingham, Reschke, eds.) — Standards Track | RFC 9111 (obsoletes RFC 7234) | June 2022 | https://www.rfc-editor.org/rfc/rfc9111.html | 2026-09-11 | F-K3, and the TTL half of claim (f) |

## Vendor primary (class V)

| # | Title | Body / author | Version or edition | Year | URL | Accessed | Ids resting on it |
|---|---|---|---|---|---|---|---|
| V1 | *Server and Client Components* (App Router) | Vercel — Next.js documentation | docs frontmatter `version: 16.3.4`, `lastUpdated: 2026-08-25` | 2026 | https://nextjs.org/docs/app/getting-started/server-and-client-components | 2026-09-11 | Q-G1, Q-G4, Q-E1, Q-G4-S, claim (d) |
| V2 | *The Server and Client Boundary* | Vercel — Next.js documentation | `version: 16.3.4` | 2026 | https://nextjs.org/docs/app/guides/server-and-client-boundary | 2026-09-11 | Q-G1, Q-G4, Q-E1, claim (d) |
| V3 | *next CLI* (`next build` / `next dev` / command table) | Vercel — Next.js documentation | `version: 16.3.4` | 2026 | https://nextjs.org/docs/app/api-reference/cli/next | 2026-09-11 | Q-G2, Q-G4, Q-K3, Q-E2, claim (d) |
| V4 | *How to upgrade to version 16* (§ `next lint` Command; § Caching APIs) | Vercel — Next.js documentation | `version: 16.3.4` | 2026 | https://nextjs.org/docs/app/guides/upgrading/version-16 | 2026-09-11 | Q-G2, Q-E2, F-T12, F-K1, claim (f) |
| V5 | *unstable_cache* | Vercel — Next.js documentation | `version: 16.3.4`, `lastUpdated: 2026-07-21`; API introduced `v14.0.0` | 2026 | https://nextjs.org/docs/app/api-reference/functions/unstable_cache | 2026-09-11 | F-T6, F-R2, F-T6-S, claim (f) |
| V6 | *revalidateTag* | Vercel — Next.js documentation | `version: 16.3.4` | 2026 | https://nextjs.org/docs/app/api-reference/functions/revalidateTag | 2026-09-11 | F-T6, F-M5, F-R2, F-T6-S, claim (f) |
| V7 | *updateTag* | Vercel — Next.js documentation | `version: 16.3.4` (API new in `v16.0.0`) | 2026 | https://nextjs.org/docs/app/api-reference/functions/updateTag | 2026-09-11 | F-T6, F-R2, claim (f) |
| V8 | *use cache* (directive) | Vercel — Next.js documentation | `version: 16.3.4`; directive `v15.0.0` experimental, `v16.0.0` with Cache Components | 2026 | https://nextjs.org/docs/app/api-reference/directives/use-cache | 2026-09-11 | F-T6, F-T5, claim (f) |
| V9 | *Caching* (Cache Components) | Vercel — Next.js documentation | `version: 16.3.4` | 2026 | https://nextjs.org/docs/app/getting-started/caching | 2026-09-11 | F-T5, F-T6, F-M5, claim (f) |
| V10 | *Test rules* (`--test`, `ruleid:` / `ok:` / `todoruleid:` / `todook:`) | Semgrep, Inc. — Semgrep documentation | current docs (unversioned page) | 2026 | https://semgrep.dev/docs/writing-rules/testing-rules | 2026-09-11 | Q-T4, Q-G5, Q-R3, Q-E9 |
| V11 | *Generated Columns* (§ 5.4) | PostgreSQL Global Development Group | PostgreSQL **17** | 2026 | https://www.postgresql.org/docs/17/ddl-generated-columns.html | 2026-09-11 | F-T8, F-R4 |
| V12 | *Indexes on Expressions* (§ 11.7) | PostgreSQL Global Development Group | PostgreSQL **17** | 2026 | https://www.postgresql.org/docs/17/indexes-expressional.html | 2026-09-11 | F-T8, F-M7, F-R4 |
| V13 | *Sorting Rows* (`ORDER BY`, `NULLS FIRST` / `NULLS LAST`) | PostgreSQL Global Development Group | PostgreSQL **17** | 2026 | https://www.postgresql.org/docs/17/queries-order.html | 2026-09-11 | F-K7, F-T8 |
| V14 | *Pagination and Count* (`count=exact` / `planned` / `estimated`) | PostgREST contributors — PostgREST documentation | **v12** | 2026 | https://postgrest.org/en/v12/references/api/pagination_count.html | 2026-09-11 | F-T2, F-K5, F-M7 |
| V15 | *Global setup and teardown* | Microsoft — Playwright documentation | current docs; installed line pinned at `@playwright/test` **1.63.0** | 2026 | https://playwright.dev/docs/test-global-setup-teardown | 2026-09-11 | Q-T7a |
| V16 | *Parallelism* (`describe.configure({ mode: 'serial' })`) | Microsoft — Playwright documentation | current docs; `@playwright/test` **1.63.0** | 2026 | https://playwright.dev/docs/test-parallel | 2026-09-11 | Q-M2 |
| V17 | *Annotations* (`test.fixme` vs `test.skip`) | Microsoft — Playwright documentation | current docs; `@playwright/test` **1.63.0** | 2026 | https://playwright.dev/docs/test-annotations | 2026-09-11 | Q-T7b |
| V18 | *Configuration* → `mutate` option | Stryker Mutator team — StrykerJS documentation | current docs; `@stryker-mutator/core` **10.0.0** | 2026 | http://stryker-mutator.io/docs/stryker-js/configuration/ | 2026-09-11 | Q-K4 (partial) |
| V19 | *about_Automatic_Variables* (`$?`, `$LASTEXITCODE`) | Microsoft — PowerShell documentation | **PowerShell 7.6**, page dated 2026-04-02 | 2026 | https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables | 2026-09-11 | Q-T1b, Q-R4, V-e1 (host-OS caveat) |

## Published evidence (class P)

| # | Title | Authors | Venue / edition | Year | URL (fetched copy) | Accessed | Ids resting on it |
|---|---|---|---|---|---|---|---|
| P1 | *Are Mutants a Valid Substitute for Real Faults in Software Testing?* | R. Just, D. Jalali, L. Inozemtseva, M. D. Ernst, R. Holmes, G. Fraser | **FSE 2014**, 22nd ACM SIGSOFT Int. Symp. on Foundations of Software Engineering, Hong Kong; ACM 978-1-4503-3056-5 (DOI 10.1145/2635868.2635929) | 2014 | https://homes.cs.washington.edu/~rjust/publ/mutants_real_faults_fse_2014.pdf (author PDF; ACM DL returned 403) | 2026-09-11 | Q-P1a, Q-T5, Q-G9, Q-M5, Q-R2, Q-E7, Q-P2-S, Q-T5-S, V-e3 |
| P2 | *An Empirical Analysis of Flaky Tests* | Q. Luo, F. Hariri, L. Eloussi, D. Marinov | **FSE 2014**, pp. 643–653 (DOI 10.1145/2635868.2635920) | 2014 | https://mir.cs.illinois.edu/lamyaa/publications/fse14.pdf (author PDF; ACM DL 403) | 2026-09-11 | Q-T7b, Q-K7 |
| P3 | *Simple Testing Can Prevent Most Critical Failures: An Analysis of Production Failures in Distributed Data-Intensive Systems* | D. Yuan, Y. Luo, X. Zhuang, G. R. Rodrigues, X. Zhao, Y. Zhang, P. U. Jain, M. Stumm | **OSDI '14**, 11th USENIX Symp. on Operating Systems Design and Implementation, pp. 249–265; ISBN 978-1-931971-16-4 | 2014 | https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-yuan.pdf | 2026-09-11 | Q-T11, Q-E10, F-R3, F-K2, F-R3-S |
| P4 | *Lessons from Building Static Analysis Tools at Google* | C. Sadowski, E. Aftandilian, A. Eagle, L. Miller-Cushon, C. Jaspan | **Communications of the ACM**, Vol. 61 No. 4, pp. 58–66 (DOI 10.1145/3188720) | April 2018 | https://storage.googleapis.com/gweb-research2023-media/pubtools/4365.pdf (publisher-hosted author copy; cacm.acm.org 403) | 2026-09-11 | Q-M3, Q-K5, Q-K5-S, Q-G2 (rationale) |
| P5 | *A Few Billion Lines of Code Later: Using Static Analysis to Find Bugs in the Real World* | A. Bessey, K. Block, B. Chelf, A. Chou, B. Fulton, S. Hallem, C. Henri-Gros, A. Kamsky, S. McPeak, D. Engler | **Communications of the ACM**, Vol. 53 No. 2, pp. 66–75 (DOI 10.1145/1646353.1646374) | February 2010 | https://web.stanford.edu/~engler/BLOC-coverity.pdf (author PDF, Stanford; cacm.acm.org 403) | 2026-09-11 | Q-M3, Q-K5, Q-T4 (rationale) |
| P6 | *QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs* | K. Claessen, J. Hughes | **ICFP '00**, Montreal; ACM 1-58113-202-6 (DOI 10.1145/351240.351266) | 2000 | https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf (venue/author PDF; ACM DL 403) | 2026-09-11 | Q-G6 |
| P7 | *Chaos Engineering* | A. Basiri, N. Behnam, R. de Rooij, L. Hochstein, L. Kosewski, J. Reynolds, C. Rosenthal (Netflix) | **IEEE Software**, vol. 33 no. 3, pp. 35–41 (DOI 10.1109/MS.2016.60) | May–June 2016 | https://arxiv.org/pdf/1702.05843 (author preprint of the published article, carries the IEEE Software citation line and © 2016 IEEE; ieeexplore paywalled) | 2026-09-11 | Q-T10, Q-M8, Q-E11, Q-K6, Q-K6-S |

## Corpus files read (not sources — the object of the audit)

`C:\Users\Utente\Desktop\harden-codebase-properly\areas\quality.md`,
`…\areas\performance.md`, `…\SKILL.md`, `…\briefs\verifier.md`,
`…\briefs\phase-1-gates.md`, `…\briefs\phase-3-performance.md`,
`…\briefs\phase-5-tests.md`, `…\GLOSSARY.md`, `…\README.md`, `…\procedure.md` (grep only).
