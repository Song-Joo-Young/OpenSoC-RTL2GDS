#!/bin/bash
# Step 7: CTS — 클럭 트리 합성
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Clock Tree Synthesis =========="
echo ""
echo "내부적으로 실행되는 OpenROAD 명령:"
echo "  clock_tree_synthesis -root_buf sky130_fd_sc_hd__clkbuf_16"
echo "  repair_timing -hold (hold fix)"
echo "  detailed_placement (CTS 버퍼 배치 합법화)"
echo ""

$MAKE_CMD cts

echo ""
echo "========== 결과 파일 =========="
echo "  [CTS ODB]    $RESULTS/4_cts.odb"
echo "               → 클럭 버퍼가 삽입된 설계 데이터베이스"
echo "  [CTS SDC]    $RESULTS/4_cts.sdc"
echo "               → propagated clock 반영"
echo "  [CTS 리포트] $REPORTS/4_cts_final.rpt"
echo "               → clock skew, 버퍼 개수"
echo ""
echo "========== GUI로 확인 (optional) =========="
echo "  openroad -gui 실행 후:"
echo "    read_db $RESULTS/4_cts.odb"
echo "  → Clock Net 하이라이트: View → Nets → clk 선택"
echo "  → 클럭 버퍼 트리가 어떻게 분배되는지 확인"
echo ""
echo "다음: bash 08_route.sh"
