# Sources — every source fetched in this session (merged)

Merged from `sources-a.md`, `sources-b.md`, `sources-c.md`. Each entry: title | body or author | version or edition | year | URL | date accessed | which finding ids rest on it. Every source below was fetched on 2026-09-11; nothing is cited from memory. Sources that could not be fetched are in § Could not verify at the end, never in the tables.

Sources cited by the integrity, usability, coverage and failure-mode passes (Claude Code skill docs, Agent Skills spec, PostgreSQL catalogs, Next.js data-security guide, OWASP Top 10 / API Top 10 / CWE Top 25 / SSDF / SLSA / Scorecard, EU directives) are listed in each of those reports' own "Sources fetched" section: `01-integrity.md`, `02-usability.md`, `04-coverage.md`, `05-failure-modes.md`.

Overlap between slices: the three slices cite disjoint sources except the Next.js 16.3.4 docs (slices a and b, different pages). No two slices cite the same source for the same claim.

---

## Slice a — quality, performance, verifier

## Sources — slice A (`areas/quality.md`, `areas/performance.md`)

Every entry below was **fetched and read in this session**. Nothing here is cited from memory.
Sources that could not be fetched are **not** in this file; they are listed in
`audit/03-evidence-a.md` § Could not verify.

All accesses: **2026-09-11**.

Installed-version anchors pinned this session from the npm registry (`registry.npmjs.org/<pkg>/latest`,
accessed 2026-09-11): `next` **16.3.4**, `@playwright/test` **1.63.0**, `@stryker-mutator/core` **10.0.0**.

---

### Standards and specifications (class S)

| # | Title | Body / author | Version or edition | Year | URL | Accessed | Ids resting on it |
|---|---|---|---|---|---|---|---|
| S1 | *Shell Command Language*, § 2.9.2 Pipelines ("Exit Status") and § 2.5.2 (`$?`), § 2.13 `set -o pipefail` | The Open Group / IEEE — Base Specifications **Issue 8**, IEEE Std 1003.1-2024 | Issue 8 | 2024 | https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html | 2026-09-11 | Q-T1b, Q-R4, Q-K1, Q-T1b-S, V-e1 |
| S2 | *RFC 9111 — HTTP Caching* | IETF (Fielding, Nottingham, Reschke, eds.) — Standards Track | RFC 9111 (obsoletes RFC 7234) | June 2022 | https://www.rfc-editor.org/rfc/rfc9111.html | 2026-09-11 | F-K3, and the TTL half of claim (f) |

### Vendor primary (class V)

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

### Published evidence (class P)

