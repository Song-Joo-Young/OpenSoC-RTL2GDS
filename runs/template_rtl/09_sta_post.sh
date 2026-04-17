#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Post-Route STA =========="
sta -exit << STASCRIPT
read_liberty $LIBERTY
read_verilog $RESULTS/6_final.v
link_design $TOP_MODULE
read_sdc $ORFS_CFG/constraint.sdc
read_spef $RESULTS/6_final.spef

puts "\n=== Post-Route Setup ==="
report_checks -path_delay max
puts "\n=== Post-Route Hold ==="
report_checks -path_delay min
puts "\n=== Summary ==="
report_tns
report_wns
STASCRIPT

echo ""
echo "다음: bash 10_gds.sh"
