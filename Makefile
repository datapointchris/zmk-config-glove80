# Glove80 ZMK Config Makefile

CONFIG_DIR := config
KEYMAP := $(CONFIG_DIR)/glove80.keymap
LAYOUT := glove80_layout.json
DRAWER_YAML := glove80_keymap.yaml
SVG := glove80_keymap.svg

.PHONY: help align draw build sync clean

help:
	@echo "Glove80 ZMK Config"
	@echo "=================="
	@echo ""
	@echo "Workflows:"
	@echo "  sync    - align + draw + build"
	@echo ""
	@echo "Individual Tasks:"
	@echo "  align   - Align Glove80 keymap"
	@echo "  draw    - Generate SVG from YAML"
	@echo "  build   - Build firmware (outputs: glove80_lh.uf2, glove80_rh.uf2)"
	@echo "  clean   - Remove generated files and UF2s"

align:
	keymap-align --keymap $(KEYMAP) --layout $(LAYOUT)

draw:
	keymap -c keymap_drawer.config.yaml draw $(DRAWER_YAML) > $(SVG)
	@echo "$(SVG) generated"

build:
	./build.sh

sync: align draw build
	@echo "Sync complete"

clean:
	rm -f ./*.uf2 2>/dev/null || true
	@echo "Cleaned"
