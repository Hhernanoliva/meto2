# 001 - meto2: el método, empaquetado para proyectos nuevos

Escrita el 2026-08-27 sobre el brief acordado con Hernán ese mismo día (dos
rondas). **Todo lo que el brief dejó decidido entra acá como premisa y no se
vuelve a discutir**; lo que estaba abierto se cierra en *Decisiones que esta
spec toma* al final, marcado para que Hernán lo dé vuelta si quiere.

> **Estado: construido, los 6 pasos del gate pasados.** Hernán corrió
> `instalar.sh` el 2026-08-27: los dos comandos aparecen, `codebase-memory-mcp
> 0.10.8` contesta, y el resumen imprimió las tres partes — incluida la de
> *no pude*, que era real.

## En criollo (resumen para Hernán)

CopyNotes no salió bien por el código. Salió bien por **cómo se trabajó**: hay
un `AGENTS.md` que un agente lee antes de tocar nada, specs numeradas, una guía
que se escribe en el mismo commit, un changelog con vencimiento real, y una
memoria que se genera sola y grita cuando le falta algo.

`meto2` es eso mismo **sin CopyNotes adentro**: las cajas vacías y las reglas de
cómo se llenan. Se instala una vez por computadora, y después en cada proyecto
nuevo escribís `/arrancar` y en dos segundos tenés el esqueleto entero. Al
terminar una sesión escribís `/cerrar` y te dice qué quedó sin escribir — no lo
escribe él, te avisa.

Lo importante es lo que **no** lleva: ni Svelte, ni Tailwind, ni las 19 reglas de
CopyNotes, ni las 89 memorias. Un proyecto nuevo arranca con la sección de reglas
**vacía**, y eso está bien: una regla sin la cicatriz que la produjo es
superstición.

## Objective

Que arrancar un proyecto nuevo con el método completo cueste **un comando**, y
que el método viaje a otra computadora y a otra persona **sin arrastrar nada de
CopyNotes, de Hernán, ni de esta máquina**.

## Non-goals

- **No** porta el método a los 10 proyectos que ya existen en la Mac. Descartado
  explícitamente.
- **No** es un plugin de Claude Code (ceremonia sin destinatario) ni un repo para
  clonar (choca cuando el proyecto arranca con un generador tipo `npx sv create`).
- **No** toca CopyNotes. CopyNotes es la fuente: se lee, no se modifica.
- **No** arregla las dos deudas que el brief destapó en CopyNotes (el `AGENT.md`
  de 97 KB y las reglas duplicadas entre `AGENT.md` y memoria). Trabajo aparte.
- **No** porta los comandos, la memoria ni la lista de complementos a otros
  agentes. Ver la decisión **D**: el método viaja en `AGENTS.md`, la cañería no.

## La distinción que decide todo: forma vs contenido

| VIAJA (la forma) | NO VIAJA (el contenido) |
|---|---|
| Que exista una sección "reglas que costaron caro" | Las 19 reglas de CopyNotes |
| Que las specs estén numeradas y con índice | Las 49 specs |
| Que la guía se escriba en el mismo commit | Los 23 temas |
| El sistema de memoria entero (3 campos + generador) | Las 89 memorias |
| La skill `verify` como idea: cómo se prende y maneja *esta* app | Los comandos `pnpm` de CopyNotes |

Copiar contenido en vez de forma es el **riesgo N°1** del paquete y tiene una
prueba mecánica, abajo en *La prueba del núcleo agnóstico*.

## Premisas ya decididas (brief del 2026-08-27)

1. **Forma:** carpeta propia con git (`~/Projects/meto2`), dos enlaces simbólicos
   hacia `~/.claude/commands/`.
2. **Alcance:** esqueleto **completo** el día 1 (5 archivos, 4 carpetas). Lo que
   crece son las reglas, no las carpetas. Nada de "una segunda parte que se
   activa después": sin disparador, nunca se activa.
3. **El núcleo es agnóstico del stack.** No trae capa de SvelteKit ni de ninguna
   otra: traer una capa lista ya es decirle al que llega cuál es el stack bendecido.
