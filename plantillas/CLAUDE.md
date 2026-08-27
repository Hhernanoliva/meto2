@AGENTS.md

# Claude Code plumbing for <PROJECT NAME>

`AGENTS.md`, imported above, is the method and the source of truth. This file
holds only what is specific to Claude Code. If the two ever disagree, `AGENTS.md`
wins and this file is the one that is wrong.

## Verification Skill

`.claude/skills/verify/SKILL.md` says how to launch, build, and drive this app
end to end. Keep it true. Every hour it saves is an agent not re-discovering how
to run the project.

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

## Tooling

`.claude/settings.json` lists which plugins this project turns off. **This project
decides which tools are noise.** A plugin left on that this project never uses
costs context in every single session, silently. An explicit `false` means this
project decided; an absent entry means nobody did.

`.mcp.json` is versioned. It names `codebase-memory-mcp` by name, not by path, so
it works on any machine where the installer ran. The one project-specific line is
`CBM_ALLOWED_ROOT`, which must point at this folder.
