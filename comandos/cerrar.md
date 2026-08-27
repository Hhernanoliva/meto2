---
description: End-of-session check — what the method already asks for, and what it does not ask for YET.
allowed-tools: Bash, Read
---

# /cerrar — check and tell, never write

Optional argument: a git range or start point (`/cerrar HEAD~5`, `/cerrar main`).
Without it, the range is **today's commits plus whatever is uncommitted**.

**This command never writes anything on its own.** Not a memory, not a guide
entry, not a changelog bullet. It checks, it reports, and it offers. A closing
ritual that writes produces exactly the thing it is meant to prevent: entries
written at the moment of least remaining context, which then read as true and are
not.

It also **detects, it does not read configuration**. Does `docs/guia/` exist? Does
`CHANGELOG.md`? A project set up today works with it, and so does a project from
before this method existed.

## Step 1 — run this, exactly as it is

```bash
set -u
PROJ="$PWD"
DESDE="${1:-}"
if [ -n "$DESDE" ]; then RANGO="$DESDE..HEAD"; ETIQ="$RANGO"; else RANGO=""; ETIQ="hoy (--since=midnight)"; fi
git rev-parse --git-dir >/dev/null 2>&1 && HAYGIT=1 || HAYGIT=0
gl() { if [ -n "$RANGO" ]; then git log "$RANGO" "$@"; else git log --since=midnight "$@"; fi; }
cuenta() { if [ "$HAYGIT" = 1 ]; then gl --oneline -- "$1" | wc -l | tr -d " "; else echo "-"; fi; }

echo "=== /cerrar — $PROJ"
echo "rango: $ETIQ"
echo
echo "--- QUÉ EXISTE EN ESTE PROYECTO (detectado, no configurado)"
for f in AGENT.md CLAUDE.md CHANGELOG.md .mcp.json; do
  [ -e "$PROJ/$f" ] && echo "  sí   $f" || echo "  no   $f"
done
for d in specs docs/guia; do
  [ -d "$PROJ/$d" ] && echo "  sí   $d/" || echo "  no   $d/"
done
echo
echo "--- QUÉ DISPARADOR YA SE ENCENDIÓ (¿hay contenido, no sólo la caja?)"
GUIA=$(find "$PROJ/docs/guia" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
SPECS=$(ls "$PROJ/specs"/[0-9][0-9][0-9]-*.md 2>/dev/null | wc -l | tr -d ' ')
CHLOG=$(grep -c '^- ' "$PROJ/CHANGELOG.md" 2>/dev/null); CHLOG=${CHLOG:-0}
echo "  guía:      $GUIA archivo(s) en docs/guia/"
echo "  specs:     $SPECS spec(s) numerada(s)"
echo "  changelog: $CHLOG viñeta(s)"
echo
if [ "$HAYGIT" = 1 ]; then
  echo "--- COMMITS DEL RANGO"
  gl --oneline
  echo
  echo "--- ¿ALGÚN COMMIT DEL RANGO TOCÓ LA GUÍA / EL CHANGELOG?"
  echo "  docs/guia/:   $(cuenta docs/guia) commit(s)"
  echo "  CHANGELOG.md: $(cuenta CHANGELOG.md) commit(s)"
  echo "  AGENT.md:     $(cuenta AGENT.md) commit(s)"
  echo
  echo "--- ARCHIVOS TOCADOS EN EL RANGO (para juzgar qué ve el usuario)"
  { gl --name-only --pretty=format: ; git diff --name-only ; git diff --cached --name-only ; } \
    | grep -v '^$' | sort -u | head -60
  echo
  echo "--- SIN COMMITEAR"
  git status --short | head -30
  [ -z "$(git status --short)" ] && echo "  (nada)"
else
  echo "--- GIT"
  echo "  este proyecto todavía no es un repo git: no hay commits que revisar."
  echo "  la mitad 1 del cierre no aplica; la mitad 2 sí."
fi
echo
echo "--- .mcp.json: ¿CBM_ALLOWED_ROOT apunta acá?"
if [ -f "$PROJ/.mcp.json" ]; then
  RAIZ=$(python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print(d['mcpServers']['codebase-memory-mcp']['env']['CBM_ALLOWED_ROOT'])" "$PROJ/.mcp.json" 2>/dev/null || echo "(no pude leerlo)")
  echo "  dice: $RAIZ"
  [ "$RAIZ" = "$PROJ" ] && echo "  → coincide" || echo "  → NO coincide con $PROJ"
else
  echo "  (este proyecto no tiene .mcp.json)"
fi
echo
echo "--- MEMORIA"
SLUG="$(python3 -c "import re,sys;print(re.sub(r'[^A-Za-z0-9]','-',sys.argv[1]))" "$PROJ")"
MEMDIR="$HOME/.claude/projects/$SLUG/memory"
if [ -d "$MEMDIR" ]; then
  # si el proyecto trajo su propio generador, gana el suyo
  GEN="$MEMDIR/generar-indice.py"
  [ -f "$GEN" ] || GEN="$(python3 -c "import os;print(os.path.dirname(os.path.dirname(os.path.realpath(os.path.expanduser('~/.claude/commands/cerrar.md')))))" )/memoria/generar-indice.py"
  echo "  carpeta:   $MEMDIR"
  echo "  generador: $GEN"
  python3 "$GEN" "$MEMDIR"; echo "  → salió $?"
else
  echo "  (todavía no hay carpeta de memoria: $MEMDIR)"
fi
```

## Step 2 — the two halves

Report **in the human language of the conversation**, plainly, in two halves. The
second half is the whole point of this command.

### Half 1 — what is already active: is it done?

Only ask about a rule whose trigger is already on (there is content, not just the
empty box). For each one that is on:

- **Guide** — did anything in the range change what a person sees, without
  `docs/guia/` being touched? Name the commits. Offer to write it **now**, and
  say which topic file it belongs in.
- **Changelog** — same question against `CHANGELOG.md`. This is the one with a
  real expiry date: written at release time it is already too late.
- **`AGENT.md`** — did anything break in a way that was expensive to find? If so,
  it is a candidate for *Rules That Cost Us* — and only then. A preference is not
  a rule. Show what changed and let the person decide.
- **Memory** — the generator's exit code. Non-zero names the incomplete file.

### Half 2 — what is NOT active yet: has its trigger been met?

For each rule that is still off, ask the question out loud, once:

| rule | ask |
|---|---|
| guide in the same commit | is there now a user who is not you? |
| changelog bullet in the same commit | is there now a first distributable version? |
| spec before building | is the next feature one that needs decisions before code? |

**This half is why the command exists.** The missing part of the method does not
depend on anyone remembering it: it asks itself, every close.

## Rules for you while doing this

- **Do not write anything.** Not a memory, not a guide file, not a bullet. Offer;
  the person says yes, and *then* you write — in this session's normal flow, with
  the reasons still in view.
- **Do not invent a memory to have something to save.** If nothing was learned,
  say nothing was learned. That is a valid close.
- If `.mcp.json` does not match this folder, say so and offer the one-line fix.
- If the range looks wrong (too many commits, or none), say so and suggest
  `/cerrar <punto-de-partida>`.
