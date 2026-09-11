# 04 — Coverage

## Summary

Ten hypotheses: **6 CONFIRMED, 4 PARTIALLY CONFIRMED, 0 REFUTED** — but three of the four partials were refuted on their sharpest point (the correlation id *does* connect both halves; the sibling degradation *is* specified everywhere it matters; Next.js *does* guarantee server-action CSRF), so the first reading was more pessimistic than the corpus deserves.

The three gaps that matter most: **(A6-01) supply chain is absent end to end** — no dependency audit, no lockfile discipline, no SBOM, no pinned CI, against a corpus whose own OWASP Top 10:2025 rank for this is A03 and whose SSDF practices PW.4.4 and RV.1.1 are entirely unstaffed; **(A6-05) object-level authorization is unreachable by the current controls** — the skill's RLS is deny-all with grants held by `service_role` only (`areas/data-security.md:54`) while the app's data layer holds the service key (`areas/quality.md:10`), so RLS is never evaluated on a request path and the only application-side control is a rule that checks a guard is *textually present* (`briefs/phase-1-gates.md:25`); **(A6-14) there is no rollback for anything the method applies** — zero occurrences of `rollback`, `revert`, `down migration`, `backout` in 28 files, in Phases 2, 3, 6 and 7 that apply migrations, change grants, change cache semantics and rebuild an environment.

Does it cover hardening? **It covers the hardening of a product against its own accumulated defects with unusual rigour, and barely covers the hardening of a product against an attacker or a dependency** — the measurement discipline, the evidence ledger, the canary and the variant search are ahead of every corpus checked; the attack surface (input, authorization by object, the web perimeter, the supply chain) and the recovery surface (rollback, observability) are behind all of them.

---

## Part 1 — Control mapping

Legend for *belongs in*: **this** = `harden-codebase-properly`; **sibling** = `design-software-properly`; **neither** = out of scope, should be named in `SKILL.md` § When not to use it. Severity: **P1** one step from irreversible damage or data loss · **P2** must be fixed · **P3** fix when touched · **none** no gap.

### 1.1 OWASP ASVS 5.0.0 (chapters V1–V17)

Scoped to a back-office with a database and integrations. V17 (WebRTC) is out of surface and is listed once for completeness.

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| ASVS 5.0 | V1 Encoding and Sanitization | no | — | P2 | this |
| ASVS 5.0 | V2 Validation and Business Logic | partial — business logic is exhaustive (`areas/data-security.md:8-16`: one-directional source, unsubscribe ≠ deletion, consent read never inferred, tombstones, "not a duplicate" as a revocable fact); input validation is absent | `areas/data-security.md:8-16` for logic; nothing for validation | P1 | this |
| ASVS 5.0 | V3 Web Frontend Security (CSP, headers, clickjacking, subresource integrity) | no | — | P2 | this |
| ASVS 5.0 | V4 API and Web Service | partial — rate limiting `areas/data-security.md:28`; no schema on request payloads, no method/CORS posture | `areas/data-security.md:28` | P2 | this |
| ASVS 5.0 | V5 File Handling | no | — | P2 | this (conditional: only when the stack map shows an upload path) |
| ASVS 5.0 | V6 Authentication | partial — fail-closed `areas/data-security.md:27`, rate limiting on auth endpoints `areas/data-security.md:28`; credential storage, MFA, recovery not addressed | `areas/data-security.md:27-28` | P3 | this (one line naming what the identity provider owns) |
| ASVS 5.0 | V7 Session Management | partial — revocation runbook and the signed-cookie trap `areas/data-security.md:29,89`; cookie attributes, fixation, idle timeout absent | `areas/data-security.md:29,89` | P2 | this |
| ASVS 5.0 | V8 Authorization | partial — database side is the corpus's strongest control (`areas/data-security.md:22-23`); application object-level is a textual grep (`briefs/phase-1-gates.md:25`) | `areas/data-security.md:22-23`; `briefs/phase-1-gates.md:25` | P1 | this |
| ASVS 5.0 | V9 Self-contained Tokens | yes — "**Signed tokens with a separated rejection cause** (unreadable / invalid signature / expired), signature verified before every query" | `areas/data-security.md:24-25`; `briefs/phase-2-data.md:37` | none | — |
| ASVS 5.0 | V10 OAuth and OIDC | no | — | P3 | neither |
| ASVS 5.0 | V11 Cryptography | partial — "Secrets are **distinct per purpose** (data signing, session), required, and different from one another" is a real key-separation control; no algorithm/key-length/randomness requirements | `areas/data-security.md:20` | P3 | neither |
| ASVS 5.0 | V12 Secure Communication | no | — | P3 | neither (platform) |
| ASVS 5.0 | V13 Configuration | partial — best-in-class on secrets and environments (`areas/data-security.md:19-21,26,34`); nothing on dependency or build configuration | `areas/data-security.md:19-21,26,34` | P2 | this (the supply-chain half only) |
| ASVS 5.0 | V14 Data Protection | partial — deletion by durable hash, export scope = deletion scope, no PII in logs (`areas/data-security.md:11,41`); no classification, no retention, no at-rest posture | `areas/data-security.md:11,41` | P3 | this |
| ASVS 5.0 | V15 Secure Coding and Architecture | partial — "every defense **fails closed**" and "no service key outside the data layer" are exactly this chapter's spirit; third-party component risk absent | `areas/data-security.md:27`; `areas/quality.md:10` | P2 | this (components) / sibling (module boundaries) |
| ASVS 5.0 | V16 Security Logging and Error Handling | partial — error handling is exemplary (`areas/user-communication.md:9`; `briefs/phase-4-interface.md:65`); security-event logging, retention and tamper-resistance absent | `areas/user-communication.md:9`; `areas/data-security.md:41` | P2 | this |
| ASVS 5.0 | V17 WebRTC | n/a | — | none | neither |

### 1.2 OWASP Top 10:2025

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| Top 10:2025 | A01:2025 Broken Access Control | partial — database yes, application object-level no | `areas/data-security.md:22-23`; `briefs/phase-1-gates.md:25` | P1 | this |
| Top 10:2025 | A02:2025 Security Misconfiguration | partial — env, single source DB, test endpoints disabled in production; no headers, no secure defaults for the framework | `areas/data-security.md:19,26,34` | P2 | this |
| Top 10:2025 | A03:2025 Software Supply Chain Failures | **no** — zero occurrences of `dependency audit`, `lockfile`, `SBOM`, `provenance`, `CVE` in 28 files | — | P1 | this |
| Top 10:2025 | A04:2025 Cryptographic Failures | partial — key separation only | `areas/data-security.md:20` | P3 | neither |
| Top 10:2025 | A05:2025 Injection | no — no parameterization check, no DOM-sink grep; note that `areas/data-security.md:47-53` runs raw SQL only as read-only diagnosis | — | P2 | this |
| Top 10:2025 | A06:2025 Insecure Design | partial — the corpus is a design-for-failure method (fail closed, tombstones, discriminated outcomes, idempotency, reconciliation) but never runs a threat model | `areas/data-security.md:8-16,27`; `briefs/phase-2-data.md:60` | P3 | this |
| Top 10:2025 | A07:2025 Authentication Failures | partial — rate limiting, fail closed, three token outcomes | `areas/data-security.md:24,27,28` | P3 | this |
| Top 10:2025 | A08:2025 Software or Data Integrity Failures | split — **data** integrity is exemplary (webhook dedupe, idempotency keys, outbox, reconciliation `briefs/phase-2-data.md:60`); **software** integrity (provenance, signing, untrusted CI action) is absent | `briefs/phase-2-data.md:57-63` | P1 (software half) | this |
| Top 10:2025 | A09:2025 Security Logging and Alerting Failures | partial — the live channel check ("Every channel … exercised live with an **injected failure**") is a stronger control than the corpus asks for; security-event logging, thresholds and retention are absent | `areas/data-security.md:40-41`; `briefs/phase-2-data.md:50-55` | P2 | this |
| Top 10:2025 | A10:2025 Mishandling of Exceptional Conditions | **yes, above requirement** — fail closed, no empty `catch {}`, error ≠ empty, five states, discriminated outcomes, readable rejection | `areas/data-security.md:27`; `areas/performance.md:41`; `areas/user-communication.md:10,12` | none | — |

### 1.3 OWASP API Security Top 10 2023

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| API 2023 | API1:2023 Broken Object Level Authorization | no — the only application control is textual presence of a guard, which cannot see *which* object | `briefs/phase-1-gates.md:25-26` | P1 | this |
| API 2023 | API2:2023 Broken Authentication | partial | `areas/data-security.md:24,27,28` | P2 | this |
| API 2023 | API3:2023 Broken Object Property Level Authorization | no — nothing measures what an action *returns* to the client, nor mass assignment on what it accepts | — | P2 | this |
| API 2023 | API4:2023 Unrestricted Resource Consumption | partial — caps declared, batched rounds above the guard, rate limiting on auth endpoints | `areas/performance.md:16`; `areas/data-security.md:28`; `briefs/phase-3-performance.md:45` | P2 | this |
| API 2023 | API5:2023 Broken Function Level Authorization | partial — the R1.2 rule is exactly this control, at grep strength | `briefs/phase-1-gates.md:25` | P2 | this |
| API 2023 | API6:2023 Unrestricted Access to Sensitive Business Flows | partial — irreversible actions physically isolated, typed confirmation with a quantity; no flow-abuse analysis | `areas/interface.md:24`; `areas/user-communication.md:15` | P3 | this |
| API 2023 | API7:2023 Server Side Request Forgery | no | — | P2 | this |
| API 2023 | API8:2023 Security Misconfiguration | partial | `areas/data-security.md:19,26` | P2 | this |
| API 2023 | API9:2023 Improper Inventory Management | partial — D0 inventories the actions/endpoints folder and R5.3 makes the acceptance checklist "a partition of the surface (pages, routes, actions)"; no versioning/deprecation/environment inventory | `briefs/phase-0-diagnosis.md:31`; `briefs/phase-5-tests.md:28` | P3 | this |
| API 2023 | API10:2023 Unsafe Consumption of APIs | partial — idempotency keys, reconciliation "reports the differences (never silently fixes them)", one-directional external source; nothing validates the *shape* of what a third party returns | `areas/data-security.md:8`; `briefs/phase-2-data.md:60` | P2 | this |

### 1.4 CWE Top 25 (2025 edition, released 15 December 2025)

