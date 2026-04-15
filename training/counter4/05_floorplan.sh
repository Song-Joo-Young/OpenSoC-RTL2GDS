#!/bin/bash
# Step 5: Floorplan — 칩 크기 + 전원 네트워크
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Floorplan =========="
$MAKE_CMD floorplan

echo ""
echo "========== Floorplan 리포트 =========="
echo "파일: $REPORTS/2_floorplan_final.rpt"
cat "$REPORTS/2_floorplan_final.rpt" 2>/dev/null || echo "(리포트 없음)"

echo ""
echo "다음: bash 06_place.sh"
