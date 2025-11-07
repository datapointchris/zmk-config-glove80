# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal ZMK firmware configuration repository for custom mechanical keyboards (Corne 42-key and Glove80 80-key). Includes automated keymap alignment, visual generation, and firmware building.

## Common Commands

### Complete Workflows
```bash
make sync              # align → draw → build (both keyboards)
make sync-glove80      # Complete workflow for Glove80 only
make sync-corne        # Complete workflow for Corne only
```

### Individual Operations
```bash
# Alignment
make align             # Align both keymaps
make align-glove80     # Align Glove80 keymap
make align-corne       # Align Corne keymap

# Visual Generation
make draw              # Generate SVG diagrams for both keyboards
make draw-glove80      # Generate Glove80 SVG
make draw-corne        # Generate Corne SVG

# Firmware Building
make build             # Build firmware for both keyboards
make build-glove80     # Build Glove80 firmware (outputs: glove80.uf2)
make build-corne       # Build Corne firmware (outputs: corne_left.uf2, corne_right.uf2)

# Testing
make test              # Run test suite
make test-verbose      # Run tests with detailed output
uv run pytest tests/test_align_keymap.py::test_name -v  # Run specific test

# Cleanup
make clean             # Remove generated files and UF2s
```

### Build Script (Direct)
```bash
./build.sh [KEYBOARD] [BRANCH]
# Examples:
./build.sh                # Build both keyboards
./build.sh glove80        # Build Glove80 with main branch
./build.sh glove80 beta   # Build Glove80 with beta branch
./build.sh corne          # Build Corne
```

### Manual Keymap Parsing (for YAML updates)
```bash
# Parse .keymap → YAML (run manually after keymap changes)
keymap -c keymap_drawer.config.yaml parse -c 12 -z config/corne.keymap > corne_keymap.yaml
keymap -c keymap_drawer.config.yaml parse -c 12 -z config/glove80.keymap > glove80_keymap.yaml
```

## Code Architecture

### Repository Structure
```
config/
├── glove80.keymap          # Glove80 keymap (80 keys)
├── corne.keymap            # Corne keymap (42 keys)
├── shared_behaviors.dtsi   # Shared custom behaviors (home row mods, layer taps)
├── *.conf                  # Board configurations
└── west.yml                # ZMK dependencies

align_keymap.py             # Python script for keymap alignment
*_layout.json               # Physical keyboard layout definitions (JSON)
*_keymap.yaml               # keymap-drawer intermediate files (manual edit)
*_keymap.svg                # Generated visual diagrams
build.sh                    # Docker-based firmware build wrapper
Makefile                    # Build automation orchestration
```

### Core Components

**1. Keymap Alignment System (`align_keymap.py`)**
- Parses ZMK keymap files and aligns bindings according to JSON layout definitions
- Handles complex behaviors (home row mods, layer-taps, nested behaviors)
- Calculates optimal column widths for physical keyboard alignment
- Input: `.keymap` file + `*_layout.json`
- Output: Properly aligned `.keymap` file (in-place modification)

**2. Layout Definitions (`*_layout.json`)**
- Define physical keyboard matrix (key positions vs. empty spaces)
- Format: 2D array where "X" = key position, "-" = empty space
- Used by alignment script to determine column structure
- Examples: `corne_layout.json`, `glove80_layout.json`

**3. Shared Behaviors (`config/shared_behaviors.dtsi`)**
- Custom ZMK behaviors shared across all keyboards
- **Home row mods**: `&hml`, `&hmr`, `&hmlt`, `&hmrt` (mod-tap with positional holds)
- **Layer taps**: `&ltl`, `&ltr`, `&ltlt`, `&ltrt` (layer-tap with positional holds)
- **Tap dances**: `&bt_0` through `&bt_3` (Bluetooth pairing), `&caps_shift`, `&caps_aero`
- **Macros**: `bt_select_*`, `ctrlaltdel`
- Key positions defined per keyboard using `KEYS_L`, `KEYS_R`, `THUMBS_L`, `THUMBS_R` macros

**4. Visual Generation (keymap-drawer)**
- Generates SVG diagrams from YAML intermediate files
- Parse step is **manual** (run after keymap changes to update YAML)
- Draw step is **automated** (preserves manual YAML formatting)
- Configuration: `keymap_drawer.config.yaml` (custom behavior mappings)
- Column specification: `-c 12` for both keyboards (6 columns × 2 halves)

**5. Build System**
- **Glove80**: Docker-based Nix build using MoErgo's custom ZMK fork
- **Corne**: Standard ZMK build with official Docker container
- **Controllers**: Glove80 (integrated), Corne (nice!nano v2 with nice!view displays)
- **Output**: UF2 files for direct flashing to keyboards

### Key Position Definitions

Each keymap defines macros for home row mod and layer tap positional holds:

**Glove80 (80 keys):**
```c
#define KEYS_L 4 3 2 1 0 14 13 12... // 34 left-hand keys
#define KEYS_R 5 6 7 8 9 16 20 19... // 34 right-hand keys
#define THUMBS_L 54 53 52 71 70 69   // 6 left thumb keys
#define THUMBS_R 55 56 57 72 73 74   // 6 right thumb keys
```

**Corne (42 keys):**
```c
#define KEYS_L 0 1 2 3 4 5 12 13...  // 18 left-hand keys
#define KEYS_R 6 7 8 9 10 11 18 19... // 18 right-hand keys
#define THUMBS_L 36 37 38            // 3 left thumb keys
#define THUMBS_R 39 40 41            // 3 right thumb keys
```

These definitions are used by hold-tap behaviors to enable opposite-hand activation only.

### Workflow Pipeline

Standard development workflow:
1. **Edit keymap** in `config/*.keymap`
2. **Align keymap**: `make align` (or `align-glove80`, `align-corne`)
3. **Test changes**: `make test` (validates binding counts and alignment)
4. **Parse to YAML** (manual, only if visual needs updating): `keymap parse -c 12 -z config/corne.keymap > corne_keymap.yaml`
5. **Generate SVG**: `make draw` (automated, preserves YAML formatting)
6. **Build firmware**: `make build` (Docker-based compilation)
7. **Flash firmware**: Copy `*.uf2` files to keyboard bootloader drive

### Testing Framework

**Test Structure:**
```
tests/
├── test_align_keymap.py    # Main test suite (pytest)
├── layouts/                # Test layout definitions
├── simple_tests/           # Basic test cases
└── test_keymaps/
    ├── correct/            # Reference files (hand-aligned)
    ├── misaligned/         # Test input files
    └── test_output/        # Generated test outputs
```

**Test Coverage:**
- Layout loading and JSON validation
- Binding extraction (simple, multi-parameter, nested behaviors)
- Alignment formatting and column width calculation
- Binding count validation with detailed error messages
- End-to-end integration tests (byte-for-byte comparison with reference files)

**Running Tests:**
```bash
make test                   # Full suite
make test-verbose           # Detailed output
uv run pytest tests/test_align_keymap.py::TestClass::test_method -v  # Specific test
```

## Development Guidelines

### Python Environment
- Always use virtual environment: `.venv/` exists in the repo
- Use `uv run` prefix for Python commands (e.g., `uv run pytest`)
- Python version: 3.7+

### Modifying Keymaps
- Use ZMK devicetree syntax (`.keymap` files are C preprocessor + devicetree)
- Leverage shared behaviors from `shared_behaviors.dtsi`
- After editing, always run `make align` before committing
- Run `make test` to validate binding counts match layout definitions
- Update visual diagrams with `make draw` if desired

### Adding New Behaviors
- Define in `config/shared_behaviors.dtsi` for cross-keyboard reuse
- Or define locally in specific `*.keymap` file if keyboard-specific
- Update `keymap_drawer.config.yaml` if custom behavior needs visual representation
- Add to `MULTI_PARAM_BEHAVIORS` in `align_keymap.py` if behavior takes multiple parameters

### Build System Notes
- **Docker required** for firmware compilation
- Glove80 uses Moergo's custom ZMK fork (different from standard ZMK)
- Corne build expects ZMK source at `/Users/chris/code/zmk` (will clone if missing)
- Build outputs are `.uf2` files (gitignored, not committed)
- GitHub Actions build is disabled (see `build.yaml` comment in README)

### Alignment Script Behavior
- **In-place modification**: Overwrites `.keymap` file directly
- Preserves all content outside `bindings = <...>;` blocks
- Handles complex binding types:
  - Simple: `&kp A`, `&trans`, `&none`
  - Multi-param: `&hml LCTRL A`, `&lt 1 SPACE`
  - Nested: `&hmr &caps_word RALT`
- Validates binding count matches layout definition
- Provides detailed error messages for mismatches (expected vs. actual counts)

### Visual Generation Workflow
- **Two-step process**: Parse (manual) → Draw (automated)
- **Parse step** (`keymap parse`): Convert `.keymap` → `.yaml` (run after keymap changes)
- **Draw step** (`make draw`): Convert `.yaml` → `.svg` (run anytime, preserves YAML)
- **Why manual parse?** Allows hand-editing YAML for custom visual formatting
- Column spec `-c 12` used for both keyboards (6 columns per half × 2 = 12 total)

## Important Notes

- **Never skip errors** - Always fix or document them immediately
- **Minimal emoji usage** - Only ✅ and ❌ for pass/fail, avoid decorative emojis
- **No emojis in commit messages**
- **Use lowercase naming** for docs/ files
- Virtual environment exists at `.venv/` - use for all Python operations
- ZMK uses devicetree syntax, not standard C
- Home row mod timings are critical - test thoroughly on actual hardware
- Binding count must exactly match layout definition (alignment script validates this)
