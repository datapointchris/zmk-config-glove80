# Glove80 AI Context

## Ecosystem

All ZMK repos live under `~/code/zmk/`. See `~/code/zmk/shared/CLAUDE.md` for shared behaviors, layer defines, and build tools.

## Key Files

| File | Purpose |
|---|---|
| `config/glove80.keymap` | Keymap with 7 layers, combos, `magic` behavior, RGB macro |
| `config/glove80.conf` | Minimal config (pointing + smooth scrolling) |
| `config/west.yml` | West manifest — pulls zmk-shared + **MoErgo ZMK fork** |
| `build.yaml` | Build matrix: glove80_lh/rh × macOS/Linux (OS-conditional) |
| `Makefile` | align, draw, build, sync, clean |
| `keymap_drawer.config.yaml` | Keymap-drawer config for this keyboard |
| `keymap_align.toml` | Keymap-align config |

## Keyboard Details

- **80 keys**: non-sequential numbering across left/right halves
- **Key groups**: `KEYS_L` (34 positions), `KEYS_R` (34 positions), `THUMBS_L` (54,53,52,71,70,69), `THUMBS_R` (55,56,57,72,73,74)
- **ZMK source**: `moergo-sc/zmk@main` (MoErgo fork, NOT upstream)

## Layers Used

Uses all 7 shared layers: BASE (0), COLEMAK (1), DEVLEFT (2), NPAD (3), SYSTEM (4), NAV (5), WM (6).

## Glove80-Specific Behaviors

- `magic`: hold-tap — hold=`&mo SYSTEM`, tap=`&rgb_ug_status_macro`
- `rgb_ug_status_macro`: triggers `&rgb_ug RGB_STATUS`
- SYSTEM layer has full RGB controls (`RGB_EFF/EFR`, `RGB_HUI/HUD`, `RGB_SAI/SAD`, `RGB_BRI/BRD`, `RGB_TOG`)

## Guardrails

- **Must use MoErgo fork** — `west.yml` points to `moergo-sc/zmk`, not `zmkfirmware/zmk`. Changing this breaks the build.
- Position numbering is completely different from 42-key boards — don't copy key positions between Glove80 and Corne/Piantor
- RGB behaviors (`&rgb_ug`) are only available with the MoErgo fork and Glove80 hardware
- No separate half-specific `.conf` files — the single `glove80.conf` applies to both halves