| # | Title | Authors | Venue / edition | Year | URL (fetched copy) | Accessed | Ids resting on it |
|---|---|---|---|---|---|---|---|
| P1 | *Are Mutants a Valid Substitute for Real Faults in Software Testing?* | R. Just, D. Jalali, L. Inozemtseva, M. D. Ernst, R. Holmes, G. Fraser | **FSE 2014**, 22nd ACM SIGSOFT Int. Symp. on Foundations of Software Engineering, Hong Kong; ACM 978-1-4503-3056-5 (DOI 10.1145/2635868.2635929) | 2014 | https://homes.cs.washington.edu/~rjust/publ/mutants_real_faults_fse_2014.pdf (author PDF; ACM DL returned 403) | 2026-09-11 | Q-P1a, Q-T5, Q-G9, Q-M5, Q-R2, Q-E7, Q-P2-S, Q-T5-S, V-e3 |
| P2 | *An Empirical Analysis of Flaky Tests* | Q. Luo, F. Hariri, L. Eloussi, D. Marinov | **FSE 2014**, pp. 643–653 (DOI 10.1145/2635868.2635920) | 2014 | https://mir.cs.illinois.edu/lamyaa/publications/fse14.pdf (author PDF; ACM DL 403) | 2026-09-11 | Q-T7b, Q-K7 |
| P3 | *Simple Testing Can Prevent Most Critical Failures: An Analysis of Production Failures in Distributed Data-Intensive Systems* | D. Yuan, Y. Luo, X. Zhuang, G. R. Rodrigues, X. Zhao, Y. Zhang, P. U. Jain, M. Stumm | **OSDI '14**, 11th USENIX Symp. on Operating Systems Design and Implementation, pp. 249–265; ISBN 978-1-931971-16-4 | 2014 | https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-yuan.pdf | 2026-09-11 | Q-T11, Q-E10, F-R3, F-K2, F-R3-S |
| P4 | *Lessons from Building Static Analysis Tools at Google* | C. Sadowski, E. Aftandilian, A. Eagle, L. Miller-Cushon, C. Jaspan | **Communications of the ACM**, Vol. 61 No. 4, pp. 58–66 (DOI 10.1145/3188720) | April 2018 | https://storage.googleapis.com/gweb-research2023-media/pubtools/4365.pdf (publisher-hosted author copy; cacm.acm.org 403) | 2026-09-11 | Q-M3, Q-K5, Q-K5-S, Q-G2 (rationale) |
| P5 | *A Few Billion Lines of Code Later: Using Static Analysis to Find Bugs in the Real World* | A. Bessey, K. Block, B. Chelf, A. Chou, B. Fulton, S. Hallem, C. Henri-Gros, A. Kamsky, S. McPeak, D. Engler | **Communications of the ACM**, Vol. 53 No. 2, pp. 66–75 (DOI 10.1145/1646353.1646374) | February 2010 | https://web.stanford.edu/~engler/BLOC-coverity.pdf (author PDF, Stanford; cacm.acm.org 403) | 2026-09-11 | Q-M3, Q-K5, Q-T4 (rationale) |
| P6 | *QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs* | K. Claessen, J. Hughes | **ICFP '00**, Montreal; ACM 1-58113-202-6 (DOI 10.1145/351240.351266) | 2000 | https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf (venue/author PDF; ACM DL 403) | 2026-09-11 | Q-G6 |
| P7 | *Chaos Engineering* | A. Basiri, N. Behnam, R. de Rooij, L. Hochstein, L. Kosewski, J. Reynolds, C. Rosenthal (Netflix) | **IEEE Software**, vol. 33 no. 3, pp. 35–41 (DOI 10.1109/MS.2016.60) | May–June 2016 | https://arxiv.org/pdf/1702.05843 (author preprint of the published article, carries the IEEE Software citation line and © 2016 IEEE; ieeexplore paywalled) | 2026-09-11 | Q-T10, Q-M8, Q-E11, Q-K6, Q-K6-S |

### Corpus files read (not sources — the object of the audit)

`C:\Users\Utente\Desktop\harden-codebase-properly\areas\quality.md`,
`…\areas\performance.md`, `…\SKILL.md`, `…\briefs\verifier.md`,
`…\briefs\phase-1-gates.md`, `…\briefs\phase-3-performance.md`,
`…\briefs\phase-5-tests.md`, `…\GLOSSARY.md`, `…\README.md`, `…\procedure.md` (grep only).


---

## Slice b — data-security, method-documentation

## Sources — 03b (data-security + method-documentation)

Every source below was fetched and read in this session. Anything that could not be fetched is in `audit/03-evidence-b.md` § Could not verify and is cited nowhere in the table. Date accessed is the same for all: **2026-09-11**.

Order: standards and specifications, then published work, then vendor primaries, then tools.

---

### Standards and specifications

**[ASVS5]** Application Security Verification Standard | OWASP Foundation | version 5.0.0 (345 requirements, 17 chapters), released 30 May 2025 | 2025 | https://raw.githubusercontent.com/OWASP/ASVS/master/5.0/docs_en/OWASP_Application_Security_Verification_Standard_5.0.0_en.csv (machine-readable requirement list; version and release date confirmed at https://owasp.github.io/www-project-application-security-verification-standard — "[30 May 2025] ASVS Version 5.0.0 is released LIVE at Global AppSec EU Barcelona 2025!") | accessed 2026-09-11 | ids: DS-S1 (V13.2.3), DS-S3 (V13.3.1), DS-S4 (V8.2.1, V8.2.2), DS-S6 (V9.1.1), DS-S7 (V8.3.2), DS-S8 (V15.2.3), DS-S9 + DS-S9-S (V16.5.3), DS-S11 (V6.1.1), DS-I4 (V16.2.5), DS-W6 (V13.3.1), DS-W7 (V9.2.1), DS-K8 (V8.3.2, V9.2.1), DS-K9 (V7.4.2), DS-K13 (V16.5.3), DS-M9/DS-W10 (V16.2.2, supporting), plus the whole § ASVS mapping summary.

