#!/bin/bash
# Step 2: register this design into ORFS
set -e
source "$(dirname "$0")/design.cfg"

echo "========== ORFS Setup =========="

rm -rf "$ORFS_SRC" "$ORFS_CFG"
mkdir -p "$ORFS_SRC" "$ORFS_CFG"

for f in $RTL_FILES; do
    cp "$f" "$ORFS_SRC/"
    echo "  RTL: $f → $ORFS_SRC/"
done

cp "$SDC_FILE" "$ORFS_CFG/constraint.sdc"
echo "  SDC: $SDC_FILE → $ORFS_CFG/constraint.sdc"

cat > "$ORFS_CFG/config.mk" << MKEOF
export DESIGN_NAME = $DESIGN_NAME
export PLATFORM    = $PLATFORM

export VERILOG_FILES = \$(sort \$(wildcard ./designs/src/\$(DESIGN_NICKNAME)/*.v))
export SDC_FILE      = ./designs/\$(PLATFORM)/\$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION  = $CORE_UTILIZATION
export EQUIVALENCE_CHECK = 0
MKEOF

[ -n "$PLACE_DENSITY" ]       && echo "export PLACE_DENSITY       = $PLACE_DENSITY" >> "$ORFS_CFG/config.mk"
[ -n "$ADDITIONAL_LEFS" ]     && echo "export ADDITIONAL_LEFS     = $ADDITIONAL_LEFS" >> "$ORFS_CFG/config.mk"
[ -n "$ADDITIONAL_LIBS" ]     && echo "export ADDITIONAL_LIBS     = $ADDITIONAL_LIBS" >> "$ORFS_CFG/config.mk"
[ -n "$ADDITIONAL_GDS" ]      && echo "export ADDITIONAL_GDS      = $ADDITIONAL_GDS" >> "$ORFS_CFG/config.mk"
[ -n "$MACRO_PLACE_HALO" ]    && echo "export MACRO_PLACE_HALO    = $MACRO_PLACE_HALO" >> "$ORFS_CFG/config.mk"
[ -n "$MACRO_PLACE_CHANNEL" ] && echo "export MACRO_PLACE_CHANNEL = $MACRO_PLACE_CHANNEL" >> "$ORFS_CFG/config.mk"

echo "  Config: $ORFS_CFG/config.mk"
echo ""
cat "$ORFS_CFG/config.mk"
echo ""
echo "다음: bash 03_synth.sh"