Memory-safety entries are marked **n/a** for a managed-runtime web stack; they are a genuine "neither" and are the clearest candidates for a scope bullet.

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| CWE Top 25 2025 | 1 · CWE-79 XSS | no | — | P2 | this |
| CWE Top 25 2025 | 2 · CWE-89 SQL Injection | no | — | P2 | this |
| CWE Top 25 2025 | 3 · CWE-352 CSRF | partial — framework-guaranteed for server actions (see § 2.3); nothing for route handlers or non-Next stacks | — | P2 | this |
| CWE Top 25 2025 | 4 · CWE-862 Missing Authorization | partial — grep-strength only | `briefs/phase-1-gates.md:25` | P1 | this |
| CWE Top 25 2025 | 5 · CWE-787 Out-of-bounds Write | n/a | — | none | neither |
| CWE Top 25 2025 | 6 · CWE-22 Path Traversal | no | — | P3 | this (conditional on a file path) |
| CWE Top 25 2025 | 7 · CWE-416 Use After Free | n/a | — | none | neither |
| CWE Top 25 2025 | 8 · CWE-125 Out-of-bounds Read | n/a | — | none | neither |
| CWE Top 25 2025 | 9 · CWE-78 OS Command Injection | no | — | P3 | neither (unless the stack map shows a shell-out) |
| CWE Top 25 2025 | 10 · CWE-94 Code Injection | no | — | P3 | neither |
| CWE Top 25 2025 | 11 · CWE-120 Classic Buffer Overflow | n/a | — | none | neither |
| CWE Top 25 2025 | 12 · CWE-434 Unrestricted File Upload | no | — | P2 | this |
| CWE Top 25 2025 | 13 · CWE-476 NULL Pointer Dereference | n/a | — | none | neither |
| CWE Top 25 2025 | 14 · CWE-121 Stack-based Buffer Overflow | n/a | — | none | neither |
| CWE Top 25 2025 | 15 · CWE-502 Deserialization of Untrusted Data | no | — | P3 | neither |
| CWE Top 25 2025 | 16 · CWE-122 Heap-based Buffer Overflow | n/a | — | none | neither |
| CWE Top 25 2025 | 17 · CWE-863 Incorrect Authorization | partial | `briefs/phase-1-gates.md:25`; `briefs/phase-5-tests.md:42` | P1 | this |
| CWE Top 25 2025 | 18 · CWE-20 Improper Input Validation | no — the only "validate" in the corpus is the env module's shape check and UI copy consistency | `briefs/phase-2-data.md:13` (env only) | P1 | this |
| CWE Top 25 2025 | 19 · CWE-284 Improper Access Control | partial | `areas/data-security.md:22-23` | P1 | this |
| CWE Top 25 2025 | 20 · CWE-200 Exposure of Sensitive Information | partial — no PII in logs, no technical error on screen, secrets server-side; nothing on over-broad return values | `areas/quality.md:10`; `areas/user-communication.md:9`; `areas/data-security.md:21` | P2 | this |
| CWE Top 25 2025 | 21 · CWE-306 Missing Authentication for Critical Function | partial — R5.5 "for every action, a test that calls it for real without permission and checks the rejection" is precisely this control | `briefs/phase-5-tests.md:42` | P3 | this |
| CWE Top 25 2025 | 22 · CWE-918 SSRF | no | — | P2 | this |
| CWE Top 25 2025 | 23 · CWE-77 Command Injection | no | — | P3 | neither |
| CWE Top 25 2025 | 24 · CWE-639 Authorization Bypass Through User-Controlled Key | no — this is the named form of the gap in § 2.2 | — | P1 | this |
| CWE Top 25 2025 | 25 · CWE-770 Allocation Without Limits or Throttling | partial — caps, batched rounds, rate limiting | `areas/performance.md:16-17`; `areas/data-security.md:28` | P3 | this |

### 1.5 NIST SP 800-218 SSDF v1.1 (February 2022)

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| SSDF v1.1 | PO.1 Define Security Requirements for Software Development | partial — the "Target state" checklists *are* a written requirement set; nothing external or legal | `areas/*.md` § Target state | P3 | this |
| SSDF v1.1 | PO.2 Implement Roles and Responsibilities | **yes** — autonomy contract, orchestrator ≠ implementer ≠ verifier, "who owns what as of today" at handover | `procedure.md:20-26`; `briefs/phase-7-handover.md:38` | none | — |
| SSDF v1.1 | PO.3 Implement Supporting Toolchains | partial — verify script and guard set wired into CI; toolchain integrity and provenance absent | `briefs/phase-1-gates.md:16`; `modes/maintain.md:22` | P2 | this |
| SSDF v1.1 | PO.4 Define and Use Criteria for Software Security Checks | **yes, above requirement** — "a row without evidence is not done", exit criteria per phase, the two-stage verifier | `modes/status.md:11`; `procedure.md:17`; `templates/status.md:6` | none | — |
| SSDF v1.1 | PO.5 Implement and Maintain Secure Environments for Software Development | partial — single source-of-truth database, environment comparison before every write, fresh environment at handover; development-endpoint hardening absent | `areas/data-security.md:34`; `briefs/phase-7-handover.md:17` | P3 | neither (organizational) |
| SSDF v1.1 | PS.1 Protect All Forms of Code from Unauthorized Access and Tampering | no — no branch protection, code owners or commit signing; "Never commit or push without explicit authorization" is a different control | `procedure.md:26` (adjacent, not this) | P3 | neither |
| SSDF v1.1 | PS.2 Provide a Mechanism for Verifying Software Release Integrity | no | — | P3 | neither |
| SSDF v1.1 | PS.3 Archive and Protect Each Software Release (PS.3.2: "share provenance data for all components … e.g., in a software bill of materials [SBOM]") | no | — | P2 | this (as a Phase 7 deliverable) |
| SSDF v1.1 | PW.1 Design Software to Meet Security Requirements and Mitigate Security Risks (threat modelling) | no | — | P2 | this |
| SSDF v1.1 | PW.2 Review the Software Design to Verify Compliance | partial — decision records carry rejected alternatives and "Where it lives in the code"; the verifier reviews compliance with the brief, not with a risk model | `templates/decision-record.md:25-30`; `briefs/verifier.md:10` | P3 | this |
| SSDF v1.1 | PW.4 Reuse Existing, Well-Secured Software (PW.4.1 "Obtain provenance information (e.g., SBOM…)"; PW.4.4 "Regularly check whether there are publicly known vulnerabilities in the software modules and services that vendors have not yet fixed") | **no** | — | P1 | this |
| SSDF v1.1 | PW.5 Create Source Code by Adhering to Secure Coding Practices (PW.5.1 Example 1: "Validate all inputs, and validate and properly encode all outputs") | partial — four custom static rules exist, none of them is input validation or output encoding | `briefs/phase-1-gates.md:25` | P2 | this |
| SSDF v1.1 | PW.6 Configure the Compilation, Interpreter, and Build Processes | partial — the real production build is in the mandatory path; lint at zero Error is the "clean build" concept; no toolchain-version or integrity check | `areas/quality.md:7,27`; `briefs/phase-1-gates.md:16` | P3 | this |
| SSDF v1.1 | PW.7 Review and/or Analyze Human-Readable Code | **yes** — `modes/review.md` in full, the verifier's brief-compliance stage, the adversarial bug hunt with mandatory executed reproduction | `modes/review.md`; `briefs/verifier.md:10`; `briefs/phase-5-tests.md:46-51` | none | — |
| SSDF v1.1 | PW.8 Test Executable Code to Identify Vulnerabilities (PW.8.2 Example 5 "fuzz testing", Example 6 "penetration testing") | partial, above requirement on the rest — canary on every harness, dirty corpus with an oracle, flow tests with compensations, live channel checks; no fuzzing, no penetration test | `briefs/phase-5-tests.md:9-65` | P3 | this |
| SSDF v1.1 | PW.9 Configure Software to Have Secure Settings by Default | partial — env fail-fast, test endpoints disabled by default, fail closed, read-only pages by default; framework security settings not enumerated | `areas/data-security.md:19,26,27`; `areas/interface.md:15` | P3 | this |
| SSDF v1.1 | RV.1 Identify and Confirm Vulnerabilities on an Ongoing Basis (RV.1.1 "Monitor vulnerability databases…") | partial — drift check and adversarial hunt find *defects*, not published vulnerabilities in dependencies | `modes/maintain.md:42-49`; `briefs/phase-5-tests.md:46-51` | P1 | this |
| SSDF v1.1 | RV.2 Assess, Prioritize, and Remediate Vulnerabilities | **yes** — defect register with class, severity, effort, proof and ruling; the capped rejection cycle | `procedure.md:39,160-168` | none | — |
| SSDF v1.1 | RV.3 Analyze Vulnerabilities to Identify Their Root Causes (RV.3.3 "Review the software for similar vulnerabilities to eradicate a class of vulnerabilities, and proactively fix them rather than waiting for external reports") | **yes, above requirement** — the variant search after every closed defect, promotion of a mechanical shape into a static rule, `lessons.md` as RV.3.4 | `procedure.md:16,46`; `modes/diagnose.md` | none | — |

### 1.6 SLSA · OpenSSF Scorecard · SBOM

SLSA: the levels page documents v1.1 (marked Retired) and states the current specification version is **1.2**.

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| SLSA | Build L0 (none) | n/a | — | none | — |
| SLSA | Build L1 "Provenance showing how the package was built" | no | — | P2 | this (as a handover artefact) |
| SLSA | Build L2 "Signed provenance, generated by a hosted build platform" | no | — | P3 | neither |
| SLSA | Build L3 "Hardened build platform" | no | — | P3 | neither |
| Scorecard | Vulnerabilities — "Does the project have unfixed vulnerabilities? Uses the OSV service." | no | — | P1 | this |
| Scorecard | Dependency-Update-Tool — "…Dependabot, RenovateBot?" | no | — | P2 | this |
| Scorecard | Pinned-Dependencies — "Does the project declare and pin dependencies?" | no | — | P2 | this |
| Scorecard | Token-Permissions — "Does the project declare GitHub workflow tokens as read only?" | no | — | P2 | this |
| Scorecard | Dangerous-Workflow — "Does the project avoid dangerous coding patterns in GitHub Actions?" | no | — | P2 | this |
| Scorecard | Binary-Artifacts — "Is the project free of checked-in binaries?" | no | — | P3 | this (one grep line) |
| Scorecard | SAST — "Does the project use static code analysis tools…?" | **yes** — custom rules shipped with `ruleid:`/`ok:` fixtures and run offline is stricter than the check | `areas/quality.md:10`; `briefs/phase-1-gates.md:22-29` | none | — |
| Scorecard | CI-Tests — "Does the project run tests in CI…?" | **yes** — and "a guard that only runs when someone remembers is not a guard" | `modes/maintain.md:22`; `briefs/phase-0-diagnosis.md:43` | none | — |
| Scorecard | Fuzzing | no — the dirty fixture corpus and property-based models are the local substitute | `areas/quality.md:15,29` | P3 | neither |
| Scorecard | Maintained · Licence · CII-Best-Practices · Branch-Protection · Code-Review · Contributors · Packaging · Signed-Releases · Security-Policy | no | — | P3 | neither (repository and release governance) |
| SBOM | CycloneDX 1.7 (OWASP / Ecma **ECMA-424**) as a deliverable | no | — | P2 | this |
| SBOM | SPDX 3.0 (**ISO/IEC 5962:2021**) as a deliverable | no | — | P2 | this |

