# One defect, end to end

The chain, once. Every other defect has the same shape.

**D4, measure 3.** `grep -rn "disabled" src/components` → 14 hits, 04/03/2026.

**Report line** (`00-diagnosis/interface.md`):

`src/components/contact/contact-form.tsx:88`: fields render `disabled={!editing}` | a disabled field is absent from `FormData`, and the save reads absent as cleared | class: silent data loss | P1 | effort M | lands on: entity editors | NEW

**Synthesis.** Place: entity editors · copies 5 · defects landing 3 → multiplier. Repaired once, before the per-screen work.

**Brief R4.4, filled** (from `briefs/phase-4-interface.md`):

```
CONTEXT: records always in edit mode: contact, company. disabled on editors: contact-form.tsx:88, company-form.tsx:61.
GOAL: read-only by default; Edit as ?edit=1 with replaceState; editors mounted and hidden with CSS, never disabled.
TEST: read the real FormData after read → Edit → Cancel → Edit and count the fields. Canary: put disabled back on one field, it must turn red.
DONE: grep disabled on the components = 0 or documented; 5 records converted.
```

**Repair report** (the agent's own, 15 lines): 5 files · fields in `FormData` 12 → 18 · canary red on `disabled`, restored, `git diff --stat` unchanged · left out: the import preview, no editor · to record: editors mounted and hidden.

**Verifier** (`04-interface/verification.md`):

| brief line | verdict | evidence |
|---|---|---|
| read-only by default | YES | 5 records, `?edit=1` |
| never `disabled` | NO | `company-form.tsx:61` |
| canary seen red | YES | run log |

Verdict: RESIDUAL, 1 × P2 → round 1, same agent resumed, rejection quoted verbatim → CLOSED.

**Ledger** (`status.md`):

| Step | Done | Evidence | By | Date |
|---|---|---|---|---|
| 4.5 Repairs | x | `04-interface/R4.4-report.md` | R4.4 | 06/03/2026 |
| 4.6 Variant search | x | 2 variants, static rule proposed | R4.4 | 06/03/2026 |
| 4.7 Verification | x | RESIDUAL 1xP2 → round 1 → CLOSED | verifier | 07/03/2026 |

**Record 041.** Choice: editors mounted and hidden. Rejected: `disabled`, absent from `FormData`; unmounting, loses uncontrolled fields.