4. **Idioma en dos capas:** lo que lee la máquina (`AGENTS.md`, `CLAUDE.md`,
   skills, comandos, specs) en **inglés**; lo que lee la persona (`docs/guia/`,
   `CHANGELOG.md`, el tutorial, la conversación) en **el idioma del usuario**,
   declarado en `CLAUDE.md`, nunca supuesto.
5. **El instalador instala todo**, y le explica al usuario qué instaló, qué no
   pudo y por qué, y qué le toca a él con el comando exacto para copiar.
6. **OKF** no recibe más lugar que un párrafo explicando el parentesco.
7. **Nombre del repo:** `meto2`. Comandos: `/arrancar`, `/cerrar` y `/simple`.

## Estructura del repo `meto2`

```
meto2/
  README.md                          # qué es y cómo se instala (idioma del usuario)
  instalar.sh                        # paso 1: una vez por computadora
  comandos/
    arrancar.md                      # → ~/.claude/commands/arrancar.md
    cerrar.md                        # → ~/.claude/commands/cerrar.md
    simple.md                        # → ~/.claude/commands/simple.md
  memoria/
    generar-indice.py                # el generador, UNA copia para todos los proyectos
    agregar-hook.py                  # agrega el recordatorio sin pisar hooks ajenos
  plantillas/
    AGENTS.md
    CLAUDE.md
    CHANGELOG.md
    specs/README.md
    docs/guia-de-uso.md
    .claude/settings.json
    .claude/skills/verify/SKILL.md
    .mcp.json
  specs/
    README.md
    001-el-paquete.md                # esta spec
```

Los comandos van por **enlace simbólico**, no por copia: se edita el repo y el
cambio ya está activo en todos los proyectos.

## Instalación en dos pasos

### Paso 1 — por computadora: `bash instalar.sh`

1. Enlaza los tres comandos a `~/.claude/commands/`.
2. Deja `memoria/generar-indice.py` accesible (queda en el repo; los comandos lo
   llaman por su ruta, resuelta desde el enlace simbólico).
3. Instala los plugins del núcleo: **superpowers**, **ponytail**, **caveman**,
   **context7**. Medido el 2026-08-27: **`claude plugin install` sale con código
   0 aunque falle** (un nombre que no está en el mercado imprime el error y sale
   0). El único chequeo que sirve es preguntarle después a `claude plugin list`
   si el complemento está. El nombre del complemento de context7 además cambió
   —`context7-plugin` → `context7`—, que es exactamente el tipo de cosa que un
   código de salida mentiroso deja pasar en silencio.
4. Instala `codebase-memory-mcp` **llamando al instalador oficial de ellos**
   (`install.sh` / `install.ps1` de `github.com/DeusData/codebase-memory-mcp`,
   o la fórmula de Homebrew). Nunca copiar el binario: pesa 282 MB y es
   específico de la máquina.
5. Imprime el resumen.

**Antes de bajar nada, una sola pregunta.** El instalador va a traer software de
internet que no es nuestro. Dice **qué** va a bajar y **de dónde**, y espera el
sí. Una vez, al principio — no paso por paso.

**Comprobaciones previas, antes de empezar** (fallar por la mitad no es una
opción): que existan `git` y `curl`, que el sistema esté soportado, y que
`~/.claude/` exista. Si falta algo, lo dice y no arranca.

**El resumen final** tiene tres partes y siempre las tres, en el idioma del
usuario y sin jerga:

```
✅ Instalado:   ...
⚠️  No pude:    ... y POR QUÉ
👉 Te toca:     ... con el comando exacto para copiar y pegar
```

Nunca *"falló el paso 3"*. Siempre *"no encontré `git`; instalalo así y volvé a
correr"*.

### Paso 2 — por proyecto: `/arrancar` adentro de la carpeta

Crea **5 archivos**:

