# <PROJECT NAME> — Instructions for Claude Code

- **Read `AGENT.md` before any work.** It is the source of truth for product
  direction, architecture, and quality bar. Never contradict it.
- Before implementing a meaningful feature, read the relevant spec in `specs/`
  (index in `specs/README.md`).
- **Commit as you go, not all at once at the end.**

## This File Outranks Your Global Rules

A global `~/.claude/CLAUDE.md` applies to **every** project on this machine,
including the ones it was never written for. If it names a stack, a package
manager, a UI flow or a testing convention, **none of that applies here unless
`AGENT.md` › Technical Direction says it does.**

Write the exception down here the first time it bites — one line naming what does
not apply and why. A rule inherited from a project this is not costs an agent a
wrong assumption in every session, and nothing in the code will ever contradict
it: it fails silently, as a suggestion that sounds informed.

## Human Language

The human language of this project is: **<DECLARE IT HERE>**.

Everything a person reads — `docs/guia/`, `CHANGELOG.md`, the conversation — is
written in that language. Everything a machine reads — `AGENT.md`, this file,
specs, skills, commands — is written in English.

This is a setting, not a guess. Fill it in before the first commit.

## Specs Rule

Every meaningful feature gets a numbered spec in `specs/` before it is built.
Sections: Objective / What enters / What does not / Data / Flows / Acceptance /
Tests / Agent notes.

**Trigger:** the first feature that needs decisions made *before* code. Until
then, `specs/` is empty on purpose and `specs/README.md` says so.

## User Guide Rule

The user-facing guide, in this project's human language, lives in `docs/guia/`
(one file per topic; index at `docs/guia-de-uso.md`). Every user-visible feature
or behavior change is documented **in the same commit that implements it** — edit
the topic file it touches, or create a new one and add it to the index. Update
the index's **Última actualización / Last updated** line too.

Specs describe intent for builders; the guide describes usage for people. No
technical jargon.

**Trigger:** there is a user who is not you. Until then this rule is written down
and not yet active, and `docs/guia-de-uso.md` says so.

## Changelog Rule

`CHANGELOG.md` at the root is what a person reads to find out what changed. Every
user-visible change adds its bullet to the section of the version in progress
**in the same commit that implements it**. In the project's human language, one
bullet per change, no jargon.

Writing it at release time does not work: by then the change is a diff nobody can
translate back into a sentence, and whatever build step reads this file has
already run.

**Trigger:** there is a first distributable version. Until then, `CHANGELOG.md`
says so.

## Memory

This project's memory lives in `__MEMORY_DIR__`.

One fact per file, with a header. Four fields under `metadata:` — `type`,
`titulo`, `estado`, `verificado` — and the `description:` line is the **only
routing line**: it answers "do I open this file or not?", nothing else.

`MEMORY.md` and `ARCHIVO.md` are **generated, never hand-edited**. After creating
or changing a memory:

```bash
python3 __GENERATOR__ __MEMORY_DIR__
```

It exits **1** and names the file when a field is missing. A memory with no
`estado` falls back to `vigente` — it stays in the index rather than vanishing.

## Verification Skill

`.claude/skills/verify/SKILL.md` says how to launch, build, and drive this app
end to end. Keep it true. Every hour it saves is an agent not re-discovering how
to run the project.

## Tooling

`.claude/settings.json` starts with `enabledPlugins: {}` — an empty list on
purpose. **This project decides which tools are noise.** A plugin left on that
this project never uses costs context in every single session. Turn one off by
adding `"plugin@source": false`; turn one on the same way with `true`.

`.mcp.json` is versioned. It names `codebase-memory-mcp` by name, not by path, so
it works on any machine where the installer ran. The one project-specific line is
`CBM_ALLOWED_ROOT`, which must point at this folder.
