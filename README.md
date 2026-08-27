# meto2 — el método, empaquetado

Esto no es una app ni una librería. Es **la forma de trabajar** con la que se
construyó un proyecto que salió bien, guardada en cajas vacías para poder
arrancar otro proyecto con ella desde el día uno.

Lo que hace, en una línea: **`/arrancar` te deja el esqueleto entero del método
en cualquier carpeta, y `/cerrar` te dice al final del día qué quedó sin
escribir** — no lo escribe él, te avisa.

Lo que **no** lleva, a propósito: ninguna tecnología, ninguna regla heredada de
otro proyecto, ninguna memoria vieja. Las cajas vienen vacías porque **una regla
sin la cicatriz que la produjo es superstición**, y le cuesta contexto a todos los
que vengan después.

---

## Instalación

### Paso 0 — traelo

```bash
git clone https://github.com/<usuario>/meto2.git ~/Projects/meto2
```

Necesitás **Claude Code** ya instalado, más `git`, `curl` y `python3`. Anda en
Mac y en Linux; en Windows todavía no.

### Paso 1 — una vez por computadora

```bash
bash ~/Projects/meto2/instalar.sh
```

Ojo, y lo decimos acá porque conviene saberlo antes: este paso **baja software de
internet que no es nuestro** —cuatro complementos de Claude Code y un programa de
otra gente— y para uno de ellos usa el instalador oficial de ellos. Te dice qué y
de dónde antes de bajar nada, y espera tu sí.

Antes de bajar nada te dice **qué** va a bajar y **de dónde**, y espera el sí.
Una sola vez, no paso por paso. Al final imprime tres partes, siempre las tres:

```
✅ Instalado:   ...
⚠️  No pude:    ... y por qué
👉 Te toca:     ... con el comando exacto para copiar y pegar
```

Los tres comandos quedan como **enlaces** al repo, no como copias: si mañana los
mejorás acá, el cambio ya está activo en todos tus proyectos.

Al final te hace **una segunda pregunta, opcional**: si querés un recordatorio que
se dispare con cada mensaje que mandes, en cualquier carpeta, diciéndole al agente
que vaya a leer quién sos antes de contestar. No lleva tu descripción adentro —
sólo apunta a tu `~/.claude/CLAUDE.md`, donde eso lo escribís vos.

### Paso 2 — una vez por proyecto

Entrá con Claude Code a la carpeta del proyecto y escribí:

```
/arrancar
```

No hace `git init` ni instala dependencias: el proyecto ya existe, esto le agrega
el método encima. Correrlo dos veces no rompe nada — lo que ya existe no se pisa,
se nombra.

---

## Tu primer proyecto, en tres pasos

1. **`/arrancar`.** Aparecen cinco archivos y cuatro carpetas. Todos los archivos
   están llenos de **preguntas, no de respuestas**. Eso es correcto.
2. **Contestá `AGENTS.md`.** Qué es esto y para quién, con qué está hecho, y en
   qué idioma se le habla a la persona. Diez minutos. Es lo único que hay que
   hacer a mano, y es lo que hace que ningún agente vuelva a preguntarlo.
3. **Trabajá.** Al final del día, `/cerrar`.

---

## Qué crea `/arrancar`

| archivo | para qué |
|---|---|
| `AGENTS.md` | **el método entero**: lo que un agente tiene que saber siempre, antes de tocar nada |
| `CLAUDE.md` | diez renglones: importa `AGENTS.md` y agrega sólo lo propio de Claude Code |
| `specs/README.md` | el índice de las decisiones tomadas antes de programar |
| `docs/guia-de-uso.md` | el índice de la guía para quien usa la app |
| `CHANGELOG.md` | qué cambió en cada versión, contado para quien la usa |

Más cuatro carpetas (`specs/`, `docs/guia/`, `docs/superpowers/`, `.claude/`), el
`.mcp.json` apuntando a esta carpeta, la skill `verify` en blanco con sus
preguntas, y la memoria del proyecto arrancada.

### Los tres disparadores

El esqueleto está entero desde el día uno, pero **cada regla dice por escrito qué
la enciende**. Hasta entonces la caja está vacía y lo dice, para que nadie la lea
como un olvido:

