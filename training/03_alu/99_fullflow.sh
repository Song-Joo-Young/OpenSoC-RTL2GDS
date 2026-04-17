#!/bin/bash
# Full flow — 한 번에 전체 실행 (학습 완료 후 사용)
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Full RTL-to-GDS Flow =========="
echo ""

# Clean
$MAKE_CMD clean_all 2>/dev/null

# congestion.rpt workaround
mkdir -p "$REPORTS"
touch "$REPORTS/congestion.rpt"

# Full flow
if ! $MAKE_CMD; then
    echo ""
    echo "[WARN] ORFS built-in GDS merge failed."
    echo "       Known issue: duplicate MACRO names in merged.lef during do-gds-merged."
    echo "       Checking whether 6_final.def was already generated for manual merge..."
    [ -f "$RESULTS/6_final.def" ] || exit 1
fi

# GDS
cat platforms/$PLATFORM/lef/sky130_fd_sc_hd.tlef \
    platforms/$PLATFORM/lef/sky130_fd_sc_hd_merged.lef \
    > "$RESULTS/merged.lef"
klayout -zz \
  -rd design_name=$DESIGN_NAME \
  -rd in_def="$RESULTS/6_final.def" \
  -rd in_files="./platforms/$PLATFORM/gds/sky130_fd_sc_hd.gds" \
  -rd out_file="$RESULTS/6_final.gds" \
  -rd seal_file="" \
  -rd tech_file=./platforms/$PLATFORM/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py

[ -f "$RESULTS/6_final.gds" ]

echo ""
echo "========== 최종 결과 =========="
ls -lh "$RESULTS/6_final.gds"
grep "Chip area for module" "$REPORTS/synth_stat.txt" 2>/dev/null
grep -A1 "report_design_area" "$REPORTS/5_global_route.rpt" 2>/dev/null
grep "worst slack" "$REPORTS/5_global_route.rpt" 2>/dev/null
