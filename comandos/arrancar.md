---
description: Set up the meto2 method in the current project folder (8 files, 4 folders, memory).
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
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
for f in AGENTS.md CLAUDE.md CHANGELOG.md specs/README.md docs/guia-de-uso.md \
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

# El inventario se lee EN VIVO, no de una lista escrita a mano: una lista
# escrita envejece, y en otra computadora ya nace mintiendo.
NUCLEO=" superpowers@claude-plugins-official ponytail@ponytail caveman@caveman context7@context7-marketplace "
echo
echo "--- COMPLEMENTOS CARGADOS EN ESTA COMPUTADORA"
# Cada complemento se anuncia en CADA sesion con la descripcion de cada una de
# sus skills y agentes. Eso es lo que se cobra, y es contable: se cuenta.
python3 - "$NUCLEO" <<'PY'
import json, os, sys, glob
nucleo = sys.argv[1].split()
try:
    inst = json.load(open(os.path.expanduser('~/.claude/plugins/installed_plugins.json')))['plugins']
except Exception:
    inst = {}
for pid in sorted(inst):
    ruta = inst[pid][0].get('installPath', '')
    sk = len(glob.glob(os.path.join(ruta, 'skills', '*', 'SKILL.md')))
    ag = len(glob.glob(os.path.join(ruta, 'agents', '*.md')))
    marca = 'nucleo  ' if pid in nucleo else 'opcional'
    print('  %s  %-42s %2d skills, %2d agentes' % (marca, pid, sk, ag))
PY
echo
echo "--- LO QUE SE COBRA EN CADA SESION Y NO TIENE INTERRUPTOR POR PROYECTO"
echo "  skills sueltos en ~/.claude/skills:  $(ls "$HOME/.claude/skills" 2>/dev/null | wc -l | tr -d " ")"
echo "  agentes en ~/.claude/agents:         $(ls "$HOME/.claude/agents" 2>/dev/null | wc -l | tr -d " ")"
echo
echo "--- LO QUE NO SE COBRA (medido el 2026-08-27 con /context)"
echo "  servidores MCP: $(python3 -c "
import json,os
try: print(len(json.load(open(os.path.expanduser('~/.claude.json'))).get('mcpServers',{})))
except Exception: print(0)") globales, y sus herramientas cuestan CERO hasta que se usan."

echo
echo "=== /arrancar ==="
echo "proyecto:  $NAME  ($PROJ)"
echo "creados:  ${CREADOS:-  (ninguno)}"
echo "intactos: ${INTACTOS:-  (ninguno)}"
echo "memoria:  $MEMDIR  (generador salió $MEM)"
```

## Step 2 — one question: which tools does THIS project need?

Skip this whole step if `.claude/settings.json` was reported as **kept** (it
already existed): somebody already decided, and re-deciding for them is worse
than any list.

Otherwise, ask **one** question with checkboxes, using the live inventory the
script printed:

- The four marked **nucleo** stay on. They are the method itself.
- Every one marked **opcional** starts **off**. Offer them as checkboxes and turn
  on only what the person ticks.

Why off by default, and say it in the question: a tool left on costs context in
**every session, forever, invisibly**. A tool left off costs one line the day it
is missed, and that day is obvious. When one mistake is silent and the other is
loud, choose the loud one.

Then edit `.claude/settings.json`, **keeping its `hooks` block exactly as it
arrived** — that hook is what makes *Collaboration Style* enforceable instead of
decorative — and fill `enabledPlugins` with **every** optional plugin listed
explicitly: `false` for the ones not ticked, `true` for the ones ticked:

```json
{
  "enabledPlugins": {
    "un-complemento@su-mercado": false,
    "otro@su-mercado": true
  }
}
```

Explicit `false` beats leaving it out. An absent entry reads as "nobody decided";
a written `false` reads as "this project decided, and this is what it decided".

## Step 3 — report it, do not just paste it

Tell the person, **in the human language of the conversation**, plainly and
without jargon:

1. **What was created** — the five method files, the four folders, the memory
   index. One line each, in terms of what it is *for*, not its path.
2. **What was already there and was left untouched**, if anything. Name the files.
3. **The next step**, which is always the same one: `AGENTS.md` arrived as
   **questions, not answers**. The first real task is filling in *Product
   Vision*, *Technical Direction* and *Human Language*. Offer to do it now by
   asking about the project.

Say plainly which file is which, because the split is the point: **`AGENTS.md` is
the method** — every agent reads it, whichever tool it runs in — and **`CLAUDE.md`
is only Claude Code's plumbing**, importing the other on its first line.

Also mention, in one line each, only if true:
- **The receipt, not a promise.** Add up the skills and agents of the plugins
  that were left off and say the total: *"apagaste N complementos: X skills y Y
  agentes menos anunciados en cada sesión"*. Counts, never token estimates —
  those would be invented, and this method does not do invented numbers.
- **It does not take effect in this session.** Plugins are read once, when the
  session opens; this file was written afterwards. Say so, and say how to check:
  restart and run `/context` — the Skills and Custom agents lines should drop.
  Measured 2026-08-27: without that sentence the change looks like it did
  nothing, and the obvious conclusion is that it does not work.
- **What could not be turned off**, using the numbers the script printed: loose
  skills and agents have no per-project switch, so they stay on. Say it plainly
  instead of implying the project is clean. If one of them is noise in *every*
  project, the place to remove it is the global setup, not here.
- **Keep it in proportion, and say it.** Measured 2026-08-27 on a real machine:
  the fixed toll of a session was ~28,000 tokens, of which everything this
  question can reach was ~6,000. Long context and long answers cost more than
  every plugin combined. This step is worth doing and it is not the big lever;
  claiming otherwise is the kind of promise this method exists to avoid.
- The generator exited non-zero (a memory is missing a field — it names which).
- `docs/guia/` and `CHANGELOG.md` say "not applicable yet" **on purpose**: their
  triggers are written down in `CLAUDE.md` and have not been met.

Do **not** fill any template in with plausible-sounding content on your own. A
section left as a question is honest; a guessed answer is a lie the next agent
will act on.