| archivo | qué es |
|---|---|
| `AGENTS.md` | **el método entero**: lo que un agente debe saber siempre, lea el tool que lea |
| `CLAUDE.md` | ~10 renglones: importa `AGENTS.md` y agrega sólo la cañería de Claude Code |
| `specs/README.md` | el índice de specs |
| `docs/guia-de-uso.md` | el índice de la guía |
| `CHANGELOG.md` | la versión en curso |

y **4 carpetas**: `specs/`, `docs/guia/`, `docs/superpowers/` (con `specs/` y
`plans/` adentro) y `.claude/`.

Además:

- Genera `.mcp.json` con `CBM_ALLOWED_ROOT` apuntando a **esta** carpeta.
- **Pregunta una sola vez qué herramientas necesita ESTE proyecto**, con el
  inventario leído en vivo (`claude plugin list`), no de una lista escrita a
  mano que envejece. Los 4 del núcleo —superpowers, ponytail, caveman,
  context7— quedan encendidos; **todo el resto arranca apagado** y se prende lo
  que la persona marque. El desbalance es a propósito: un complemento prendido
  de más cuesta contexto en cada sesión, para siempre, y **en silencio**; uno
  apagado de más cuesta un renglón el día que se nota. Entre un error mudo y
  uno ruidoso, se elige el ruidoso. Escribe `.claude/settings.json` con **todos**
  los opcionales nombrados explícitamente (`false` los no marcados): un `false`
  escrito dice "este proyecto decidió", una ausencia dice "nadie decidió".
- **Dice qué NO pudo apagar.** Medido el 2026-08-27: los complementos tienen
  interruptor por proyecto (`enabledPlugins`), pero los skills sueltos de
  `~/.claude/skills`, los agentes de `~/.claude/agents` y los servidores MCP
  globales **no lo tienen**. `/arrancar` imprime cuántos son. Fingir que dejó el
  proyecto limpio sería peor que no preguntar.
- Escribe `.claude/skills/verify/SKILL.md` **en blanco, con sus preguntas**.
- Inicia la memoria: crea `~/.claude/projects/<slug>/memory/` y corre el
  generador para que `MEMORY.md` exista desde el primer día. El `<slug>` se
  calcula desde la ruta absoluta del proyecto, no se configura.
- **Al final dice qué creó y cuál es el próximo paso.**

`/arrancar` **no** hace `git init` ni instala dependencias: el proyecto ya
existe, esto le agrega el método encima.

Correrlo dos veces no rompe nada: lo que ya existe no se pisa, se nombra
(*"ya tenías `AGENTS.md`, lo dejé como estaba"*).

## Las plantillas

### `AGENTS.md` (inglés) — el método entero

**El nombre no es cosmético y se midió** (2026-08-27, con control):
`AGENTS.md` a secas **no** lo carga Claude Code, pero un `CLAUDE.md` cuya primera
línea es `@AGENTS.md` **sí**, y `AGENTS.md` es el nombre que Codex, Cursor y
OpenCode ya leen nativo. Antes de esto, el archivo del método se leía **sólo
porque `CLAUDE.md` le pedía al agente que lo abriera** —una instrucción, o sea
algo que se puede desobedecer—; ahora entra cargado. La división entre los dos
archivos pasa a ser una pregunta contestable: *¿esto es el método, o es la
cañería de una herramienta?*

Secciones, todas presentes, todas con su pregunta adentro en vez de contenido:

- **Product Vision** — qué es y para quién.
- **Collaboration Style** — cómo se explica y en qué idioma se habla.
- **Product Principles**.
- **Technical Direction** — ⬅ *costura de stack N°2*: el único lugar del núcleo
  donde se nombra una tecnología, y arranca vacío.
- **Application Architecture**.
- **Rules That Cost Us** — **vacía a propósito**, con el texto que explica por
  qué y cómo se escribe una regla nueva: *una regla entra acá cuando algo se
  rompió de verdad y costó encontrarlo; el título es la lección, no el bug*.
- **Verification Rules** — las 8 meta-reglas de abajo. **Estas sí vienen
  llenas**: no son de CopyNotes, son de trabajar con agentes.
- **Quality Bar**.
- **Where Detail Lives (topic → spec)** — la tabla, con encabezados y sin filas.

