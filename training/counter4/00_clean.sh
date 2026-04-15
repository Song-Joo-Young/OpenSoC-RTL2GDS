#!/bin/bash
# Step 0: 모든 결과 삭제 — 처음부터 다시 하고 싶을 때
source "$(dirname "$0")/design.cfg"

echo "========== Cleaning $DESIGN_NAME results =========="
rm -rf "$RESULTS" "$REPORTS" "$LOGS"
rm -rf "$ORFS_FLOW/objects/$PLATFORM/$DESIGN_NAME"
rm -rf "$SIM_BUILD_DIR"
echo "Done. 처음부터 다시: bash 01_sim.sh"
