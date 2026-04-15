#!/bin/bash
# Step 6: Placement — 셀을 배치
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Placement =========="
$MAKE_CMD place

echo ""
echo "========== Placement 리포트 =========="
cat "$REPORTS/3_detailed_place.rpt" 2>/dev/null || \
cat "$REPORTS/3_resizer.rpt" 2>/dev/null || echo "(리포트 없음)"

echo ""
echo "다음: bash 07_cts.sh"
