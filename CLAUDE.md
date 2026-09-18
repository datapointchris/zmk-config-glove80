# Glove80 AI Context

Read `~/code/zmk/shared/CLAUDE.md` first: it holds the shared behaviors, the `zmk` build tool and the guardrails every board follows, and a session here does not load it.

## Keyboard Details

- **80 keys**: non-sequential numbering across left/right halves
- **Key groups**: `KEYS_L` (34 positions), `KEYS_R` (34 positions), `THUMBS_L` (54,53,52,71,70,69), `THUMBS_R` (55,56,57,72,73,74)
- **Two firmwares per half** — compile-time OS switching. `build.yaml` builds each half for Linux and again with `-DOS_MACOS` for macOS. There are no OS_MAC / WM_MAC layers, so the shared runtime-OS-switching guardrail does not apply.

## Layers

Seven layers: BASE (0), COLEMAK (1), DEVLEFT (2), NPAD (3), SYSTEM (4), NAV (5), WM (6).

## Glove80-Specific Behaviors

- `magic`: hold-tap — hold=`&mo SYSTEM`, tap=`&rgb_ug_status_macro`
- `rgb_ug_status_macro`: triggers `&rgb_ug RGB_STATUS`
- SYSTEM layer has full RGB controls (`RGB_EFF/EFR`, `RGB_HUI/HUD`, `RGB_SAI/SAD`, `RGB_BRI/BRD`, `RGB_TOG`)

## Guardrails

- **Must use MoErgo fork** — `config/west.yml` points to `moergo-sc/zmk` at `main`, not `zmkfirmware/zmk`. Changing this breaks the build.
- Position numbering is completely different from 42-key boards — don't copy key positions between Glove80 and Corne/Piantor
- RGB behaviors (`&rgb_ug`) are only available with the MoErgo fork and Glove80 hardware
- No separate half-specific `.conf` files — the single `config/glove80.conf` applies to both halves
