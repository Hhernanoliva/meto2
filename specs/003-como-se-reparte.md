# 003 - Cómo se reparte meto2: un comando en vez de dos

Escrita el 2026-08-28, después de ver a la primera usuaria que no es el autor
instalar el paquete y tropezar **antes** de llegar al instalador.

> **Estado: decidida, sin construir.** Las tres decisiones de abajo están
> tomadas. Lo que falta es hacerlo, y el gate está escrito al final.
>
> Esta spec no reemplaza nada de `001`: el instalador, los comandos, las
> plantillas y los enlaces siguen exactamente igual. Lo único que cambia es
> **la puerta de entrada**.

## En criollo

Hoy instalar `meto2` son dos comandos: traer el repo con `git clone` y después
correr el instalador. Suena poco. En la práctica, la primera persona ajena al
autor se equivocó tres veces en el medio —entró a una carpeta que no existía,
escribió *Proyects* con y griega, buscó `meto2` donde no estaba— y todo eso pasó
**antes** de que el instalador llegara a hacer nada.

La idea es que sea **un solo comando**. La persona escribe una línea, y de ahí en
adelante todo es idéntico a hoy.

## Objetivo

Que instalar `meto2` cueste **una línea**, sin perder ninguna de las propiedades
que `001` ya se ganó — sobre todo la de los enlaces, que es la que hace que un
arreglo llegue solo a todos los proyectos.

## No-objetivos

- **No** reemplazar `git clone`. Sigue siendo el camino de quien toca el código.
  Son dos puertas para dos personas distintas, no una que jubila a la otra.
- **No** tocar `instalar.sh` por dentro, ni los comandos, ni las plantillas.
  Todo lo que ya está probado sigue igual. Sólo cambia cómo se llega.
- **No** publicar todavía. Publicar es la tajada 3 y tiene su propio gate.

## Lo que se midió (2026-08-28, en la máquina del autor)

### `pnpm` no puede instalar Python, y no es una limitación: es una defensa

Para que un paquete instale otra cosa durante su instalación hace falta un
*script de postinstalación*. **`pnpm` los bloquea por defecto desde su versión
10**, y en la 11 el ajuste `strictDepBuilds` viene en `true`, o sea que la
instalación **falla** si un paquete lo intenta.

El motivo declarado por ellos es la cadena de suministro: ese mecanismo es por
donde entran los ataques. Coincide con la regla de `001` › *Instalación*:
*se dice qué se va a bajar y de dónde, y se espera el sí*. Instalar un lenguaje
entero en la máquina de alguien sin preguntarle es lo contrario.

**Consecuencia:** la idea de que el instalador de npm resuelva el requisito de
Python queda descartada por imposible, no por gusto.

### JavaScript **no** es más rápido que Python para estas tareas

Medido con 20 corridas de cada uno:

| | encender y no hacer nada | el generador de memoria, de verdad |
|---|---|---|
| `python3` | **16 ms** | **32 ms** |
| `node` | **31 ms** | ~47 ms (proyectado) |

`/arrancar` llama a `python3` **6 veces** y `/cerrar` **4**. Pasar todo a
JavaScript le sumaría ~90 ms y ~60 ms respectivamente.

**Los dos son instantáneos para una persona, y el más rápido es Python.** Queda
escrito porque la intuición dice lo contrario, y una spec que no lo dijera
dejaría a alguien tomando la decisión por el motivo equivocado dentro de seis
meses.

### El tamaño de lo que habría que reescribir

`generar-indice.py` 111 renglones · `agregar-hook.py` 39 · `prueba.py` 111.
**261 en total.** Poco, pero son los únicos programas de verdad del paquete, y
`agregar-hook.py` es la **zona de riesgo alto N°3** de `AGENTS.md` porque escribe
adentro del archivo de configuración de otra persona.

## Decisiones que esta spec toma

Continúan la serie A–E de `001`.

### F · Se alquila el instalador; el instalador deja puesto lo que tiene que quedar

`pnpm dlx meto2` baja el instalador, lo corre, y **el instalador hace exactamente
lo que hace hoy** — incluido traerse el repo y dejar los tres comandos como
enlaces.

Es la forma que consigue lo que se busca cambiando lo mínimo:

- Para quien instala: **dos comandos pasan a ser uno**, y desaparece con ellos
  todo el tropiezo de carpetas que se midió arriba.
- Para el autor: **no cambia nada**. Los enlaces siguen siendo enlaces, así que
  se arregla el repo y el arreglo sigue activo al instante en todos los
  proyectos. `001` › *Estructura* llama a eso una propiedad de diseño, y se
  conserva entera.

Descartadas, y por qué:

- **Que el paquete de npm contenga todo y copie los archivos.** Los comandos
  pasarían a ser copias y se perdería la propiedad de arriba. El costo cae
  justo sobre la persona que más lo usa.
- **`pnpm add -g` (instalarlo para siempre).** `meto2` se corre **una vez por
  computadora**. Un programa que se usa una vez no tiene por qué quedarse a
  vivir en la máquina, y encima envejece: se actualiza el día que alguien se
  acuerde de pedírselo.