**[T10-25]** OWASP Top 10:2025 | OWASP Foundation | 2025 edition | 2025 | https://top10.owasp.org/2025 and https://top10.owasp.org/2025/A10_2025-Mishandling_of_Exceptional_Conditions/ | accessed 2026-09-11 | ids: DS-S9, DS-K13, DS-S9-S. Quoted: "A10:2025 Mishandling of Exceptional Conditions"; mapped CWEs include "CWE-636 Not Failing Securely ('Failing Open')".

**[CWE-636]** CWE-636: Not Failing Securely ('Failing Open') | MITRE | CWE version 4.20, page updated 30 April 2026 | 2026 | https://cwe.mitre.org/data/definitions/636.html | accessed 2026-09-11 | ids: DS-S9, DS-K13, DS-S9-S. Quoted: "When the product encounters an error condition or failure, its design requires it to fall back to a state that is less secure than other options that are available".

**[CWE-732]** CWE-732: Incorrect Permission Assignment for Critical Resource | MITRE | CWE version 4.20, page updated 30 April 2026 | 2026 | https://cwe.mitre.org/data/definitions/732.html | accessed 2026-09-11 | ids: DS-P0, DS-S5, DS-R1 (background for the permissions family; cited as context, not as the operative obligation). Quoted: "The product specifies permissions for a security-critical resource in a way that allows that resource to be read or modified by unintended actors."

**[RFC3339]** RFC 3339, *Date and Time on the Internet: Timestamps* | G. Klyne, C. Newman (IETF) | Proposed Standard | 2002 | https://www.rfc-editor.org/rfc/rfc3339 | accessed 2026-09-11 | ids: DS-M9, DS-W10, DS-R7, DS-K7, claim (g). Quoted: §4.3 "This differs semantically from an offset of 'Z' or '+00:00', which imply that UTC is the preferred reference point for the specified time."; §5.1 "the date and time strings may be sorted as strings … and a time-ordered sequence will result".

**[ECMA]** ECMAScript Language Specification | Ecma International / TC39 | living draft, self-titled "ECMAScript® 2027 Language Specification" (the two clauses quoted are unchanged in the published ES2024/ES2025 editions) | 2026 | https://tc39.es/ecma262/multipage/numbers-and-dates.html | accessed 2026-09-11 | ids: DS-M9, DS-R7, DS-K7, claim (g). Quoted: §21.4.1.32 "`Z` is the UTC offset representation specified as \"Z\" (for UTC with no offset) or as either \"+\" or \"-\" followed by a time expression HH:mm"; §21.4.4.36 "Return a String representation of tv in the Date Time String Format on the UTC time scale, including all format elements and the UTC offset representation \"Z\"."; §21.4.3.2 `Date.parse`.

**[CC1]** Conventional Commits | conventionalcommits.org (Conventional Commits community specification) | version 1.0.0 | accessed 2026 | https://www.conventionalcommits.org/en/v1.0.0/ | accessed 2026-09-11 | ids: MD-Y5. Quoted: "`<type>[optional scope]: <description>`"; "The type `fix` MUST be used when a commit represents a bug fix for your application."

**[CS-AUTHZ]** Authorization Cheat Sheet | OWASP Cheat Sheet Series | no version or date shown on the page | accessed 2026 | https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | accessed 2026-09-11 | ids: DS-P0, DS-S9 (supporting). Quoted: "The application must always make a decision, whether implicitly or explicitly, to either deny or permit the requested access."; "Access control checks must be performed server-side, at the gateway, or using serverless function."

**[CS-SECRETS]** Secrets Management Cheat Sheet | OWASP Cheat Sheet Series | no version or date shown on the page | accessed 2026 | https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | accessed 2026-09-11 | ids: DS-S3, DS-W6. Quoted: §8.1 "Consider enabling secrets detection at the developer level to avoid checking secrets into code before commit/PR either in the IDE, as part of test-driven development, or via pre-commit hook."

**[CS-DB]** Database Security Cheat Sheet | OWASP Cheat Sheet Series | no version or date shown on the page | accessed 2026 | https://cheatsheetseries.owasp.org/cheatsheets/Database_Security_Cheat_Sheet.html | accessed 2026-09-11 | ids: DS-S5, DS-R1 (supporting). Quoted: "Only grant the required permissions on the databases."; "The account should not be the owner of the database as this can lead to privilege escalation vulnerabilities."

