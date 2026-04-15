#!/bin/bash
# Step 5: Floorplan — 칩 크기 + 전원 네트워크
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Floorplan =========="
$MAKE_CMD floorplan

echo ""
echo "========== 결과 파일 =========="
echo "  [Floorplan ODB] $RESULTS/2_floorplan.odb"
echo "                  → 코어 면적, IO 핀 위치, PDN이 포함된 데이터베이스"
echo "  [Floorplan SDC] $RESULTS/2_floorplan.sdc"
echo "  [리포트]        $REPORTS/2_floorplan_final.rpt"
echo "                  → die 크기, core 면적, utilization 확인"
echo "  [PDN 로그]      $LOGS/2_6_pdn.log"
echo "                  → 전원 네트워크 생성 과정. 에러 시 CORE_UTILIZATION 조정"
echo ""
echo "다음: bash 06_place.sh"
