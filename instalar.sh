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
command -v git     >/dev/null 2>&1 || FALTA="$FALTA git"
command -v curl    >/dev/null 2>&1 || FALTA="$FALTA curl"
command -v python3 >/dev/null 2>&1 || FALTA="$FALTA python3"
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

Además voy a dejar tres comandos nuevos en $CMDDIR
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
for c in arrancar cerrar simple; do
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
# Esta es la parte lenta y hasta ahora era la parte muda: la pantalla quedaba en
# blanco y lo razonable era pensar que se habia colgado.
#
# Se muestra "X de Y" y NO un spinner, a proposito. Un spinner gira igual de
# contento cuando todo anda y cuando nada anda; el numero, si algo se traba, se
# queda quieto y eso SE VE. Es la misma idea que "un codigo de salida 0 es una
# afirmacion, no un resultado", aplicada a lo que mira el usuario.
PLUG_TOTAL=4   # tiene que coincidir con las llamadas a instalar_plugin de abajo
PLUG_N=0
if command -v claude >/dev/null 2>&1; then
  # 'claude plugin install' devuelve 0 aunque falle (medido: un nombre que no
  # existe en el mercado sale 0 e imprime el error). El unico chequeo que sirve
  # es preguntarle despues a 'claude plugin list' si el complemento esta.
  instalar_plugin() { # nombre_visible  plugin@mercado  repo-de-github
    PLUG_N=$((PLUG_N+1))
    printf '  [%d/%d] bajando %s…\n' "$PLUG_N" "$PLUG_TOTAL" "$1"
    claude plugin marketplace add "$3" >/dev/null 2>&1
    claude plugin install "$2" -y >/dev/null 2>&1
    if claude plugin list 2>/dev/null | grep -q "$2"; then
      printf '  ✅      %s instalado\n' "$1"
      ok "complemento $1 instalado"
    else
      printf '  ⚠️       %s no se pudo\n' "$1"
      nopude "no pude instalar el complemento $1"
      tetoca "Instalalo a mano:  claude plugin install $2"
    fi
  }
  instalar_plugin superpowers "superpowers@claude-plugins-official" "anthropics/claude-plugins-official"
  instalar_plugin ponytail    "ponytail@ponytail"                   "DietrichGebert/ponytail"
  instalar_plugin caveman     "caveman@caveman"                     "JuliusBrussee/caveman"
  instalar_plugin context7    "context7@context7-marketplace"        "upstash/context7"
  # Una regla escrita no evita nada; una comprobacion ruidosa si. Si alguien
  # agrega un quinto complemento y se olvida del contador, el cierre lo canta.
  if [ "$PLUG_N" != "$PLUG_TOTAL" ]; then
    nopude "aviso para quien edite instalar.sh: PLUG_TOTAL dice $PLUG_TOTAL y se intentaron $PLUG_N"
  fi
else
  nopude "no encontré el programa 'claude' en la terminal, así que no pude instalar los $PLUG_TOTAL complementos"
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
      # Su instalador ya suele escribir el PATH en el .zshrc y DESPUES avisar que
      # falta igual. Las dos cosas son ciertas: en la terminal abierta falta de
      # verdad, porque todavia no releyo el archivo. Medir el estado correcto en
      # el momento equivocado da un consejo que duplica la linea. Se le pregunta
      # al archivo, no a la sesion actual.
      if grep -qs '\.local/bin' "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; then
        tetoca "Abrí una terminal nueva y ya lo vas a encontrar: la línea del PATH ya quedó escrita en tu configuración. No la pegues de nuevo."
      else
        nopude "esa carpeta no está en el PATH de tu terminal, así que el programa no se encuentra por su nombre"
        tetoca "Pegá esto y abrí una terminal nueva:  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
      fi
    fi
  else
    nopude "no pude instalar codebase-memory-mcp (falló la descarga)"
    tetoca "Instalalo a mano siguiendo el README de github.com/DeusData/codebase-memory-mcp"
  fi
fi