### Las 8 meta-reglas que sí viajan (van en la plantilla, en inglés)

1. **A massive red is almost never the code.** Measure the environment before
   reading the diff: ports, stale servers, reused state.
2. **A green can be a file nobody ran.** Check that the runner's output *names*
   the file.
3. **A red is a claim, not a verdict.** Run the same command against the baseline
   and compare rates. One failure alone proves nothing.
4. **How long it took to fail names its cause.** Sub-second is an assertion;
   five seconds is a timeout. They lead to opposite investigations.
5. **"Pre-existing and unrelated" is not accepted without checking.** In the
   project this method came from, those failures were two real data-loss bugs.
6. **Plan defects are normal, and hollow tests are too.** The rule that catches
   them: *name the line where the test fails if you delete its control*.
7. **Look at the screen before calling it done.** Tests assert that elements
   exist, not that the composition works.
8. **The manual gate finds what the tests don't.** In one feature, two manual
   gates found 11 bugs — more than all the build tasks combined.

Más el flujo — **brainstorm → spec → plan → TDD → gate a mano → merge** — y las
convenciones de commit.

Adentro de `AGENTS.md` van, además de las secciones de arriba:

- **Que este proyecto le gana a las reglas globales de tu herramienta.** Agregado
  el 2026-08-27, después de ver que el propio `meto2` necesitó exactamente esa
  sección: un archivo global con reglas de un stack se aplica a todos los
  proyectos de la máquina, incluso a los que no son de ese stack, y falla en
  silencio — como una sugerencia que suena informada. `instalar.sh` avisa una
  vez; esta sección es la que lo arregla en cada proyecto.
- **El idioma humano del proyecto**, declarado. Es un ajuste, no una suposición.
- **La regla de las specs**, con su disparador escrito al lado.
- **La regla de la guía**, con su disparador escrito al lado.
- **La regla del changelog**, con su disparador escrito al lado.
- Commitear a medida que se avanza.
- Un cierre que nombra las tres cosas que **no** están ahí porque cambian según
  la herramienta —cómo se prende la app, qué se apaga, dónde vive la memoria— y
  dice que no se inventen.

### `CLAUDE.md` (inglés) — sólo la cañería de Claude Code

Primera línea `@AGENTS.md`, y después nada más que lo que no es portable: la
skill `verify`, dónde vive la memoria y cómo se corre su generador, y qué
significan `.claude/settings.json` y `.mcp.json`. Si los dos archivos se
contradicen, **gana `AGENTS.md`**, y está escrito ahí.

### `specs/README.md`, `docs/guia-de-uso.md`, `CHANGELOG.md`

Los tres nacen con su índice vacío y **una línea que dice que la estructura es
intencional**: *"todavía no aplica — el disparador está en `CLAUDE.md`"*. Sin esa
línea, un agente que abre una carpeta vacía asume que se olvidaron y la ignora.

`docs/guia-de-uso.md` lleva además el campo **Última actualización**, que es lo
que hace visible el olvido.

### `.claude/skills/verify/SKILL.md`

En blanco con sus preguntas: **cómo se prende, cómo se compila y cómo se maneja
esta app de punta a punta**, más una sección *Gotchas* vacía. Es la costura de
stack N°3.

Es de las piezas más valiosas del paquete: sin ella, cada agente vuelve a
descubrir cómo correr el proyecto.

### `.claude/settings.json`

Nace con `enabledPlugins: {}` y el comentario de qué significa: *este proyecto
decide qué herramientas son ruido*. Es la costura de stack N°1.

## Los disparadores: qué se enciende cuándo

El esqueleto está entero desde el día 1, pero **cada regla dice por escrito qué
la activa**:

| regla | se activa cuando |
|---|---|
| Guía en el mismo commit | hay un usuario que **no sos vos** |
| Viñeta de CHANGELOG en el mismo commit | hay una **primera versión distribuible** |
| Spec antes de construir | la primera funcionalidad que necesita **decisiones antes de código** |

