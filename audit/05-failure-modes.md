# 05 — Failure modes

## Summary

1. **The canary destroys work and reports success** (`briefs/verifier.md:24-30`, A7-09): repairs are uncommitted by rule, so `git show HEAD:<file>` captures the *pre-repair* code, the restore reverts the phase's repair, and `cmp` is silent — "restore verified: YES" over a repair that no longer exists. Run below.
2. **Parallel dispatch has no allocation step** (`procedure.md:16`, A7-22/23): "non-overlapping files" is promised, never computed or checked, and `R4.6`/`R4.8`/`R4.10` ship with overlapping lists dispatched "in parallel on distinct files" (`briefs/phase-4-interface.md:5`); the clobber is invisible to `git status --short`.
3. **Phase 7 never reads the defect register** (`procedure.md:39` vs `:152`, A7-16): "P1 blocks handover" exists only inside a directory legend, so a parked P1 ships with signed minutes that need not name it.
4. **Can the verifier be fooled cheaply: yes.** Cheapest false CLOSED costs **one line not written** (omit the new test from the repair report; `<list of test files>` is empty; no canary runs). Second cheapest costs **eight lines**: a test asserting a fixture declared inside itself passes gates, canary, `cmp`, diff and declarations with the product defect untouched — run below.
5. **Is the ledger unguarded: yes.** Nothing requires an evidence path to exist, a command's output to be quoted, or the verdict line to be copied verbatim; a literal resume opens 3 files against ~63 evidence cells in a seven-phase run.

---

## 1. Can the verifier be satisfied without the work being done?

The verifier is `model: sonnet` (`briefs/verifier.md:3`) and receives only the prompt block at `briefs/verifier.md:6-38`. It has no access to `briefs/`, to the repair agents' transcripts, or to the session. Everything it checks arrives through a `<…>` slot filled by the orchestrator, or through a report it is explicitly told not to trust. That asymmetry is the whole attack surface.

One step in the file *does* pin its inputs. Step 2: "RE-MEASURE the phase's numbers, with the **SAME commands as the diagnosis** (copied from `<remediation>/00-diagnosis/synthesis.md`)" (`briefs/verifier.md:20`). No other step names where its slot content must come from. The fix pattern for this whole section already exists in the file; it is applied once out of five opportunities.

### A7-01 · `briefs/verifier.md:3` + `:24` · P1 · the canary's input list comes from the report the verifier is told not to trust

Line 3: "The orchestrator trusts this report, **not the repair agents' report**." Line 24: "for **every new test declared by the repair agents** (`<list of test files>`)". The only source for that list is the repair agent's own 15-line report (`briefs/phase-1-gates.md:6`: "Final report, max 15 lines: files touched, before/after counts, canary outcome, …"). Step 6 ("every new test has the 'tested against' line") has the same single source.

Construction, cost **one line not written**: the repair agent writes a test, does not name it in its report. The orchestrator fills `<list of test files>` with what the report gave. Step 3 runs the canary on the tests that *were* named — or on nothing — and reports "canaries: n/a". Steps 1, 2, 4, 5, 6 are unaffected. Verdict CLOSED.

**Change:** `<list of test files>` is not taken from any report: derive it from `git status --short` plus `git diff --name-only`, filtered to the test glob in `<map>`; a test file present in the tree and absent from the list is a P1 residue.

### A7-02 · `briefs/verifier.md:24-27` · P1 · the canary never says which file to break

"deliberately break the invariant on ONE file with this protocol": the slot is `<list of test files>`, so the file the verifier is holding is the test. Nothing says "a non-test file", "a file the repair agent changed", or "the file under test".

Construction, cost **eight lines**. The phase's defect is a public action with no role guard. The repair agent ships a test that re-declares the invariant locally instead of importing the product's guard.

```
$ cat actions.js                               # the product, UNREPAIRED
export async function deleteRow(db, user, id){
  return db.delete(id);            // <-- P1: no role guard. UNREPAIRED.
}
$ cat actions.test.js                          # the repair agent's "test that was red once"
// tested against: fake
const guard = (user) => { if (user.role !== 'admin') throw new Error('forbidden'); };
test('deleteRow rejects a non-admin', () => {
  assert.throws(() => guard({role:'user'}), /forbidden/);
});
```

Verifier step 3 executed literally on that list:

```
git show $?=0
canary run: $? = 1  -> 'red on break? YES'
cmp $? = 0 -> 'restore verified: YES'
gate 'unit': $? = 0 -> green
### step 5 diff: ###            (empty: nothing outside the list)
### the product, after a CLOSED verdict: ###
export async function deleteRow(db, user, id){
  return db.delete(id);            // <-- P1: no role guard. UNREPAIRED.
}
```

Every step passes. Step 6's "tested against" line is present and literally honest. Step 0's DONE line ("a test that calls it for real without permission", `briefs/phase-5-tests.md:42`) is the only thing that could catch it, and it is a prose judgement by a sonnet agent reading a test file it did not write.

**Change:** the canary breaks a **non-test file** that the repair changed; if the test does not turn red when the product file is broken, the test does not cover the product — residue P1.

### A7-03 · `briefs/verifier.md:12-18` · P2 · step 1's `<command>` slots have no provenance rule

Six gates, six bare `<command>` slots. Step 2 pins its commands to `synthesis.md`; step 1 pins nothing. The `verify` script the gates run was itself written by `R1.1` (`briefs/phase-1-gates.md:16`), and from Phase 2 onward no step ever inspects it again. A `verify` weakened in Phase 1 — or an orchestrator pasting a narrower command than the stack map's — makes every later phase's gates green by construction.

**Change:** step 1's commands are copied verbatim from `stack-map.md`, quoted in the report next to each result; a command not found in the map is a residue, never a substitution.

### A7-04 · `briefs/verifier.md:10` vs `procedure.md:17` · P2 · "never tells the verifier what to ignore" is unenforceable by construction

Step 0 checks "every line of GOAL and DONE in the phase's repair briefs (`<paste the lines>`)". The verifier compares the paste against itself. An omitted GOAL line and a brief that never had that line are the same object from inside the verifier. `procedure.md:17`'s prohibition — "it **never tells the verifier what to ignore**" — has no mechanical residue.

**Change:** step 0 receives the brief ids and counts: "`R4.8`: 4 GOAL clauses, 3 DONE clauses"; a paste whose clause count disagrees with the header is a residue P1.

### A7-05 · `briefs/verifier.md:17-18` · P2 · conditional gates plus a "not found" map cell delete gates silently

