# Glove80 AI Context

Read `../shared/CLAUDE.md` (zmk-shared, cloned beside this repo as `shared`) first: it holds the shared behaviors, the `zmk` build tool and the guardrails every board follows, and a session here does not load it.

`README.md` is the reference for this board: the layer table, the combos, the two firmwares per half and the MoErgo fork. `config/glove80.keymap` holds the values. This file keeps only the constraints a change must not break.

## Guardrails

- **Key positions are the Glove80's own, not sequential across halves.** `KEYS_L`, `KEYS_R`, `THUMBS_L` and `THUMBS_R` at the top of `config/glove80.keymap` list them. Never copy positions between this board and Corne/Piantor.
- **A layer's number is its block's position in `keymap`.** The `#define`s at the top only name it, so a new layer goes last. README § "Layers" has the table.
- **The OS is fixed at build time, not switched at runtime.** There are no OS_MAC / WM_MAC layers, so the shared runtime-OS-switching guardrail does not apply. README § "Two firmwares per half" says how `build.yaml` builds both.
- **Must use the MoErgo fork.** `config/west.yml` points at `moergo-sc/zmk`, because the `magic` key binds `RGB_STATUS` and only the fork has it. Changing this breaks the build. README § "The MoErgo fork" has the reason in full.
- **One `.conf` for both halves.** `config/glove80.conf` applies to each, so no half-specific `.conf` files exist.
