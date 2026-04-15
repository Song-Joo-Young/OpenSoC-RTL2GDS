#!/bin/bash
# Step 8: Routing — 금속선 연결
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

mkdir -p "$REPORTS"
touch "$REPORTS/congestion.rpt"

echo "========== Routing =========="
echo ""
echo "내부적으로 실행되는 OpenROAD 명령:"
echo "  global_route -guide_file route.guide"
echo "  detailed_route -bottom_routing_layer met1 -top_routing_layer met5"
echo "  filler_placement (빈 공간 채움)"
echo ""

$MAKE_CMD route

echo ""
echo "========== 결과 파일 =========="
echo "  [Route ODB]      $RESULTS/5_route.odb"
echo "                   → 라우팅 완료된 설계"
echo "  [Global Route]   $REPORTS/5_global_route.rpt"
echo "                   → ★ timing slack, area, power, DRC 종합 리포트"
echo "  [Route DRC]      $REPORTS/5_route_drc.rpt"
echo "                   → 라우팅 DRC 위반 (0이어야 정상)"
echo "  [Antenna]        $REPORTS/drt_antennas.log"
echo ""
echo "========== GUI로 확인 (강력 권장!) =========="
echo "  openroad -gui 실행 후:"
echo "    read_db $RESULTS/5_route.odb"
echo "  → 실제 금속선(met1~met5)이 그려진 모습 확인"
echo "  → 레이어별 on/off: 왼쪽 패널에서 met1, met2 등 토글"
echo ""
echo "다음: bash 09_sta_post.sh"
