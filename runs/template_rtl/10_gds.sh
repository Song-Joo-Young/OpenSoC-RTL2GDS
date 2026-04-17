#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== GDS 생성 =========="

if [ ! -f "$RESULTS/6_final.def" ]; then
    echo "ERROR: missing DEF input: $RESULTS/6_final.def"
    echo "Run bash 99_fullflow.sh or finish route/final_report first."
    exit 1
fi

cat platforms/$PLATFORM/lef/sky130_fd_sc_hd.tlef \
    platforms/$PLATFORM/lef/sky130_fd_sc_hd_merged.lef \
    > "$RESULTS/merged.lef"

klayout -zz \
  -rd design_name=$TOP_MODULE \
  -rd in_def="$RESULTS/6_final.def" \
  -rd in_files="./platforms/$PLATFORM/gds/sky130_fd_sc_hd.gds" \
  -rd out_file="$RESULTS/6_final.gds" \
  -rd seal_file="" \
  -rd tech_file=./platforms/$PLATFORM/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py

[ -f "$RESULTS/6_final.gds" ]

echo ""
echo "  [GDS]  $RESULTS/6_final.gds"
echo "다음: bash 11_signoff.sh"
