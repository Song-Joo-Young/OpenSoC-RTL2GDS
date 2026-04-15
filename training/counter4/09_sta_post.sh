#!/bin/bash
# Step 9: Post-Route STA — SPEF 포함 최종 타이밍
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Post-Route STA (SPEF 포함) =========="
echo "SPEF: $RESULTS/6_final.spef"
echo ""

sta -exit << STASCRIPT
read_liberty $LIBERTY
read_verilog $RESULTS/6_final.v
link_design $DESIGN_NAME
read_sdc $ORFS_CFG/constraint.sdc
read_spef $RESULTS/6_final.spef

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
echo "  Pre-Route (04_sta.sh):  추정값 기반"
echo "  Post-Route (이 결과):   SPEF 실측값 ← Sign-off 기준"
echo ""
echo "다음: bash 10_gds.sh"
