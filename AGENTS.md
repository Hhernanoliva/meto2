# meto2

Source of truth for how this project is built. Detailed decisions live in
`specs/` — this file is the map, the specs are the territory.

**Every agent working here reads this file first, whichever tool it runs in.**
Tool-specific plumbing lives in `CLAUDE.md`; the method is here.

## Read This First

- **Read this whole file before any work.** Never contradict it.
- Then read `specs/001-el-paquete.md`. It is the only spec and it decides
  everything: what travels and what does not, the two install stages, the
  templates file by file, the 6-step manual gate, and decisions A–E.
- **Commit as you go, not all at once at the end.**

## This Project Outranks Global Rules

A global instructions file applies to **every** project on this machine,
including the ones it was never written for. Here, concretely: a global file
carrying rules for a web stack — a framework, a package manager, a UI flow —
**does not apply.** This project is shell, markdown and two Python programs, and
its core is technology-agnostic **on purpose**.

Still valid from any global file: explain in plain language to someone who is
not an engineer, and get the plan approved before writing code.

## Human Language

**Castellano** for anything a person reads: `README.md`, the specs, this
project's own conversation. **English** for anything the package hands to other
projects: the templates in `plantillas/`, the commands in `comandos/`.

Not a contradiction — two different readers. Premise 4 of the spec.

## Product Vision

A working method, packaged so that starting a new project with all of it costs
**one command**, and so the method travels to another machine and another person
without dragging along the project it was extracted from.

Not a plugin, not a repo to clone. A folder with git, three commands symlinked
into the agent's command directory, and a set of empty boxes with the rules for
how they get filled.

**Status:** built and tested; the 6-step gate passes and a person ran the manual
gate on a real project. Not published yet. Publishing is what `specs/001` calls
the open decision.

## Collaboration Style

The reader is not an engineer. Every explanation in plain Spanish: no
untranslated jargon, analogies over internals, and what will actually happen
before how it works inside. Lead with the outcome, not with test counts.

Plan first, in simple language, then approval, then code.

## Product Principles

- **Form travels, content does not.** That a "rules that cost us" section exists
  travels; the rules of any one project do not. This is the whole design and its
  violation is failure mode number one.
- **The core names no technology.** Exactly three seams may: the tool settings
  file, `AGENTS.md` › Technical Direction, and the verify skill. There is a
  mechanical test for this and it runs in the gate.
- **Nothing is claimed without running it.** Decisions in the spec marked
  *medido* were measured; everything else is an opinion and says so.
- **A written rule does not prevent anything; a noisy check does.** Where a rule
  could be forgotten, there is a check that fails loudly instead.
- **Empty boxes with their question inside beat plausible answers.** A blank
  section is honest; an invented one is a lie the next agent acts on.

## Technical Direction

`bash` (POSIX-ish, must also survive `zsh`), markdown, and Python 3 with the
standard library only. **No dependencies, no package manager, no build step.**

- Commands are markdown files symlinked into the agent's command folder, so
  editing the repo takes effect everywhere immediately.
- The two Python programs (`memoria/generar-indice.py`,
  `memoria/agregar-hook.py`) run with `python3` and import nothing outside the
  standard library. Keep it that way: this package installs onto machines whose
  Python situation is unknown.
- Anything that shells out must be tested under **`zsh` as well as `bash`** —
  see *Rules That Cost Us*.

Rejected: making this a plugin (ceremony with no audience) and making it a repo
to clone (collides when the project starts from a generator).

## Application Architecture

```
instalar.sh     stage 1, once per machine: symlinks, plugins, the MCP binary
comandos/       the three commands: arrancar, cerrar, simple
plantillas/     the empty boxes /arrancar copies into a project
memoria/        the index generator, the hook adder, and their test
specs/          the decisions (castellano)
```

Two boundaries that must not be crossed:

1. **`plantillas/` and `comandos/` may not name a technology.** Enforced by the
   grep in the verify skill.
2. **The generators live here in one copy** and receive the target folder as an
   argument. Copying them into each project would mean a fix never reaches the
   old ones.

## Rules That Cost Us

Three, all earned on 2026-08-27, all found by a person running things rather
than by a test.