### 1.7 Google SRE + DORA (operations lens)

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| SRE book | Ch. 3 Embracing Risk (error budgets) | no | — | P3 | this (one line: what availability the client is promised) |
| SRE book | Ch. 4 Service Level Objectives | no | — | P3 | this |
| SRE book | Ch. 5 Eliminating Toil | **yes, in substance** — counts printed by a script never typed by hand; guards wired into `verify` and CI rather than remembered; "If it feels heavy, the guard set is incomplete" | `areas/method-documentation.md:72`; `modes/maintain.md:22,40` | none | — |
| SRE book | Ch. 6 Monitoring Distributed Systems | partial — the live channel table with dates is a real monitoring control for integrations; no metrics, no golden signals, no dashboard, no alert threshold policy beyond "alerts guarded against an alert that stays permanently stuck on" | `areas/data-security.md:40-41`; `modes/maintain.md:17` | P2 | this |
| SRE book | Ch. 11 Being On-Call | no | — | P3 | neither |
| SRE book | Ch. 15 Postmortem Culture | partial — `lessons.md`, the ruling line, the variant search and "a closed defect found again is a P1" are a postmortem discipline *for the remediation*, not for a production incident | `procedure.md:18,40`; `modes/maintain.md:46` | P3 | this (an incident record in `R6.7`) |
| DORA | Deployment Frequency — "How often an organization successfully releases to production" | no | — | P3 | neither |
| DORA | Lead Time for Changes — "The amount of time it takes a commit to get into production" | no | — | P3 | neither |
| DORA | Change Failure Rate — "The percentage of deployments causing a failure in production" | no — and this is the metric § 2.9 asks for | — | P3 | this |
| DORA | Time to Restore Service — "How long it takes an organization to recover from a failure in production" | no — this is the metric § 2.8 asks for | — | P2 | this |

### 1.8 WCAG 2.2 principles + EN 301 549 (principle level only)

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| WCAG 2.2 | 1. Perceivable — "Information and user interface components must be presentable to users in ways they can perceive." | partial — sufficient contrast, local SVG icons `aria-hidden` next to text, five visually distinct states; no text-alternative policy, no 1.3 Adaptable, no 1.2 Time-based Media | `areas/user-communication.md:20`; `areas/interface.md:26` | P2 | this |
| WCAG 2.2 | 2. Operable — "User interface components and navigation must be operable." | partial — visible focus, commands reachable by keyboard, "a tooltip that only fires on mouse hover … doesn't exist on keyboard or touch", expiry announced beforehand (2.2 Enough Time in substance); no focus order, no skip link, no target size | `areas/user-communication.md:16,20,58` | P2 | this |
| WCAG 2.2 | 3. Understandable | **yes, above requirement** — real labels, hints, marked required fields, errors next to the field with identical wording on every entry point, one name per concept, confirmations with a quantity and a typed word | `areas/user-communication.md:13,15,18`; `briefs/phase-4-interface.md:73` | none | — |
| WCAG 2.2 | 4. Robust | partial — `aria-sort`, `aria-live`/`role="status"`, `aria-busy`, ARIA forwarded by shared components, "Hyphenated ARIA props aren't checked by the type system: declare them explicitly and test them"; no name/role/value discipline in general, no automated audit run | `areas/interface.md:30,56`; `areas/user-communication.md:20` | P2 | this |
| EN 301 549 | Clause 9 Web | partial, via the above | as above | P2 | this |
| EN 301 549 | Clause 10 Non-web documents (the generated guide, the discards file, exports) | no — the guide's own accessibility is never measured, and R4.10 mandates "a downloadable file of rejects" with no accessibility requirement | `areas/user-communication.md:17`; `briefs/phase-6-documentation.md:32` | P3 | this |
| EN 301 549 | Clause 11 Non-web software | n/a for a web back-office | — | none | neither |
| EN 301 549 | Clause 12 Documentation and support services | partial — the guide exists, is generated from a single source and has measured coverage; its accessibility and the support channel's are not addressed | `areas/method-documentation.md:12` | P3 | this |
| EN 301 549 | Clause 13 ICT providing relay or emergency access | n/a | — | none | neither |

Version note, **from a web search, not a primary fetch** (the ETSI PDF returned HTTP 403 and the EU accessibility-centre page HTTP 404): EN 301 549 V4.1.1 was published 2 September 2026 and references WCAG 2.2 AA; V3.2.1 (March 2021, WCAG 2.1 AA) remains the harmonised standard until the expected OJEU citation in October 2026. Treat this row as unverified.

### 1.9 Diátaxis (four quadrants)

| corpus | control | covered? | where | severity | belongs in |
|---|---|---|---|---|---|
| Diátaxis | Tutorials — "an **experience** that takes place under the guidance of a tutor. A tutorial is always **learning-oriented**." | **no** — the 14-folder documentation map has no home for a first-day path | `areas/method-documentation.md:23-38` | P2 | this |
| Diátaxis | How-to guides | **yes** — the guide is "searchable **by intent** (every step declares the words someone would search it with)", and the runbooks are how-to in the strict sense | `areas/method-documentation.md:12,15`; `briefs/phase-6-documentation.md:53` | none | — |
| Diátaxis | Technical reference | partial — `features/`, `architecture/`, an index whose counts come from a command; no field/API reference derived from the field registry | `areas/method-documentation.md:8,13-14` | P3 | this |
| Diátaxis | Explanation | **yes, above requirement** — the decision record *is* explanation: "Why and what we rejected", "What would change our mind" | `templates/decision-record.md:25-32` | none | — |

Finding: the documentation map is partitioned by **artefact** (13 folders by kind), not by **need**. Three of the four quadrants land somewhere by accident; the tutorial is the one with no folder and no brief. `R6.4` builds a guide indexed by intent, which is how-to; nothing builds the "first day with the product" path that a client's new employee needs after handover — the one moment the skill exists for.

### 1.10 ISO/IEC 25010 — do the six conditions partition the space?

The nine product-quality characteristics returned by the ISO 25000 portal are Functional Suitability, Performance Efficiency, Compatibility, Interaction Capability, Reliability, Security, Maintainability, Flexibility and Safety (the portal page does not state the edition year; the presence of Interaction Capability, Flexibility and Safety marks it as the revised nine-characteristic model, not the 2011 eight-characteristic one). Mapped against `SKILL.md:31-36`: condition 1 is Performance Efficiency; condition 3 is Security; condition 2 is Maintainability § Testability plus Reliability § Faultlessness; conditions 4 and 5 are Interaction Capability (four and four of its eight sub-characteristics respectively — Operability and Appropriateness recognizability for condition 4, User assistance, Self-descriptiveness, User error protection and Inclusivity for condition 5); condition 6 is Maintainability § Analysability plus Modifiability, reached through documentation rather than through code. **The six conditions are not a partition: they are a cover with two overlaps and four holes.** The overlaps: conditions 4 and 5 split one ISO characteristic along a line ISO does not draw (what the interface *does* vs what it *says*), and condition 2 straddles Reliability and Maintainability. The holes are Functional Suitability (nothing in the six conditions asks whether the product does what it was bought to do — the acceptance checklist at `briefs/phase-5-tests.md:28` covers the code's surface, not the requirement's), Compatibility, Flexibility (Adaptability, Scalability, Installability, Replaceability — none measured, though Phase 7 rebuilds an environment, which is Installability in practice and unnamed), and Safety. Two of those four holes are deliberate and defensible: Compatibility and Flexibility are structural and belong to the sibling. Functional Suitability is neither deliberate nor the sibling's: it is simply absent, and it is the characteristic a client would name first. The honest reading is that the six conditions are an **ad-hoc list with a strong internal logic** — they enumerate the six places where this author watched a product lie about itself — not a derived partition; `SKILL.md:29` calling them "Six conditions, each **measured**, never asserted" is a claim about evidence, not about completeness, and the corpus never claims completeness. That is a defensible design; it is worth saying out loud in the file, because a reader currently infers a partition from the numbering.

---

## Part 2 — Ten hypotheses

### 2.1 Supply chain is absent

**Verdict: CONFIRMED.**

Evidence. A grep over all 28 files for `dependenc|lockfile|package-lock|sbom|provenance|npm audit|supply chain|transitive|renovate|dependabot|pinned|CVE|vulnerab` returns ten hits, and **every one of them is about something else**: nine are the sibling skill's *dependency rule* between layers (`SKILL.md:10`, `README.md:5`, `procedure.md:7,71`, `GLOSSARY.md:7`, `briefs/phase-1-gates.md:9`, `modes/diagnose.md:44`, `modes/maintain.md:20`), and one is `areas/data-security.md:11` "anonymizes dependencies", meaning database rows. The word `package.json` appears twice and both times as a thing to *read for scripts*: `briefs/phase-0-diagnosis.md:30` "READ: package.json (scripts, dependencies)" and `:43` "Existing scripts and what they actually run (read package.json: `test` might be e2e)". D2's secrets measure is the only third-party-tooling call in the corpus — `briefs/phase-0-diagnosis.md:61` "scan with gitleaks if available" — and it looks for leaked secrets, not for vulnerable packages. CI is inspected only for *presence of the gates*: `briefs/phase-0-diagnosis.md:43` "Is there a CI or a hook that runs them (`.github/` folder, `.husky/`, pipeline config)?" — never for what the workflow is allowed to do or what it pulls in. `modes/maintain.md:22` wires guards *into* CI without ever auditing CI itself.

Severity: **P1**. A03:2025 is the highest-ranked category the corpus has no control for at all, and RV.1.1/PW.4.4 are unstaffed practices in a method that claims to close every defect class with evidence.

Belongs in: **this skill**. It is not structure.

Minimal change (3 lines, `areas/data-security.md` § Security, after line 21):
```
- [ ] A dependency audit in the verify chain: known vulnerabilities at zero High/Critical, or each one with a written ruling and a date.
- [ ] Lockfile committed and installs reproducible (`ci`-style install, not `install`); direct dependencies pinned; CI actions pinned to a commit, workflow token read-only.
- [ ] An SBOM (CycloneDX or SPDX) generated by a command and handed over with the minutes.
```
plus one measure line in `briefs/phase-0-diagnosis.md` D2 and one column in `templates/diagnosis-report.md`.

### 2.2 Authorization as a model is absent

**Verdict: CONFIRMED**, and more sharply than the hypothesis states: **RLS as this skill configures it cannot cover object-level authorization on any request path.**

Evidence, in three quotes that must be read together.

1. `areas/data-security.md:22`: "**Deny-all row-level security** on every table, no policy for public roles until real database identities exist; verified with a query."
2. `areas/data-security.md:54`: "Only the expected roles should appear (normally `postgres` / `service_role`)." — and `briefs/phase-2-data.md:21` makes this the goal: "every sensitive function with an explicit `revoke execute from public, anon, authenticated`".
3. `areas/quality.md:10`: a static rule for "no service key outside the data layer" — which is a rule about *where* the service key is used, and therefore a statement that it **is** used, in the data layer.

The service role bypasses RLS by construction. So in the target state this skill drives a project toward, every application read and write travels on a `service_role` connection, RLS is never evaluated for it, and the deny-all policies protect only against direct database access with an `anon`/`authenticated` key. The hypothesis's condition — "every read goes through a role-scoped client, no `service_role` bypass in request paths" — is not merely unmet; the corpus's own grant target (`normally postgres / service_role`) makes it unreachable without a rewrite of the access model. RLS here is a perimeter control against PostgREST-style direct access, correctly and thoroughly specified, and it is not an authorization model.

