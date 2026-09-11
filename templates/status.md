# Remediation status — <project>

Host language: <language> · Stack map: `docs/remediation/00-diagnosis/stack-map.md` · Started: <date>
Current phase: <N> · Open ask-first items: <n> · Parked rulings: <n> · Last re-diagnosis: <date or —> · Last drift check: <date or —>

Rules: a row without evidence is not done. Evidence = path, command with exit code, record number, verdict line. Phase N+1 does not start while phase N has an empty evidence cell (unless a ruling line in `defect-register.md` explains it).

## Phase 0 — diagnosis

| Step | Done | Evidence | By | Date |
|---|---|---|---|---|
| 0.1 Preconditions (git clean, DB read-only, MCP identity) | | | orchestrator | |
| 0.2 Dispatch D0–D5 | | | orchestrator | |
| 0.3 Synthesis, defect register, decisions README | | | orchestrator | |
| 0.4 Ordered plan confirmed by the user | | | orchestrator | |

## Phase <N> — <name>

| Step | Done | Evidence | By | Date |
|---|---|---|---|---|
| N.1 Briefs filled from the synthesis and lessons | | | orchestrator | |
| N.2 Dispatch (agents: …) | | | orchestrator | |
| N.3 Synthesis written | | | orchestrator | |
| N.4 Decisions: records <numbers> / ask-first batched | | | orchestrator | |
| N.5 Repairs (reports: …) | | | R… | |
| N.6 Variant search done for every closed defect | | | R… | |
| N.7 Verification verdict | | | verifier | |
| N.8 Report written, lessons line added, numbers re-measured | | | orchestrator | |

(Repeat the block for every phase in the confirmed plan, in plan order. Add phase-specific rows when the phase has them: e.g. Phase 4 stages A–B, Phase 5 canary per harness.)

## Re-diagnosis

| Step | Done | Evidence | By | Date |
|---|---|---|---|---|
| RD.1 Phase 0 rerun with the same commands | | | D0–D5 | |
| RD.2 `re-diagnosis.md`: measure before/after, defects RESOLVED/UNCHANGED/NEW | | | orchestrator | |
| RD.3 Reopened phases (if any) | | | orchestrator | |

## Maintenance

| Item | State | Evidence | Date |
|---|---|---|---|
| Guard set installed and wired into `verify` and CI | | | |
| Last change-time review | | | |
| Last drift check | | | |
