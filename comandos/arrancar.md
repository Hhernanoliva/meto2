---
description: Set up the meto2 method in the current project folder (5 files, 4 folders, memory).
allowed-tools: Bash, Read, Edit
---

# /arrancar — put the method into this project

The current folder is an existing project. This adds the method **on top of it**:
it does not `git init`, does not install dependencies, and does not touch code.

Running it twice is safe: **nothing that already exists is overwritten** — it is
reported as kept.

## Step 1 — run this, exactly as it is

```bash
set -u
PROJ="$PWD"
REPO="${METO2:-$(python3 - <<'PY'
import os
p = os.path.realpath(os.path.expanduser('~/.claude/commands/arrancar.md'))
print(os.path.dirname(os.path.dirname(p)))
PY
)}"
[ -d "$REPO/plantillas" ] || { echo "ERROR: no encuentro las plantillas de meto2 en $REPO"; echo "Correr de nuevo con:  METO2=/ruta/a/meto2 ..."; exit 1; }

NAME="$(basename "$PROJ")"
SLUG="$(python3 -c "import re,sys;print(re.sub(r'[^A-Za-z0-9]','-',sys.argv[1]))" "$PROJ")"
MEMDIR="$HOME/.claude/projects/$SLUG/memory"
GEN="$REPO/memoria/generar-indice.py"

CREADOS=""; INTACTOS=""
for f in AGENT.md CLAUDE.md CHANGELOG.md specs/README.md docs/guia-de-uso.md \
         .claude/settings.json .claude/skills/verify/SKILL.md .mcp.json; do
  if [ -e "$PROJ/$f" ]; then
    INTACTOS="$INTACTOS  $f"
  else
    mkdir -p "$(dirname "$PROJ/$f")"
    cp "$REPO/plantillas/$f" "$PROJ/$f"
    python3 - "$PROJ/$f" "$NAME" "$PROJ" "$MEMDIR" "$GEN" <<'PY'
import io, sys
ruta, nombre, raiz, memdir, gen = sys.argv[1:6]
s = io.open(ruta, encoding='utf-8').read()
for viejo, nuevo in (('<PROJECT NAME>', nombre), ('__PROJECT_ROOT__', raiz),
                     ('__MEMORY_DIR__', memdir), ('__GENERATOR__', gen)):
    s = s.replace(viejo, nuevo)
io.open(ruta, 'w', encoding='utf-8').write(s)
PY
    CREADOS="$CREADOS  $f"
  fi
done

for d in specs docs/guia docs/superpowers/specs docs/superpowers/plans .claude; do
  mkdir -p "$PROJ/$d"
  # una carpeta vacía no existe para git: sin esto, el esqueleto desaparece al clonar
  [ "$(ls -A "$PROJ/$d")" ] || touch "$PROJ/$d/.gitkeep"
done

mkdir -p "$MEMDIR"
python3 "$GEN" "$MEMDIR"; MEM=$?

echo
echo "=== /arrancar ==="
echo "proyecto:  $NAME  ($PROJ)"
echo "creados:  ${CREADOS:-  (ninguno)}"
echo "intactos: ${INTACTOS:-  (ninguno)}"
echo "memoria:  $MEMDIR  (generador salió $MEM)"
```

## Step 2 — report it, do not just paste it

Tell the person, **in the human language of the conversation**, plainly and
without jargon:

1. **What was created** — the five method files, the four folders, the memory
   index. One line each, in terms of what it is *for*, not its path.
2. **What was already there and was left untouched**, if anything. Name the files.
3. **The next step**, which is always the same one: `AGENT.md` and `CLAUDE.md`
   arrived as **questions, not answers**. The first real task is filling in
   *Product Vision*, *Technical Direction* and the human language in `CLAUDE.md`.
   Offer to do it now by asking about the project.

Also mention, in one line each, only if true:
- The generator exited non-zero (a memory is missing a field — it names which).
- `docs/guia/` and `CHANGELOG.md` say "not applicable yet" **on purpose**: their
  triggers are written down in `CLAUDE.md` and have not been met.

Do **not** fill any template in with plausible-sounding content on your own. A
section left as a question is honest; a guessed answer is a lie the next agent
will act on.
