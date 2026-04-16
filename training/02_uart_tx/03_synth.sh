#!/bin/bash
# Step 3: Synthesis — RTL을 게이트로 변환
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Synthesis =========="
$MAKE_CMD synth

echo ""
echo "========== 결과 파일 =========="
echo "  [넷리스트]    $RESULTS/1_synth.v"
echo "                → 합성된 gate-level Verilog. 어떤 셀이 쓰였는지 확인"
echo "  [합성 통계]   $REPORTS/synth_stat.txt"
echo "                → 셀 종류별 개수, 전체 면적. FF 개수가 예상과 맞는지 확인"
echo "  [합성 로그]   $LOGS/1_1_yosys.log"
echo "                → Yosys 실행 로그. 에러/경고 확인용"
echo ""
echo "다음: bash 04_sta.sh"
