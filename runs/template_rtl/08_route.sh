#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

mkdir -p "$REPORTS"
touch "$REPORTS/congestion.rpt"

echo "========== Routing =========="
$MAKE_CMD route

echo ""
echo "  [Route ODB]   $RESULTS/5_route.odb"
echo "  [Route rpt]   $REPORTS/5_global_route.rpt"
echo ""
echo "다음: bash 09_sta_post.sh"
