---
name: verify
description: How to check the meto2 package end to end — tests, the agnostic grep, and the 6-step manual gate.
---

# Verifying meto2

There is nothing to launch: this package has no runtime. Verifying it means
**generating a project with it and reading what came out**, not reading the
templates.

## The two automatic checks

```bash
python3 memoria/prueba.py          # both Python programs; must exit 0

grep -riE 'svelte|tailwind|react|vue|django|rails|pnpm|npm run|/Users/|/home/' \
  plantillas/ comandos/ | grep -v 'Technical Direction' \
  | grep -v 'skills/verify' | grep -v 'settings.json'
# must give ZERO. The core names no technology outside its three seams.
```

## Driving a command by hand

The commands are markdown; their shell block is what does the work. Extract and
run it against a throwaway folder — **and run it under `zsh`, not only `bash`**:

```bash
awk '/^```bash$/{f=1;next} /^```$/{if(f)exit} f' comandos/arrancar.md > /tmp/a.sh
mkdir -p /tmp/proyecto-prueba && cd /tmp/proyecto-prueba
env -u METO2 zsh /tmp/a.sh
```

`env -u METO2` matters: it forces the command to resolve where the package lives
by following its own symlink, which is what happens on a stranger's machine.

Clean up afterwards, including the memory folder the run creates under
`~/.claude/projects/<slug>/memory`.

## The manual gate

Six steps, in `specs/001-el-paquete.md` › *El gate a mano*. **A person runs it.**
Measured 2026-08-27: the six automatic steps passed while three real defects sat
in the package; all three were found by a person running the commands and
reading the output out loud.

Step 1 (`bash instalar.sh`) downloads software and writes to the machine's global
configuration. Do not run it to "check something" — it is the user's call.

## Gotchas

- **`zsh`, not `bash`.** A glob with no matches is a shell error in zsh, raised
  before `2>/dev/null` can suppress it. Every shell block must be run under zsh
  before it is called done.
- **A heredoc inside a heredoc eats the outer one.** Patching a command file with
  `python3 - <<'PY'` fails silently when the replacement text itself contains a
  `PY` terminator. Write the patch to a file and run it.
- **`claude plugin install` exits 0 on failure.** Ask `claude plugin list`
  afterwards instead.
- **Templates are verified through their output.** Reading `plantillas/AGENTS.md`
  will not reveal a pointer that names the wrong file; generating a project and
  reading it will.
