#!/bin/bash
# Step 4: Pre-Route STA — 합성 직후 타이밍 확인
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Pre-Route STA =========="
sta -exit << STASCRIPT
read_liberty $LIBERTY
read_verilog $RESULTS/1_synth.v
link_design $DESIGN_NAME
read_sdc $ORFS_CFG/constraint.sdc

puts "\n=== Setup (max path) ==="
report_checks -path_delay max
puts "\n=== Hold (min path) ==="
report_checks -path_delay min
puts "\n=== Summary ==="
report_tns
report_wns
STASCRIPT

echo ""
echo "========== 해석 =========="
echo "  slack > 0 (MET)      → OK, 다음 단계로"
echo "  slack < 0 (VIOLATED) → $SDC_FILE 에서 CLOCK_PERIOD 늘리기"
echo ""
echo "========== 입출력 파일 =========="
echo "  [입력 Liberty]  $LIBERTY"
echo "                  → 셀 타이밍/파워 모델. PVT corner별로 다름"
echo "  [입력 넷리스트] $RESULTS/1_synth.v"
echo "  [입력 SDC]      $ORFS_CFG/constraint.sdc"
echo "                  → clock period, input/output delay 정의"
echo ""
echo "다음: bash 05_floorplan.sh"
