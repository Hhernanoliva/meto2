# 002 - meto2 en un segundo agente: OpenCode

Escrita el 2026-08-28. La decisión **D** de `001` dejó esto fuera de alcance con
un disparador escrito: *"escribir en los formatos de nueve agentes distintos se
hace **el día que haya un segundo agente en uso de verdad**, no antes."*

> **Estado: abierta.** El disparador se cumplió el 2026-08-28: la primera usuaria
> que no es el autor usa **OpenCode**, no Claude Code. No es una hipótesis ni un
> proyecto futuro — es la única herramienta con la que la primera persona ajena
> al autor va a tocar este paquete.
>
> Esta spec no construye nada todavía. Nombra lo que se midió, lo que viaja
> gratis, lo que no viaja, y **las cuatro decisiones** que hay que tomar antes de
> escribir una línea.
>
> **Actualizada el 2026-08-29: D1 quedó resuelta midiendo.** Resultó que el autor
> tiene OpenCode instalado, así que la mitad de este port se puede probar sin
> esperar a nadie. Quedan tres decisiones: D2, D3 y D4.

## En criollo

`meto2` está hecho de dos cosas que hasta hoy venían pegadas: **el método** —un
archivo de texto que dice cómo se trabaja— y **la cañería** —el instalador, los
tres comandos, el apagado de complementos, el recordatorio.

El método viaja solo: OpenCode lee `AGENTS.md` de forma nativa, sin que nadie
haga nada. La cañería no viaja: está escrita contra las carpetas y los formatos
de Claude Code, uno por uno.

La pregunta de esta spec no es *"¿se puede portar?"*. Se puede. Es **cuánto de la
cañería vale la pena portar**, sabiendo que una de las piezas —la que apaga los
complementos que no usás, que es la que da el ahorro medido— **no tiene
equivalente del otro lado**, y que otra —el recordatorio de para quién escribir—
sólo se puede hacer con un lenguaje que la *Technical Direction* de este paquete
dice que no se usa.

## Objetivo

Que una persona que trabaja con OpenCode obtenga de `meto2` **el método completo
y la parte de la cañería que tenga sentido allá**, sin que el paquete finja que
instaló cosas que esa persona no puede usar.

Lo segundo no es un detalle de cortesía: hoy el instalador le dice **tres veces
que sí** a cosas que en su máquina son mentira. Ver *Lo que se midió*.

## No-objetivos

- **No** soportar los nueve agentes que soporta el instalador de
  `codebase-memory-mcp`. Dos agentes en uso real, dos agentes soportados.
- **No** portar los cuatro complementos del núcleo. Son de Claude Code y no
  existen del otro lado; lo que se decide es qué se hace con el hueco, no cómo
  se rellena.
- **No** tocar Windows. Pausado aparte, con su diagnóstico ya escrito.
- **No** reescribir `AGENTS.md` ni las plantillas. Ya son agnósticas y el
  `grep` del gate lo comprueba. Ésa es la mitad que ya funciona.

## Lo que se midió (2026-08-28, en la Mac de la primera usuaria)

Corrida real de `bash instalar.sh` en una Mac que no es la del autor. Es la
primera vez que el paso 1 del gate se corre en una segunda máquina.

### Lo que salió bien, y hay que decirlo

- **Las tres partes del resumen se imprimieron, y las tres se entienden.** Los
  renglones de `⚠️ No pude` y `👉 Te toca` **se estrenaron acá**: en la máquina
  del autor nunca aparecieron porque nunca faltó nada. Cada uno nombró el
  problema y dio el comando exacto. La promesa de `001` › *Instalación en dos
  pasos* se cumplió.
- **La detección de que falta `claude` funcionó.** No estaba en la terminal, el
  instalador lo dijo y no fingió haber instalado los complementos.
- **`codebase-memory-mcp` se instaló entero** con el instalador oficial de ellos,
  bajado y verificado. El camino que en la máquina del autor estaba salteado
  (ahí el binario estaba compilado a mano) corrió de verdad por primera vez.

### Los tres "sí" que son mentira en su máquina

1. **`✅ /arrancar disponible en Claude Code`** — cierto, y **inútil**. Los tres
   comandos quedaron en `~/.claude/commands/`, que OpenCode no lee. El instalador
   **nunca preguntó con qué agente trabaja**. Es el defecto de fondo: no es que
   falle, es que reporta éxito de algo que ella no puede usar.
2. **`✅ recordatorio de para quién escribir, activo en cada mensaje`** — **falso**.
   Se escribió en `~/.claude/settings.json`. OpenCode no lo lee. La decisión E de
   `001` —la que convierte *Collaboration Style* de adorno en algo que se cumple—
   en su máquina **no está haciendo nada**, y el resumen dice que sí.
3. **`👉 Abrí Claude Code, corré /doctor ... y volvé a correr este instalador`** —
   le pide entrar a una herramienta que no usa, para instalar complementos que
   allá no funcionan.