"custom static rules with fixtures: `<command>`, **if any exist**" and "e2e: **ONLY if the phase touches them** … otherwise skip". The diagnosis header instructs agents to write "not found" when something is absent (`briefs/phase-0-diagnosis.md:9`). A `stack-map.md` with "not found" in the static-analysis row therefore removes a gate from every subsequent verification, and the verifier's report shows nothing — not a skip, not a residue.

**Change:** a gate whose command is "not found" is reported as **MISSING**, not skipped, and counts as a residue P2 until Phase 1 installs it.

### A7-06 · `briefs/verifier.md:14` · P2 · the unit gate reports skipped tests and has no criterion on them

"unit: `<command>`; report passed/failed/skipped". Lint gets a criterion ("zero Error is the criterion"); unit gets none. `node --test` on a skipped test whose body would fail:

```
﹣ guard rejects non-admin (0.5963ms) # SKIP
ℹ pass 0   ℹ fail 0   ℹ skipped 1
real $? = 0
```

**Change:** the unit gate's criterion is zero failed **and** zero newly skipped; a test skipped since the phase started is listed by name in the report.

### Cost ranking of the false-CLOSED constructions

| # | Construction | Cost to the repair agent | Steps that would catch it |
|---|---|---|---|
| 1 | Omit the new test from the 15-line report (A7-01) | one line not written | none |
| 2 | `test.skip` / `test.todo` on the new test (A7-06, A7-11) | one word | none as written |
| 3 | Test asserts a fixture declared in the test file (A7-02) | ~8 lines | step 0, as a prose judgement only |
| 4 | Stack-map cell reads "not found" (A7-05) | zero — inherited from Phase 0 | none |
| 5 | Orchestrator pastes a narrower `<command>` (A7-03) | zero | none |
| 6 | Orchestrator drops a GOAL clause from the paste (A7-04) | zero | none |

---

## 2. The canary protocol, walked and run

Protocol under test, `briefs/verifier.md:24-30`, mirrored at `areas/quality.md:56` ("A/B comparisons and counter-tests on **one file**: `git show HEAD:<file>` into a temp file, swap it in, run the targeted test, restore, `cmp`") and `briefs/phase-5-tests.md:13` ("list the invariants; for each one, the minimal break; run it and report the red; restore; `cmp`").

All experiments below were run in throwaway repos under the session scratchpad. Git 2.55.0.windows.3, node v24.19.0.

### A7-08 · `briefs/verifier.md:25` · P1 · (a) a brand-new file: the protocol empties it and reports success

Line 25: "`git show HEAD:<file>` into `<scratch>/<name>.orig` (**if the file is new, copy the current file**)". The parenthetical is the whole defence, and it is a parenthetical. Run without it:

```
--- file exists, untracked:
?? guard.test.js
=== VERIFIER STEP 3, line 25, executed literally on a NEW file ===
fatal: path 'guard.test.js' exists on disk, but not in 'HEAD'
exit=128
--- size of the .orig produced by the failed redirect:
0
=== 'restore the file' from that .orig ===
--- the new test file is now:
0
[content: ]
=== 'cmp <orig> <file> must be silent' ===
cmp exit=0 (0 = silent = 'restore verified')
```

The shell creates and truncates `.orig` **before** `git show` runs, so the failure leaves a 0-byte file. "restore the file" from it empties the new test. `cmp` compares empty to empty and is silent: the report reads "restore verified with cmp: YES". Every new test in the phase can be deleted this way, and the canary table says all is well.

Classification: **destroys work, passes silently.**

**Change:** step 3 line 1 becomes two lines — `git show HEAD:<file> > <scratch>/<name>.orig || cp <file> <scratch>/<name>.orig` — and a `.orig` of zero bytes for a non-empty file aborts the canary as a residue P1.

### A7-09 · `briefs/verifier.md:25,28` · P1 · (b) a file carrying the phase's repair: the protocol reverts it and `cmp` says YES

No agent may commit (`procedure.md:26`, `briefs/phase-1-gates.md:6`: "Do not commit"), so at verification time **every repair in the phase is an unstaged change**. `git show HEAD:<file>` therefore returns the code the phase exists to replace.

```
=== the repair agent applies the phase's repair (uncommitted, per the rule 'Do not commit') ===
 M service.js
=== VERIFIER STEP 3 executed literally ===
git show exit=0
--- what landed in the .orig (this is the PRE-repair code):
export function listRows(db, userId){
  return db.all('select * from rows');
}
--- apply the minimal break, run the test (omitted), then: 'restore the file' ---
=== 'cmp must be silent' ===
cmp exit=0 -> verifier reports: restore verified = YES
=== the actual state of the repair: ===
export function listRows(db, userId){
  return db.all('select * from rows');
}
?? scratch/
(clean tree: the phase's repair is GONE, no error anywhere)
```

The full-scan repair is gone. `cmp` is silent because it compares the pre-repair text against the pre-repair text. Step 5 (`git status --short`) now shows a *clean* tree — and step 5 only flags "files touched **outside** the phase's authorized list" (`briefs/verifier.md:34`), never files that should have been touched and are not.

Classification: **destroys work, passes silently, and the destruction makes two later steps look better.**

**Change:** the canary baseline is the **working-tree** file, never HEAD: `cp <file> <scratch>/<name>.orig` unconditionally; `git show` has no role here.

### A7-10 · `briefs/verifier.md:28` · P2 · (c) CRLF: `cmp` fails on a file nobody touched

`core.autocrlf=true` is set in the **system** gitconfig on this machine — the Git for Windows installer default. This repository neutralises it with `.gitattributes` (`* text=auto eol=lf`); a host project without one does not.

```
system: [true]    global: []    effective in this repo: [true]
--- worktree bytes:
0000000   l   i   n   e   1  \r  \n   l   i   n   e   2  \r  \n
--- blob bytes (what git show emits):
0000000   l   i   n   e   1  \n   l   i   n   e   2  \n
=== no change at all is made to the file. Now step 3 line 28: ===
scratch/f.js.orig f.js differ: byte 6, line 1
cmp exit=1  (non-zero = NOT silent = verifier reports 'restore verified: NO')
=== and the 'fix' a verifier would reach for, cp, corrupts the line endings: ===
0000000   l   i   n   e   1  \n   l   i   n   e   2  \n
 M f.js
```

Two harms. Every canary on a Windows host reports a false restore failure, which under `procedure.md:162` is a rejection and burns a round. And the obvious remedy, `cp`, rewrites the file to LF, leaving it permanently modified — one spurious diff per canary'd file, which step 5 then reads as real churn.

Classification: **fails loudly for the wrong reason, then corrupts on the remedy.**