**[SSDF]** Secure Software Development Framework (SSDF) Version 1.1: Recommendations for Mitigating the Risk of Software Vulnerabilities | M. Souppaya, K. Scarfone, D. Dodson (NIST) | SP 800-218, v1.1 | February 2022 | https://csrc.nist.gov/pubs/sp/800/218/final and https://csrc.nist.gov/Projects/ssdf (project page last updated 13 April 2026) | accessed 2026-09-11 | ids: **none** — no row in this slice touches the supply chain or CI, so nothing rests on it; recorded so the next pass does not re-hunt it. Practice-group names verified ("PO", "PS", "PW", "RV"); practice-level statements are PDF-only and were not extracted.

### Published work

**[NDSS19]** *How Bad Can It Git? Characterizing Secret Leakage in Public GitHub Repositories* | Michael Meli, Matthew R. McNiece, Bradley Reaves | NDSS Symposium (peer-reviewed) | 2019 | https://www.ndss-symposium.org/ndss-paper/how-bad-can-it-git-characterizing-secret-leakage-in-public-github-repositories/ | accessed 2026-09-11 | ids: DS-S3, DS-W6 (why a secrets scan is not optional). Finding quoted: secret leakage "is rampant" across over 100,000 repositories, and "thousands of new, unique secrets are leaked every day".

**[SRE-DI]** *Site Reliability Engineering: How Google Runs Production Systems*, chapter "Data Integrity: What You Read Is What You Wrote" | eds. Betsy Beyer, Chris Jones, Jennifer Petoff, Niall Richard Murphy (Google) | O'Reilly Media | 2016 | https://sre.google/sre-book/data-integrity/ | accessed 2026-09-11 | ids: DS-I1, DS-I2, DS-W9, DS-K12, DS-R8 (near). Quoted: "No one really *wants* to make backups; what people *really* want are *restores*."; "you only know that you can recover your recent state if you actually do so"; "a system of out-of-band checks and balances is needed within and between its datastores".

**[SRE-MON]** *Site Reliability Engineering*, chapter "Monitoring Distributed Systems" | same editors and publisher | 2016 | https://sre.google/sre-book/monitoring-distributed-systems/ | accessed 2026-09-11 | ids: DS-I4 (the "alert stuck permanently on" half). Quoted: "Every page should be actionable."; "If a page merely merits a robotic response, it shouldn't be a page."

**[EVODB]** *Evolutionary Database Design* | Martin Fowler and Pramod Sadalage | article, revised May 2016 | 2016 | https://martinfowler.com/articles/evodb.html | accessed 2026-09-11 | ids: DS-G2, DS-K4, DS-G1 (near). Quoted: "All database changes are migrations"; during a transition phase "the database supports both the old access pattern and the new ones simultaneously". Note: the book the audit brief named as "Sadalage & Fowler, *Refactoring Databases*" is *Refactoring Databases: Evolutionary Database Design*, **Ambler & Sadalage**, Addison-Wesley, 2006 — not fetched, not cited.

**[HELLAND]** *Life beyond Distributed Transactions: an Apostate's Opinion* | Pat Helland (Amazon.com) | 3rd Biennial Conference on Innovative Data Systems Research (CIDR), Asilomar, 7–10 January 2007, pp. 132–141 | 2007 | https://www.cidrdb.org/cidr2007/papers/cidr07p15.pdf | accessed 2026-09-11 | ids: **none in the table** — the outbox/idempotency material it supports lives in brief `R2.7`, which has no corresponding row in `areas/data-security.md` (see § ASVS mapping summary, coverage gap). Quoted for that finding: "The application must include mechanisms to ensure that these, too, are idempotent. This means remembering in some fashion that the message has been processed so that subsequent attempts make no substantive change."; "Processing messages that are not naturally idempotent requires ensuring each message is processed at-most-once".

**[OUTBOX]** Pattern: Transactional outbox | Chris Richardson, microservices.io | no version; page copyright 2026 | accessed 2026 | https://microservices.io/patterns/data/transactional-outbox.html | accessed 2026-09-11 | ids: **none in the table**, same reason as [HELLAND]. Quoted: "How to atomically update the database and send messages to a message broker?"; "a message consumer must be idempotent, perhaps by tracking the IDs of the messages that it has already processed."

