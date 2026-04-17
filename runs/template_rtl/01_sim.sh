#!/bin/bash
# Step 1: optional Verilator simulation
set -e
source "$(dirname "$0")/design.cfg"

echo "========== Simulation =========="
echo "RTL:  $RTL_FILES"
echo "Top:  $TOP_MODULE"
echo "TB:   $TB_FILE"
echo "Mode: ENABLE_SIM=$ENABLE_SIM"
echo ""

if [ "$ENABLE_SIM" != "1" ]; then
    echo "Simulation skipped."
    echo "Set ENABLE_SIM=1 in design.cfg and provide a valid C++ TB to enable Verilator."
    echo ""
    echo "다음: bash 02_setup_ORFS.sh"
    exit 0
fi

if [ ! -f "$TB_FILE" ]; then
    echo "ERROR: missing TB file: $TB_FILE"
    echo "Either add the testbench or set ENABLE_SIM=0."
    exit 1
fi

verilator --cc --exe --build -Wno-fatal \
  -Mdir "$SIM_BUILD_DIR" --top-module "$TOP_MODULE" \
  $RTL_FILES "$TB_FILE"

echo ""
"$SIM_BUILD_DIR/V${TOP_MODULE}"

echo ""
echo "다음: bash 02_setup_ORFS.sh"