**Change:** compare after normalisation — `git diff --quiet -- <file>` against the pre-canary state, or `cmp` on `git show`-normalised copies of both sides; never `cmp` a blob against a worktree file.

### A7-11 · `briefs/verifier.md:27` · P2 · (d)+(e) "it must be RED" is undefined

`test.todo` with a body that genuinely fails:

```
⚠ guard rejects non-admin (1.4773ms) # TODO
  AssertionError [ERR_ASSERTION]: 1 == 2
      ...
real $? = 0
```

A verifier reading the output records "red on break: YES". A verifier reading `$?` — which `briefs/verifier.md:12` mandates for step 1 and never mentions for step 3 — records NO. Either way that test exits 0 forever and guards nothing in `verify`.

And a break that makes the module unparseable scores identically to a break that violates the invariant:

```
###### (e) 'the minimal break: remove the guard' done by deleting the guard LINE ######
ℹ pass 0   ℹ fail 1
$? = 1 -> recorded 'red on break? YES'

###### (e2) the same 'minimal break' that lands a SYNTAX error ######
SyntaxError: Unexpected token 'return'
ℹ pass 0   ℹ fail 1
$? = 1 -> ALSO recorded 'red on break? YES'
```

A canary that passes on a syntax error proves the test file imports the product file. It does not prove the test asserts anything.

Classification: **passes silently for the wrong reason.**

**Change:** RED means `$?` non-zero **and** the failure names the invariant's assertion; a break that produces a load or parse error is not a canary — re-do the break inside the function body.

### A7-12 · `briefs/verifier.md:12-30` · P1 · nothing re-runs after the restore

The gates are step 1; the canary is step 3; steps 4-6 read the tree but run nothing. So every restore defect in A7-08, A7-09 and A7-10 lands *after* the last green signal and before the verdict. This is what converts a restore bug into a false CLOSED rather than a caught error.

**Change:** after the last canary, re-run the unit gate and `git diff --stat`; a tree whose diff shrank since step 1 aborts the verification as a residue P1.

### Minimal protocol change (replaces `briefs/verifier.md:25-30`)

```
- cp <file> <scratch>/<name>.orig            (the working tree, never HEAD: repairs are uncommitted)
- apply the minimal break INSIDE the function body; a parse error is not a canary
- run ONLY that test: RED = $? non-zero AND the assertion named in the output
- restore: cp <scratch>/<name>.orig <file>; then `git diff --stat` must equal its pre-canary value
- after the last canary, re-run the unit gate
- never `git stash`, never `git checkout --` on the whole tree
```

---

## 3. The evidence ledger is self-reported

### A7-13 · `modes/status.md:9-11,24-27` · P1 · nothing requires an evidence path to exist

The rule is about the evidence's **shape**, not its truth: "**Evidence** is a file path, a command with its exit code, a record number, a verifier verdict line, or an agent report path. Never 'done', never 'ok'." (`modes/status.md:9`). `templates/status.md:6` restates it identically. `docs/remediation/02-data/verification.md` satisfies that rule whether or not the file was ever created.

Mechanically, what stops an orchestrator writing that line for work never done: **nothing in the corpus**. There is no rule that the path be opened, no rule that a command's output be quoted, no rule that the verifier's verdict line be copied verbatim. The verifier writes its own report and replies with five lines (`briefs/verifier.md:38`); the orchestrator transcribes one of them into the ledger; no step compares the transcription to the file.

Resume, run literally (`modes/status.md:24-27`):

1. "Read `status.md`. Read `lessons.md`. Read the last phase report." — three files.
2. "Find the first row without evidence." — the walk stops at the first empty cell; every row above it is trusted by position.
4. "If the evidence looks stale (a file that no longer exists, a command that now fails), mark the row 'stale'" — "**looks** stale" is a judgement offered to an agent that has not opened the file, immediately after step 27's "**Never redo a step that has evidence**."

A seven-phase run has 8 rows per phase (`procedure.md:11`) plus 4 for Phase 0 and 3 for the re-diagnosis (`templates/status.md:12-15,36-38`): **63 evidence cells, 3 files opened**. A fabricated line placed in Phase 2 is load-bearing for the remaining five phases, the re-diagnosis and the handover.

The cheapest check is one line, and it runs from the repo root:

```
$ grep -oE '[A-Za-z0-9_./-]+\.md' docs/remediation/status.md | sort -u | \
    while read -r p; do [ -f "$p" ] || echo "MISSING EVIDENCE: $p"; done
MISSING EVIDENCE: docs/remediation/02-data/R2.2.md
MISSING EVIDENCE: docs/remediation/02-data/verification.md
```

**Change:** before any dispatch and on every resume, run the path check above; a missing path empties its cell and the step is not done. Add it as ledger rule 4 in `modes/status.md` § Rules.

### A7-14 · `modes/status.md:15` · P2 · the verdict line is transcribed, never copied

"verification → verdict line". `briefs/verifier.md:38` has the verifier write `<remediation>/<NN-phase>/verification.md` and reply with five lines. Two independent renderings of the verdict exist and nothing binds them.

**Change:** the verification cell carries the report path **and** the verdict line copied byte-for-byte from its last line; a mismatch is a residue P1.

### A7-15 · `procedure.md:158` · P2 · the re-diagnosis re-measures numbers, never ledger claims

"a table of measure | before | after | command" and "mark every defect in the register: **RESOLVED / UNCHANGED / NEW**". The register is checked against the code; the ledger is checked against nothing. The one moment in the procedure designed to catch drift between claim and reality never reads the file that holds the claims.

**Change:** `re-diagnosis.md` opens every evidence path in `status.md` and adds a row "evidence cells: `<n>` claimed, `<n>` resolved to an existing file"; any gap is a P1.

---

## 4. Four rounds, then a ruling

### A7-16 · `procedure.md:39` vs `procedure.md:152` · P1 · Phase 7 can complete with parked P1s, and nothing in Phase 7 reads the register

Severity is defined once, inside the artifact directory listing: "severity (**P1 blocks handover** · P2 must be fixed · P3 when touched)" (`procedure.md:39`). That is the only sentence in the corpus that binds a P1 to the handover, and it lives in a file-tree diagram.

Trace Phase 7's exit criteria. Entry: "Phases 1-6 closed; the re-diagnosis done" (`procedure.md:148`). Exit: "**No team credential survives; restore with counts; minutes accepted.**" (`procedure.md:152`). `briefs/phase-7-handover.md` never names `defect-register.md` — a grep for it across the corpus returns `phase-1-gates.md:35`, `phase-5-tests.md:51`, `decision-qa.md:52`, `diagnose.md:33`, `maintain.md:37`, `review.md:24`, `status.md:16`, `procedure.md:5,39,130,166`, `templates/status.md:6,14`. Phase 7 is absent from that list.

