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
echo "========== 결과 파일 =========="
echo "  [Route ODB]      $RESULTS/5_route.odb"
echo "                   → 라우팅 완료된 설계 데이터베이스"
echo "  [Global Route]   $REPORTS/5_global_route.rpt"
echo "                   → ★ 핵심 리포트: timing slack, area, power, DRC"
echo "  [Route DRC]      $REPORTS/5_route_drc.rpt"
echo "                   → 라우팅 DRC 위반 (0이어야 정상)"
echo "  [Antenna]        $REPORTS/drt_antennas.log"
echo "                   → antenna rule 위반 (0이어야 정상)"
echo ""
echo "다음: bash 09_sta_post.sh"
