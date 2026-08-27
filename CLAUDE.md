# meto2 — instrucciones para Claude Code

## Qué es esto

`meto2` empaqueta **un método de trabajo** para arrancar proyectos nuevos:
plantillas vacías, tres comandos (`/arrancar`, `/cerrar`, `/simple`), el sistema
de memoria y un instalador.

**Leé `specs/001-el-paquete.md` antes de tocar nada.** Es la fuente de verdad:
qué viaja y qué no, las dos etapas de instalación, las plantillas archivo por
archivo, el gate a mano de 6 pasos y las decisiones A–E del final.

## Este proyecto NO ES de ningún stack

Un `~/.claude/CLAUDE.md` global suele traer reglas de una tecnología. **Acá no
aplican.** `meto2` es shell + markdown + dos programas de Python, y su núcleo es
agnóstico del stack **a propósito**: si una plantilla nombra una tecnología fuera
de las tres costuras declaradas en la spec, está mal.

Sí sigue valiendo del global: explicar en castellano y sin jerga (el autor no es
ingeniero), y aprobar el plan antes de escribir código.

## La distinción que decide todo

Lo que viaja es **la forma** (que exista una sección de reglas ganadas a golpes,
que las specs estén numeradas, que la guía se escriba en el mismo commit), no
**el contenido** (las reglas concretas de ningún proyecto). Copiar contenido en
vez de forma es el riesgo N°1 y tiene una prueba mecánica en la spec, sección
*La prueba del núcleo agnóstico*.

## Antes de dar algo por listo

Corré el gate a mano de 6 pasos de la spec, y las dos pruebas de los programas:

```bash
python3 memoria/prueba.py                 # los dos scripts de memoria
grep -riE 'svelte|tailwind|react|vue|django|rails|pnpm|npm run|/Users/|/home/' \
  plantillas/ comandos/ | grep -v 'Technical Direction' | grep -v 'skills/verify' \
  | grep -v 'settings.json'               # tiene que dar CERO
```

## Cómo se trabaja acá

- Plan en castellano simple, aprobación, después código.
- Commitear a medida que se avanza, no todo junto al final.
- Nada se da por bueno sin correrlo. Las decisiones de la spec que dicen
  *"medido"* se midieron; las demás son opiniones y están marcadas como tales.