El patrón de los tres es el mismo y ya tiene nombre en `AGENTS.md`:
**una afirmación que ningún chequeo puede ver.** El grep busca tecnologías, las
pruebas miran archivos; ninguno de los dos sabe qué agente usa la persona,
porque nadie se lo preguntó.

### El regalo: `codebase-memory-mcp` dibujó el mapa entero, gratis

Su instalador imprimió, en la misma corrida:

```
Detected agents: Claude-Code Codex OpenCode VS-Code

OpenCode:
  mcp:          /Users/<x>/.config/opencode/opencode.jsonc
  instructions: /Users/<x>/.config/opencode/AGENTS.md
  skill:        /Users/<x>/.config/opencode/skills/codebase-memory/SKILL.md
  agent:        /Users/<x>/.config/opencode/agents/codebase-memory-scout.md
  extension:    /Users/<x>/.config/opencode/plugins/cbm-augment.ts
```

Es exactamente el programa que la decisión D de `001` señaló como *"lo que no
vamos a hacer todavía"*, **haciéndolo delante nuestro y dejando las rutas
verificadas**. No hay que adivinar dónde va nada: está medido en una máquina real.

## El mapa: dónde vive cada cosa en cada agente

| pieza | Claude Code | OpenCode | cómo lo sabemos |
|---|---|---|---|
| el método | `AGENTS.md` del proyecto, vía `@import` de `CLAUDE.md` | `AGENTS.md`, **nativo** | doc + `001` |
| instrucciones globales | `~/.claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` | **medido** |
| config y MCP | `.claude/settings.json` + `.mcp.json` | `~/.config/opencode/opencode.jsonc` | **medido** |
| skills | `.claude/skills/<n>/SKILL.md` | `~/.config/opencode/skills/<n>/SKILL.md` | **medido** |
| agentes | `~/.claude/agents/*.md` | `~/.config/opencode/agents/*.md` | **medido** |
| hook por mensaje | un renglón en `settings.json` | un plugin **`.ts`** en `~/.config/opencode/plugins/` | **medido** |
| carpeta global de comandos | `~/.claude/commands/` | `~/.config/opencode/command/` | **medido** |
| cabecera del comando | `allowed-tools:` | `description:` · `agent:` · `model:` — **y las claves que no conoce las ignora** | **medido** |

**Ya no queda nada sin verificar en este mapa.** Se midió el 2026-08-29 en la
máquina del autor, que resultó tener OpenCode 1.18.23 instalado — ver abajo.

## Las cuatro decisiones

### D1 · Dónde viven los comandos — RESUELTA el 2026-08-29, midiendo

**Existe carpeta global y es `~/.config/opencode/command/`.** Se puso un archivo
ahí y `opencode debug config` pasó de ver 0 comandos a ver 1. Después se
enlazaron los tres comandos reales del repo y OpenCode vio los tres, leyó sus
descripciones, y **siguió los enlaces simbólicos sin problema**.

Más: la cabecera **no hay que cambiarla**. `arrancar.md` declara
`allowed-tools: Bash, Read, Edit, Write, AskUserQuestion`, que es una clave de
Claude Code, y OpenCode la ignoró sin una queja mientras tomaba el `description:`
que sí entiende.

**Consecuencia, y es la mejor posible:** los tres archivos de `comandos/` sirven
**tal como están** en los dos agentes, y la propiedad de los enlaces —se arregla
el repo y el arreglo está activo en todos lados— se conserva entera. `instalar.sh`
sólo tiene que enlazar en una carpeta más.

**Lo que esto NO probó, y hay que decirlo:** que los comandos *funcionen*. Se
midió que OpenCode los **encuentra y los lee**. El cuerpo de `arrancar.md`
menciona `~/.claude` diez veces y el de `cerrar.md` dos —para resolver dónde
está el repo, dónde vive la memoria, y para contar los complementos— y eso sigue
siendo trabajo pendiente. Encontrarlos era la incógnita de diseño; hacerlos
andar es tarea.

### D2 · El apagado de complementos no tiene equivalente

Es la función con **el único número medido del paquete**: ~6.000 tokens menos por
sesión. Depende de `enabledPlugins` en `.claude/settings.json` y de los cuatro
complementos del núcleo. Nada de eso existe en OpenCode.

- **a)** Se declara **fuera de alcance** para OpenCode, y `/arrancar` lo dice en
  voz alta en vez de saltearlo en silencio.
- **b)** Se busca el equivalente en OpenCode y se mide antes de prometer nada.
- **c)** Se investiga si su sistema de *skills* y *agents* tiene un costo
  parecido que valga la pena apagar.

Lo que **no** es opción: dejar el hueco sin nombrar. Hoy el resumen de la
instalación no menciona que esa mitad del valor no llegó.

### D3 · El recordatorio necesita TypeScript, y eso choca con una regla nuestra

La decisión E de `001` es de las mejores del paquete: hace que *"escribime
simple"* se cumpla de verdad. En Claude Code cuesta **un renglón** en un archivo
de configuración. En OpenCode el equivalente es un **plugin escrito en
TypeScript** con el hook `chat.message`.

