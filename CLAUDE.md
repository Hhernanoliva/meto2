@AGENTS.md

# Claude Code plumbing for meto2

`AGENTS.md`, imported above, is the method and the source of truth. This file
holds only what is specific to Claude Code. If the two disagree, `AGENTS.md`
wins and this file is the one that is wrong.

## Verification Skill

`.claude/skills/verify/SKILL.md` says how to check this package end to end: the
tests, the agnostic grep, and the 6-step manual gate. Run it before calling
anything done.

## Memory

This project's memory lives in
`~/.claude/projects/-Users-hernanoliva-Projects-meto2/memory`.

One fact per file, with a header. Four fields under `metadata:` — `type`,
`titulo`, `estado`, `verificado` — and `description:` is the **only routing
line**. `MEMORY.md` and `ARCHIVO.md` are **generated, never hand-edited**:

```bash
python3 memoria/generar-indice.py ~/.claude/projects/-Users-hernanoliva-Projects-meto2/memory
```

It exits 1 and names the file when a field is missing. Missing `estado` falls
back to `vigente` — the memory stays in the index rather than vanishing.

## Tooling

`.claude/settings.json` does two things. Its `hooks` block re-injects one line
before every message: *re-read Collaboration Style and Human Language in
`AGENTS.md`*. It **points, it never copies**, so it cannot go stale. Its
`enabledPlugins` block turns off what this project does not use — an explicit
`false` means this project decided; an absent entry means nobody did.

`.mcp.json` names `codebase-memory-mcp` by name, not by path. Its one
project-specific line is `CBM_ALLOWED_ROOT`, which must point at this folder.
