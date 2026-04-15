#!/bin/bash
# Step 7: CTS — 클럭 트리 합성
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Clock Tree Synthesis =========="
$MAKE_CMD cts

echo ""
echo "========== CTS 리포트 =========="
cat "$REPORTS/4_cts_final.rpt" 2>/dev/null || echo "(리포트 없음)"

echo ""
echo "다음: bash 08_route.sh"