# ------------------------ 5b. el recordatorio de para quién se escribe
# Segunda pregunta, y aparte: la primera era bajar software, esta toca TU
# configuracion. Un "no" aca no rompe nada de lo anterior.
#
# El hook APUNTA, nunca copia: no lleva adentro quien sos, dice donde leerlo.
# Asi no se desactualiza, y sirve igual para cualquier persona en cualquier PC.
GLOBAL="$HOME/.claude/CLAUDE.md"
HOOKTXT="Before answering: re-read who you are writing for in ~/.claude/CLAUDE.md, and write for THAT person. A rule read once at startup loses to everything that arrives after it."
if [ "$SI" != "si" ]; then
  cat <<TXT

Una cosa más, opcional, y es sólo para Claude Code. No baja nada: cambia un
archivo de configuración tuyo.

Si trabajás con otro agente, decí que no. Esto se escribe en un archivo que sólo
lee Claude Code, así que en las demás herramientas no haría absolutamente nada —
y es peor tenerlo puesto creyendo que te cubre.

El problema que arregla: en una carpeta cualquiera, Claude Code te explica las
cosas como si fueras programador. En los proyectos que armes con /arrancar eso
ya queda resuelto; afuera de ellos, no.

Lo que hace, y es una sola cosa: antes de contestarte, Claude Code pasa por tu
archivo $GLOBAL y lee cómo querés que te hablen.
Eso lo escribís vos y lo cambiás cuando quieras.

Acá no queda guardada ninguna copia de lo que digas de vos — sólo la dirección
donde está. Por eso no se desactualiza nunca.

Para sacarlo mañana, pedile a Claude Code: "sacame el recordatorio que puso meto2".

TXT
  printf "¿Lo agrego? [s/N] "
  read -r RH
  case "$RH" in
    s|S|si|Si|SI|y|Y|yes)
      if python3 "$REPO/memoria/agregar-hook.py" "$HOME/.claude/settings.json" "$HOOKTXT"; then
        ok "recordatorio de para quién escribir, activo en cada mensaje de Claude Code"
      else
        nopude "no pude agregar el recordatorio a tu settings.json"
      fi
      if ! grep -qiE '^#{1,3} *(communication|comunicaci|audience|lector|qui[eé]n)' "$GLOBAL" 2>/dev/null; then
        tetoca "Escribí quién sos en $GLOBAL, así el recordatorio tiene qué leer. Una sección '## Communication' con, por ejemplo: 'No soy ingeniero: explicame en castellano llano, sin jerga sin traducir.'"
      fi
      ;;
    *) echo "Listo, no toqué tu configuración." ;;
  esac
fi

# ------------------------------------- 6. el CLAUDE.md global: leer y avisar
# Decisión A de la spec: se lee y se avisa, NUNCA se edita. Es tuyo.
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
printf '%s\n' "────────────────────────────────────────────────────────────"

# Claude Code lee su lista de comandos UNA sola vez, al abrir la sesion. Los
# enlaces recien creados no existen para una sesion que ya estaba abierta:
# /arrancar no aparece y la conclusion obvia del usuario es que esto fallo.
# CLAUDECODE=1 lo setea Claude Code cuando el comando corre desde adentro
# (medido 2026-08-27: 'echo $CLAUDECODE' devuelve 1). Ahi la certeza es total y
# el aviso deja de ser condicional.
if [ -n "${CLAUDECODE:-}" ]; then
  cat <<TXT

⚠️  Estás corriendo esto desde adentro de Claude Code, y esta sesión NO ve los
comandos nuevos: la lista la leyó al abrirse. Cerrala y volvé a entrar, y recién
ahí /arrancar te va a aparecer. Si no aparece, entonces sí falló algo.
TXT
else
  cat <<TXT

Si tenías Claude Code abierto mientras corría esto, cerralo y volvé a entrar: la
lista de comandos la lee al empezar la sesión, así que hasta entonces /arrancar
no le figura.
TXT
fi

cat <<TXT

Cómo se usa: entrá con Claude Code a la carpeta de un proyecto y escribí
/arrancar. Al terminar una sesión de trabajo, /cerrar.
TXT

if [ -n "$AVISO" ]; then
  cat <<TXT

Una cosa más, y no la toqué: tu archivo $GLOBAL
tiene reglas de tecnología ($AVISO). Ése archivo se aplica a
TODOS tus proyectos, sean o no de esa tecnología. Si querés, mové esas reglas
al AGENTS.md de cada proyecto que sí las use. Yo no lo edito: es tuyo.
TXT
fi