### G · Node se acepta como requisito, y se escribe como decisión

Quien usa estos agentes casi seguro ya tiene Node: **Claude Code y OpenCode se
reparten los dos por npm**. Pedirlo agrega poco.

Queda escrito como decisión y no como obviedad, porque es una suposición sobre
el público y no un hecho. El propio `meto2` es la prueba de que existen proyectos
sin Node: es bash, markdown y Python.

### H · Python: se comprueba ahora, se saca cuando moleste de verdad

Dos etapas, con el disparador escrito para no discutirlo de nuevo.

**Ahora (hecho el 2026-08-28):** el instalador comprueba `python3` en su bloque
de chequeos previos y, si falta, frena en el primer segundo y da el comando
exacto. En macOS la cura es `xcode-select --install`, que ya trae Python.

**Después:** reescribir los dos programas y su prueba en JavaScript, y entonces
`meto2` deja de necesitar Python. La cuenta que lo justifica **no es velocidad**
—eso quedó medido y es falso— sino que hoy hacen falta **dos** cosas (Node para
instalar, Python para funcionar) y así haría falta **una**.

**El disparador: cuando a una persona de verdad le falte Python y le cueste
conseguirlo.** No antes. Motivos, en orden de peso:

1. El beneficio es comodidad de instalación, y la comodidad se arregla el día
   que a alguien le molesta. Hasta entonces es una molestia supuesta.
2. Se reescribe la única red del paquete. Mientras la prueba no esté portada,
   los 261 renglones no tienen quién los cuide.
3. Es `AGENTS.md` › *Nada se afirma sin correrlo*, aplicado a una decisión de
   diseño en vez de a un resultado.

## Lo que NO cambia, y conviene tenerlo a la vista

- `instalar.sh`, por dentro: igual.
- Los tres comandos y sus enlaces: igual.
- Las plantillas: igual. El `grep` del núcleo agnóstico las sigue cubriendo.
- El sistema de memoria: igual.
- `git clone` + `bash instalar.sh`: **sigue funcionando y sigue documentado.**

## Riesgos

- **Un error tuyo llega a todos, al instante.** Es la contracara de que `dlx`
  traiga siempre lo último: hoy una versión rota queda encerrada en la máquina
  del autor hasta que alguien haga `git pull`; con esto, no. No es motivo para
  no hacerlo — es el motivo por el que **la etiqueta de versión y el changelog
  dejan de ser opcionales** y pasan a ser parte del proceso de publicar.
- **Un `package.json` es una puerta abierta a las dependencias.** Hoy no hay
  ninguna y la *Technical Direction* lo prohíbe. Tener el archivo hace que
  agregar una cueste un renglón. Se ataca donde ya se atacan estas cosas en este
  paquete: con una comprobación ruidosa, no con una regla escrita — el gate
  falla si `package.json` declara una sola dependencia.
- **Que "se reparte por npm" se lea como "es un proyecto de JavaScript".** El
  paquete sigue sin nombrar tecnologías adentro. Hay que decirlo en el README,
  porque es exactamente el malentendido que el riesgo N°1 de `001` describe.

## Lo que hay que precisar en `AGENTS.md`

*Technical Direction* dice hoy: **"sin dependencias, sin gestor de paquetes, sin
paso de compilación"**. Con esta spec esa frase queda a medias cierta y hay que
partirla en dos, no borrarla:

- **Lo que el paquete contiene:** sigue siendo bash, markdown y Python 3 de la
  biblioteca estándar. Sin dependencias y sin compilación. **Intacto.**
- **Cómo se reparte:** npm es una de las dos puertas. Eso es distribución, no
  contenido.

Escribirlo así, y no borrar la regla, es lo que evita que dentro de seis meses
alguien la lea como permiso para agregar una dependencia.

## El gate de esta spec

1. `pnpm dlx` desde una carpeta cualquiera deja el paquete instalado y los tres
   comandos disponibles, **en una máquina que no es la del autor**.
2. Después de eso, `git pull` en el repo traído sigue actualizando los comandos
   al instante. Si esto falla, se perdió la propiedad de los enlaces y la
   decisión F no se cumplió.
3. `git clone` + `bash instalar.sh` sigue funcionando igual que antes.
4. `package.json` declara **cero** dependencias, y hay una comprobación que
   falla si alguien agrega una.
5. Los 6 pasos del gate de `001` vuelven a pasar. Esta spec no toca su código,
   así que si alguno se rompe, se rompió por la puerta nueva.

## Plan de construcción

| tajada | qué entra | listo cuando |
|---|---|---|
| **1** | `package.json` mínimo y el arranque que trae el repo y corre el instalador | pasos 1 a 4 del gate |
| **2** | el README con las dos puertas, y `AGENTS.md` › *Technical Direction* partido en contenido y distribución | se lee y no se malinterpreta |
| **3** | publicar: etiqueta de versión, changelog cerrado, y la primera publicación | paso 5 |
| **4** | *(disparador H)* los dos programas y su prueba en JavaScript | cuando a alguien le falte Python de verdad |
