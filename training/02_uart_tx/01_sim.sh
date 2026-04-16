#!/bin/bash
# Step 1: Simulation — RTL 기능 검증
source "$(dirname "$0")/design.cfg"

echo "========== Verilator Simulation =========="
echo "RTL:  $RTL_FILES"
echo "TB:   $TB_FILE"
echo "Top:  $TOP_MODULE"
echo ""

verilator --cc --exe --build -Wno-fatal \
  -Mdir "$SIM_BUILD_DIR" --top-module "$TOP_MODULE" \
  $RTL_FILES $TB_FILE

echo ""
"$SIM_BUILD_DIR/V${TOP_MODULE}"

echo ""
echo "다음: bash 02_setup_ORFS.sh"
