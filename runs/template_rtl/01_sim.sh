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

mapfile -t RTL_DIRS < <(
    grep -v '^\s*#' "$RTL_FILELIST" | grep -v '^\s*$' | while read -r rel; do
        case "$rel" in
            /*) dir=$(dirname "$rel") ;;
            *)  dir=$(dirname "$SCRIPT_DIR/$rel") ;;
        esac
        printf '%s\n' "$dir"
    done
    for dir in $EXTRA_VERILOG_INCLUDE_DIRS; do
        printf '%s\n' "$dir"
    done | sort -u
)

VERILATOR_INCLUDE_ARGS=()
for dir in "${RTL_DIRS[@]}"; do
    VERILATOR_INCLUDE_ARGS+=("-I$dir")
done

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
  "${VERILATOR_INCLUDE_ARGS[@]}" \
  $RTL_FILES "$TB_FILE"

echo ""
"$SIM_BUILD_DIR/V${TOP_MODULE}"

echo ""
echo "다음: bash 02_setup_ORFS.sh"