Y `AGENTS.md` › *Technical Direction* dice: **bash, markdown y Python 3 de la
biblioteca estándar. Sin dependencias, sin gestor de paquetes, sin paso de
compilación.**

No es un detalle de implementación: es un choque frontal con una regla escrita,
y por eso se decide acá y no en el código.

- **a)** Se acepta TypeScript **sólo para esta pieza**, y se agrega como una
  cuarta costura declarada, igual que las tres de stack que ya existen.
- **b)** No se porta. En OpenCode el recordatorio no existe, y **se dice**.
- **c)** Se busca si OpenCode admite algo equivalente sin código —una sección de
  su `AGENTS.md` global, que ya sabemos que lee (`~/.config/opencode/AGENTS.md`,
  medido). Más débil que un hook, pero es markdown y no rompe ninguna regla.

**La (c) merece mirarse primero**, porque el hallazgo que originó la decisión E
fue justamente que *una regla que llega al arranque pierde contra todo lo que
llega después*. Si en OpenCode la única opción sin código es exactamente esa
regla débil, entonces la (c) es la que ya se sabe que falla, y la decisión real
es entre (a) y (b).

### D4 · Un instalador que pregunta, o dos instaladores

Hoy `instalar.sh` asume Claude Code desde la primera línea: comprueba `~/.claude`,
y si no está, sale.

- **a)** Una pregunta al principio: *"¿con qué agente trabajás?"*, con las
  respuestas detectadas mirando qué carpetas existen — nunca una lista escrita a
  mano, que es lo que ya manda `001` para los complementos.
- **b)** **Detectar en vez de preguntar**, como hace `codebase-memory-mcp`:
  encuentra los agentes instalados y trabaja con todos. Menos preguntas, pero
  toca configuración de herramientas que la persona quizá no usa.
- **c)** Dos instaladores separados.

La **(a)** es la que se parece al resto del paquete: `001` ya eligió preguntar
una vez con el inventario leído en vivo, y ya eligió que un error ruidoso le gana
a uno mudo.

## Lo que hay que arreglar igual, sea cual sea la decisión

Dos defectos que la corrida destapó y que **no dependen de OpenCode**:

1. **El consejo del `PATH` está duplicado.** El instalador de ellos dice
   `Added /Users/<x>/.local/bin to PATH in ~/.zshrc` y, tres renglones después,
   `NOTE: ... is not in your PATH`. `meto2` le cree al segundo y en `👉 Te toca`
   manda a pegar la línea — que **ya está en el archivo**. Si ella obedece,
   queda dos veces.
   La causa no es confiar en un código de salida: es **medir el estado correcto
   en el momento equivocado**. `command -v` en la terminal actual da falso porque
   el `.zshrc` recién cambió y esa terminal no lo releyó. El consejo correcto es
   *"abrí una terminal nueva y probá"*, no *"agregá la línea"*.
2. **El texto de la segunda pregunta nombra a Claude** cuatro veces
   (*"Claude te explica las cosas como si fueras programador"*). Para quien usa
   otro agente es incorrecto, y es texto que lee una persona.

## Riesgos

- **Prometer paridad.** El riesgo grande de esta spec es que el port termine
  diciendo *"meto2 anda en OpenCode"* cuando en realidad anda **el método** y una
  parte de la cañería. Se ataca con lo mismo de siempre: el resumen de la
  instalación nombra lo que **no** llegó.
- **Mantener dos cañerías.** Cada arreglo pasa a costar el doble. Es el motivo
  por el que `001` no quería hacerlo antes de tener un segundo agente real.
- **TypeScript entrando por la ventana.** Si se acepta para el hook (D3-a), la
  regla *sin paso de compilación* deja de ser cierta y hay que reescribirla, no
  ignorarla.

## El gate de esta spec

Además del gate de 6 pasos de `001`, esta spec no está lista hasta que, **en la
máquina de ella y con ella mirando**:

1. ~~Se confirmen los dos renglones *no verificados* del mapa.~~ **Hecho el
   2026-08-29** en la máquina del autor: carpeta global `~/.config/opencode/command/`,
   enlaces simbólicos seguidos, cabecera de Claude Code aceptada sin cambios.
2. `/arrancar` corra desde OpenCode en una carpeta nueva y deje los 8 archivos.
3. `/cerrar` corra desde OpenCode y **no escriba nada**.
4. El resumen de la instalación **no afirme ni una sola cosa que en su máquina
   sea falsa**. Es el defecto que originó esta spec y es el único paso que no se
   puede automatizar: se lee la pantalla y se compara con la realidad.

## Plan de construcción

| tajada | qué entra | listo cuando |
|---|---|---|
| **0** | los dos arreglos de *Lo que hay que arreglar igual* | no dependen de ninguna decisión |
| **1** | D4: el instalador pregunta con qué agente se trabaja | deja de afirmar cosas falsas |
| **2** | D1: los comandos, donde se haya decidido | pasos 2 y 3 del gate de arriba |
| **3** | D2 y D3: el hueco de complementos y el recordatorio | paso 4 |
