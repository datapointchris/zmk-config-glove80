# zmk-config-glove80

ZMK firmware configuration for the MoErgo Glove80 ergonomic keyboard.

## Hardware

- **Board**: glove80_lh / glove80_rh (built-in board definitions)
- **Keys**: 80
- **RGB**: Underglow supported
- **Pointing**: Enabled with smooth scrolling

## Layers

| # | Layer | Notes |
|---|---|---|
| 0 | BASE | QWERTY + home row mods + 8 combos + number row + F-keys |
| 1 | DEVLEFT | Programming symbols (left hand) |
| 2 | DEVRIGHT | Programming symbols (right hand) + arrow nav (left hand) |
| 3 | NPAD | Numpad (right) + media/nav (left) + brightness controls |
| 4 | SYSTEM | Bluetooth, RGB controls, bootloader, media |
| 5 | MOUSE | Mouse movement, scrolling, clicks |
| 6 | NAV | Arrow keys + sticky modifiers |

Uses all 7 shared layers.

## Notable

- Uses **MoErgo ZMK fork** (`moergo-sc/zmk@main`), NOT upstream ZMK
- `magic` behavior: hold for SYSTEM layer, tap for `rgb_ug_status_macro`
- `rgb_ug_status_macro`: shows RGB underglow status
- Full SYSTEM layer with RGB controls (speed, saturation, hue, brightness, effects, toggle)
- 80-key position numbering (non-sequential, see keymap for `KEYS_L`/`KEYS_R`/`THUMBS_L`/`THUMBS_R`)
- Minimal `.conf` — most config is in the built-in board definitions

## Build

```sh
make build    # Build firmware → glove80_lh.uf2, glove80_rh.uf2
make sync     # Align + draw + build
make help     # Show all targets
```

## Ecosystem

See [zmk-shared](https://github.com/datapointchris/zmk-shared) for shared behaviors, layer architecture, and full documentation.
