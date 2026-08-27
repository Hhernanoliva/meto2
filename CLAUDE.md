# meto2 — instrucciones para Claude Code

## Qué es esto

`meto2` empaqueta **el método** con el que se construyó CopyNotes, para arrancar
proyectos nuevos: plantillas vacías, dos comandos (`/arrancar`, `/cerrar`), el
sistema de memoria y un instalador.

**Leé `specs/001-el-paquete.md` antes de tocar nada.** Es la fuente de verdad:
qué viaja y qué no, las dos etapas de instalación, las plantillas archivo por
archivo, el gate a mano de 6 pasos y el plan en 4 tajadas. Estado: escrita y
aprobada, **cero código**.

## Este proyecto NO ES de Svelte, ni de ningún stack

El `~/.claude/CLAUDE.md` global trae reglas de Svelte 5, tiers de animación,
Tailwind y pnpm. **Acá no aplican.** `meto2` es shell + markdown + un script de
Python, y su núcleo es agnóstico del stack a propósito: si una plantilla nombra
una tecnología fuera de las tres costuras declaradas en la spec, está mal.

Sí siguen valiendo del global: explicar en castellano y sin jerga (Hernán no es
ingeniero), y aprobar el plan antes de escribir código.

## CopyNotes es la FUENTE, y es de sólo lectura

`~/Projects/CopyNotes` es de dónde sale el método. Se lee para copiar **la
forma**, nunca el contenido. **No se modifica un solo archivo suyo.**

Piezas que conviene mirar ahí: `AGENT.md` (estructura de secciones),
`specs/README.md`, `docs/guia-de-uso.md`, `.claude/settings.json`,
`.claude/skills/verify/SKILL.md`.

El brief que originó la spec —con el inventario medido y las decisiones que
Hernán ya tomó— está en:
`~/.claude/projects/-Users-hernanoliva-Projects-CopyNotes/memory/copynotes-metodo-portable.md`
La spec manda; el brief explica cómo se llegó.

## Cómo se trabaja acá

- Plan en castellano simple, aprobación de Hernán, después código.
- Commitear a medida que se avanza, no todo junto al final.
- Las tajadas y su criterio de "listo" están en la spec, sección *Plan de construcción*.
