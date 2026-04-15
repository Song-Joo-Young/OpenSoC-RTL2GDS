#!/bin/bash
# Step 4: Pre-Route STA — 합성 직후 타이밍 확인
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Pre-Route STA =========="
echo "Liberty: $LIBERTY"
echo "Netlist: $RESULTS/1_synth.v"
echo ""

sta -exit << STASCRIPT
read_liberty $LIBERTY
read_verilog $RESULTS/1_synth.v
link_design $DESIGN_NAME
read_sdc $ORFS_CFG/constraint.sdc

puts "\n=== Setup Analysis (가장 느린 경로) ==="
report_checks -path_delay max

puts "\n=== Hold Analysis ==="
report_checks -path_delay min

puts "\n=== Summary ==="
report_tns
report_wns
report_power
STASCRIPT

echo ""
echo "========== 해석 =========="
echo "  slack > 0 (MET)      → OK, 다음 단계 진행"
echo "  slack < 0 (VIOLATED) → $SDC_FILE 에서 clock period 늘리세요"
echo ""
echo "다음: bash 05_floorplan.sh"