## `/cerrar`: comprueba y avisa, no escribe

El ritual viejo era *"guardá en memoria, guía y arquitectura"*. Tres defectos
medidos: dos de las tres ya son obligatorias por commit (pedirlas al final
significa que la regla se rompió y se parcha en el peor momento), el cierre es
cuando el contexto está más lleno (la dieta de memoria encontró **4 memorias
cuya `description` se contradecía con su propio cuerpo**, todas escritas al
cierre), y no nombraba el `CHANGELOG`, el único con vencimiento real.

`/cerrar` hace **dos mitades**:

```
lo que YA está activo   → ¿está hecho?  (guía, changelog, AGENTS.md, memoria)
lo que TODAVÍA NO       → ¿ya se cumplió el disparador? ¿lo encendemos?
```

Esa segunda mitad es el punto entero: **la parte que falta no depende de que
alguien se acuerde, se pregunta sola en cada cierre.**

Comprobaciones concretas:

| comprueba | cómo |
|---|---|
| ¿hay commits que tocan lo que ve el usuario y no tocan `docs/guia/`? | `git diff` del rango de la sesión |
| ¿y sin tocar `CHANGELOG.md`? | idem |
| ¿el generador de memoria sale con código 0? | corriéndolo |
| ¿`CBM_ALLOWED_ROOT` apunta a esta carpeta? | leyendo `.mcp.json` |
| ¿alguna regla nueva merece entrar en `AGENTS.md`? | pregunta, con lo que cambió a la vista |
| ¿algún disparador apagado ya se cumplió? | pregunta |

**Detecta, no lee configuración**: ¿existe `docs/guia/`? ¿`CHANGELOG.md`?
¿`AGENTS.md` o el `AGENT.md` de un proyecto anterior? Un proyecto nuevo funciona
el primer día sin darlo de alta, y uno
viejo —CopyNotes mismo— funciona sin adaptarlo.

**Nunca escribe por su cuenta.** Un `/cerrar` que escribiera memorias al cierre
fabricaría en serie exactamente las 4 memorias vencidas que la dieta encontró.
Comprueba, avisa, ofrece.

## El sistema de memoria

Viaja **entero**: los 3 campos (`titulo`, `estado`, `verificado`), la regla del
`description` como única línea de ruteo, el índice generado, y `ARCHIVO.md`
aparte para lo terminado.

**Una sola copia del generador** para todos los proyectos, en `meto2/memoria/`,
recibiendo la carpeta de memoria como argumento. Copiar el script a cada proyecto
haría que un arreglo no llegue nunca a los viejos.

Dos propiedades que hay que conservar si alguien lo toca — las dos ya probadas de
verdad en CopyNotes, no razonadas:

1. **Falla hacia el lado seguro.** Sin `estado`, la memoria cae en `vigente`, o
   sea **entra al índice**. Nunca desaparece por un campo mal escrito: queda
   visible y marcada.
2. **Sale con código 1** cuando falta un campo, y nombra el archivo. Así
   `/cerrar` se entera sin que nadie lea la salida.

El riesgo real no es que un hook pise una cabecera (medido: no hay hooks, no hay
MCP de memoria, nada tocó los archivos en toda la jornada). Es que **dentro de
dos meses un agente edite una memoria y borre los 3 campos porque no sabe que
existen**. Una regla escrita no lo evita; una comprobación ruidosa sí.

Va también el párrafo sobre **OKF**: el formato es primo hermano, la diferencia
exacta es dónde vive `type` (Claude Code lo mete adentro de `metadata`) y
`[[enlaces]]` vs enlaces markdown. Si algún día importa, el cambio ya está
identificado.

## La prueba del núcleo agnóstico

El stack entra por **tres costuras y sólo tres**:

1. `.claude/settings.json` — qué plugins se encienden y cuáles se apagan.
2. `AGENTS.md` › *Technical Direction* — el stack declarado en palabras.
3. `.claude/skills/verify/` — cómo se prende y se compila esta app.

Fuera de esas tres, el núcleo no nombra ninguna tecnología. Prueba mecánica, que
corre en el gate:

