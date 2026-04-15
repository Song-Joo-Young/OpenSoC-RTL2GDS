#!/bin/bash
# Step 6: Placement — 셀을 배치
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Placement =========="
echo ""
echo "내부적으로 실행되는 OpenROAD 명령:"
echo "  global_placement -density $PLACE_DENSITY"
echo "  repair_timing -setup (resizer)"
echo "  detailed_placement"
echo "  check_placement -verbose"
echo ""

$MAKE_CMD place

echo ""
echo "========== 결과 파일 =========="
echo "  [배치 ODB]       $RESULTS/3_place.odb"
echo "                   → global + detailed placement 결과"
echo "  [리사이저 리포트] $REPORTS/3_resizer.rpt"
echo "                   → 버퍼 삽입, 셀 리사이징 내역"
echo "  [배치 리포트]     $REPORTS/3_detailed_place.rpt"
echo ""
echo "========== GUI로 확인 (optional) =========="
echo "  openroad -gui 실행 후:"
echo "    read_db $RESULTS/3_place.odb"
echo "  → 셀들이 row에 배치된 모습 확인. 회색=빈 공간, 색상=셀"
echo ""
echo "다음: bash 07_cts.sh"
