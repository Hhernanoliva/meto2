#!/usr/bin/env bash
# instalar.sh — paso 1 del método: una vez por computadora.
# Deja los comandos /arrancar y /cerrar disponibles en Claude Code e instala
# las herramientas del núcleo. No toca ningún proyecto.
set -u

REPO="$(cd "$(dirname "$0")" && pwd)"
CMDDIR="$HOME/.claude/commands"
SI="no"
[ "${1:-}" = "--si" ] || [ "${1:-}" = "-y" ] && SI="si"

OK=""; NOPUDE=""; TETOCA=""
ok()     { OK="$OK
  ✅ $1"; }
nopude() { NOPUDE="$NOPUDE
  ⚠️  $1"; }
tetoca() { TETOCA="$TETOCA
  👉 $1"; }

# ---------------------------------------------------------------- 1. chequeos
# Fallar por la mitad no es una opción: todo lo que hace falta se mira antes.
FALTA=""
command -v git  >/dev/null 2>&1 || FALTA="$FALTA git"
command -v curl >/dev/null 2>&1 || FALTA="$FALTA curl"
case "$(uname -s)" in
  Darwin|Linux) ;;
  *) echo "Este instalador anda en Mac y en Linux. En Windows todavía no."; exit 1 ;;
esac
if [ -n "$FALTA" ]; then
  echo "Me falta esto para poder seguir:$FALTA"
  echo
  case "$(uname -s)" in
    Darwin) echo "  Instalalos con:  xcode-select --install" ;;
    Linux)  echo "  Instalalos con:  sudo apt install$FALTA" ;;
  esac
  echo "  Después volvé a correr:  bash $0"
  exit 1
fi
if [ ! -d "$HOME/.claude" ]; then
  echo "No encuentro la carpeta ~/.claude, así que Claude Code no está instalado en esta"
  echo "computadora (o nunca se abrió). Abrilo una vez y volvé a correr:  bash $0"
  exit 1
fi

# ------------------------------------------------------------- 2. el permiso
# Una sola pregunta, al principio. Después no vuelve a preguntar nada.
cat <<TXT

Voy a bajar de internet software que no es mío:

  · 4 complementos de Claude Code, desde GitHub:
      superpowers      github.com/anthropics/claude-plugins-official
      ponytail         github.com/DietrichGebert/ponytail
      caveman          github.com/JuliusBrussee/caveman
      context7         github.com/upstash/context7
  · codebase-memory-mcp, con el instalador oficial de ellos:
      github.com/DeusData/codebase-memory-mcp

Además voy a dejar dos comandos nuevos en $CMDDIR
(enlaces al repo que ya tenés acá, eso no baja nada).

TXT
if [ "$SI" != "si" ]; then
  printf "¿Sigo? [s/N] "
  read -r RESP
  case "$RESP" in s|S|si|Si|SI|y|Y|yes) ;; *) echo "Listo, no hice nada."; exit 0 ;; esac
fi
echo

# ------------------------------------------------------------- 3. los comandos
mkdir -p "$CMDDIR"
for c in arrancar cerrar; do
  DEST="$CMDDIR/$c.md"
  if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
    nopude "Ya había un archivo propio en $DEST y no lo pisé."
    tetoca "Si ese comando no te sirve, borralo y volvé a correr este instalador."
  else
    ln -sfn "$REPO/comandos/$c.md" "$DEST" && ok "/$c disponible en Claude Code" \
      || nopude "no pude crear el enlace $DEST"
  fi
done

# ------------------------------------------------------------- 4. los plugins
if command -v claude >/dev/null 2>&1; then
  instalar_plugin() { # nombre_visible  plugin@mercado  repo-de-github
    claude plugin marketplace add "$3" >/dev/null 2>&1
    if claude plugin install "$2" -y >/dev/null 2>&1; then
      ok "complemento $1 instalado"
    else
      nopude "no pude instalar el complemento $1"
      tetoca "Instalalo a mano:  claude plugin install $2"
    fi
  }
  instalar_plugin superpowers "superpowers@claude-plugins-official" "anthropics/claude-plugins-official"
  instalar_plugin ponytail    "ponytail@ponytail"                   "DietrichGebert/ponytail"
  instalar_plugin caveman     "caveman@caveman"                     "JuliusBrussee/caveman"
  instalar_plugin context7    "context7-plugin@context7-marketplace" "upstash/context7"
else
  nopude "no encontré el programa 'claude' en la terminal, así que no pude instalar los 4 complementos"
  tetoca "Abrí Claude Code, corré /doctor para que instale su comando de terminal, y volvé a correr este instalador."
fi

# ------------------------------------------------- 5. codebase-memory-mcp
# Nunca copiar el binario: pesa cientos de MB y es específico de la máquina.
if command -v codebase-memory-mcp >/dev/null 2>&1; then
  ok "codebase-memory-mcp ya estaba instalado"
else
  if curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash; then
    if command -v codebase-memory-mcp >/dev/null 2>&1; then
      ok "codebase-memory-mcp instalado"
    else
      ok "codebase-memory-mcp instalado en ~/.local/bin"
      nopude "esa carpeta no está en el PATH de tu terminal, así que el programa no se encuentra por su nombre"
      tetoca "Pegá esto y abrí una terminal nueva:  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
    fi
  else
    nopude "no pude instalar codebase-memory-mcp (falló la descarga)"
    tetoca "Instalalo a mano siguiendo el README de github.com/DeusData/codebase-memory-mcp"
  fi
fi

# ------------------------------------- 6. el CLAUDE.md global: leer y avisar
# Decisión A de la spec: se lee y se avisa, NUNCA se edita. Es tuyo.
GLOBAL="$HOME/.claude/CLAUDE.md"
AVISO=""
if [ -f "$GLOBAL" ]; then
  AVISO=$(grep -oiE 'svelte|tailwind|react|vue|next\.js|django|rails|flutter|swiftui' "$GLOBAL" \
          | tr 'A-Z' 'a-z' | sort -u | tr '\n' ' ')
fi

# ------------------------------------------------------------- 7. el resumen
cat <<TXT

────────────────────────────────────────────────────────────
✅ Instalado:${OK:-
  (nada nuevo)}
TXT
[ -n "$NOPUDE" ] && printf '\n⚠️  No pude:%s\n' "$NOPUDE"
[ -n "$TETOCA" ] && printf '\n👉 Te toca:%s\n' "$TETOCA"
cat <<TXT
────────────────────────────────────────────────────────────

Cómo se usa: entrá con Claude Code a la carpeta de un proyecto y escribí
/arrancar. Al terminar una sesión de trabajo, /cerrar.
TXT

if [ -n "$AVISO" ]; then
  cat <<TXT

Una cosa más, y no la toqué: tu archivo $GLOBAL
tiene reglas de tecnología ($AVISO). Ése archivo se aplica a
TODOS tus proyectos, sean o no de esa tecnología. Si querés, mové esas reglas
al AGENT.md de cada proyecto que sí las use. Yo no lo edito: es tuyo.
TXT
fi
