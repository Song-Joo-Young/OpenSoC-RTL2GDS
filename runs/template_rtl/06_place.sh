#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Placement =========="
$MAKE_CMD place

echo ""
echo "  [Place ODB]   $RESULTS/3_place.odb"
echo "  [Place rpt]   $REPORTS/3_detailed_place.rpt"
echo ""
echo "다음: bash 07_cts.sh"
