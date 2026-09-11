# 008. Version-drifted Next.js claims are made version-conditional, not rewritten to Next.js 16

**When:** 2026-09-11 (backlog rows C-05, C-06, C-32, C-39)
**Status:** in force

## The problem
The corpus's Next.js vocabulary was written against the origin project's Next.js 14. Against the current release (16.3.4, fetched 2026-09-11) three claims are false or stale: `next build` no longer lints, so "lint Errors block the build" lets a project ship lint Errors with a green build; `unstable_cache` is replaced by `use cache`; `revalidateTag` needs a second argument and `updateTag` throws outside a Server Action, so "invalidate inside the shared service" can throw on the webhook path. The skill's own trap says "verify against the installed package, not the latest docs", and the corpus violates it.

## The choice
Each affected line states the condition and both branches in one clause ("on Next.js ≤ 15 lint also breaks the build; on 16+ it must be its own step in the verify script"; "an invalidation API callable from every path that reaches the service"), and `SKILL.md` § Note on the stack says once that the names were written against Next.js 14 and that Phase 0 re-verifies every named API against the installed major before a brief quotes it. No line is rewritten to assume 16.

## Why and what we rejected
*Rewrite to Next.js 16 throughout.* The origin project and the second project the stack map was tested on are 14 and 15; the corpus would become wrong for the only projects it has run on, and would drift again at 17.

*Leave the wording and rely on the stack map.* The stack map translates names, not gate semantics; a cold orchestrator reading "lint Errors block the build" on a Next.js 16 project does not know to look.

*Strip every framework-specific claim.* Loses the vendor-verified rows, which are a quarter of the evidence base and the best-sourced part of the quality slice.

## Where it lives in the code
`areas/quality.md` § The gate chain; `areas/performance.md` § Target state and § Rules; `SKILL.md` § Excuses and reality, § Note on the stack; `briefs/phase-3-performance.md` R3.4; `templates/diagnosis-report.md` lint row.

## What would change our mind
Next.js 17 changing the cache or build contract again. Then the conditional clauses gain a branch or the framework-specific rows move into a per-version appendix the stack map selects.
