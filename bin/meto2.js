#!/usr/bin/env node
// La puerta de entrada de meto2. NO instala nada por su cuenta: trae el repo y
// le pasa el trabajo a instalar.sh, que es lo que ya está probado.
//
// specs/003 > decisión F. Los comandos tienen que seguir siendo ENLACES al
// repo, y por eso el repo tiene que existir en el disco. Un paquete que copiara
// los archivos rompería esa propiedad en silencio.

const { execFileSync, spawnSync } = require("node:child_process");
const { existsSync } = require("node:fs");
const { homedir } = require("node:os");
const { join } = require("node:path");

const ORIGEN = "https://github.com/Hhernanoliva/meto2.git";
const REPO = process.env.METO2_DIR || join(homedir(), "Projects", "meto2");

const salir = (msg, comando) => {
  console.error(`\n${msg}`);
  if (comando) console.error(`\n  ${comando}\n`);
  process.exit(1);
};

const hay = (programa) => {
  try {
    execFileSync("command", ["-v", programa], { shell: true, stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
};

const correr = (cmd, args, opciones = {}) =>
  spawnSync(cmd, args, { stdio: "inherit", ...opciones });

if (!hay("git")) {
  salir("Me falta git para poder traer meto2.", "xcode-select --install");
}

if (existsSync(REPO)) {
  // Antes de tocar una carpeta que ya existe, mirar QUÉ es. Si no es meto2, se
  // frena: pisar la carpeta de otro es peor que no instalar nada.
  const esMeto2 =
    existsSync(join(REPO, "instalar.sh")) &&
    existsSync(join(REPO, "comandos", "arrancar.md"));
  if (!esMeto2) {
    salir(
      `Ya existe ${REPO} y no parece ser meto2, así que no la toco.\n` +
        "Movela o elegí otra carpeta con METO2_DIR:",
      `METO2_DIR=~/otra/carpeta pnpm dlx meto2`
    );
  }
  console.log(`Ya tenías meto2 en ${REPO}. Lo actualizo.`);
  const r = correr("git", ["-C", REPO, "pull", "--ff-only"]);
  if (r.status !== 0) {
    // No se inventa la causa: git ya la imprimió arriba. Acá sólo se dice qué
    // pasa a partir de ahora.
    console.log("\nNo pude actualizarlo. Sigo con la versión que ya tenías.");
  }
} else {
  console.log(`Traigo meto2 a ${REPO}...`);
  const r = correr("git", ["clone", "--depth", "1", ORIGEN, REPO]);
  if (r.status !== 0) salir("No pude traer meto2. ¿Hay internet?");
}

// De acá en adelante manda instalar.sh: las dos preguntas, los enlaces, el
// resumen de tres partes. stdio heredado para que pueda preguntar de verdad.
const inst = correr("bash", [join(REPO, "instalar.sh"), ...process.argv.slice(2)]);
process.exit(inst.status === null ? 1 : inst.status);
