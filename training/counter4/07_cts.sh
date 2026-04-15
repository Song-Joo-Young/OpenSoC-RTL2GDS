#!/bin/bash
# Step 7: CTS — 클럭 트리 합성
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Clock Tree Synthesis =========="
$MAKE_CMD cts

echo ""
echo "========== 결과 파일 =========="
echo "  [CTS ODB]    $RESULTS/4_cts.odb"
echo "               → 클럭 버퍼가 삽입된 설계 데이터베이스"
echo "  [CTS SDC]    $RESULTS/4_cts.sdc"
echo "               → propagated clock이 반영된 제약"
echo "  [CTS 리포트] $REPORTS/4_cts_final.rpt"
echo "               → clock skew, 삽입된 버퍼 수, 타이밍 확인"
echo ""
echo "다음: bash 08_route.sh"
