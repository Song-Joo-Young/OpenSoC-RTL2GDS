#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== CTS =========="
$MAKE_CMD cts

echo ""
echo "  [CTS ODB]     $RESULTS/4_cts.odb"
echo "  [CTS rpt]     $REPORTS/4_cts_final.rpt"
echo ""
echo "다음: bash 08_route.sh"
