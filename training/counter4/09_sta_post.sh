#!/bin/bash
# Part 11: Post-Route STA — SPEF 포함 최종 타이밍
source ../../env.sh
cd $ORFS/flow

echo "========== Post-Route STA (SPEF 포함) =========="
sta -exit << 'STASCRIPT'
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/sky130hd/counter4/base/6_final.v
link_design counter4
read_sdc designs/sky130hd/counter4/constraint.sdc
read_spef results/sky130hd/counter4/base/6_final.spef

puts "\n=== Post-Route Setup (최종) ==="
report_checks -path_delay max

puts "\n=== Post-Route Hold ==="
report_checks -path_delay min

puts "\n=== Power ==="
report_power

puts "\n=== Summary ==="
report_tns
report_wns
STASCRIPT

echo ""
echo "========== Pre vs Post 비교 =========="
echo "  Pre-Route STA  (04_sta.sh):  추정값 기반"
echo "  Post-Route STA (이 결과):    SPEF 실측값 기반 ← Sign-off 기준"
echo ""
echo "다음: bash 10_gds.sh"