Worse, `modes/status.md:16` makes parking an explicit bypass of the ledger's only blocking rule: "Phase N+1 does not start while phase N has a row without evidence, **unless a ruling line in the defect register explains the parking**." So parked residue advances the procedure by design, and nothing downstream re-reads it.

### A7-17 · `procedure.md:158` · P2 · "parked" escapes the re-diagnosis reopen rule permanently

"a defect marked **closed** in the register and found again by the diagnosis is a P1". The rule keys on `closed`. A parked defect found again by the re-diagnosis is behaving exactly as recorded — it was never claimed fixed — so it produces no finding, no reopen, and no line in `re-diagnosis.md`. The one gate that could resurface it is the gate that exempts it.

### A7-18 · `briefs/phase-7-handover.md:38` · P2 · the minutes need not name a parked P1

R7.6's content: "what was delivered, what was verified and with which command, **remaining open questions with their record**, who owns what as of today." A parked P1 has a *ruling*, not an open question — `procedure.md:166` requires "a decision record marked 'decided, being applied' or 'pending'", and `decision-qa.md:52` reserves "open contradiction" for a different case. A P1 parked with "decided, being applied" is neither open nor a question, and the signed minutes can omit it without violating a single line of the brief.

**Should Phase 7 close with parked P1s?** Yes — but never silently, and never on the orchestrator's signature. Parking exists because `procedure.md:168` is right: "A declared residue is worth more than a forced green." The defect is that the declaration stops at the register.

**The rule to write** (`procedure.md` § Phase 7, Exit):

```
Exit. … ; every P1 with status `parked` listed in the minutes by id, with its Ruling
line verbatim and its cost-if-wrong, and the list signed by the client as a separate
item. A parked P1 absent from the minutes blocks the handover.
```

**The rule it must not be:** "no P1 may be parked at handover." That converts a P1 the client has priced and accepted into a hostage, and it pushes the orchestrator toward re-classifying a P1 as P2 in round 4 — which is the same forced green, one column to the left.

---

## 5. Cost blowup

Inputs: Phase 0 ≈ 1.4M billed tokens (usability pass); repair agent 150-300k; verifier 100-200k. Agent counts from `procedure.md:71,85,99,114,126,138,150`, with the "one agent per X" multipliers expanded at the low end of what `briefs/phase-0-diagnosis.md:32,34` produces (3 hot pages, 3-5 processes, 4 rigs). Worst case = every agent rejected four times (`procedure.md:164-165`: three resumes plus one fresh agent on a stronger model = 5 executions) and five verifier runs per phase; Phase 4 doubles its verifier because `briefs/phase-4-interface.md:5` puts one "Between stages".

| Phase | Agents (min → max) | Verifier runs (min → max) | Best | Worst |
|---|---|---|---|---|
| 0 diagnosis | 6 | 0 | 1.4M | 1.4M |
| 1 gates | 4 | 1 → 5 | 0.7M | 7.0M |
| 2 data | 7 | 1 → 5 | 1.15M | 11.5M |
| 3 performance | 8 → 10 (`R3.1` per hot path) | 1 → 5 | 1.3M | 16.0M |
| 4 interface | 10 (2 stages) | 2 → 10 | 1.7M | 17.0M |
| 5 tests | 8 → 15 (`R5.1` per rig, `R5.8` per process) | 1 → 5 | 1.3M | 23.5M |
| 6 documentation | 8 | 1 → 5 | 1.3M | 13.0M |
| 7 handover | 6 | 1 → 5 | 1.0M | 10.0M |
| re-diagnosis | 6 | 0 | 1.4M | 1.4M |
| **total** | **51 → 60** | **8 → 40** | **≈ 11.3M** | **≈ 100.8M** |

### A7-19 · `procedure.md:158,164-166`; `briefs/phase-5-tests.md:49` · P2 · three unbounded loops, no cap anywhere

Round-4's "fresh agent on a **more capable model**" multiplies price, not just tokens. Beyond that: the re-diagnosis "Every line that got worse, or stayed unchanged with no written reason, **reopens the corresponding phase**" (`procedure.md:158`) with no cap on reopenings and no rule that a reopened phase skip the re-diagnosis; and `R5.6`'s "keep going **until two rounds in a row find nothing new**" (`briefs/phase-5-tests.md:49`) runs four agents per round with no round limit and no budget. The worst case above assumes each loop runs once.

**Change:** cap it in `procedure.md` § Convergence: "A phase that reaches round 4 twice, or a re-diagnosis that reopens the same phase twice, stops and returns to the plan question. `R5.6` stops at four rounds or at the budget in the plan, whichever comes first."

### Abandonment

Assumption: a solo consultant on a subscription with a weekly allowance, running this against a client project. Phase 0 alone is 1.4M tokens and 20-45 minutes of wall clock before the first artifact. At that rate the best case is 3-6 hours of continuous dispatch spread across several sessions; the worst case is 30-50 hours and several allowance resets.

Abandonment becomes likely at **Phase 3 or Phase 4**, for three reasons that coincide: cumulative cost crosses ~5M (best case) there; the blocking user rounds have by then accumulated well past the "only mandatory user checkpoint" the skill promises (`SKILL.md:45`); and Phase 4 Stage B is the single largest dispatch in the procedure — ten agents in one message (`briefs/phase-4-interface.md:5`) — so it is the phase most likely to be abandoned *mid-dispatch* rather than at a boundary.

### A7-20 · `procedure.md:22-26`; `templates/status.md:1-46` · P1 · an abandoned run leaves an unrecoverable state that the ledger does not record

Where abandonment leaves the tree and the database:

- **The tree.** "Do not commit" (`briefs/phase-1-gates.md:6`); "**Never**: commit or push without explicit authorization" (`procedure.md:26`). After three phases that is up to 21 agents' worth of edits, unstaged, uncommitted, unattributed, in one working tree. Nothing in the corpus ever asks for the commit mandate; no ledger row records one.
- **The database.** "Asks first … any write to the real database (migrations, grants, policies)" (`procedure.md:24`). Once approved, `R2.2`, `R3.2` and `R3.6` apply migrations to the real database. Abandoning after that leaves the database *ahead* of an uncommitted tree: policies and grants exist that no committed code knows about, and `git checkout .` on that tree silently restores the mismatch.
- **The guards.** `R1.1` rewrites `package.json` scripts; `R1.2` adds a static-rule config; `modes/maintain.md:22` wires the set "into the `verify` script and the CI configuration". A run abandoned after Phase 1 leaves a zero-Error gate wired into CI for a codebase whose Phase 2-4 repairs never landed: every human commit afterwards is blocked by a gate installed for repairs that do not exist.
- **Phase 7.** `R7.2` creates a new database project with "environment variables set with **regenerated secrets**" and `R7.6` is the last step. Abandoning between them leaves two live environments, the new one holding secrets that exist only in the abandoned session's context, and "no team credential survives" unverified.

