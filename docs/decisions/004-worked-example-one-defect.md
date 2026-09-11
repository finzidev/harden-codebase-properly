# 004. One worked example ships, on the skill's own canonical defect

**When:** 2026-09-11 (backlog row U-10)
**Status:** in force

## The problem
The chain measure → report line → synthesis → brief → repair report → verifier verdict → ledger row → decision record is the whole method, and it is specified in five files that never show it joined. The cold-start traces assembled it wrong in three places (report filenames, the missing common header, the timing of the go-ahead). One malformed brief costs a repair round plus a verifier round, an estimated 30–60k tokens.

## The choice
`examples/one-defect.md`, 335 words, the `disabled`-editor defect already used as the canonical case in `SKILL.md`, `areas/interface.md`, `GLOSSARY.md` and `templates/decision-record.md`. Named in the `run <N>` load cell and in `modes/diagnose.md` § Synthesis. Cost per `run` load: about 1.6 %.

## Why and what we rejected
*No example; the templates are enough.* The traces say otherwise, and the cost of the example is one order of magnitude below the cost of the round it prevents.

*A longer example with two defects, or one per phase.* Every added line is paid on every run; one defect shows the shape, and every other defect has the same shape.

*A new defect for the example.* Introduces a concept the corpus does not otherwise define; the `disabled` case is already explained in four files.

## Where it lives in the code
`examples/one-defect.md`; `SKILL.md` § Modes; `modes/diagnose.md`.

## What would change our mind
A run in which the example's shape is copied literally where it does not fit (a Phase 2 migration is not a Phase 4 editor). Then the example gains one line saying what varies by phase, or moves out of the `run` load list into `diagnose` only.
