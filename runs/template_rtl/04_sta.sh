#!/bin/bash
set -e
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
echo "다음: bash 05_floorplan.sh"
