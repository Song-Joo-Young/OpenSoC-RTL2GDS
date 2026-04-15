#!/bin/bash
# Step 10: GDS 생성 — 최종 레이아웃
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== GDS 생성 =========="

# merged LEF
cat platforms/$PLATFORM/lef/sky130_fd_sc_hd.tlef \
    platforms/$PLATFORM/lef/sky130_fd_sc_hd_merged.lef \
    > "$RESULTS/merged.lef"

# DEF → GDS
klayout -zz \
  -rd design_name=$DESIGN_NAME \
  -rd in_def="$RESULTS/6_final.def" \
  -rd in_files="./platforms/$PLATFORM/gds/sky130_fd_sc_hd.gds" \
  -rd out_file="$RESULTS/6_final.gds" \
  -rd seal_file="" \
  -rd tech_file=./platforms/$PLATFORM/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py

echo ""
echo "========== 결과 =========="
ls -lh "$RESULTS/6_final.gds"
echo ""
echo "GUI로 보기: klayout $RESULTS/6_final.gds"
echo ""
echo "다음: bash 11_signoff.sh"
