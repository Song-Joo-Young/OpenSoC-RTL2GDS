#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Floorplan =========="
$MAKE_CMD floorplan

echo ""
echo "  [Floorplan ODB] $RESULTS/2_floorplan.odb"
echo "  [Floorplan rpt] $REPORTS/2_floorplan_final.rpt"
echo ""
echo "다음: bash 06_place.sh"
