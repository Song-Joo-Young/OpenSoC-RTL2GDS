#!/bin/bash
# Step 0: clean local simulation and ORFS outputs
source "$(dirname "$0")/design.cfg"

echo "========== Cleaning $DESIGN_NAME results =========="
rm -rf "$RESULTS" "$REPORTS" "$LOGS"
rm -rf "$ORFS_FLOW/objects/$PLATFORM/$DESIGN_NAME"
rm -rf "$ORFS_SRC" "$ORFS_CFG"
rm -rf "$SIM_BUILD_DIR"
echo "Done. next: bash 01_sim.sh"