| regla | se enciende cuando |
|---|---|
| la guía se escribe en el mismo commit | hay un usuario que **no sos vos** |
| la viñeta del changelog, en el mismo commit | hay una **primera versión distribuible** |
| la spec antes de construir | la primera cosa que necesita **decisiones antes de código** |

---

## `/simple`: decime eso otra vez, pero para mí

Cuando una respuesta te llegó escrita para un ingeniero, en vez de pedir *"volvé a
explicármelo"* escribís `/simple`.

Vuelve a decir **lo mismo** —sin recortar la parte difícil, sin volverla vaga—
pero para el lector que declaraste: cada término traducido la primera vez que
aparece, primero qué significa para vos, y números sólo cuando cambian una
decisión.

## Por qué existe: una regla escrita se pierde

*"Explicame simple"* escrito en un archivo se carga al arrancar la sesión, y
después compite contra todo lo que llega más tarde: las instrucciones de cada
herramienta, la salida de cada comando. Cuando el contexto se comprime, esa frase
vieja es lo primero que se poda.

Por eso no alcanza con escribirla. `/arrancar` deja en el proyecto un recordatorio
de un renglón que se **re-inyecta con cada mensaje**: *"releé Collaboration Style
y Human Language en `AGENTS.md`, y escribí para ESE lector"*.

**Apunta, nunca copia.** No lleva adentro quién sos, dice dónde leerlo. Por eso no
se desactualiza, funciona aunque completes esas secciones tres semanas después, y
sirve igual para cualquier persona: cada proyecto declara su propio lector.

## Qué hace `/cerrar`

Dos mitades:

```
lo que YA está activo   → ¿está hecho?   (guía, changelog, AGENTS.md, memoria)
lo que TODAVÍA NO       → ¿ya se cumplió el disparador? ¿lo encendemos?
```

**La segunda mitad es el punto entero.** La parte que falta del método no depende
de que alguien se acuerde: se pregunta sola en cada cierre.

Y **nunca escribe por su cuenta**. Comprueba, avisa y ofrece. Un cierre que
escribiera memorias solo las fabricaría justo en el momento de menos contexto
disponible — que es exactamente cuando salen mal y encima parecen ciertas.

También **detecta en vez de leer configuración**: mira si existen `docs/guia/`,
`CHANGELOG.md` y el archivo del método. Por eso funciona igual en un proyecto de
hoy y en uno
anterior a que este método existiera.

---

## La memoria

Un hecho por archivo, con una cabecera. Cuatro campos y una regla:

- `titulo:` — el nombre que aparece en el índice.
- `estado:` — `abierto` (alguien tiene que hacer algo) · `vigente` (no leerlo hace
  que un agente se equivoque) · `archivado` (no leerlo sólo cuesta contexto).
- `verificado:` — `humano` · `medido` (se corrió algo y la salida está citada
  adentro) · `no` (lo dijo un agente, nadie comprobó).
- `type:` — `user` · `feedback` · `project` · `reference`.

Y la regla: **el `description:` es la única línea de ruteo.** Contesta "¿abro este
archivo o no?". Nada más. Lo de adentro no se resume ahí.

`MEMORY.md` y `ARCHIVO.md` **se generan, no se editan a mano**:

```bash
python3 memoria/generar-indice.py ~/.claude/projects/<tu-proyecto>/memory
```

Hay **una sola copia** del generador, ésta, para todos los proyectos. Copiarla a
cada uno haría que un arreglo no llegue nunca a los viejos.

Dos propiedades suyas que no hay que romper, las dos probadas de verdad:

1. **Falla hacia el lado seguro.** Sin `estado`, la memoria cae en `vigente`, o
   sea que **entra al índice**. Nunca desaparece por un campo mal escrito.
2. **Sale con código 1** cuando falta un campo, y nombra el archivo. Así `/cerrar`
   se entera sin que nadie lea la salida.

El riesgo real no es que algo pise una cabecera. Es que dentro de dos meses un
agente edite una memoria y borre los tres campos **porque no sabe que existen**.
Una regla escrita no lo evita; una comprobación ruidosa sí.