`status.md` records none of it. Its rows are the eight cycle steps (`templates/status.md:21-28`) plus a three-row Maintenance block (`:44-46`). There is no row for "migration applied to the real database", none for "guards wired into CI", none for "new environment created", and the header carries only a **count** — "Open ask-first items: `<n>`" (`templates/status.md:4`) — not a list of what was approved and executed. A cold session inheriting the tree cannot learn from the ledger that a grant migration is live.

### A7-21 · corpus-wide · P2 · the skill never says where it is safe to stop

Zero occurrences of a stopping rule. The only exit language is per-phase exit criteria.

**Change** (`procedure.md` § Autonomy contract, 3 lines):

```
Safe stopping points: only at a phase boundary whose exit row carries evidence, and
before any ask-first execution. Stopping elsewhere: say so, and write the two header
lines below. `status.md` header carries, from the first ask-first onward:
`Applied to the real database: <migration|grant> on <date>` (one line each, never removed)
and `Working tree: uncommitted repairs from phases <list>; guards wired into CI: <yes/no>`.
```

---

## 6. Parallel-agent hazards

### A7-22 · `procedure.md:16`; `templates/agent-brief.md:3,40` · P1 · there is no allocation step, no artifact, and no disjointness check

The promise: "Repair agents, one per area, **non-overlapping files** (parallel only across files that don't touch each other)" (`procedure.md:16`), echoed at `templates/agent-brief.md:3` ("Parallelize only across files that don't touch each other") and `:40` ("Work ONLY in: `<list of files>`. Do not touch anything else.").

How overlap is *actually* prevented: it is not. The file lists come from the `files:` line of each brief, whose `<list>` placeholders the orchestrator fills "with data from the diagnosis" (`procedure.md:13`). There is no step that computes a partition, no artifact that records one, and no check that two lists are disjoint. The ledger row that covers this moment is "N.1 Briefs filled from the synthesis and lessons" (`templates/status.md:21`) — its evidence is that the briefs were filled, not that they were disjoint. The only defence is a per-agent instruction to surrender: "if you need to touch others, **stop and say so in the report**" (`briefs/phase-1-gates.md:6`) — which fires only when an agent *notices*, and cannot fire at all when both agents legitimately own the file.

### A7-23 · `briefs/phase-4-interface.md:5,48,63,79` · P1 · Stage B ships overlapping lists as written

Stage B dispatches "`R4.2`–`R4.10` **in parallel on distinct files**" (line 5). Three of those nine briefs name the same population:

- `R4.6` files: "…, **the actions returning `{ok:true}` for different outcomes**, the Trash page" (line 48)
- `R4.8` files: "…, **the actions that return to the client**, a new static rule" (line 63)
- `R4.10` files: "outcome component …, **actions with a generic outcome (from D4)**, confirmations for irreversible actions, …" (line 79)

An action that returns `{ok:true}` for two different outcomes is, by definition, an action with a generic outcome that returns to the client. The three lists are the same files under three descriptions, and no placeholder-filling pass can separate them because the overlap is in the briefs' own GOAL clauses: `R4.6` wants "every outcome is a closed enumeration", `R4.10` wants "every action responds with the discriminated outcome **rendered in words**" — both rewrite the same `return` statement.

### A7-24 · `briefs/verifier.md:10,34` · P1 · the verifier cannot see a clobber, and re-verification is narrowed so it never re-checks the loser

Two agents, one action file, both holding the text they read before either wrote:

```
=== what the verifier sees at step 5 ===
 M actions/members.js
 actions/members.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

=== the file ===
  return { ok: true, message: `${r.n} imported, ${r.bad} discarded` };  // R4.10: worded outcome

=== R4.6's GOAL ('every outcome is a closed enumeration') in the tree: ===
0
```

`git status --short` shows one modified file — in *both* agents' authorized lists, so step 5's criterion ("files touched **outside** the phase's authorized list = a flag", `briefs/verifier.md:34`) produces nothing. `git diff --stat` shows a single-line change, indistinguishable from one agent working alone. R4.6's entire contribution is gone with zero signal.

The only step that catches it is step 0's per-GOAL check on R4.6 — which produces a rejection, which resumes R4.6 (`procedure.md:164`), which re-applies R4.6's version, which clobbers R4.10. And the re-verification is narrowed by design: "If this is a RE-VERIFICATION after a rejection: **look only at the fix's diff**; for every previous rejection, mark RESOLVED / NOT RESOLVED; **new breakage only within the diff**" (`briefs/verifier.md:10`). R4.10's GOAL lines were marked YES in round 0 and are never re-checked. When the two agents own different regions of the same file, the loss falls outside the fix's diff and is unreachable even in principle. Whichever agent writes last survives; whichever is checked last is believed.

**Change** (`procedure.md` § The cycle of a phase, step 1, 3 lines):

```
Before dispatch, write the allocation table into <remediation>/NN-<phase>/synthesis.md:
file | agent | shared?. A file in two lists forces sequencing, never parallelism; a
shared file gets one owner and the others' briefs say "stop and say so". The verifier
receives the table and flags any file whose diff crosses two owners.
```

---

## 7. Instruction-hierarchy conflicts

What the skill forbids, and where: commit or push without authorization (`procedure.md:26`; `briefs/phase-1-gates.md:6` "Do not commit"); `git stash` (`briefs/phase-1-gates.md:6` "Do not use `git stash`"; `briefs/verifier.md:29` "never `git stash`"; `procedure.md:26` "`git stash` **on a shared tree**"); telling the verifier what to ignore (`procedure.md:17,26`); running live integrations without approval (`procedure.md:24`); writing outside `docs/remediation/` and `docs/decisions/` (`procedure.md:22`, `modes/diagnose.md:62`).

### A7-25 · corpus-wide · P2 · there is no precedence rule, and the one sentence that looks like one is a special case

`CLAUDE.md` appears exactly once in the corpus, as reading material for the stack map: "READ: package.json …, the README, **any CLAUDE.md or docs/conventions**" (`briefs/phase-0-diagnosis.md:30`). It is an input to a table, not an authority. `settings.json` and `.claude/` appear nowhere except a clone command in `README.md:10`. Hooks are not mentioned in the corpus at all.

