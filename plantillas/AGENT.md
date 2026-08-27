# <PROJECT NAME>

Source of truth for product direction, architecture, and quality bar. Detailed
feature decisions live in `specs/` — this file is the map, the specs are the
territory.

> **This file starts as questions, not answers.** Replace each question with the
> real answer as the project decides it. A section left as a question is honest;
> a section filled with a plausible guess is a lie an agent will act on.

## Product Vision

*What is this, and for whom? What problem does it solve, and who is the primary
audience? What is the current status — what is built, what is being built now?*

## Collaboration Style

*How should decisions be explained, and to whom? In which human language, at what
level of technical detail? (The human language of this project is declared in
`CLAUDE.md` — never assumed.) The goal: the person reading can approve, reject,
or adjust with confidence.*

## Product Principles

*The three to seven commitments this product will not trade away. Each one is a
sentence that can veto a feature. If a principle here could never reject
anything, it is decoration — delete it.*

## Technical Direction

*The stack, in words: languages, frameworks, storage, test runners, and the
decisions already locked (with a pointer to the spec that locked them). Also what
was rejected and why, so nobody re-opens it by accident.*

> This is one of the three places in this method where a technology may be named.
> The other two are `.claude/settings.json` and `.claude/skills/verify/`.
> Everywhere else, naming a technology is a bug.

## Application Architecture

*How the pieces fit: the main modules, what each owns, and which boundaries must
not be crossed. Where data lives, how it flows in and out. Enough that an agent
can place a new file without guessing.*

## Rules That Cost Us

**This section starts empty on purpose. That is correct — do not fill it with
best practices.**

A rule enters here when **something actually broke and it was expensive to find**.
Not a preference, not a lesson from another project, not a rule you read
somewhere. A rule without the scar that produced it is superstition, and it costs
every future agent the context to read it.

How to write one when the day comes:

- **The heading is the lesson, not the bug.** "A read-only lock is not the
  `contenteditable`" — not "fixed bug #47".
- Say what was measured, not what was assumed.
- Say what the wrong version looked like from outside, because that is how the
  next person will meet it again.
- Keep the trap that made it hard to find. That is the part worth the tokens.

## Verification Rules

**These arrive filled in.** They are not about any one product — they are about
working with agents, and they were paid for in another project.

1. **A massive red is almost never the code.** Measure the environment before
   reading the diff: ports, stale servers, reused state.
2. **A green can be a file nobody ran.** Check that the runner's output *names*
   the file. "No test files found" is a green that means nothing.
3. **A red is a claim, not a verdict.** Run the same command against the baseline
   and compare rates. One failure alone proves nothing.
4. **How long it took to fail names its cause.** Sub-second is an assertion;
   five seconds is a timeout. They lead to opposite investigations.
5. **"Pre-existing and unrelated" is not accepted without checking.** In the
   project this method came from, those failures were two real data-loss bugs.
6. **Plan defects are normal, and hollow tests are too.** The rule that catches
   them: *name the line where the test fails if you delete its control*.
7. **Look at the screen before calling it done.** Tests assert that elements
   exist, not that the composition works.
8. **The manual gate finds what the tests don't.** In one feature, two manual
   gates found 11 bugs — more than all the build tasks combined.

### The flow

**brainstorm → spec → plan → TDD → manual gate → merge.**

- **brainstorm** — intent and requirements, before any design.
- **spec** — a numbered file in `specs/`; see `specs/README.md`.
- **plan** — the slices and what "done" means for each.
- **TDD** — the test fails first, for the right reason, and names its file.
- **manual gate** — a person drives the real thing. Rule 8 is why.
- **merge** — only after the gate.

### Commit conventions

*Declare them here: message format, what one commit is allowed to contain, and
what must ride along in the same commit (see the trigger table in `CLAUDE.md`).*

## Quality Bar

*What must be true before a feature is called done: the app runs, risky logic has
tests, critical flows are driven end to end, docs updated, nothing unrelated
broke, data-loss risk considered. Name the high-risk areas of THIS project — the
ones that get extra care.*

## Where Detail Lives (topic → spec)

| Topic | Spec |
|---|---|
| | |

*One row per topic once specs exist. This table is how an agent finds the right
spec without reading all of them.*

## Agent-Controlled Development

*Agents drive development here. Keep the project easy for them to understand and
change safely: explicit architecture, small focused modules, clear feature
boundaries, no clever abstractions, decisions documented in specs, tests around
risky behavior.*
