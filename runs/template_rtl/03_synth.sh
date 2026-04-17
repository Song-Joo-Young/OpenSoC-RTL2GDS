#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Synthesis =========="
$MAKE_CMD synth

echo ""
echo "========== 결과 파일 =========="
echo "  [넷리스트]    $RESULTS/1_synth.v"
echo "  [합성 통계]   $REPORTS/synth_stat.txt"
echo "  [합성 로그]   $LOGS/1_1_yosys.log"
echo ""
echo "다음: bash 04_sta.sh"