The sentence in eleven files — "these are defaults: **if the host project already has a docs language and folder convention, use it**" (`procedure.md:51`, `briefs/verifier.md:7`, `briefs/phase-0-diagnosis.md:22`, and eight more) — is a **special case, not a precedence rule**. It resolves exactly one axis (where documents go and in which language) and says nothing about the other six. Read as a precedence rule it would be worse than nothing: it would license "the host project has a convention, so the host wins", which is exactly the inference that breaks the commit and stash prohibitions.

### A7-26 · `procedure.md:20-26` · P2 · five conflict classes, one covered

| Class | Host requirement | Skill rule | What the corpus says |
|---|---|---|---|
| Commit cadence | "commit after every change" | `procedure.md:26`, `briefs/phase-1-gates.md:6` | **nothing.** Three area files prescribe commit content while no step obtains the mandate (integrity pass). A host with a commit-per-change convention and a skill that forbids committing deadlock on the first repair. |
| Build locally | "never run the build locally" (paid API, shared artifacts dir) | `briefs/phase-1-gates.md:17` "Run the real build"; `briefs/verifier.md:16` "real production build" | **nothing.** The build is the only gate that prerenders (`areas/quality.md:27`); skipping it silently removes the phase's strongest signal. |
| Docs location | "docs under `documentation/`" | `procedure.md:22,51` | **covered** — the one sentence, in eleven files. |
| Package manager | "always use `pnpm`" | `briefs/phase-1-gates.md:19` "`npm run verify` (or equivalent)" | **partially** — "(or equivalent)" plus the stack map, but nothing states the host's tooling wins; the map is descriptive, not binding. |
| `git stash` | "stash before switching branches" | absolute for agents and the verifier, conditional ("on a shared tree") for the orchestrator | **contradicts itself** (integrity pass). A host convention lands on the weaker of two rules in the same skill. |
| Write-on-save hooks / formatters | a format-on-save or lint-fix hook in `settings.json` | `briefs/verifier.md:34` flags "files touched outside the phase's authorized list" | **nothing.** A formatter touching neighbouring files produces a verifier flag, a rejection, and a burned round for work nobody did. |

**Change** (`procedure.md` § Autonomy contract, after the **Never** paragraph, 4 lines):

```
Host precedence. The host project's CLAUDE.md, settings and conventions win on
NAMES and PLACES (commands, package manager, folders, docs language, branch and
commit-message format); this contract wins on ACTIONS (commit mandate, git stash,
production, secrets, the verifier). A conflict on an action is a decision question,
never a silent choice: record it and ask in the phase's one question.
```

---

## 8. Measurement bias

### Inventory

Every numbered measure in `briefs/phase-0-diagnosis.md` D1-D5 (51 items; D0 produces a name table and is read-and-judge throughout), classified by its dominant mechanism.

| Brief | grep | count | query | read-and-judge | run |
|---|---|---|---|---|---|
| D1 quality gates (`:42-51`) | 0 | 4 | 0 | 4 | 1 |
| D2 data and security (`:59-71`) | 3 | 0 | 2 | 7 | 0 |
| D3 performance (`:79-89`) | 4 | 2 | 0 | 3 | 1 |
| D4 interface (`:97-109`) | 5 | 1 | 0 | 5 | 0 |
| D5 documentation (`:116-125`) | 2 | 1 | 0 | 6 | 0 |
| **total** | **14** | **8** | **2** | **25** | **2** |

**Ratio: 24/51 mechanical (47%) · 25/51 read-and-judge (49%) · 2/51 run (4%).** The areas' "What to measure" sections mirror this — `areas/interface.md` is 3 greps in 8 items, `areas/performance.md` 3 in 8, `areas/user-communication.md` 2 in 12.

### A7-28 · `briefs/phase-0-diagnosis.md:8` · P2 · zero measures exercise the running product, and the header makes it impossible

Of the two "run" items, D1.2 runs the *tooling* ("Run ONLY what doesn't write into the repo: typecheck and lint") and D3.10 is conditional ("**IF** the real database … is reachable read-only … Otherwise 'not measured'"). Neither starts the application. The common header closes the door: "Do not modify any project file and **do not run commands that write (no install, no build** that writes into the repo, no migrations, no push)" (`:8`). Without install there is no `node_modules`; without a build there is no app. So D4.11's "tab through a page (is focus visible?)" and "a real report (import, sync) read without the code" and D4.10's "what a user sees on returning with an expired session or lock" are, as written, unmeasurable by the agent asked to measure them — and the header's own instruction ("write 'not measured' — never zero") converts them into blanks rather than findings.

**Change:** mark the measures that need a running product in each D brief with `[needs a running app]`; Phase 0 reports them as **deferred to R5.6**, never as "not measured", and the plan says who provides the environment.

### Defect classes invisible to greps and counts