### Parentesco con OKF

Este formato es primo hermano del **Open Knowledge Format**. Las diferencias son
exactamente dos: acá `type` va **adentro de `metadata:`** (así lo guarda Claude
Code) en vez de suelto en la raíz, y los enlaces entre memorias son `[[dobles
corchetes]]` en vez de enlaces markdown. Si algún día conviene converger, el
cambio ya está identificado y es chico.

---

## El núcleo no nombra ninguna tecnología

El stack entra por **tres costuras, y sólo tres**:

1. `.claude/settings.json` — qué herramientas se encienden y cuáles son ruido.
2. `AGENTS.md` › *Technical Direction* — el stack declarado en palabras.
3. `.claude/skills/verify/` — cómo se prende, se compila y se maneja esta app.

Fuera de esas tres, nombrar una tecnología es un error. Hay una prueba mecánica:

```bash
grep -riE 'svelte|tailwind|react|vue|django|rails|pnpm|npm run|/Users/|/home/' plantillas/ comandos/ \
  | grep -v 'Technical Direction' | grep -v 'skills/verify' | grep -v 'settings.json'
# tiene que dar CERO
```

---

## Dos idiomas, a propósito

Lo que lee **una máquina** (`AGENTS.md`, `CLAUDE.md`, las specs, las skills, los
comandos) va en **inglés**. Lo que lee **una persona** (`docs/guia/`,
`CHANGELOG.md`, este README, la conversación) va en **el idioma del usuario**,
declarado en `CLAUDE.md` de cada proyecto. Declarado, nunca supuesto.

Los comandos se llaman `/arrancar` y `/cerrar` en castellano. Si algún día esto
viaja de verdad, se les agregan alias en inglés y no se rompe nada.

---

## ¿Y si uso otro agente que no es Claude Code?

**El método viaja; la cañería no.** Y eso es a propósito.

Todo lo que importa vive en **`AGENTS.md`** — que es el nombre que Codex, Cursor y
OpenCode ya leen solos. Junto con `specs/`, `docs/guia/`, `CHANGELOG.md` y el
generador de memoria, es markdown y Python: lo abre cualquiera.

`CLAUDE.md` quedó de diez renglones y no lleva método adentro: sólo importa
`AGENTS.md` en su primera línea y agrega lo que **únicamente** existe en Claude
Code. Si los dos alguna vez se contradijeran, gana `AGENTS.md`.

**Un detalle que medí y conviene saber:** Claude Code **no** carga un `AGENTS.md`
suelto. Lo carga a través de ese `@AGENTS.md` de la primera línea del `CLAUDE.md`.
Por eso los dos archivos siguen existiendo — y por eso el archivo del método ahora
entra **cargado** en vez de *pedido*, que es lo que pasaba antes.

Lo que **no** viaja, y no pienso portarlo hasta que haga falta de verdad: los
comandos `/arrancar` y `/cerrar` (aunque son markdown legible, así que cualquier
agente puede abrir el archivo y hacer lo que dice), la memoria y la lista de
complementos apagados.

---

## Qué hay adentro de este repo

```
instalar.sh          paso 1: una vez por computadora
comandos/            /arrancar, /cerrar y /simple (se enlazan a ~/.claude/commands/)
memoria/             el generador del índice y el agregador de recordatorios
plantillas/          las cajas vacías que /arrancar copia
specs/               las decisiones de este paquete (en castellano)
```

## Licencia

MIT — hacé lo que quieras con esto, dejá el aviso de copyright. Ver `LICENSE`.

## Si querés cambiarle algo

Los dos programas de Python tienen prueba:

```bash
python3 memoria/prueba.py
```

Prueba lo que se rompe **en silencio**: que una memoria a la que le falta un campo
no desaparezca del índice, y que el recordatorio no pise hooks ajenos ni se
duplique. Comprobado que no es hueca — rompiendo cada una de esas dos cosas a
propósito, la prueba falla en el renglón que las nombra.

Y el gate a mano de 6 pasos está en `specs/001-el-paquete.md`.
