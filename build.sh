#!/bin/bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

KEYBOARD="glove80"
DOCKER_IMAGE="zmkfirmware/zmk-build-arm:3.5-branch"
CONTAINER_NAME="zmk-build-${KEYBOARD}"
WORKSPACE="/workspaces/zmk-config"

echo -e "${BLUE}Building Glove80 firmware...${NC}"

if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker not found.${NC}"
    exit 1
fi

ZMK_CONFIG_PATH="$(pwd)"

# Check timestamps before build
lh_old_ts=""
rh_old_ts=""
if [ -f "glove80_lh.uf2" ]; then
    lh_old_ts=$(stat -c "%Y" glove80_lh.uf2)
fi
if [ -f "glove80_rh.uf2" ]; then
    rh_old_ts=$(stat -c "%Y" glove80_rh.uf2)
fi

# Remove any previous container with the same name
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo -e "${YELLOW}Building with Docker...${NC}"

docker run --name "$CONTAINER_NAME" --rm \
  -v "$ZMK_CONFIG_PATH":"$WORKSPACE" \
  -w "$WORKSPACE" \
  "$DOCKER_IMAGE" \
  /bin/bash -c "
    # Initialize west workspace (cached between runs)
    if [ ! -f .west/config ]; then
      echo 'Initializing west workspace...'
      west init -l config/
      west update
    elif [ \"\${FORCE_UPDATE:-}\" = 1 ]; then
      echo 'Forcing west update...'
      west update
    fi

    export ZEPHYR_BASE=${WORKSPACE}/zephyr

    echo 'Building Glove80 left half...'
    west build -s zmk/app -d build/glove80_lh -b glove80_lh -- \
      -DZMK_CONFIG=${WORKSPACE}/config \
      -DZephyr_DIR=${WORKSPACE}/zephyr/share/zephyr-package/cmake
    cp build/glove80_lh/zephyr/zmk.uf2 ${WORKSPACE}/glove80_lh.uf2

    echo 'Building Glove80 right half...'
    west build -s zmk/app -d build/glove80_rh -b glove80_rh -- \
      -DZMK_CONFIG=${WORKSPACE}/config \
      -DZephyr_DIR=${WORKSPACE}/zephyr/share/zephyr-package/cmake
    cp build/glove80_rh/zephyr/zmk.uf2 ${WORKSPACE}/glove80_rh.uf2

    echo 'Glove80 firmware built successfully!'
  "

# Verify files were created and timestamps changed
if [ -f "glove80_lh.uf2" ] && [ -f "glove80_rh.uf2" ]; then
    lh_new_ts=$(stat -c "%Y" glove80_lh.uf2)
    rh_new_ts=$(stat -c "%Y" glove80_rh.uf2)
    lh_human=$(stat -c "%y" glove80_lh.uf2)
    rh_human=$(stat -c "%y" glove80_rh.uf2)
    if [ "$lh_new_ts" = "$lh_old_ts" ] || [ "$rh_new_ts" = "$rh_old_ts" ]; then
        echo -e "${RED}Glove80 build failed or did not update UF2 files. Timestamp unchanged.${NC}"
        echo -e "LH: $lh_human | RH: $rh_human"
        exit 1
    fi
    echo -e "${GREEN}Glove80 firmware built successfully:${NC}"
    echo "LH UF2: $lh_human"
    echo "RH UF2: $rh_human"
    ls -lh glove80_*.uf2
else
    echo -e "${RED}Glove80 build failed - no output files found${NC}"
    exit 1
fi
