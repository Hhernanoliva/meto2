#!/usr/bin/env python3
"""Agrega un hook UserPromptSubmit a un settings.json, sin pisar lo que ya hay.

Uso:  agregar-hook.py <ruta-settings.json> <texto-del-recordatorio>

Idempotente: si el mismo recordatorio ya está, no lo duplica. Nunca borra hooks
ajenos ni ninguna otra clave del archivo.
"""
import io, json, os, sys

if len(sys.argv) < 3:
    print('uso: agregar-hook.py <settings.json> <texto>')
    sys.exit(2)

ruta, texto = sys.argv[1], sys.argv[2]

if os.path.exists(ruta):
    with io.open(ruta, encoding='utf-8') as f:
        datos = json.load(f)          # un JSON roto ES un error: mejor fallar que pisar
else:
    datos = {}

grupos = datos.setdefault('hooks', {}).setdefault('UserPromptSubmit', [])

# La huella es un tramo del texto, no el comando entero: así una corrección de
# redacción no deja dos recordatorios diciendo casi lo mismo.
huella = texto[:40]
ya_esta = any(huella in h.get('command', '')
              for g in grupos for h in g.get('hooks', []))

if not ya_esta:
    grupos.append({'hooks': [{'type': 'command',
                              'command': 'echo ' + json.dumps(texto),
                              'timeout': 5}]})

with io.open(ruta, 'w', encoding='utf-8') as f:
    f.write(json.dumps(datos, indent=2, ensure_ascii=False) + '\n')

print('ya estaba, no lo dupliqué' if ya_esta else 'recordatorio agregado')