### `zsh` is not `bash`, and the test environment that is not the user's produces greens that mean nothing

`ls specs/[0-9][0-9][0-9]-*.md 2>/dev/null` works in bash and **fails in zsh**:
a pattern with no matches is a *shell* error, raised before the redirection can
suppress it. Every test had been run in bash; the user's shell is zsh. The user
saw an error message the author never could.

The trap: the command is correct, the redirection is correct, and the failure
depends only on which shell reads it. Use `find` for patterns that may not match.

This is meta-rule 1 — *measure the environment* — aimed at whoever is testing,
not at whoever is failing.

### A pointer that lies is invisible to every check

Three templates said the rules lived in `CLAUDE.md` after they moved to
`AGENTS.md`. Files were created perfectly, the agnostic grep passed, the tests
passed. What was wrong was a sentence, and the agent repeated it faithfully to
the user.

Nothing automatic can see this: the grep looks for technologies, not for broken
references. Now the signs name the exact section, so a future rename breaks
visibly instead of lying quietly.

### An exit code of 0 is a claim, not a result

`claude plugin install` **exits 0 when it fails** — it prints the error and
returns success. The installer believed it and would have reported a plugin as
installed for months. Meanwhile the marketplace had renamed the plugin, which is
exactly the kind of drift a lying exit code hides.

The check that works asks afterwards whether the thing is actually there.
Generalized: **never trust a status code from a program you did not write; ask
the system for the state you wanted.**

## Verification Rules

1. **A massive red is almost never the code.** Measure the environment before
   reading the diff: ports, stale servers, reused state.
2. **A green can be a file nobody ran.** Check that the runner's output *names*
   the file.
3. **A red is a claim, not a verdict.** Run the same command against the baseline
   and compare rates.
4. **How long it took to fail names its cause.** Sub-second is an assertion;
   five seconds is a timeout.
5. **"Pre-existing and unrelated" is not accepted without checking.**
6. **Plan defects are normal, and hollow tests are too.** The rule that catches
   them: *name the line where the test fails if you delete its control*. Applied
   to this repo's own test on 2026-08-27, and it held.
7. **Look at the screen before calling it done.**
8. **The manual gate finds what the tests don't.** Measured here: 6 automated
   steps passed while 3 real defects sat in the package, all three found by a
   person running the commands and reading the output.

### The flow

**brainstorm → spec → plan → TDD → manual gate → merge.**

### Commit conventions

Conventional Commits, subject in castellano, body explaining *why* and what was
measured. One commit per coherent change; commit as you go.

## The Specs Rule

Every meaningful decision gets a numbered spec in `specs/`. **Active:** there is
one, `001-el-paquete.md`, and it governs everything.

## The User Guide Rule

**For this project the user guide is `README.md`, not `docs/guia/`.** Declared
deliberately: the package is one installer and three commands, so a folder of
topic files would be more structure than content — the exact drowning the spec
warns about under *Riesgos › Escala*.

The rule itself stands: every user-visible change is documented **in the same
commit that implements it**. Only its location differs, and that difference is
written down rather than pretended away.

## The Changelog Rule

`CHANGELOG.md` at the root. **Active since 0.1.0.** Every user-visible change
adds its bullet to the version in progress, in the same commit, in castellano,
no jargon.

## Quality Bar

Nothing is done until the **6-step manual gate in `specs/001`** passes, plus:

- `python3 memoria/prueba.py` exits 0.
- The agnostic grep gives **zero**.
- Anything that shells out was run under `zsh`, not only `bash`.
- The templates were checked by generating a project and reading the result, not
  by reading the templates.

High-risk areas, in order: the templates (a wrong word ships to every future
project), `instalar.sh` (it touches a machine's global configuration), and
`memoria/agregar-hook.py` (it writes into someone else's settings file).

## Where Detail Lives

Detail lives in `specs/`. The topic → spec table is in `specs/README.md`, and
that is the only place it exists.

## Agent-Controlled Development

Agents drive development here. Keep it explicit and small: no clever
abstractions, no dependency added for what a few lines can do, and every
non-trivial behavior leaves behind one runnable check.
