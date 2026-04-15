#!/bin/bash
# Part 6: Pre-Route STA — 합성 직후 타이밍 확인
source ../../env.sh
cd $ORFS/flow

echo "========== Pre-Route STA =========="
sta -exit << 'STASCRIPT'
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/sky130hd/counter4/base/1_synth.v
link_design counter4
read_sdc designs/sky130hd/counter4/constraint.sdc

puts "\n=== Setup Analysis (가장 느린 경로) ==="
report_checks -path_delay max

puts "\n=== Hold Analysis (가장 빠른 경로) ==="
report_checks -path_delay min

puts "\n=== Summary ==="
report_tns
report_wns
report_power
STASCRIPT

echo ""
echo "========== 해석 가이드 =========="
echo "  slack > 0 (MET)  → OK, 다음 단계 진행"
echo "  slack < 0 (VIOLATED) → SDC clock period 늘리세요"
echo ""
echo "다음: bash 05_floorplan.sh"
