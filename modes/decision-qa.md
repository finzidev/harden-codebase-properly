# Decision Q&A: how the orchestrator asks, and when it must not

Two failure modes, both real: deciding in silence (a choice nobody wrote down, later contradicted), and interrogating (open-ended questions that block work). The protocol below sits between them: **few questions, multiple-choice, batched, each one with a recommendation and a written consequence.**

## Notes: reformulation before any work

When the user brings notes, goals or a backlog (even a single note), before dispatching anything:

1. **Reformulate.** Rewrite every note in your own words, grouped by area. This proves understanding: if a note was misread, the user sees it here.
2. **Merge.** Merge only notes that share a file or a flow. Notes that look close but have different root causes stay separate: merging them is how an agent gets stuck.
3. **Order.** What unblocks first, then the independent, last what waits for a decision.
4. **Distribute.** One agent per area, closed task, done criterion, explicit `model`.
5. **Ask now.** Every ambiguity becomes one multiple-choice question, in this same message, not after the agents are running.
6. **Confirm.** Wait for the user's confirmation of the reformulation and the questions. Then dispatch.

## Decisions: when a question is due

A decision record is due for every **reversible choice with a cost**: someone could reasonably do the opposite tomorrow. Sources: the diagnosis (proposals), a repair report ("decisions to record"), a verifier residue, a documented refusal, a conflict with an existing record.

Not due, and must not become a question:
- choices already covered by an existing decision record (respect it; if the repair contradicts it, that contradiction is the question);
- mechanical repairs inside the autonomy contract (a lint override, a test declaration, a skeleton);
- anything the target state prescribes (the target state is the mandate; the question was already answered by adopting this skill).

## The question format

One `AskUserQuestion` per phase, batched, each item in this shape:

```
<Title of the choice, as a verb phrase>
Problem: <the concrete fact that forces a choice, with the number and the date>
Options:
  A. <what> — cost <S/M/L> — risk <what it breaks or what it would take to reverse>
  B. <what> — cost — risk
  C. <what> — cost — risk           (2 to 4 options; "do nothing" is an option when it is honest)
Recommendation: <letter> — <why in one line>
If we do not decide: <what happens, and which step waits>
Belongs to: user | client
```

Rules:
- The recommended option is listed first and marked "(Recommended)".
- Options are exclusive; if two can coexist, they are one option.
- A question that only has one honest option is not a question: decide, record, move on.
- Never more than one question round per phase, unless a P1 blocks the phase midway.
- Never re-ask a question that has a record; link the record instead.

## What happens with the answer

- **User answered**: write the decision record (`templates/decision-record.md`), status "in force", with the rejected options and why they lost. Tick the step in `status.md` with the record number.
- **Belongs to the client**: write the record with status "awaiting client answer", add the exact question to the client table in `docs/decisions/README.md`, and continue with the recommended option **only if** it is reversible at low cost and the user says so; otherwise the dependent step waits, and `status.md` says which.
- **User declines to decide**: the record gets status "open contradiction" or "decided, being applied" as appropriate, with a ruling line in the defect register; the step is parked, not silently dropped.

## Plan question (Phase 0 checkpoint)

The one question that closes the diagnosis:

```
Ordered plan for <project> (N steps, first step = <…>)
Options:
  A. Run the plan as ordered (Recommended) — <why: the multipliers, with numbers>
  B. Same plan, but start from step <k> — <when that makes sense>
  C. Drop phases <list> because the measures say they are done — <evidence>
  D. Pause: I have notes to add first
Ask-first items already visible: <list, each with the phase where it will be asked>
Decision questions of the first step: <list, in the question format above>
```

## Client questions

Product questions the client must answer live in the client table of `docs/decisions/README.md`, one row per question, with the record that instructs it and what it blocks. Organizational questions (accounts, domains, cards, keys) live in `docs/client/open-questions.md`. Internal questions (waiting for whoever leads the project) are a separate table and are never taken to a client meeting. All written in the host project's language.
