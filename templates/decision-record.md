# The decision register

It answers exactly one question: **why did we do it this way?** It is not a list of features, not a plan. A decision counts as one only if someone, someday, could reasonably do the opposite: only reversible choices that carry a cost. A document without the rejected alternatives describes; it does not decide.

## Folder structure

`docs/decisions/README.md` (how to read it, the statuses, the table of open questions) plus one file per decision: `NNN-descriptive-title.md`.

**Numbering.** The first free number, found by **listing the whole folder** (`ls docs/decisions/[0-9]*.md 2>/dev/null`), never `ls | tail -1`: two parallel sessions produce two records with the same number.

## The parts of a record: the title line, `When`, `Status`, and five sections

```markdown
# NNN. <Descriptive title: one sentence stating the choice, not the topic>

**When:** <date taken from the commit, the migration, or the client's note, never from memory>
**Status:** in force | superseded by NNN | awaiting client answer | open contradiction | decided, being applied | diagnosis closed

## The problem
<the concrete fact that forced the choice: numbers, dates, symptom>

## The choice
<what is done, in a form verifiable in the code>

## Why and what we rejected
<the real alternatives that were on the table, one per paragraph, and why they lost>

## Where it lives in the code
<file, migration, test that guards it>

## What would change our mind
<the concrete condition that would reopen the discussion>
```

`diagnosis closed` is for a defect that is understood and proven, whose repair is a separate matter, dated on its own.

## Records worth writing on purpose

- **Ones someone will bring up again** (a feature outside the quote, an automation the client doesn't want, who makes the commit): they exist so the answer is already ready.
- **Rejected mistakes** (a configuration taken from the latest version's docs and applied to an older one): the line discarded today may become necessary again after an upgrade, and the record says which half to keep.
- **Non-decisions** (two analyses without a choice; a documentation layout still to be clarified): they live there because it is the one place they won't get lost.
- **Code-structure choices** (one file per invariant, the re-export barrel as debt): no user notices, but the next person who opens the file does.

## The table of open questions

In `README.md`, **two tables**, never merged:

| record | the question, briefly | open since |
|---|---|---|

1. *For the client*: opened before a meeting and walked through line by line. Every row carries the exact question; `blocking` where it blocks.
2. *Internal*: wait on whoever is driving the project, not the client. Never brought to a client meeting.

**Organizational** questions (accounts, domain, card, keys) live elsewhere (`docs/client/open-questions.md`), not here.

If the same question also lives in a task register, declare which of the two wins (by default: wherever it originated).

## Condensed example

> **NNN. The entity page opens into tabs, and editors stay mounted**
> **When:** DD/MM/YYYY (commit). **Status:** in force.
> **Problem.** A single page paid nine reads to open; a form always open on an already-published entity is the condition for an unintended edit.
> **Choice.** Routes with their own reads; read-only by default, `?edit=1` with `replaceState`; editors stay mounted and hidden.
> **Rejected.** `disabled` on fields: a disabled field is left out of `FormData`, and whoever saves reads "absent" as "cleared". Unmounting the editors: loses uncontrolled fields.
> **Where it lives.** The edit-mode hook; the test on the real `FormData`.
> **What would change our mind.** The framework serializing disabled fields, or the editors no longer having uncontrolled fields.
