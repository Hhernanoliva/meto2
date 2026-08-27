---
name: verify
description: How to build, launch, and drive <PROJECT NAME> end-to-end for runtime verification.
---

# Verifying <PROJECT NAME>

> **Starts blank, on purpose.** Fill each section the first time you do that
> thing by hand. Without this file every agent re-discovers how to run the
> project, every session, from scratch — and gets it subtly wrong.
>
> This is one of the three places in this method where a technology may be named.

## Launch

*What single command starts this app for a human to look at? Which port? How long
until it is ready, and what command proves it is ready (not just that the process
started)?*

```bash
# command here
```

## Build

*What command produces the real artifact? How long does it take? What does a
successful build print, and where does the output land?*

```bash
# command here
```

## Drive (end to end)

*How does an agent operate this app without a human — the test runner, the
browser driver, the CLI harness? Is it already a project dependency, or does it
need a one-time install? Where do the driving scripts live?*

```bash
# command here
```

## Gotchas

*Empty until something bites. Each entry: what looks broken, what is actually
happening, and the command that tells them apart. Timing traps, seeded state,
stale servers, ports that move on their own, two things matching the same
selector — the things that cost an hour once and would cost an hour again.*
