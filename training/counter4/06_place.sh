#!/bin/bash
# Step 6: Placement — 셀을 배치
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Placement =========="
$MAKE_CMD place

echo ""
echo "========== 결과 파일 =========="
echo "  [배치 ODB]       $RESULTS/3_place.odb"
echo "                   → global + detailed placement 결과"
echo "  [리사이저 리포트] $REPORTS/3_resizer.rpt"
echo "                   → 타이밍 최적화: 버퍼 삽입, 셀 리사이징 내역"
echo "  [배치 리포트]     $REPORTS/3_detailed_place.rpt"
echo "                   → 배치 후 타이밍/면적 요약"
echo ""
echo "다음: bash 07_cts.sh"
