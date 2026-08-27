#!/usr/bin/env python3
"""Prueba de los dos programas de memoria.  Correr:  python3 memoria/prueba.py

No prueba todo: prueba lo que, si se rompe, se rompe EN SILENCIO. Una memoria
que desaparece del índice y un recordatorio que pisa hooks ajenos no avisan.
"""
import io, json, os, shutil, subprocess, sys, tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
GENERAR = os.path.join(AQUI, 'generar-indice.py')
AGREGAR = os.path.join(AQUI, 'agregar-hook.py')


def correr(script, *args):
    r = subprocess.run([sys.executable, script] + list(args),
                       capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


def memoria(carpeta, nombre, **campos):
    cab = ['---', 'name: ' + nombre[:-3], 'description: ' + campos.pop('desc', 'una descripcion'),
           'metadata:']
    cab += ['  %s: %s' % (k, v) for k, v in campos.items()]
    cab += ['---', '', 'cuerpo', '']
    io.open(os.path.join(carpeta, nombre), 'w', encoding='utf-8').write('\n'.join(cab))


def prueba_generador():
    d = tempfile.mkdtemp()
    try:
        memoria(d, 'viva.md', type='project', titulo='Viva', estado='vigente', verificado='humano')
        code, salida = correr(GENERAR, d)
        assert code == 0, 'una memoria completa no debe fallar: ' + salida
        indice = io.open(os.path.join(d, 'MEMORY.md'), encoding='utf-8').read()
        assert 'Viva' in indice, 'la memoria vigente tiene que estar en el indice'

        # LA propiedad que importa: sin `estado` no desaparece, y ademas grita.
        memoria(d, 'rota.md', type='project', titulo='Rota', verificado='humano')
        code, salida = correr(GENERAR, d)
        assert code == 1, 'falta un campo: tiene que salir con codigo 1'
        assert 'rota.md' in salida, 'tiene que NOMBRAR el archivo incompleto'
        indice = io.open(os.path.join(d, 'MEMORY.md'), encoding='utf-8').read()
        assert 'Rota' in indice, 'sin estado cae en vigente: NUNCA desaparece del indice'

        # Lo archivado sale del indice vivo y va al otro archivo.
        os.remove(os.path.join(d, 'rota.md'))
        memoria(d, 'vieja.md', type='project', titulo='Vieja', estado='archivado', verificado='humano')
        code, _ = correr(GENERAR, d)
        assert code == 0
        indice = io.open(os.path.join(d, 'MEMORY.md'), encoding='utf-8').read()
        archivo = io.open(os.path.join(d, 'ARCHIVO.md'), encoding='utf-8').read()
        assert 'Vieja' not in indice, 'lo archivado no va al indice vivo'
        assert 'Vieja' in archivo, 'lo archivado va a ARCHIVO.md'

        # Lo que nadie comprobo se marca a la vista.
        memoria(d, 'dudosa.md', type='project', titulo='Dudosa', estado='vigente', verificado='no')
        correr(GENERAR, d)
        indice = io.open(os.path.join(d, 'MEMORY.md'), encoding='utf-8').read()
        assert 'SIN VERIFICAR' in indice, 'verificado:no tiene que quedar marcado'

        code, salida = correr(GENERAR, os.path.join(d, 'no-existe'))
        assert code == 2, 'una carpeta que no existe es un error de uso, no un indice vacio'
    finally:
        shutil.rmtree(d)
    print('  ok  generar-indice.py')


def prueba_hook():
    d = tempfile.mkdtemp()
    try:
        ruta = os.path.join(d, 'settings.json')
        texto = 'Antes de contestar: lee para quien escribis, y escribi para esa persona.'

        # Sobre un archivo que ya tiene cosas: no se pierde ninguna.
        io.open(ruta, 'w', encoding='utf-8').write(json.dumps({
            'model': 'opus',
            'hooks': {'SessionStart': [{'hooks': [{'type': 'command', 'command': 'echo ajeno'}]}]},
        }))
        code, _ = correr(AGREGAR, ruta, texto)
        assert code == 0
        d1 = json.load(io.open(ruta, encoding='utf-8'))
        assert d1['model'] == 'opus', 'no puede perder otras claves'
        assert 'SessionStart' in d1['hooks'], 'no puede pisar hooks ajenos'
        assert len(d1['hooks']['UserPromptSubmit']) == 1

        # Dos veces seguidas no deja dos recordatorios.
        correr(AGREGAR, ruta, texto)
        d2 = json.load(io.open(ruta, encoding='utf-8'))
        assert len(d2['hooks']['UserPromptSubmit']) == 1, 'tiene que ser idempotente'

        # Un settings.json que todavia no existe se crea.
        nuevo = os.path.join(d, 'sub', 'settings.json')
        os.makedirs(os.path.dirname(nuevo))
        code, _ = correr(AGREGAR, nuevo, texto)
        assert code == 0 and os.path.exists(nuevo)

        # Un JSON roto NO se pisa: mejor fallar que borrarle la configuracion a alguien.
        roto = os.path.join(d, 'roto.json')
        io.open(roto, 'w', encoding='utf-8').write('{ esto no es json')
        code, _ = correr(AGREGAR, roto, texto)
        assert code != 0, 'un JSON roto tiene que fallar, no sobrescribirse'
        assert io.open(roto, encoding='utf-8').read() == '{ esto no es json', 'y quedar intacto'
    finally:
        shutil.rmtree(d)
    print('  ok  agregar-hook.py')


if __name__ == '__main__':
    prueba_generador()
    prueba_hook()
    print('todo bien')