The one application-side control is `briefs/phase-1-gates.md:25`: "(1) every function exported from an actions file textually contains a role guard", implemented as `:26` "pattern on the text (`export async function $F` with a guard inside); glob on the action file names, and in the rule's comment state that a file outside the glob makes the rule go **SILENT**." A textual guard proves that a function *mentions* a role check. It cannot see the object. `R5.5` (`briefs/phase-5-tests.md:42`) strengthens it to "a test that calls it for real **without permission**" — which tests function-level authorization (API5:2023 / CWE-306), never object-level (API1:2023 / CWE-639). Nothing in the corpus asks whether user A can read user B's record.

The external corpus is explicit that this is the project's job, not the framework's. Next.js, `app/guides/data-security`, v16.3.4: "Beyond authentication (is the user logged in?), remember to check **authorization** (does this user have permission to act on this specific resource?). This prevents Insecure Direct Object Reference (IDOR) vulnerabilities" — and its own audit checklist asks "Does the action check ownership of the resource (authorization, not just authentication)?"

Severity: **P1**. Belongs in: **this skill**.

Minimal change (3 lines). One in `areas/data-security.md` § Security: `- [ ] Every action that takes an identifier from the client proves ownership or scope on the object before acting; the read that proves it and the read that acts are the same read.` One in `briefs/phase-1-gates.md` R1.2, as rule (5): a rule that flags an exported action whose parameters include an id and whose body has no ownership predicate, with its own `ruleid:`/`ok:` fixtures. One in `briefs/phase-5-tests.md` R5.5: `for every action taking an identifier, a second test that calls it as a legitimate user of the wrong object; canary: remove the ownership predicate, the test turns red.`

### 2.3 Web-surface classes

**Verdict: PARTIALLY CONFIRMED.** All seven classes are absent from the corpus (a grep for `csp|content-security|security header|csrf|xss|ssrf|open redirect|clickjack|upload|sanitiz|cors|samesite|httponly` across 28 files returns **zero** relevant hits — the three matches are `areas/data-security.md:29,89` and `GLOSSARY.md:46`, all about cookie revocation and channels). But one of the seven is out of scope by design, and the rest split.

Pinned framework fact, `https://nextjs.org/docs/app/guides/data-security`, version **16.3.4**, lastUpdated **2026-08-25**:
> "Behind the scenes, Server Actions use the `POST` method, and only this HTTP method is allowed to invoke them. This prevents most CSRF vulnerabilities in modern browsers, particularly with SameSite cookies being the default." … "As an additional protection, Server Actions in Next.js also compare the Origin header to the Host header (or `X-Forwarded-Host`). If these don't match, the request will be aborted."

Per class:

| class | verdict | why |
|---|---|---|
| **CSRF, server actions** | **out of scope by design** | The framework guarantees POST-only plus Origin/Host comparison. Adding a CSRF checklist item here would be noise. |
| **CSRF, route handlers and non-Next stacks** | **missing** | The guarantee is specific to server actions. The corpus's own scope sentence says "Next.js/Supabase **or a similar stack**" (`SKILL.md:3`) and `SKILL.md:96` promises translation of *names*; a guarantee is not a name. On Django or on a `route.ts` the guarantee is gone and nothing replaces it. P2. |
| **Security headers and CSP** | **missing** | Not framework-provided (Next.js ships a separate CSP guide). ASVS V3, A02:2025, and the corpus's own strongest instinct — fail closed, secure by default — all point here, and `R2.1` already owns startup configuration. P2. |
| **Clickjacking** | **missing** | One directive (`frame-ancestors`) inside the CSP item above; not a separate finding. P3. |
| **XSS / DOM sinks** | **missing** | React escapes by default, which is why this is a *grep* rather than a policy: `dangerouslySetInnerHTML`, `innerHTML`, `srcdoc`, `javascript:` hrefs. The corpus already greps for eight other shapes in D4; this is the cheapest possible addition. P2. |
| **File upload** | **missing, conditional** | Applies only when the stack map shows an upload path. Where it applies, CWE-434 is rank 12 and the corpus has nothing. P2. |
| **SSRF** | **missing, conditional** | Applies wherever the app fetches a URL that a user or an integration supplied. The corpus has integrations throughout Phase 2 and never asks where the URL came from. P2. |
| **Open redirect** | **missing** | Sharpened by the corpus's own rule: `areas/data-security.md:42` "Post-write navigation happens server-side (`redirect()` inside the action, after invalidations)". It mandates the sink and never checks the destination is not client-controlled. P3. |

Belongs in: **this skill** for all of them. Minimal change (3 lines, `areas/data-security.md` § Security):
```
- [ ] Security headers set in one place and asserted by a test: CSP (with `frame-ancestors`), `Strict-Transport-Security`, `X-Content-Type-Options`, `Referrer-Policy`; session cookies `HttpOnly`, `Secure`, `SameSite`.
- [ ] No client-controlled value reaches a redirect target, an outbound fetch URL, or an HTML sink (`dangerouslySetInnerHTML` and equivalents): grep = 0, or each hit justified next to it.
- [ ] Uploads, where they exist: declared type and size limit, stored outside the served root, served with a fixed content type, filename never used as a path.
```

### 2.4 Input validation at the boundary is assumed, never measured

**Verdict: CONFIRMED.**

Evidence. Every occurrence of `validat` in the corpus is one of two things. (a) The environment module's own shape check — `briefs/phase-2-data.md:13` "one module loaded at startup; validates presence, non-placeholder, shape (URL, minimum length)". (b) User-facing validation *copy* — `areas/user-communication.md:13` "validation errors sit next to the field, with **the same wording on every entry point** (create, edit, import)", and `briefs/phase-4-interface.md:75` "test that the validation wording is identical across entry points". No area, no brief and no diagnosis measure asks whether a server action's arguments, a route handler's body, a URL parameter or a webhook payload is parsed against a schema before use. The four static rules in `briefs/phase-1-gates.md:25` are guards, PII in logs, service keys and server directives; input validation is not among them.

The hypothesis is confirmed and the gap is load-bearing: without boundary validation, the corpus's *own* controls degrade. A cap that "declares `truncated`" (`areas/performance.md:17`) assumes the page size it received is a number. A discriminated outcome assumes the input reached a known branch. The framework doc is explicit — "You should always validate input from client, as they can be easily modified. For example, form data, URL parameters, headers, and searchParams" — and its audit checklist asks "Are the Action arguments validated in the action or inside the Data Access Layer?" and "**`/[param]/.`** Folders with brackets are user input. Are params validated?"

Severity: **P1** (CWE-20 rank 18, and it is the precondition for several others). Belongs in: **this skill**.

Minimal change (2 lines). `areas/data-security.md` § Security: `- [ ] Every public entry point (action, route handler, webhook, URL parameter) parses its input against a declared schema before the first use; a parse failure is a readable rejection, never a crash and never a coerced value.` Plus rule (5) in `briefs/phase-1-gates.md` R1.2 and one row in `templates/diagnosis-report.md`.

### 2.5 Observability is thin

**Verdict: PARTIALLY CONFIRMED — and the correlation-id half is REFUTED.**

The two halves do connect, explicitly and in three places. `areas/user-communication.md:9`: "On screen: what happened, what the person can do, a short correlation id for support. **The technical detail goes to the server log under the same id.**" `GLOSSARY.md:64`: "what happened, what to do, a correlation id; details go to the server log under the same id." `briefs/phase-4-interface.md:65`: "every error becomes `{title, whatToDo, id}`, and the detail goes to the server log under the same id." The on-screen id is specified to be the same id as the server log line. That is end-to-end correlation for the error path, and the hypothesis's claim that it is missing is wrong.

What the hypothesis gets right. The correlation covers only the *error* path — nothing carries an id through a successful multi-module process, which is exactly where the flow tests of `R5.8` operate. Logging policy is a single negative constraint: `areas/data-security.md:41` "Structured logs with no personal data" and the static rule at `areas/quality.md:10` "no personal data in logs"; nothing says what *must* be logged (who did what to which object, when), which is ASVS V16 and A09:2025. Metrics do not exist: zero occurrences of `metric`, `dashboard`, `SLO`, `golden signal`. Retention does not exist. Alert fatigue is one clause — `areas/data-security.md:41` "alerts guarded against an alert that stays permanently stuck on" — which is real but is one failure mode, not a policy. A `MONITORING.md` runbook is required by `briefs/phase-6-documentation.md:51` with no content specified for it, and `briefs/phase-0-diagnosis.md:124` asks only "do they exist? have they been run?".

Severity: **P2**. Belongs in: **this skill** — `R6.7` already owns `MONITORING.md` and `areas/data-security.md` § Integrations and operations already owns the channel table.

Minimal change (3 lines, `areas/data-security.md` § Integrations and operations, after line 41):
```
- [ ] A request id generated at the edge, carried through every log line of the request, and returned as the support id on screen; one grep proves the same id reaches both.
- [ ] A written list of the events that must be logged (authentication outcome, authorization refusal, irreversible action, permission change, migration applied) with the actor, the object and the instant.
- [ ] Log retention and alert routing decided and written down (who gets woken, after how many, for how long logs are kept); `MONITORING.md` carries the list.
```

### 2.6 Secret lifecycle stops at presence

**Verdict: PARTIALLY CONFIRMED.**

What exists. Fail-fast on presence, placeholder and mutual consistency (`areas/data-security.md:19`, `briefs/phase-2-data.md:12`). Key separation by purpose (`:20`). "Secrets stay server-side only; a clean secrets scan" (`:21`), scanned with gitleaks (`briefs/phase-0-diagnosis.md:61`). Never in reports (`procedure.md:26`, `briefs/phase-7-handover.md:3,18`). Regenerated once, at handover (`briefs/phase-7-handover.md:17`, `GLOSSARY.md:80`).

What the hypothesis calls the revocation runbook is stronger than "one runbook": `areas/data-security.md:29` requires "a 'what it hits, what it doesn't' table (changing a password does not revoke a signed cookie; rotating the session secret does)", and `briefs/phase-2-data.md:37` enumerates its rows — "(password, session secret, signing secret, revocation counter)". That is a blast-radius table for revocation, and it is precisely the artefact the hypothesis says is missing. So the hypothesis is over-stated on blast radius.

