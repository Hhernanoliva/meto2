#!/usr/bin/env python3
"""Genera MEMORY.md y ARCHIVO.md desde las cabeceras de las memorias.

Uso:  generar-indice.py <carpeta-de-memoria>

Una sola copia para todos los proyectos: vive en meto2/memoria/ y recibe la
carpeta como argumento. No editar MEMORY.md a mano: se pisa en la proxima corrida.
"""
import io, os, re, glob, sys

if len(sys.argv) < 2:
    print('uso: generar-indice.py <carpeta-de-memoria>')
    sys.exit(2)
HERE = os.path.abspath(os.path.expanduser(sys.argv[1]))
if not os.path.isdir(HERE):
    print('no existe la carpeta de memoria: %s' % HERE)
    sys.exit(2)

# El nombre del proyecto NO se deduce del slug: la carpeta ya dice de quien es.

def campo(head, clave):
    m = re.search(r'^\s*%s:\s*(.*?)\s*$' % clave, head, re.M)
    if not m:
        return ''
    v = m.group(1)
    if len(v) > 1 and v[0] == v[-1] == '"':
        v = v[1:-1]
    return v

memorias = []
incompletas = []
for ruta in sorted(glob.glob(os.path.join(HERE, '*.md'))):
    nombre = os.path.basename(ruta)
    if nombre in ('MEMORY.md', 'ARCHIVO.md'):
        continue
    s = io.open(ruta, encoding='utf-8').read()
    if not s.startswith('---\n'):
        print('sin cabecera, salteada:', nombre); continue
    head = s[4:].split('\n---\n', 1)[0]
    faltan = [k for k in ('titulo', 'estado', 'verificado') if not campo(head, k)]
    if faltan:
        incompletas.append((nombre, faltan))
    memorias.append({
        'archivo': nombre,
        'titulo': campo(head, 'titulo') or nombre[:-3],
        'desc': campo(head, 'description'),
        # sin estado cae a 'vigente' = ENTRA al indice: falla hacia el lado seguro
        'estado': campo(head, 'estado') or 'vigente',
        'verificado': campo(head, 'verificado') or 'no',
        'tipo': campo(head, 'type'),
    })

def bullet(m):
    marca = ' ⚠️ SIN VERIFICAR' if m['verificado'] == 'no' else ''
    return '- [%s](%s) — %s%s' % (m['titulo'], m['archivo'], m['desc'], marca)

abierto   = [m for m in memorias if m['estado'] == 'abierto']
metodo    = [m for m in memorias if m['estado'] == 'vigente' and m['tipo'] in ('feedback', 'user')]
producto  = [m for m in memorias if m['estado'] == 'vigente' and m['tipo'] not in ('feedback', 'user')]
archivado = [m for m in memorias if m['estado'] == 'archivado']
for g in (abierto, metodo, producto, archivado):
    g.sort(key=lambda m: m['titulo'].lower())

out = ['# Memoria del proyecto',
       '',
       '**Generado por `generar-indice.py`. No editar a mano** — se pisa en la próxima corrida.',
       'Cada renglón sale del `titulo:` y el `description:` de su archivo; la sección, del `estado:`.',
       '',
       '## Pendientes vivos — alguien tiene que hacer algo', '']
out += [bullet(m) for m in abierto]
out += ['', '## Reglas y estado del producto — esto todavía muerde', '']
out += [bullet(m) for m in producto]
out += ['', '## Cómo trabajar acá', '']
out += [bullet(m) for m in metodo]
# Un cartel fuera del indice cargado no rutea a nadie: los archivados que llevan
# uno se quedan aca, con el cartel solo y sin el resto de la descripcion.
def cartel(m):
    c = re.match(r'((?:EMPEZAR ACÁ|LEER ANTES|LEER)\b[^:;]*)', m['desc'])
    return c.group(1).strip() if c else None

con_cartel = [m for m in archivado if cartel(m)]
out += ['', '## Archivo', '',
        '%d memorias de trabajo ya terminado viven en **[ARCHIVO.md](ARCHIVO.md)** —'
        ' no leerlas cuesta contexto, no correcciones. Abrirlo sólo si la tarea toca esa zona.'
        % len(archivado), '']
if con_cartel:
    out += ['Las que igual hay que saber encontrar:', '']
    out += ['- [%s](%s) — %s' % (m['titulo'], m['archivo'], cartel(m)) for m in con_cartel]
    out += ['']

arch = ['# Archivo de memoria', '',
        '**Generado por `generar-indice.py`. No editar a mano.** Trabajo terminado:',
        'no leer esto cuesta contexto, no correcciones. El índice vivo es [MEMORY.md](MEMORY.md).',
        '']
arch += [bullet(m) for m in archivado]
arch += ['']
io.open(os.path.join(HERE, 'ARCHIVO.md'), 'w', encoding='utf-8').write('\n'.join(arch))

destino = os.path.join(HERE, 'MEMORY.md')
io.open(destino, 'w', encoding='utf-8').write('\n'.join(out))
print('MEMORY.md %d bytes  |  ARCHIVO.md %d bytes  |  %d memorias'
      % (os.path.getsize(destino), os.path.getsize(os.path.join(HERE,'ARCHIVO.md')), len(memorias)))
print('  abierto %d | producto %d | método %d | archivado %d'
      % (len(abierto), len(producto), len(metodo), len(archivado)))

if incompletas:
    print('\n  ATENCION: %d memoria(s) con campos faltantes.' % len(incompletas))
    print('  Se usaron valores por defecto. Completar y volver a generar:')
    for nombre, faltan in incompletas:
        print('    %-52s falta: %s' % (nombre, ', '.join(faltan)))
    sys.exit(1)