**[ADR]** *Documenting Architecture Decisions* | Michael Nygard | cognitect.com blog, 15 November 2011 (the pattern's origin description) | 2011 | https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions | accessed 2026-09-11 | ids: MD-T1, MD-K8, MD-T1-S (all as *near* sources; none reaches class P under the classification rule). Sections quoted: "Title", "Context" ("forces at play"), "Decision", "Status" ("proposed", "accepted", "deprecated", "superseded"), "Consequences". The template contains no rejected-alternatives section and no rule about when the record is written — which is the divergence reported in § Wrong or overstated.

**[DIATAXIS]** Diátaxis — a systematic approach to technical documentation authoring | Daniele Procida (diataxis.fr) | no version or date shown | accessed 2026 | https://diataxis.fr/ and https://diataxis.fr/start-here/ | accessed 2026-09-11 | ids: MD-T6, MD-T7 (near). Quoted: "four distinct needs, and four corresponding forms of documentation - *tutorials*, *how-to guides*, *technical reference* and *explanation*"; "A how-to guide addresses a real-world goal or problem, by providing practical directions to help the user."; "Crossing or blurring the boundaries described in the map is at the heart of a vast number of problems in documentation."

### Vendor primaries

**[PG-CF]** PostgreSQL documentation: CREATE FUNCTION | PostgreSQL Global Development Group | **18.6** and **12** (wording identical; behaviour holds for PostgreSQL 12–18) | 2026 / 2019 | https://www.postgresql.org/docs/current/sql-createfunction.html and https://www.postgresql.org/docs/12/sql-createfunction.html | accessed 2026-09-11 | ids: DS-G4, DS-R3, DS-K2, DS-R3-S, claim (a). Quoted: "When `CREATE OR REPLACE FUNCTION` is used to replace an existing function, the ownership and permissions of the function do not change."; "It is not possible to change the name or argument types of a function this way (if you tried, you would actually be creating a new, distinct function)."

**[PG-PRIV]** PostgreSQL documentation: §5.8 Privileges | PostgreSQL Global Development Group | **18.6** and **12** (default-privilege list identical; holds for PostgreSQL 12–18) | 2026 / 2019 | https://www.postgresql.org/docs/current/ddl-priv.html and https://www.postgresql.org/docs/12/ddl-priv.html | accessed 2026-09-11 | ids: DS-S5, DS-W3, DS-R1, DS-G4, claims (a) and (b). Quoted: "For other types of objects, the default privileges granted to `PUBLIC` are as follows: … `EXECUTE` privilege for functions and procedures"; "If the \"Access privileges\" column is empty for a given object, it means the object has default privileges (that is, its privileges entry in the relevant system catalog is null)."; "The object owner can, of course, `REVOKE` both default and expressly granted privileges."

**[PG-GRANT]** PostgreSQL documentation: GRANT | PostgreSQL Global Development Group | 18.6 | 2026 | https://www.postgresql.org/docs/current/sql-grant.html | accessed 2026-09-11 | ids: DS-R2, DS-K1, DS-R2-S, claim (b). Quoted: "The key word `PUBLIC` indicates that the privileges are to be granted to all roles, including those that might be created later. `PUBLIC` can be thought of as an implicitly defined group that always includes all roles."

**[PG-ADP]** PostgreSQL documentation: ALTER DEFAULT PRIVILEGES | PostgreSQL Global Development Group | 18.6 | 2026 | https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html | accessed 2026-09-11 | ids: DS-R2, DS-K1, claim (b). Quoted: "ALTER DEFAULT PRIVILEGES allows you to set the privileges that will be applied to objects created in the future. (It does not affect privileges assigned to already-existing objects.)"; "Change default privileges for objects created by the *target_role*, or the current role if unspecified."; "Per-schema `REVOKE` is only useful to reverse the effects of a previous per-schema `GRANT`."

**[PG-RLS]** PostgreSQL documentation: §5.9 Row Security Policies | PostgreSQL Global Development Group | 18.6 | 2026 | https://www.postgresql.org/docs/current/ddl-rowsecurity.html | accessed 2026-09-11 | ids: DS-S4, DS-W2. Quoted: "If no policy exists for the table, a default-deny policy is used, meaning that no rows are visible or can be modified."; "Superusers and roles with the `BYPASSRLS` attribute always bypass the row security system when accessing a table."; "Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with ALTER TABLE … FORCE ROW LEVEL SECURITY."

**[PG-DT]** PostgreSQL documentation: §8.5 Date/Time Types | PostgreSQL Global Development Group | 18 | 2026 | https://www.postgresql.org/docs/current/datatype-datetime.html | accessed 2026-09-11 | ids: DS-W10, DS-K7, claim (g). Quoted: Table 8.14 ISO row example `1997-12-17 07:37:16-08`; "In the ISO style, the time zone is always shown as a signed numeric offset from UTC, with positive sign used for zones east of Greenwich."

**[PG-SCH]** PostgreSQL documentation: §5.10 Schemas | PostgreSQL Global Development Group | 18.6 | 2026 | https://www.postgresql.org/docs/current/ddl-schemas.html | accessed 2026-09-11 | ids: claim (b), version caveat only. Quoted: "In PostgreSQL 15 and later, the default configuration supports this usage pattern. In prior versions … you will need to remove the public `CREATE` privilege from the `public` schema". Recorded because it is the one place where "revoke from public" advice *is* version-dependent — and it concerns the schema's CREATE privilege, not function EXECUTE, which did not change.

**[SB-INIT]** supabase/postgres — `migrations/db/init-scripts/00000000000000-initial-schema.sql` | Supabase Inc. | branch `develop` as served on the access date (the repository is the Supabase Postgres image's own source) | 2026 | https://raw.githubusercontent.com/supabase/postgres/develop/migrations/db/init-scripts/00000000000000-initial-schema.sql | accessed 2026-09-11 | ids: DS-R2, DS-K1, DS-S5, DS-R2-S, claim (b). Quoted: "alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;" and the same for tables and sequences, plus a second set "for user supabase_admin".

**[SB-ROLES]** Supabase documentation: Postgres roles | Supabase Inc. | no version or date shown | accessed 2026 | https://supabase.com/docs/guides/database/postgres/roles | accessed 2026-09-11 | ids: DS-S4, DS-R2 (defining `anon`, `authenticated`, `service_role`). Quoted: `anon` "For unauthenticated, public access. This is the role which the API (PostgREST) will use when a user *is not* signed in."; `service_role` "For elevated access. This role is used by the API (PostgREST) to bypass Row Level Security."

**[SB-RLS]** Supabase documentation: Row Level Security | Supabase Inc. | no version or date shown | accessed 2026 | https://supabase.com/docs/guides/database/postgres/row-level-security | accessed 2026-09-11 | ids: DS-S4, DS-K1, claim (b). Quoted: "Enable RLS on every table in an exposed schema."; "Once RLS is enabled, no data is accessible through the API when using a publishable key, until you create policies."; "A table in an exposed schema without RLS is readable and writable by any role with a grant on it."; "On existing projects, a new table in `public` starts with every privilege already granted to all three roles."

**[SB-CLI]** Supabase CLI reference: `supabase db push` | Supabase Inc. | no version pinned on the page | accessed 2026 | https://supabase.com/docs/reference/cli/supabase-db-push | accessed 2026-09-11 | ids: DS-G3, DS-W5, DS-R9, DS-K5, DS-G3-S. Quoted: "Pushes all local migrations to a remote database."; flags `--db-url`, `--linked` ("Pushes to the linked project"), `--local`, `--dry-run`, `--include-all`.

**[NEXT]** Next.js documentation: `redirect` | Vercel | docs version **16.3.4**, page lastUpdated 2026-07-28 | 2026 | https://nextjs.org/docs/app/api-reference/functions/redirect | accessed 2026-09-11 | ids: DS-I5, DS-K10. Quoted: "`redirect` can be used while rendering in Server and Client Components, Route Handlers, and Server Functions."; "In a Server Action, `redirect` performs a client-side navigation when JavaScript is available. For progressive enhancement form submissions, it serves a 303 HTTP redirect response." Nothing on the page documents a lost navigation after `router.push()`.

**[RESEND-API]** Resend API reference: Send Email | Resend | no API version or date shown | accessed 2026 | https://resend.com/docs/api-reference/emails/send-email | accessed 2026-09-11 | ids: DS-K6, claim (h). Quoted: `tags` is `type="array"`, optional; name and value "can only contain ASCII letters (a–z, A–Z), numbers (0–9), underscores (_), or dashes (-)" and "no more than 256 characters". No statement about empty arrays.

**[RESEND-TAGS]** Resend documentation: Email tags | Resend | no version or date shown | accessed 2026 | https://resend.com/docs/dashboard/emails/tags | accessed 2026-09-11 | ids: DS-K6, claim (h). Quoted: tags are "up to 75 tags per email", `tags: [{ name: 'category', value: 'confirm_email' }]`. No statement about empty arrays or about omitting the field.

**[RESEND-ERR]** Resend API reference: Errors | Resend | no version or date shown | accessed 2026 | https://resend.com/docs/api-reference/errors | accessed 2026-09-11 | ids: DS-K6, claim (h). Full documented error list read; the only candidate is `validation_error` (400) "An error was found with one or more fields in the request." Nothing names `tags` or empty arrays.

**[GITWT]** git-worktree(1) | Git project | git 2.54.0, manual page dated 2026-04-20 | 2026 | https://git-scm.com/docs/git-worktree | accessed 2026-09-11 | ids: MD-K6. Quoted: "Manage multiple working trees attached to the same repository."; "A git repository can support multiple working trees, allowing you to check out more than one branch at a time."

### Tools

**[GITLEAKS]** gitleaks | Zachary Rice and contributors (gitleaks organisation) | MIT licence; v8.24.2 referenced in the repository's own pre-commit example | accessed 2026 | https://github.com/gitleaks/gitleaks | accessed 2026-09-11 | ids: DS-W6 (the named tool exists and does what the rule asks: scans git history and can run as a pre-commit hook). Quoted: "Find secrets with Gitleaks".

---

### Fetched but yielding nothing citable

| source | attempted URLs | outcome |
|---|---|---|
| Regulation (EU) 2016/679 (GDPR) | `eur-lex.europa.eu` HTML, ELI (`/eli/reg/2016/679/art_4/par_11/oj`), consolidated (`CELEX:02016R0679-20160504`), PDF, and `curl` | empty body every time (0 bytes via curl; blank content via fetch). Cited nowhere. |
| Potdar & Shihab, "An Exploratory Study on Self-Admitted Technical Debt" (ICSME 2014) | author copy at `users.encs.concordia.ca` | HTTP 404. Cited nowhere. |
| ACM Queue reprint of Helland (2016) | `queue.acm.org/detail.cfm?id=3025012` | HTTP 403. The CIDR 2007 original was used instead. |
| Google SRE, "Being On-Call" (playbooks / MTTR) | `sre.google/sre-book/being-on-call/` | fetched; contains no playbook or MTTR statement. Cited nowhere. |
| ECMA-262 published editions (ES2024/ES2027 single-page) | `262.ecma-international.org/15.0/index.html`, `tc39.es/ecma262/multipage/...#fragment` | returned table of contents only; the chapter HTML was downloaded with `curl` and the two clauses extracted locally. |


---

## Slice c — interface, user-communication

## Sources — 03c (interface + user-communication)

Every source below was fetched and read in this session; the quoted text in `audit/03-evidence-c.md`
was taken from the fetched bytes, never from memory. Primary sources only: specifications, the
standards bodies' own documents, the vendors' own documentation, the Official Journal text, and the
NN/g primary pages for the heuristics (expert-derived, not experimental — noted where cited).

Format: **title** | body/author | version or edition | year | URL | accessed | ids that rest on it.

---

### Specifications (S)

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

### Published evidence (P)

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

### Vendor primary (V)

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

### Fetched but usable only at catalogue level

24. **ISO 9241-110:2020 — Ergonomics of human-system interaction — Part 110: Interaction
    principles** | ISO | second edition (ed. 2) | 2020 |
    <https://www.iso.org/standard/75258.html> | accessed 2026-09-11 | scope and abstract confirmed
    ("This document describes principles for interaction between a user and a system that are
    formulated in general terms"); the normative clauses are paywalled, so **no row rests on it** —
    it is listed in *Could not verify* for `I-TS14`, `I-TS21`, `U-P1`.

### Fetches attempted and failed

- **EUR-Lex HTML/PDF/ELI endpoints for CELEX 32019L0882** — HTTP 202 with an AWS WAF JavaScript
  challenge on every attempt (three retries with a cookie jar); `WebFetch` returned an empty
  document. Worked around via the Publications Office cellar (entry 16), which serves the same
  official OJ rendering.
- **Directive (EU) 2016/2102 (CELEX 32016L2102)** — EUR-Lex blocked as above; the cellar endpoint
  returned HTTP 400. Not verified; recorded in *Could not verify*.
- **ETSI deliver directory listing** (`https://www.etsi.org/deliver/etsi_en/301500_301599/301549/`)
  — returned empty; individual version PDFs fetch correctly by direct URL (entries 14, 15).


---

## Could not verify

### From slice a


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


### From slice b


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


### From slice c


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