```bash
grep -riE 'svelte|tailwind|pnpm|dexie|copynotes|hernan|/Users/' plantillas/ comandos/ \
  | grep -v 'Technical Direction' | grep -v 'skills/verify' | grep -v 'settings.json'
# debe dar CERO
```

## El gate a mano

El paquete está listo cuando estos seis pasos pasan, corridos por una persona:

1. `bash instalar.sh` en la Mac: los dos comandos aparecen en Claude Code,
   `codebase` contesta, y el resumen imprime las tres partes.
2. `/arrancar` en una carpeta vacía nueva: aparecen los 5 archivos y las 4
   carpetas, `.mcp.json` apunta a esa carpeta, y `MEMORY.md` existe.
3. El `grep` de arriba da cero.
4. Sacarle `estado` a una memoria: el generador la nombra y sale con código 1.
   Restaurada, vuelve a 0.
5. `/cerrar` en el proyecto de prueba: dice que guía y changelog **todavía no
   aplican** porque el disparador no se cumplió, y **no escribe nada**.
6. `/cerrar` adentro de **CopyNotes**: detecta `docs/guia/`, `CHANGELOG.md` y
   `AGENT.md` (el nombre anterior), pregunta por los cuatro, y deja el
   `git status` limpio. Este es el
   único paso que prueba la detección contra un proyecto real y viejo.

## Plan de construcción

| tajada | qué entra | listo cuando |
|---|---|---|
| **1** | plantillas + `/arrancar` + generador con argumento | pasos 2 y 3 del gate |
| **2** | `/cerrar` | pasos 5 y 6 del gate |
| **3** | `instalar.sh` con permiso único y resumen de tres partes | paso 1 del gate |
| **4** | `README.md` / tutorial en idioma del usuario, y el párrafo de OKF | el gate completo |

Las tajadas 1 y 2 se pueden usar a mano (copiando los dos `.md` a
`~/.claude/commands/`) antes de que exista el instalador.

## Riesgos

- **Culto al cargo** (el N°1): copiar contenido de CopyNotes en vez de forma. Lo
  ataca el `grep` del gate y la sección de reglas vacía con su explicación.
- **Escala**: el método se ganó su peso a lo largo de 49 specs. Un proyecto chico
  no debería ahogarse — por eso los disparadores, y por eso `/cerrar` pregunta en
  vez de exigir.
- **`/cerrar` que escriba solo**: fabricaría memorias vencidas en serie.
  Prohibido por diseño.
- **Comandos con nombre en castellano** (`/arrancar`, `/cerrar`) en un paquete
  cuyo núcleo es en inglés. Decidido así; si algún día viaja de verdad, se le
  agregan alias en inglés y no se rompe nada.

## Decisiones que esta spec toma (el brief las dejó abiertas)

**A · El paquete NO toca el `~/.claude/CLAUDE.md` global de Hernán.** Es suyo y
se queda donde está. Pero `instalar.sh` **lo lee y avisa una vez** si encuentra
reglas de una tecnología ahí adentro: *"tenés reglas de Svelte en tu archivo
global; se aplican a **todos** tus proyectos, sean o no de Svelte. Si querés,
movelas al `AGENTS.md` de cada uno."* Lee y avisa, no edita. Riesgo cero y
resuelve el problema real, que es que hoy eso ya aplica a todo.

**B · `.mcp.json` se versiona.** En CopyNotes está en `.gitignore` por una ruta
absoluta que existe sólo porque el binario se compiló a mano; con el instalador
oficial el programa se llama **por nombre, sin ruta**. Lo único propio del
proyecto queda siendo una línea, `CBM_ALLOWED_ROOT`, que escribe `/arrancar`.
Versionarlo evita que un clon quede sin `codebase` sin que nadie avise, y
`/cerrar` comprueba que la ruta siga apuntando a la carpeta actual.

**C · Esta spec y las futuras specs del propio `meto2` van en castellano**,
porque su lector es Hernán. Las **plantillas** que el paquete reparte van en
inglés, como manda la premisa 4. No es contradicción: son dos lectores distintos.


