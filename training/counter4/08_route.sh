#!/bin/bash
# Step 8: Routing — 금속선 연결
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

# ORFS congestion.rpt workaround
mkdir -p "$REPORTS"
touch "$REPORTS/congestion.rpt"

echo "========== Routing =========="
$MAKE_CMD route

echo ""
echo "========== Routing 결과 (타이밍/면적/파워) =========="
echo "파일: $REPORTS/5_global_route.rpt"
echo ""
grep -A2 "report_design_area\|worst slack\|report_wns\|report_tns" "$REPORTS/5_global_route.rpt" 2>/dev/null
echo ""
grep -A15 "report_power" "$REPORTS/5_global_route.rpt" 2>/dev/null

echo ""
echo "다음: bash 09_sta_post.sh"