| Class | The measure that should see it | Why it does not |
|---|---|---|
| Guard present, checking the wrong object (right role, another user's row) | `R1.2` rule "every function exported from an actions file **textually contains** a role guard" (`briefs/phase-1-gates.md:25`); `R5.5` "a test that calls it for real **without permission**" (`briefs/phase-5-tests.md:42`) | Both are presence tests. "Without permission" is role-level; object-level authorization is named nowhere in the corpus. |
| Policy present but permissive (`using (true)`) | D2.3 `select * from pg_policies` (`briefs/phase-0-diagnosis.md:62`) | See A7-29. |
| Cache invalidated on the wrong tag | `modes/maintain.md:18` "Cache tags **cross-checked against invalidations in the same service file**" | A textual cross-check. `revalidateTag('rows')` next to a write that changed `rows:${id}` is textually consistent and semantically wrong. |
| Label present but wrong | `R4.9` "grep of fields without a label = 0" (`briefs/phase-4-interface.md:75`) | Counts absence. The glossary script hunts *synonyms*, not wrongness. |
| Test asserts on a mock | `R1.4` "tested against" header, enforced mechanically | Enforces the header's **presence**. Experiment f above shows the canary does not catch the rest. |
| Migration idempotent and wrong | D2.5 "idempotent (`if not exists`)?"; `R7.3` "table, function and policy **counts** equal to expected" (`briefs/phase-7-handover.md:23`) | Replay proves it runs twice; counts prove arity. Neither reads a definition. |
| Correct code, wrong business rule | see A7-31 | No oracle exists. |

### A7-29 · `briefs/phase-0-diagnosis.md:62`; `areas/data-security.md:4` · P1 · the policy measure counts policies and never reads their predicate

D2.3: "`select tablename, rowsecurity from pg_tables where schemaname='public'`; `select * from pg_policies`". `select *` does return `qual` and `with_check`, but the measure is framed as presence and the defect list confirms it: "sensitive function executable by public roles; **missing policies**; public secret; …" (`:72`). `areas/data-security.md:4` is the same: "**Policies**: … From the database, not from the repository." A table with `rowsecurity = true` and a single policy `for all using (true)` satisfies every word of the measure and every word of the defect list. This is the same shape as the `pg_proc.proacl` defect the integrity pass found — a query whose output makes the clean case and the broken case look alike.

**Change:** D2.3 reports, per policy, `tablename | cmd | roles | qual | with_check`, and flags every `qual` that is `true`, null, or contains no reference to a session function as a P1 candidate.

### A7-30 · `briefs/phase-5-tests.md:46-51` · P2 · R5.6 names the invisible classes and withholds everything needed to reach them

What the brief gives the hunters: three lenses ("user flows, data and concurrency, security"), a skeptic "whose job is to tear down every finding", a referee "who decides only after the reproduction has been **executed**", a stopping condition ("until two rounds in a row find nothing new"), two prohibitions ("do not fix anything during a hunt round; accept a finding by consensus"), and an output (`defect-register.md` with id, reproduction, status).

What it withholds:

- **A `files:` line.** `R5.6` is the only repair brief in Phase 5 without one — `R5.1`, `R5.2`, `R5.3`, `R5.4`, `R5.5`, `R5.7`, `R5.8` all carry `· files:`. So the one agent set expected to find what greps cannot has no scope at all.
- **A CONTEXT line.** Its CONTEXT is "use the `bugtcher` skill if available" — a tooling note. Every other brief in the phase opens with the diagnosis. This contradicts `templates/agent-brief.md:3`: "The diagnosis already done goes **inside** the brief; the agent does not re-derive it."
- **A running application.** "no finding without an **executed artifact**" is the brief's central demand, and Phase 5's entry is "Gates green; repairs from Phases 2-4 landed" (`procedure.md:124`) — landed in an uncommitted working tree, with no statement that the app runs.
- **Write access.** The autonomy contract permits "database reads (`select` only)" (`procedure.md:22`). The concurrency lens cannot reproduce a lost update or a double-submit without two writers; so its true findings arrive without an executed artifact, and the referee is obliged to reject them.
- **A second user and a second role.** Object-level authorization — the largest class in the table above — needs two sessions. Nothing in the corpus provisions a test account; `R7.2` creates accounts, and it is two phases later and ask-first.
- **A budget.** Unbounded rounds, four agents each (A7-19).

Verdict: it **gestures at them**. The brief's rigour is real — mandatory reproduction and a skeptic are exactly right — but rigour applied to an agent with no scope, no diagnosis, no app, no write access and no second identity produces a hunt over source text, which is the grep the section exists to escape.

**Change:** give `R5.6` what every other brief has — `files: <the surfaces from D0's process list>`, a CONTEXT carrying the defect queue's unresolved P2s, and a line stating the environment: "hunters run against `<url>` with `<two accounts, distinct roles>`; a lens with no environment reports **not measured**, never 'nothing found'."

### A7-31 · `briefs/phase-5-tests.md:28` · P2 · the acceptance checklist is generated from the thing it is meant to audit

"checklist as a **partition of the surface** (pages, routes, actions) with a `covers` field" and the checks fire when "a surface item is uncovered, an entry covers a nonexistent surface item, an entry describes a gesture that no longer exists". Every one of those compares the checklist to the code. A checklist derived from the code cannot disagree with the code, so the class "correct code, wrong business rule" has no detector anywhere in the corpus — not in D1-D5, not in the areas' target states, not in `R5.6` (which has no requirements to hunt against).

**Change:** `R5.3`'s checklist carries, per entry, the **rule it is meant to satisfy** in one line, sourced from the client's own material; `check-coverage` flags entries whose rule cell is empty.

### A7-32 · `modes/maintain.md:18` · P3 · the cache guard is a textual co-location check

"Cache tags cross-checked against invalidations in the same service file; no empty `catch {}` around an invalidation." Both halves are text searches. A tag invalidated in the right file with the wrong key passes.

**Change:** the guard compares the **tag expression** at the read site with the one at the write site, and a mismatch in the interpolated part is a failure, not a warning.

---

## Findings index

| id | file:line | sev | finding | change | effort |
|---|---|---|---|---|---|
| A7-01 | `briefs/verifier.md:3,24` | P1 | canary's test list comes from the report the verifier is told not to trust; omitting a test yields no canary | derive `<list of test files>` from `git status --short`/`git diff --name-only`, not from any report | S |
| A7-02 | `briefs/verifier.md:24-27` | P1 | canary does not say which file to break; a test asserting its own fixture passes every step | break a non-test file the repair changed; no red there = residue P1 | S |
| A7-03 | `briefs/verifier.md:12-18` | P2 | step 1's `<command>` slots have no provenance rule (step 2 has one) | commands copied verbatim from `stack-map.md`, quoted next to each result | S |
| A7-04 | `briefs/verifier.md:10` | P2 | `<paste the lines>`: an omitted GOAL line is undetectable; "never tell the verifier what to ignore" unenforceable | pass brief ids + clause counts; a mismatch is a residue P1 | S |
| A7-05 | `briefs/verifier.md:17-18` | P2 | conditional gates plus a "not found" map cell delete gates with no trace | a gate whose command is "not found" reports MISSING, not skipped | S |
| A7-06 | `briefs/verifier.md:14` | P2 | the unit gate reports skipped tests and has no criterion on them; `test.skip` exits 0 | criterion = zero failed and zero newly skipped; name each skip | S |
| A7-08 | `briefs/verifier.md:25` | P1 | new file: the redirect truncates `.orig` to 0, the restore empties the test, `cmp` is silent | `git show … || cp <file> …`; a 0-byte `.orig` aborts the canary | S |
| A7-09 | `briefs/verifier.md:25,28` | P1 | uncommitted repair: HEAD baseline reverts the phase's repair and `cmp` reports success | baseline is the working-tree file (`cp`), never HEAD | S |
| A7-10 | `briefs/verifier.md:28` | P2 | `core.autocrlf=true` (system default on Windows) makes `cmp` fail on an untouched file; the `cp` remedy rewrites line endings | compare normalised copies, or use `git diff --quiet -- <file>` | S |
| A7-11 | `briefs/verifier.md:27` | P2 | "RED" undefined: a parse error scores as red; `test.todo` is red in output and 0 in `$?` | RED = `$?` non-zero **and** the assertion named; parse error is not a canary | S |
| A7-12 | `briefs/verifier.md:12-30` | P1 | nothing re-runs after the restore, so every restore defect lands after the last green signal | re-run the unit gate and `git diff --stat` after the last canary | S |
| A7-13 | `modes/status.md:9-11,24-27` | P1 | no rule requires an evidence path to exist; resume opens 3 files of ~63 evidence cells | run the one-line path check before dispatch and on resume; a missing path empties the cell | S |
| A7-14 | `modes/status.md:15` | P2 | the verdict is transcribed by the orchestrator, never compared to `verification.md` | cell carries the path **and** the verdict line byte-for-byte | S |
| A7-15 | `procedure.md:158` | P2 | the re-diagnosis re-measures numbers and never checks ledger claims against files | `re-diagnosis.md` resolves every evidence path and reports the gap | S |
| A7-16 | `procedure.md:39,152` | P1 | Phase 7 exit never reads the register; "P1 blocks handover" lives only in a directory legend | Phase 7 exit lists every parked P1 by id with its Ruling verbatim; the client signs the list | M |
| A7-17 | `procedure.md:158` | P2 | the reopen rule keys on "closed", so "parked" escapes the re-diagnosis permanently | re-diagnosis marks parked defects RE-CONFIRMED with the date and re-prices the ruling | S |
| A7-18 | `briefs/phase-7-handover.md:38` | P2 | R7.6 minutes list "open questions"; a parked P1 is neither open nor a question | add "every parked P1 by id, ruling and cost-if-wrong" to R7.6's GOAL | S |
| A7-19 | `procedure.md:158,164-166`; `briefs/phase-5-tests.md:49` | P2 | three unbounded loops: rejection rounds, phase reopenings, hunt rounds | cap at two round-4s, two reopenings, four hunt rounds; then back to the plan question | S |
| A7-20 | `procedure.md:22-26`; `templates/status.md:1-46` | P1 | abandonment leaves uncommitted repairs, applied migrations and half-wired guards, none recorded in the ledger | header lines for applied DB writes, tree state and CI wiring, added at the first ask-first | M |
| A7-21 | corpus-wide | P2 | no safe-stopping rule anywhere | name the stopping points in § Autonomy contract (3 lines, §5 above) | S |
| A7-22 | `procedure.md:16`; `templates/agent-brief.md:3,40` | P1 | "non-overlapping files" has no allocation step, no artifact, no disjointness check | allocation table in `synthesis.md` before dispatch; a file in two lists forces sequencing | M |
| A7-23 | `briefs/phase-4-interface.md:5,48,63,79` | P1 | R4.6/R4.8/R4.10 own the same server-action files and are dispatched in parallel | name one owner for the action files in Stage B; the others' briefs say "stop and say so" | S |
| A7-24 | `briefs/verifier.md:10,34` | P1 | step 5 cannot see a clobber; re-verification's narrowing means the loser is never re-checked | verifier receives the allocation table and flags a diff crossing two owners | M |
| A7-25 | `briefs/phase-0-diagnosis.md:30`; `procedure.md:51` | P2 | no precedence rule; the docs-convention sentence is a special case, not a hierarchy | add the 4-line Host precedence paragraph to § Autonomy contract | S |
| A7-26 | `procedure.md:20-26` | P2 | six conflict classes, one covered, one self-contradictory (`git stash`) | same 4-line rule; make the `git stash` prohibition absolute for everyone | S |
| A7-28 | `briefs/phase-0-diagnosis.md:8` | P2 | 2/51 measures "run", 0/51 exercise the running product; the header forbids install and build | mark `[needs a running app]` measures; report them deferred, never "not measured" | M |
| A7-29 | `briefs/phase-0-diagnosis.md:62`; `areas/data-security.md:4` | P1 | the RLS measure counts policies and never reads `qual`; `using (true)` reads clean | report `tablename \| cmd \| roles \| qual \| with_check`; flag `qual = true`/null as P1 | S |
| A7-30 | `briefs/phase-5-tests.md:46-51` | P2 | R5.6 has no `files:`, no CONTEXT, no app, no write access, no second identity, no budget | give it scope, the defect queue, and a named environment with two accounts; no environment = "not measured" | M |
| A7-31 | `briefs/phase-5-tests.md:28` | P2 | the acceptance checklist is generated from the code and cannot disagree with it; no oracle for wrong business rules | each entry carries the rule it satisfies, from client material; empty rule cell fails `check-coverage` | M |
| A7-32 | `modes/maintain.md:18` | P3 | the cache guard is a textual co-location check; a consistent-but-wrong tag passes | compare the tag expression at read and write sites, interpolated part included | S |

30 findings — **P1 × 12** (A7-01, 02, 08, 09, 12, 13, 16, 20, 22, 23, 24, 29) · **P2 × 17** · **P3 × 1**.

## Files read

- `C:\Users\Utente\Desktop\harden-codebase-properly\SKILL.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\procedure.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\README.md` (line 10 only, for the `settings`/`.claude` grep)
- `C:\Users\Utente\Desktop\harden-codebase-properly\GLOSSARY.md` (Ruling entry)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\verifier.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-0-diagnosis.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-1-gates.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-2-data.md` (headers and R-list)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-3-performance.md` (headers and R-list)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-4-interface.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-5-tests.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-6-documentation.md` (headers and R-list)
- `C:\Users\Utente\Desktop\harden-codebase-properly\briefs\phase-7-handover.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\modes\status.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\modes\diagnose.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\modes\maintain.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\modes\review.md` (line 24)
- `C:\Users\Utente\Desktop\harden-codebase-properly\modes\decision-qa.md` (lines 18, 52)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\quality.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\data-security.md` (§ What to measure)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\performance.md` (§ What to measure)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\interface.md` (§ What to measure)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\user-communication.md` (§ What to measure)
- `C:\Users\Utente\Desktop\harden-codebase-properly\areas\method-documentation.md` (§ What to measure)
- `C:\Users\Utente\Desktop\harden-codebase-properly\templates\status.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\templates\agent-brief.md`
- `C:\Users\Utente\Desktop\harden-codebase-properly\.gitattributes`

Experiments run in `…\scratchpad\exp-a` … `exp-h` (throwaway git repos; no corpus file was modified).

## Sources fetched

None. Every claim is either quoted from the corpus with a line reference or produced by a command whose output is shown above. Tool versions used for the experiments: `git version 2.55.0.windows.3`, `node v24.19.0`; `core.autocrlf` read from the system gitconfig (`true`).