**D · El método viaja en `AGENTS.md`; la cañería no viaja, y se dice.** Decidido
el 2026-08-27 después de medirlo (ver *Las plantillas*). Lo que un agente
cualquiera puede leer y usar hoy: `AGENTS.md`, `specs/`, `docs/guia/`,
`CHANGELOG.md`, el flujo, las 8 meta-reglas y el generador de memoria — todo eso
es markdown y Python.

Lo que queda **fuera de alcance**, escrito para que la pregunta no vuelva cada
tres meses:

- `/arrancar` y `/cerrar` viven en `~/.claude/commands/`. No se portan. Pero los
  dos son markdown legible: cualquier agente puede abrir el archivo y hacer lo
  que dice, y eso alcanza. El README lo explica.
- La memoria vive en una ruta de Claude Code (`~/.claude/projects/<slug>/`).
- La lista de complementos apagados es de Claude Code.

Escribir en los formatos de nueve agentes distintos —como hace el instalador de
`codebase-memory-mcp`— se hace **el día que haya un segundo agente en uso de
verdad**, no antes. Hasta entonces es mantenimiento de nueve archivos que nadie
lee.


**E · Para quién se escribe se hace cumplir con un hook, no con una frase.**
Decidido el 2026-08-27.

El problema medido: la regla *"explicame simple, no soy ingeniero"* ya existía en
el `~/.claude/CLAUDE.md` de Hernán, se cargaba en cada sesión, **y fallaba igual**.
Una regla que llega al arranque compite contra todo lo que llega después —las
instrucciones de cada skill, la salida de cada herramienta— y es lo primero que la
compresión de contexto poda.

No es una teoría: el plugin `caveman` chocó con lo mismo y dejó el diagnóstico
escrito en su propio código — *"el resumen de 2 oraciones era muy débil; los
modelos volvían a ser verbosos a mitad de conversación, sobre todo después de que
la compresión de contexto lo podaba"*. Su arreglo fueron **dos** hooks: las reglas
completas al arrancar más un recordatorio corto **re-inyectado en cada mensaje**.
Es la misma trampa que esta spec ya nombraba para la memoria: *una regla escrita no
lo evita; una comprobación ruidosa sí*.

Tres piezas, y la línea entre forma y contenido pasa por el medio:

1. **Por proyecto (forma, viaja).** `plantillas/.claude/settings.json` trae un
   hook `UserPromptSubmit` de un renglón: *releé Collaboration Style y Human
   Language en `AGENTS.md`, y escribí para ESE lector*. **Apunta, nunca copia** —
   no puede quedar desactualizado, y funciona aunque esas secciones se completen
   tres semanas después. Esto es lo que convierte *Collaboration Style* de adorno
   en algo que se cumple, y lo tiene **cualquier persona en cualquier computadora**.
   `/arrancar` debe conservar ese bloque al escribir `enabledPlugins`.
2. **Por computadora (contenido, es del usuario).** `instalar.sh` hace una segunda
   pregunta, aparte de la del software y con un "no" que no rompe nada: agrega el
   mismo tipo de recordatorio apuntando al `~/.claude/CLAUDE.md` de esa persona.
   **Sigue sin editar ese archivo** (decisión A): si no encuentra una sección que
   diga quién es, lo pone en *"👉 Te toca"*. Lo escribe `memoria/agregar-hook.py`,
   que es idempotente y no toca ningún otro hook.
3. **`/simple` (la salida de emergencia).** Cuando igual se escapa. Vuelve a decir
   lo mismo sin recortar la parte difícil, para el lector declarado.

**Y nombra cuál gana.** El recordatorio dice explícitamente que si choca con la
brevedad de `caveman`, **gana la claridad**: los dos tiran para lados opuestos, y
sin decirlo el resultado es jerga más corta — lo peor de los dos mundos.

Descartado hacerlo skill: un skill se carga cuando el modelo cree que viene al
caso, y la falla es justamente que **no se da cuenta de que está siendo confuso**.
