# ZMK Config Makefile
# Provides convenient commands for keymap alignment, testing, and building

PYTHON := python3
ALIGN_SCRIPT := align_keymap.py
CONFIG_DIR := config
TESTS_DIR := tests

CORNE_KEYMAP := $(CONFIG_DIR)/corne.keymap
CORNE_LAYOUT := corne_layout.json
CORNE_DRAWER_YAML := corne_keymap.yaml
CORNE_SVG := corne_keymap.svg
CORNE_JPG := corne_keymap.jpg

GLOVE80_KEYMAP := $(CONFIG_DIR)/glove80.keymap
GLOVE80_LAYOUT := glove80_layout.json
GLOVE80_DRAWER_YAML := glove80_keymap.yaml
GLOVE80_SVG := glove80_keymap.svg
GLOVE80_JPG := glove80_keymap.jpg

PIANTOR_KEYMAP := $(CONFIG_DIR)/piantor_pro_bt.keymap
PIANTOR_LAYOUT := piantor_layout.json
PIANTOR_DRAWER_YAML := piantor_keymap.yaml
PIANTOR_SVG := piantor_keymap.svg
PIANTOR_JPG := piantor_keymap.jpg

TEST_DIR := $(TESTS_DIR)
PYTEST_FILE := $(TESTS_DIR)/test_align_keymap.py

.PHONY: help align-glove80 align-corne align-piantor align sync sync-glove80 sync-corne sync-piantor draw draw-glove80 draw-corne draw-piantor test test-verbose build build-glove80 build-corne build-piantor clean

# Default target - show help
help:
	@echo "ZMK Config Makefile"
	@echo "==================="
	@echo ""
	@echo "Workflows:"
	@echo "  sync           - align + draw + build (all keyboards)"
	@echo "  sync-glove80   - align + draw + build (Glove80)"
	@echo "  sync-corne     - align + draw + build (Corne)"
	@echo "  sync-piantor   - align + draw + build (Piantor)"
	@echo ""
	@echo "Individual Tasks:"
	@echo "  align          - Align all keymaps"
	@echo "  align-glove80  - Align Glove80 keymap"
	@echo "  align-corne    - Align Corne keymap"
	@echo "  align-piantor  - Align Piantor keymap"
	@echo "  draw           - Generate all SVGs from YAML"
	@echo "  draw-glove80   - Generate Glove80 SVG from YAML"
	@echo "  draw-corne     - Generate Corne SVG from YAML"
	@echo "  draw-piantor   - Generate Piantor SVG from YAML"
	@echo "  build          - Build all firmwares"
	@echo "  build-glove80  - Build Glove80 firmware"
	@echo "  build-corne    - Build Corne firmware"
	@echo "  build-piantor  - Build Piantor firmware"
	@echo "  test           - Run test suite"
	@echo "  test-verbose   - Run tests with verbose output"
	@echo "  clean          - Remove temp files and UF2s"

align-glove80:
	$(PYTHON) $(ALIGN_SCRIPT) --keymap $(GLOVE80_KEYMAP) --layout $(GLOVE80_LAYOUT)
	@echo "✅ Glove80 keymap aligned"

align-corne:
	$(PYTHON) $(ALIGN_SCRIPT) --keymap $(CORNE_KEYMAP) --layout $(CORNE_LAYOUT)
	@echo "✅ Corne keymap aligned"

align-piantor:
	$(PYTHON) $(ALIGN_SCRIPT) --keymap $(PIANTOR_KEYMAP) --layout $(PIANTOR_LAYOUT)
	@echo "✅ Piantor keymap aligned"

align: align-glove80 align-corne align-piantor

test:
	@uv run pytest $(PYTEST_FILE) -v

test-verbose:
	@uv run pytest $(PYTEST_FILE) -vvv --tb=long

build: build-glove80 build-corne build-piantor

build-glove80:
	./build glove80
	@echo "✅ Glove80 firmware built"

build-corne:
	./build corne
	@echo "✅ Corne firmware built"

build-piantor:
	./build piantor
	@echo "✅ Piantor firmware built"

draw: draw-glove80 draw-corne draw-piantor

draw-glove80:
	keymap -c keymap_drawer.config.yaml draw $(GLOVE80_DRAWER_YAML) > $(GLOVE80_SVG)
	@echo "✅ $(GLOVE80_SVG)"
	magick $(GLOVE80_SVG) $(GLOVE80_JPG)
	@echo "✅ $(GLOVE80_JPG)"
	 
draw-corne:
	keymap -c keymap_drawer.config.yaml draw $(CORNE_DRAWER_YAML) > $(CORNE_SVG)
	@echo "✅ $(CORNE_SVG)"
	magick $(CORNE_SVG) $(CORNE_JPG)
	@echo "✅ $(CORNE_JPG)"

draw-piantor:
	keymap -c keymap_drawer.config.yaml draw $(PIANTOR_DRAWER_YAML) > $(PIANTOR_SVG)
	@echo "✅ $(PIANTOR_SVG)"
	magick $(PIANTOR_SVG) $(PIANTOR_JPG)
	@echo "✅ $(PIANTOR_JPG)"

clean:
	find . -name "*.pyc" -delete 2>/dev/null || true
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tmp" -delete 2>/dev/null || true
	find . -name "*~" -delete 2>/dev/null || true
	rm -f ./*.uf2 2>/dev/null || true
	@echo "✅ Cleaned"

sync: align draw build
	@echo "✅ Sync complete"

sync-glove80: align-glove80 draw-glove80 build-glove80
	@echo "✅ Glove80 sync complete"

sync-corne: align-corne draw-corne build-corne
	@echo "✅ Corne sync complete"

sync-piantor: align-piantor draw-piantor build-piantor
	@echo "✅ Piantor sync complete"