What is genuinely absent: **rotation as a recurring event** (the word `rotat` appears twice in 28 files, both inside the revocation table at `areas/data-security.md:29` and `briefs/phase-2-data.md:37`, never as a schedule or a trigger); **storage** (no vault, no manager, no statement of where a secret lives between the developer's machine and the platform); **post-leak procedure** (zero occurrences of `leak` outside `gitleaks`; nothing says what to do the hour after gitleaks fires on a commit that is already pushed). The `R7.2` regeneration is a one-off delivery step, not a lifecycle.

Severity: **P2**. Belongs in: **this skill** — `R2.4` already owns `ACCESS-REVOCATION.md`.

Minimal change (2 lines, `areas/data-security.md` § Security, after line 29): `- [ ] Every secret has a written home (where it lives, who can read it) and a rotation trigger (a date, or an event); rotation is rehearsed once, like restore.` and `- [ ] A leaked-secret procedure in the same runbook: revoke first, rotate, purge, then look for what was done with it — with the order fixed, because the order is what people get wrong under pressure.`

### 2.7 The sibling is a hard prerequisite disguised as a soft one

**Verdict: PARTIALLY CONFIRMED — and largely REFUTED on the specifics.**

Count: `design-software-properly` appears **32 times across 15 of the 28 files**. The distribution is `briefs/phase-1-gates.md` 4; `SKILL.md`, `modes/maintain.md`, `GLOSSARY.md`, `briefs/phase-4-interface.md`, `briefs/phase-0-diagnosis.md` 3 each; `README.md`, `procedure.md`, `modes/diagnose.md`, `briefs/phase-2-data.md` 2 each; `templates/diagnosis-report.md`, `modes/review.md`, `briefs/phase-6-documentation.md`, `briefs/phase-5-tests.md`, `areas/interface.md` 1 each.

The claim to test is whether the degraded path is *specified* or merely *mentioned*. It is specified, in every case that degrades, in almost identical words:

- `areas/interface.md:5` — "Repairs here land on the shell **when it exists, on the existing list components otherwise, and are repeated once the shell arrives**".
- `procedure.md:110` — the same sentence, as Phase 4's entry condition.
- `briefs/phase-4-interface.md:3` — the same sentence again, in the common header, and `:20` and `:63` name the fallback target per brief ("mounted next to the table shell … when it exists (next to the existing list otherwise)"; "the list shell (… table shell when it exists, the existing list components otherwise)").
- `briefs/phase-1-gates.md:42` — "Known divergence points (from the sibling skill …, when it exists; **otherwise list them by reading the two adapters**)".
- `briefs/phase-2-data.md:58-59` — "(from the coupling diagnosis …, D3, when it exists; **otherwise found in this brief**)" / "**otherwise measured in this brief**".
- `briefs/phase-5-tests.md:61` — "blast radius from the coupling diagnosis … when it exists, **otherwise from the processes in the stack map**".
- `modes/review.md:8` — "when they are missing, the review **says so as a note and reviews what it can**".
- `briefs/phase-0-diagnosis.md:96` and `areas/interface.md:46` — the inverse case: if the sibling's report exists, do not repeat it.

Two references have **no** degraded path, and both are the same shape: `modes/maintain.md:28` ("Blast radius of the change: owners, effect map and co-change (from the sibling skill …, when present)") and `GLOSSARY.md:53-54`, which define the field registry and table shell as artefacts "built by the sibling skill … (brief R3.1/R3.2)" with no local alternative. `modes/maintain.md:28` is the real one: it is the change-time protocol, it runs forever after handover, and if the sibling never ran there is no owners file and no effect map, so step 2 silently produces nothing while `modes/review.md:8` — the *other* place that needs the same data — has a written fallback. The asymmetry is the finding.

Severity: **P3**. The prerequisite is soft and honestly declared; one step lost its fallback.

Belongs in: **this skill**. Minimal change (1 line, `modes/maintain.md:28`, extend the sentence): "…, when present; when absent, the blast radius is the tables the change writes, the channels and caches it touches, and the processes in the stack map that cross it — and that limitation is stated in the review."

### 2.8 Rollback is missing

**Verdict: CONFIRMED.**

Evidence, negative and exhaustive: a grep over all 28 files for `rollback|roll back|revert|down migration|undo|backout|feature flag|blue-green` returns **zero hits**. `restore` returns hits only in two unrelated senses — backup/restore (`areas/data-security.md:39`, `briefs/phase-6-documentation.md:51`, `briefs/phase-7-handover.md:26-28`) and the canary's file restore (`briefs/verifier.md:28`, `briefs/phase-5-tests.md:13`).

Now the four cases the hypothesis names, against what the corpus actually applies:

| what gets applied | where | forward path | rollback path |
|---|---|---|---|
| A schema/policy/grant migration | `briefs/phase-2-data.md:18-24`, `R3.2`, `R3.6`, ask-first at `procedure.md:24` | fully specified: written from the latest definition, grants reasserted, verification queries with expected results, "apply after the go-ahead, then run verify-permissions.sql" | **none** |
| A permission change (deny-all RLS, `revoke execute`) | `briefs/phase-2-data.md:21` | as above | **none** — and this is the one that can lock the application out of its own database between the migration and the code deploy |
| A cache change (TTL + tags, invalidation moved into the service) | `briefs/phase-3-performance.md:34-40` | specified with a two-path test and a canary | **none** — and `areas/performance.md:13` lists data that must never be cached, i.e. the corpus knows the failure is a correctness failure, not a slowness one |
| An environment rebuild | `briefs/phase-7-handover.md:15-19` | specified: accounts, new project, regenerated secrets | **none** — `R7.6` records what was delivered; nothing records how to get back |

`briefs/phase-2-data.md:29` mandates the *shape* that makes rollback thinkable — "every migration rerunnable (`if not exists`, `drop … if exists`, `create or replace`)" — and never asks for the reverse. `R2.3` produces a release checklist (`docs/operations/RELEASE.md`) whose specified content is "'migration applied and column present on the DB BEFORE the code push' and 'CLI project reference = the env's host'" — the forward order only. `procedure.md:24` makes every one of these ask-first, which is a *permission* gate, not a *recovery* plan: the user approves the apply, and neither party knows the cost of undoing it.

Severity: **P1**, exactly as the hypothesis frames it: the premise of the method is that nothing is asserted without evidence and nothing irreversible happens by accident, and the corpus's own P1 definition is "one step from irreversible damage" (`modes/diagnose.md:27`). Every apply in Phases 2, 3 and 7 is currently one step from irreversible by that definition.

Belongs in: **this skill**. Minimal change (3 lines). `areas/data-security.md` § Migrations and environments: `- [ ] Every migration carries its reverse in the same file, or a written line saying why there is none and what the recovery is instead (restore from backup, at what cost, with what data loss window).` `briefs/phase-2-data.md` R2.3, GOAL: add "…; a release checklist with the forward order **and the backout order**, and for each step the observation that says it worked and the one that says to stop." `briefs/phase-3-performance.md` R3.4, DONE: add "…; the one-line kill switch that turns the cache off, and the test that proves the product is correct with it off."

### 2.9 No regression budget

**Verdict: CONFIRMED.**

Evidence. `modes/maintain.md:42-49` defines the drift check completely, and its acceptance rule is absolute: "`:46` Compare every measure with `status.md` and the last report: **a measure that got worse is a finding; a closed defect found again is a P1.**" `procedure.md:158` says the same for the re-diagnosis: "Every line that got worse, or stayed unchanged with no written reason, **reopens the corresponding phase**." A grep for `budget|acceptable rate|renegotiat|tolerance` across 28 files returns five hits, none of them about defect rates: three are a *time* budget (`areas/quality.md:13`, `briefs/phase-5-tests.md:20`, `templates/agent-brief.md:79`), one a rate-limiting threshold (`areas/data-security.md:28`), one a UI threshold to be removed (`areas/interface.md:67`).

So the corpus has a zero-tolerance rule and no escape valve. Two consequences follow, both predictable. First, there is no number at which a team stops re-enforcing and starts renegotiating: nothing says "three NEW P2s per month in this area is the expected rate; five means the target state is wrong, not the code". Second, the only exit from a finding is the ruling line (`procedure.md:166`), which is per-defect and adversarial by design; there is no per-period, per-area accounting that would show a *pattern* of rulings and read it as a signal about the target state rather than about the team. `modes/maintain.md:40` comes closest and points the other way — "If it feels heavy, the guard set is incomplete: make the guards catch what the review keeps finding" — which treats every recurrence as a guard to add, never as a target to revisit.

The external framing: DORA's Change Failure Rate is exactly the missing measure, and SRE's error budget is exactly the missing decision rule ("when the budget is spent, stop shipping and fix" — here: "when the drift budget is spent, stop enforcing and renegotiate").

Severity: **P3**. It costs nothing today and costs a project its willingness to run `maintain` in month six.

Belongs in: **this skill**. Minimal change (2 lines, `modes/maintain.md` § 3, after step 3):
```
3b. Rate, not just count: NEW defects per area since the last drift check, against the rate agreed at handover. Under it, enforce. Over it twice running, the target state for that area is the finding: open a decision question ("is this rule worth what it costs here?") instead of a repair brief.
```

### 2.10 Non-web stacks: Django + MySQL counter-case

**Verdict: PARTIALLY CONFIRMED.** The claim at `SKILL.md:96` — "Names (`loading.tsx`, RLS, server action, `next build`, semgrep, `node --test`, Playwright) come from a Next.js plus Postgres stack. Phase 0 produces `stack-map.md`, which **translates every generic name** into the host project's" — is true for 33 of the 41 units below and breaks in three identifiable places.

Test subject: a Django + MySQL back-office. No RLS; permissions enforced by Django's auth framework and by querysets scoped in views; Django templates plus HTMX; `manage.py test`; no build step; `django-admin check --deploy` as the nearest thing to a release gate.

**Diagnosis measures**

| unit | verdict | note |
|---|---|---|
| D0 stack map and processes | survives | this is the brief built for the job; `urls.py` is a *better* surface source than file-based routing |
| D0 § "real production build" row | **needs a new measure** | there is no build. `manage.py check --deploy` + `collectstatic` is the nearest, and it checks a different class (settings) |
| D1 quality gates | survives | `mypy`/`ruff`/`pytest` map one to one |
| D2 items 3–4 (RLS query, `pg_proc.proacl`) | **meaningless** | MySQL has no row-level security and no `proacl`. See "where it breaks", (a) |
| D2 items 1–2, 5–12 | survives | env, secrets, migrations, environments, tokens, dates, channels, backup, navigation, test endpoints all translate |
| D3 performance | survives, well | `.all()` is *literally* the Django ORM idiom; `select_related`/`prefetch_related` is the N+1 measure; `Paginator` is DB-side pagination; `count()` is the count |
| D4 interface | survives | and `grep disabled` matters *more*: a disabled `<input>` is omitted from an HTML form POST, which is an HTML fact, not a React one |
| D4 item 7 (skeletons per route) | **meaningless** | server-rendered templates have no route-level loading state; HTMX `hx-indicator` is a different control |
| D5 documentation and method | survives, entirely | stack-agnostic |

**Repair briefs**

| unit | verdict | note |
|---|---|---|
| R1.1 single verify script | survives | add `check --deploy` as the fourth gate in place of `build` |
| R1.2 static rules with fixtures | survives | semgrep supports Python; rules (1)–(3) translate; **(4) "no server directive in the data layer" is meaningless** (no `'use server'`/`'use client'`) |
| R1.3 red e2e on the property | survives | |
| R1.4 "tested against" declaration | survives | |
| R2.1 fail-fast configuration | survives | `SECRET_KEY`, `DEBUG=False`, `ALLOWED_HOSTS` are the canonical three |
| R2.2 RLS policies and grants | **meaningless as written; needs a new measure** | the replacement is: every queryset that serves a request is scoped by the acting user; DB account least-privilege; `has_object_permission` on every detail view. See § 2.2 — this is the measure the Next.js stack needed too |
| R2.3 migrations idempotency and replay | **needs a new measure** | "**Idempotent migrations**, never squashed" (`areas/data-security.md:32`) is wrong here. Django keeps migration state in `django_migrations`, reruns are a no-op by construction rather than by `if not exists`, and `squashmigrations` is a supported, recommended command. Following this rule on Django produces worse migrations. See (c) |
| R2.4 tokens, sessions, revocation | survives, trap inverted | Django rotates the session auth hash on password change, so the corpus's trap (`areas/data-security.md:89`) is already handled by the framework; the runbook still has value |
| R2.5 dates as instants | survives | `USE_TZ` and naive-vs-aware datetimes are the same defect with different names |
| R2.6 channels live-test plan | survives | |
| R2.7 webhook idempotency, keys, outbox | survives | |
| R3.1 full scan → targeted access | survives | |
| R3.2 counts in the database | survives | `.count()`, `.aggregate()`; the "migration with a counting function" step is optional here |
| R3.3 per-page reads and tabbed routes | survives | |
| R3.4 peripheral cache with tags | **needs a new measure** | Django's cache framework has no tag invalidation. The substitute is key versioning or `delete_many` over a derived key set; the corpus's rule "cross-check declared tags against invalidations in the same file" has no target to grep for |
| R3.5 per-request timeout, batched pagination | survives | |
| R3.6 generated columns and indexes | survives | MySQL generated columns, `Meta.indexes` |
| R3.7 declared caps | survives | |
| R3.8 per-route skeletons and Suspense | **meaningless** | no equivalent; the honest translation is "drop this step and say so in the plan", which the corpus has no cell for |
| R4.1 tokens and color-by-verb | survives | |
| R4.2 auto-apply filter panel | survives | `hx-trigger="keyup changed delay:300ms"` |
| R4.3 single view per list | survives | |
| R4.4 read-only, mounted and hidden editors | survives, and generalizes | see D4 above |
| R4.5 two tracks for actions | survives | |
| R4.6 feedback, discriminated outcomes, isolated irreversible | survives | `aria-busy` needs an HTMX equivalent; the outcome enumeration is stack-free |
| R4.7 skeletons and navigation | partly | sidebar and breadcrumb survive; the skeleton half is meaningless |
| R4.8 readable errors and five states | survives, **grep list needs new entries** | `error.message`/`digest` → `str(e)`, `traceback`, Django's `DEBUG` error page. The stack map carries *names*, not *greps*; nothing tells D4 to retranslate its own search strings |
| R4.9 labels, hints, tooltips, glossary | survives, easier | Django forms have `label` and `help_text` as first-class fields |
| R4.10 outcomes, confirmations, expiry, reports | survives | `django.contrib.messages` |
| R5.1 canary per harness | survives | |
| R5.2 e2e warm-up | **meaningless** | the warm-up exists because the Next dev server compiles on demand (`areas/quality.md:88`). Django has no on-demand compilation; the underlying invariant (never measure the first run) survives only as a weak note |
| R5.3 acceptance checklist from the code surface | survives, better | `urls.py` + admin registrations are a cleaner partition of the surface |
| R5.4 dirty fixture corpus | survives | |
| R5.5 presumed guards, a test that invokes | survives, and matters **more** | with no RLS backstop, this is the only authorization evidence |
| R5.6 adversarial bug hunt | survives | |
| R5.7 live channel checks | survives | |
| R5.8 flow test per process | survives | |
| R6.1–R6.8 documentation | survives, all eight | stack-agnostic by construction |
| R7.1 handover plan | survives | |
| R7.2 fresh environment | survives | |
| R7.3 migration replay and table verification | partly | see R2.3; the *verification* half (table/function/policy counts) needs a MySQL translation and loses the policy row |
| R7.4 backup and restore | survives | `mysqldump` + count comparison |
| R7.5 channels on the new environment | survives | |
| R7.6 minutes | survives | |

Tally: **33 survive translation, 5 need a new measure, 5 are meaningless** (`R1.2` rule 4, `R3.8`, `R5.2`, `D0`/`D4` skeleton rows, `R2.2`'s database half), **2 partly** (`R4.7`, `R7.3`).

**Where the map breaks — three places, all of them the same shape: the map translates names, and these are not names.**

(a) **A control that has no counterpart.** RLS is not a name for a thing every stack has; it is a Postgres capability. The honest translation is "this control does not exist here; the following moves into the application layer instead", and `briefs/phase-0-diagnosis.md:31`'s table — "generic name | name here | command | notes" — has no cell for *absent, replaced by*. D2 items 3–4 then read "not measured" (per `briefs/phase-0-diagnosis.md:9`), which is correct and useless: the strongest control in the whole skill silently evaporates and the report says only that it could not be measured.

(b) **A gate-chain claim presented as universal.** `areas/quality.md:22-33` is a stack-neutral table of what each gate sees and does not see, and two of its ten rows are Next-specific: "real build | **the only gate that prerenders**: server to client serialization" and "e2e with warm-up". `areas/quality.md:27` and `SKILL.md:62` assert the build's uniqueness as a general fact ("Only the real build prerenders and catches a non-serializable value crossing to the client"). On a stack with no build, the chain loses a row, nothing replaces it, and the "chain is not redundant" argument (`areas/quality.md:3`) now argues for a chain with a hole in it.

(c) **A rule that is right on one migration tool and wrong on the others.** `areas/data-security.md:32` "**Idempotent migrations**, never squashed; replay proven on an empty project" is shaped by a stateless, file-replay CLI. Django, Rails and Alembic keep migration state and support squashing as a maintenance operation. This is the only place in the corpus where following the target state makes the host project *worse*, and it is stated as a target-state checkbox rather than as a stack-conditional one.

Severity: **P2**. Belongs in: **this skill**.

Minimal change (2 lines). `SKILL.md:96`, extend: "…every generic name into the host project's. Where a control has **no counterpart** on the host stack (row-level security on a database that has none, a prerender gate on a stack with no build), the map says so in a fourth column — *absent here; replaced by* — and names the replacement or records that the phase drops the step; 'not measured' is for a control that exists and could not be read, never for one that does not exist." Plus one word in `areas/data-security.md:32`: make "idempotent, never squashed" conditional on "a migration runner that keeps no state; where the runner keeps state, the equivalent is: replay proven on an empty database, and a squash is a decision record."

---

## Part 3 — Synthesis

### 3.1 Confirmed gaps, ranked by defects prevented per line of skill text added

| rank | gap | lines to add | why this rank |
|---|---|---|---|
| 1 | **Object-level authorization** (§ 2.2) | 3 | The single highest-yield edit in the corpus. Three lines close API1, CWE-639, CWE-862's real form and A01's application half, on a method that already has the delivery mechanism (a static rule with fixtures, a test that invokes the action, a canary) and is only missing the *predicate*. |
| 2 | **Rollback** (§ 2.8) | 3 | Prevents the one class the method's own P1 definition names, on four steps it already performs. Costs nothing to state; the artefacts (`RELEASE.md`, the migration file, the cache module) all exist. |
| 3 | **Supply chain** (§ 2.1) | 3 + 1 measure | Closes A03:2025, PW.4.4, RV.1.1, four Scorecard checks and the SBOM deliverable at once, and the delivery mechanism (a gate in `verify`, a row in the diagnosis table) already exists. Ranked below rollback only because a dependency CVE is rarely one step from *this* product's data loss. |
| 4 | **Input validation at the boundary** (§ 2.4) | 2 | One target-state line and one static rule; it is the precondition several of the corpus's own controls silently assume. |
| 5 | **Web surface: headers/CSP, sinks, upload, SSRF, redirect** (§ 2.3) | 3 | Five classes in three lines, two of them conditional on the stack map. Ranked below validation because React and the framework already eliminate the most common instances. |
| 6 | **Non-web translation** (§ 2.10) | 2 | Fixes a claim the skill makes about itself, and prevents the one case where following the target state makes a project worse. |
| 7 | **Observability** (§ 2.5) | 3 | Half of it already exists; the three lines finish the correlation id, name what must be logged, and give `MONITORING.md` its content. |
| 8 | **Secret lifecycle** (§ 2.6) | 2 | Rotation trigger and leak procedure, attached to a runbook that already exists. |
| 9 | **Regression budget** (§ 2.9) | 2 | Prevents no defect directly; prevents the abandonment of `maintain`, which prevents all of them. Low rank, high half-life. |
| 10 | **Tutorial quadrant** (§ 1.9) | 1 | One folder and one line in `R6.4`; it matters only at handover, and only once — but that once is what the client remembers. |
| 11 | **Sibling fallback in `maintain`** (§ 2.7) | 1 | A one-clause repair of an asymmetry. |

### 3.2 Gaps marked "neither" — the exact bullets for `SKILL.md` § When not to use it

That section currently has four bullets (`SKILL.md:53-56`) and is silent on all of these. Add, in the skill's voice:

```
- The platform and the perimeter: TLS, WAF, DNS, network policy, hosting configuration. This skill measures what is in the repository and on the database; whatever the platform owns is named in the handover minutes as the client's, not repaired here.
- Identity infrastructure: OAuth and OIDC flows, credential storage, MFA enrolment, directory sync. The skill checks how the product uses a session and a token; it does not build or audit the identity provider.
- Repository and release governance: branch protection, code owners, commit signing, signed release artefacts, SLSA build levels above provenance. That is organisational policy. The skill wires guards into `verify` and CI; it does not decide who may push.
- Running the product after handover: on-call rotation, service level objectives and error budgets, incident command, delivery-velocity metrics. The skill leaves runbooks, a live channel table with dates, and a drift check; it does not staff an operation.
- Memory safety, native code, deserialization of untrusted binary formats, command execution. On a managed-runtime web stack these classes are absent by construction; if the stack map shows a shell-out or a native extension, that is a separate audit and the plan says so.
```

### 3.3 Gaps marked "this skill" — where each attaches

No new phases. Eight is the cap and eight is enough; every gap below lands on an area or brief that already exists.

| gap | attaches to |
|---|---|
| Supply chain | `areas/data-security.md` § Security (target state) · `briefs/phase-0-diagnosis.md` D2 (one measure) · `briefs/phase-1-gates.md` R1.1 (the audit joins the verify chain) · `briefs/phase-7-handover.md` R7.1 and R7.6 (the SBOM as a delivered artefact) · `templates/diagnosis-report.md` (one row) |
| Object-level authorization | `areas/data-security.md` § Security · `briefs/phase-1-gates.md` R1.2 (rule 5) · `briefs/phase-5-tests.md` R5.5 (a second test per action) |
| Web surface | `areas/data-security.md` § Security · `briefs/phase-2-data.md` R2.1 (headers belong with startup configuration) · `briefs/phase-0-diagnosis.md` D2 (three greps) |
| Input validation | `areas/data-security.md` § Security · `briefs/phase-1-gates.md` R1.2 (rule 5's sibling) · D2 |
| Observability | `areas/data-security.md` § Integrations and operations · `briefs/phase-6-documentation.md` R6.7 (`MONITORING.md` finally gets content) · `modes/maintain.md` § 1 (the guard table gains a row) |
| Secret lifecycle | `areas/data-security.md` § Security · `briefs/phase-2-data.md` R2.4 (`ACCESS-REVOCATION.md` gains two sections) |
| Rollback | `areas/data-security.md` § Migrations and environments · `briefs/phase-2-data.md` R2.3 (`RELEASE.md` gains the backout order) · `briefs/phase-3-performance.md` R3.4 (the kill switch) · `briefs/phase-6-documentation.md` R6.7 |
| Regression budget | `modes/maintain.md` § 3 (step 3b) |
| Tutorial quadrant | `areas/method-documentation.md` § Reference map (one folder) · `briefs/phase-6-documentation.md` R6.4 |
| Non-web translation | `SKILL.md` § Note on the stack · `briefs/phase-0-diagnosis.md` D0 (a fourth column) · `areas/data-security.md:32` (make the rule conditional) |
| WCAG P1/P2/P4 | `areas/user-communication.md` § Target state (the accessibility bullet gains three items) · `briefs/phase-4-interface.md` R4.9 |
| Threat model (PW.1) | `modes/diagnose.md` § 3 Plan, rule 2 ("what is one step from irreversible damage" is already a threat model without the name — say so and give it a list) |

**Sketch, in the skill's voice**, of the checklist items for the two highest-ranked attachments.

`areas/data-security.md` § Security — object-level authorization and the boundary, as target-state lines followed by the traps table they belong to:

> - [ ] Every action that takes an identifier from the client **proves ownership or scope on the object** before acting; the read that proves it and the read that acts are the same read.
> - [ ] Every public entry point (action, route handler, webhook, URL parameter) **parses its input against a declared schema** before first use; a parse failure is a readable rejection, never a coerced value.
> - [ ] Return values to the client are **filtered to what the screen needs**, never the raw row.
>
> | Trap | What it looks like |
> |---|---|
> | A guard that authenticates and never authorizes | the action checks the session, then reads by the id the client sent |
> | RLS believed to cover the request path | deny-all policies, and every read on the service key: the policies are never evaluated |
> | A schema on the form and none on the action | the browser validates, the direct POST does not |

`briefs/phase-2-data.md` R2.3 — rollback, as the brief already reads:

> GOAL (add): every migration carries its reverse in the same file, or one written line saying why there is none and what the recovery is instead, with its data-loss window. Release checklist with the forward order **and the backout order**; for each step, the observation that says it worked and the one that says to stop.
> TEST (add): apply, reverse, apply again on an ephemeral database; the table state matches after each. Canary: remove one reverse, the test must fail.
> DONE (add): table migration | reverse | recovery if none | data-loss window.

### 3.4 Gaps marked "sibling" — one line each

- **ASVS V15 § module boundaries** (least privilege *between modules*, not between roles): the dependency rule in lint already enforces direction; the sibling's `R1.2` is where "the data layer is the only caller of the service key" becomes a boundary rather than a grep.
- **ISO/IEC 25010 § Compatibility and § Flexibility** (co-existence, interoperability, adaptability, scalability, replaceability): these are properties of the module graph, measured by the sibling's D1 and D3 (layers, coupling, one implementation per concept), and they are correctly absent here.

### 3.5 What this skill covers that no external corpus requires — the craft contribution

None of ASVS, the Top 10s, CWE, SSDF, SLSA, Scorecard, SRE, DORA, WCAG or Diátaxis asks for any of the following. They are not gaps and not overlaps; they are what this corpus knows that the standards do not.

1. **The canary as an admission criterion.** "do not trust an anti-regression rig until it has proven it can turn red. A green that cannot fail is decoration" (`areas/quality.md:3`), operationalised as `CANARY=<n>`, a red logged with its date, a restore verified with `cmp` (`briefs/phase-5-tests.md:9-15`, `briefs/verifier.md:24-30`). SSDF PW.8 asks that you test; nothing in any corpus asks that you prove the test can fail.
2. **"Tested against" as a per-test declaration.** `// tested against: fake | real adapter | both | none`, enforced mechanically, with a frozen exemption list that can only shrink (`areas/quality.md:8`, `briefs/phase-1-gates.md:41-47`). The fake/real divergence is a defect class no corpus names.
3. **The evidence ledger.** "A row without evidence is **not done**, whatever the conversation says" (`modes/status.md:11`); evidence is "a file path, a command with its exit code, a record number, a verifier verdict line" and "Never 'done', never 'ok'". SSDF PO.4 asks for criteria; this is criteria plus a refusal to accept prose.
4. **Reading an exit code, never a pipe.** "`build | tail`: the exit status is `tail`'s, not the build's" (`areas/quality.md:81`, `briefs/verifier.md:12`). A one-line mechanical fact that invalidates a whole class of green reports, and it appears in no standard.
5. **The two-stage verifier with an explicit non-instruction.** Brief compliance first, quality second; "The orchestrator **does not trust the repair agent's own report**: it trusts the verifier. And it **never tells the verifier what to ignore**" (`procedure.md:17`). The adversarial separation is the point.
6. **The variant search as an obligation after every close.** `procedure.md:16`: "Every closed defect triggers a **search for variants** … if the shape is mechanical, a static rule is born, with a test of its own." SSDF RV.3.3 asks for the same behaviour and does not make it a per-defect obligation with a promotion path into a machine.
7. **The bounded rejection cycle ending in a written ruling.** Rounds 1–3 resume the same agent with rejections "quoted verbatim, not summarized"; round 4 is a fresh agent on a more capable model; after that, `Ruling: <decision> — <why> — <cost if wrong>` (`procedure.md:160-168`). "A declared residue is worth more than a forced green."
8. **The live channel check with an injected failure.** "Every channel … exercised live with an **injected failure**" and "**Inferring a channel's health** from the channel next to it" as a named trap (`areas/data-security.md:40,86`; `areas/quality.md:86`). A09:2025 asks for alerting; nobody asks you to break the alert on purpose and watch it arrive.
9. **The measure/repair separation and the dated number.** "Read-only rounds never repair" (`SKILL.md:43`); "a number without a date is true only on the day it was written" (`templates/diagnosis-report.md:3`); "The shape of a defect changes with the order of magnitude" (`SKILL.md:69`).
10. **The decision record as the only place with rejected alternatives**, including records for non-decisions and for rejected mistakes: "the line discarded today may become necessary again after an upgrade, and the record says which half to keep" (`templates/decision-record.md:40`).
11. **A number lives in one place.** "A number written in two places diverges. One place; the others link to it" (`SKILL.md:71`), enforced by a grep (`briefs/phase-6-documentation.md:18`). Diátaxis has no opinion on this and it is the single most reliable documentation defect.
12. **The cap that may never be shown as a total.** "Any capped count carries `truncated: true` and the screen says so" (`GLOSSARY.md:63`), and "no irreversible action starts on an ambiguous number" (`briefs/phase-3-performance.md:60`). This is a correctness control wearing a UI control's clothes, and it appears nowhere else.
13. **Error ≠ empty, and the five distinct states.** "A read error falling into the 'no results' branch: whoever looks believes there's nothing there" (`areas/user-communication.md:54`). WCAG does not ask it; A10:2025 gestures at it; only this corpus names the specific lie.
14. **The `disabled` field trap.** "A `disabled` field is omitted from `FormData`: the save reads it as cleared. Mounted and hidden" (`SKILL.md:66`). An HTML fact that silently destroys data and is in no security or quality corpus.
15. **Context isolation for the implementer.** "A subagent receives only its brief, the interfaces it needs and global constraints; never session history; it never spawns subagents" (`GLOSSARY.md:74`), with the failure mode written down: "Session history inside the brief: the agent inherits dirty context and opinions" (`templates/agent-brief.md:82`).
16. **The re-diagnosis as a nine-test.** Phase 0 rerun identically, every measure compared, "a defect marked closed in the register and found again by the diagnosis is a P1", and a declared list of lines that must *increase* (`procedure.md:158`).
17. **"Looks wrong but is fine" as a mandatory report section.** "a report that doesn't say what it ruled out cannot be judged" (`templates/diagnosis-report.md:67`). No standard asks an auditor to publish their false positives.

That list is the part worth keeping, and it is why the gaps above should be added as three-line checklist items rather than as imported chapters: this corpus's method is stronger than the standards it is missing, and the missing controls are cheap to express in its own voice.

---

## Findings index

| id | file:line | severity | finding | change | belongs in |
|---|---|---|---|---|---|
| A6-01 | `areas/data-security.md:19-30` (absence) | P1 | No dependency audit, lockfile discipline, SBOM, provenance, pinned CI action or transitive review anywhere in 28 files; A03:2025, PW.4.4, RV.1.1 and four Scorecard checks unstaffed | 3 target-state lines + 1 diagnosis measure + SBOM as a Phase 7 artefact | this |
| A6-02 | `briefs/phase-0-diagnosis.md:43` | P2 | CI is inspected for *presence of the gates* only; the workflow's own permissions and pinning are never read | one measure line in D1 | this |
| A6-03 | `briefs/phase-7-handover.md:36-39` | P2 | Handover minutes list what was delivered and verified; no bill of materials accompanies the delivery | one DONE line in R7.6 | this |
| A6-04 | `areas/data-security.md:54`; `areas/quality.md:10` | P1 | Grant target is `postgres`/`service_role` while the data layer holds the service key: RLS is never evaluated on a request path, so the corpus's strongest control cannot cover object-level authorization | make the condition explicit in `areas/data-security.md` § Security; add the application-side control | this |
| A6-05 | `briefs/phase-1-gates.md:25-26` | P1 | The only application authorization control is "textually contains a role guard", with a rule that goes SILENT outside its glob; BOLA/IDOR (API1, CWE-639) is unreachable by it | R1.2 rule 5 (ownership predicate) + R5.5 second test + 1 target-state line | this |
| A6-06 | `briefs/phase-5-tests.md:42` | P2 | R5.5 tests function-level authorization ("without permission") and never object-level ("as the wrong owner") | one GOAL clause and one canary in R5.5 | this |
| A6-07 | corpus-wide (absence) | P2 | No security headers, no CSP, no `frame-ancestors`, no cookie attribute posture | 1 target-state line; attach to R2.1 | this |
| A6-08 | corpus-wide (absence) | P2 | No DOM-sink, upload, or SSRF check; the corpus greps for eight other shapes in D4 and not these | 1 target-state line + 2 greps in D2/D4 | this |
| A6-09 | `areas/data-security.md:42` | P3 | The corpus mandates the redirect sink and never checks the destination is not client-controlled | fold into the A6-08 line | this |
| A6-10 | § 2.3 table | P2 | CSRF is framework-guaranteed for server actions only; the guarantee does not travel to route handlers or to "a similar stack" | one note in the stack map's fourth column (A6-19) | this |
| A6-11 | `briefs/phase-2-data.md:13`; `areas/user-communication.md:13` | P1 | Every "validate" in the corpus is the env module's shape check or UI copy consistency; no entry point's payload is schema-validated (CWE-20, ASVS V2, PW.5.1) | 1 target-state line + 1 static rule | this |
| A6-12 | `areas/data-security.md:41` | P2 | Logging policy is one negative constraint (no PII); nothing says what must be logged, for how long, or who is alerted at what threshold | 2 target-state lines; `MONITORING.md` gets content in R6.7 | this |
| A6-13 | `areas/user-communication.md:9`; `GLOSSARY.md:64` | P3 | The on-screen support id *is* the server log id — hypothesis refuted — but correlation exists only on the error path, not through a multi-module process | 1 target-state line (request id at the edge) | this |
| A6-14 | `briefs/phase-2-data.md:18-32`; `briefs/phase-3-performance.md:34-40`; `briefs/phase-7-handover.md:15-19` | **P1** | Zero occurrences of `rollback`/`revert`/`down migration`/`backout` in 28 files, in a method that applies migrations, grants, policies, cache semantics and a whole environment | reverse migration in the same file; backout order in `RELEASE.md`; cache kill switch | this |
| A6-15 | `briefs/phase-2-data.md:29` | P2 | R2.3 mandates the shape that makes rollback possible (`if not exists`, `drop … if exists`) and never asks for the reverse | 1 GOAL clause + 1 TEST + 1 DONE row | this |
| A6-16 | `areas/data-security.md:21,29`; `briefs/phase-7-handover.md:17` | P2 | Secret lifecycle covers presence, separation, scanning and a one-off regeneration; rotation trigger, storage and post-leak procedure are absent (blast radius, however, *is* covered by the revocation table — hypothesis over-stated) | 2 target-state lines; attach to R2.4's runbook | this |
| A6-17 | `modes/maintain.md:28` | P3 | The change-time protocol's blast-radius step has no fallback when the sibling never ran, while `modes/review.md:8` — needing the same data — has one written | extend the sentence by one clause | this |
| A6-18 | `modes/maintain.md:46`; `procedure.md:158` | P3 | Zero-tolerance drift rule with no rate, no budget and no condition under which the target state is renegotiated rather than re-enforced | step 3b in `modes/maintain.md` § 3 | this |
| A6-19 | `SKILL.md:96`; `briefs/phase-0-diagnosis.md:31` | P2 | The stack map translates names; a control with no counterpart on the host stack (RLS on MySQL, a prerender gate with no build) degrades to "not measured" and disappears silently | fourth column *absent here; replaced by*; extend `SKILL.md:96` | this |
| A6-20 | `areas/data-security.md:32` | P2 | "Idempotent migrations, never squashed" is correct for a stateless file-replay CLI and wrong for Django, Rails and Alembic — the only rule in the corpus that makes a host project worse when followed | make the rule conditional on the runner | this |
| A6-21 | `areas/quality.md:22-33,27`; `SKILL.md:62` | P3 | The gate-chain table is presented as stack-neutral; two of its ten rows (real build, e2e warm-up) are framework-specific and the "not redundant" argument does not survive their removal | one conditional note under the table | this |
| A6-22 | `areas/method-documentation.md:23-38` | P2 | The documentation map partitions by artefact, not by need; three Diátaxis quadrants land by accident and the tutorial has no folder and no brief — at handover, to a client's new employee | one folder + one R6.4 clause | this |
| A6-23 | `areas/user-communication.md:20` | P2 | Baseline accessibility is one bullet of six items; WCAG 2.2 Perceivable, Operable and Robust are partial at principle level, Understandable is above requirement | three items on the existing bullet; attach to R4.9 | this |
| A6-24 | `areas/method-documentation.md:12`; `briefs/phase-6-documentation.md:29-35` | P3 | The generated guide's own accessibility (EN 301 549 cl. 10 and 12) is never measured, though its coverage is | one DONE clause in R6.4 | this |
| A6-25 | `modes/diagnose.md:40` | P2 | Ordering rule 2 ("what is one step from irreversible damage") is a threat model without the name and without a list; PW.1 is unstaffed | name it and give it the list already implied by the rule | this |
| A6-26 | `SKILL.md:29-38` | P3 | The six conditions are a cover, not a partition of ISO/IEC 25010: two overlaps, four holes, of which Functional Suitability is the one a client names first and the one neither skill owns | one sentence saying the six are the six places a product lies about itself, not a partition | this |
| A6-27 | `SKILL.md:51-56` | P2 | § When not to use it is silent on platform, identity infrastructure, repository governance, operations and native-code classes; every "neither" in this audit has no home | five bullets, § 3.2 | this |
| A6-28 | `SKILL.md:10`; `GLOSSARY.md:7` | P3 | Least privilege *between modules* (ASVS V15) and ISO 25010 Compatibility/Flexibility are correctly absent here | no change; named for the record | sibling |
| A6-29 | `README.md:39` | P3 | "The repair phases and the verifier have not yet been proven live" — every finding above is measured against a corpus that has never executed; the first run remains the acceptance test | no change; a caveat on this whole audit | this |

---

## Files read (all 28)

`SKILL.md` · `README.md` · `procedure.md` · `GLOSSARY.md` · `areas/quality.md` · `areas/data-security.md` · `areas/performance.md` · `areas/interface.md` · `areas/user-communication.md` · `areas/method-documentation.md` · `modes/diagnose.md` · `modes/decision-qa.md` · `modes/status.md` · `modes/review.md` · `modes/maintain.md` · `briefs/phase-0-diagnosis.md` · `briefs/phase-1-gates.md` · `briefs/phase-2-data.md` · `briefs/phase-3-performance.md` · `briefs/phase-4-interface.md` · `briefs/phase-5-tests.md` · `briefs/phase-6-documentation.md` · `briefs/phase-7-handover.md` · `briefs/verifier.md` · `templates/agent-brief.md` · `templates/decision-record.md` · `templates/diagnosis-report.md` · `templates/status.md`

All 28 read in full with line numbers; 28,768 words by `wc -w` over the same set. Note on provenance: the working tree at read time was on branch **`main`** at commit **c32367a**, not `evolve/audit-01` as the task states; the commit matches, the branch name does not. Files under `audit/` (`specs/executable-assets.md`, `specs/triage-mode.md`, `specs/worked-example.md`) are other agents' concurrent output, are not part of the 28-file corpus, and were excluded from every count and grep.

## Sources fetched

Date accessed for all rows: **11 September 2026**.

| title | body | version | year | URL | accessed |
|---|---|---|---|---|---|
| Application Security Verification Standard | OWASP | 5.0.0 (released 30 May 2025) | 2025 | https://owasp.github.io/www-project-application-security-verification-standard | 2026-09-11 |
| ASVS 5.0 English chapter list (V1–V17) | OWASP (GitHub tree) | 5.0 | 2025 | https://github.com/OWASP/ASVS/tree/master/5.0/en | 2026-09-11 |
| OWASP Top 10 | OWASP | 2025 | 2025 | https://top10.owasp.org/2025 | 2026-09-11 |
| OWASP API Security Top 10 | OWASP | 2023 | 2023 | https://owasp.github.io/www-project-api-security | 2026-09-11 |
| CWE Top 25 Most Dangerous Software Weaknesses | MITRE | 2025 edition (released 15 December 2025) | 2025 | https://cwe.mitre.org/top25/archive/2025/2025_cwe_top25.html | 2026-09-11 |
| Secure Software Development Framework (SSDF), SP 800-218 — Table 1, practices PO/PS/PW/RV | NIST | 1.1 (February 2022) | 2022 | https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-218.pdf (pages 5–18) | 2026-09-11 |
| SSDF project page (four practice groups, definitions) | NIST CSRC | 1.1 | 2022 | https://csrc.nist.gov/Projects/ssdf | 2026-09-11 |
| SLSA — Security levels | OpenSSF | page documents v1.1 (Retired); states current spec is **1.2** | 2025 | https://slsa.dev/spec/v1.1/levels | 2026-09-11 |
| OpenSSF Scorecard — the checks | OpenSSF | current site | 2026 | https://scorecard.dev/#the-checks | 2026-09-11 |
| CycloneDX specification overview | OWASP / Ecma International (ECMA-424, TC54) | 1.7 (released 2025-10-21; ECMA-424 published 2025-12-10) | 2025 | https://cyclonedx.org/specification/overview/ | 2026-09-11 |
| SPDX specifications | Linux Foundation | 3.0; ISO/IEC 5962:2021 | 2021/2024 | https://spdx.dev/use/specifications/ | 2026-09-11 |
| SBOM (page fetched; does not name SPDX or CycloneDX, references 2025/2026 minimum-elements guidance) | CISA | — | 2026 | https://www.cisa.gov/sbom | 2026-09-11 |
| Site Reliability Engineering — table of contents (ch. 3, 4, 5, 6, 11, 15) | Google | 1st edition | 2016 | https://sre.google/sre-book/table-of-contents/ | 2026-09-11 |
| Use Four Keys metrics like change failure rate to measure your DevOps performance | Google Cloud Blog | four keys; editor's note adds reliability as a fifth in 2021 | 2020 | https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance | 2026-09-11 |
| DORA metrics guide (current five-metric model; states the metrics "shifted from the original four keys") | DORA | current | 2026 | https://dora.dev/guides/dora-metrics-four-keys/ | 2026-09-11 |
| How to Meet WCAG (Quick Reference) — four principles, guidelines 1.1–4.1 | W3C WAI | WCAG 2.2 | — | https://www.w3.org/WAI/WCAG22/quickref/ | 2026-09-11 |
| Diátaxis — four quadrants | Daniele Procida | current | — | https://diataxis.fr/ and https://diataxis.fr/tutorials/ | 2026-09-11 |
| ISO/IEC 25010 product quality — nine characteristics and sub-characteristics | ISO 25000 portal | page states no edition year | — | https://iso25000.com/index.php/en/iso-25000-standards/iso-25010 and `?start=5` | 2026-09-11 |
| How to think about data security in Next.js | Vercel / Next.js docs | **16.3.4**, lastUpdated **2026-08-25** | 2026 | https://nextjs.org/docs/app/guides/data-security | 2026-09-11 |

### Could not fetch

- **EN 301 549 (ETSI deliverable PDF)** — `https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf` returned **HTTP 403 Forbidden**.
- **EN 301 549 (Accessible EU Centre digital library)** — `https://accessible-eu-centre.ec.europa.eu/content-corner/digital-library/en-301-549-accessibility-requirements-ict-products-and-services_en` returned **HTTP 404 Not Found**.
- Consequently the EN 301 549 rows in § 1.8 are **search-sourced, not primary-sourced**, and are flagged as unverified in place. Nothing in them is filled from memory: the version claims (V3.2.1 March 2021 / V4.1.1 published 2 September 2026, WCAG 2.1 AA → 2.2 AA, OJEU citation expected October 2026) come from a WebSearch result set, and the clause structure quoted ("Web (Chapter 9), Non-web documents (Chapter 10), and non-web software like mobile apps (Chapter 11)") comes from the same search, not from the standard.
- **OWASP API Security Top 10 2023 canonical page** — `https://owasp.org/API-Security/editions/2023/en/0x11-t10/` returned **HTTP 404**; the category list in § 1.3 was taken instead from the project's own landing page (fetched, listed above).
- **DORA original four keys, from dora.dev** — the current guide states the metrics "shifted from the original four keys to the current five-metric model" without naming the four; `https://dora.dev/guides/dora-metrics-four-keys/history/` returned **HTTP 404**. The verbatim four-key definitions in § 1.7 are therefore taken from the Google Cloud Blog page listed above, which is the original publication of the Four Keys project.
- **CISA SBOM minimum elements** — the fetched page references 2025 and 2026 minimum-elements guidance documents without listing the elements; § 1.6 therefore maps the SBOM *as a deliverable in a named format*, not against a minimum-element list.
