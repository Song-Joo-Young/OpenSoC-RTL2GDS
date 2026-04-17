#!/bin/bash
# Step 2: register this design into ORFS
set -e
source "$(dirname "$0")/design.cfg"

echo "========== ORFS Setup =========="

rm -rf "$ORFS_SRC" "$ORFS_CFG"
mkdir -p "$ORFS_SRC" "$ORFS_CFG"

mapfile -t RTL_REL_FILES < <(grep -v '^\s*#' "$RTL_FILELIST" | grep -v '^\s*$')

ORFS_VERILOG_FILES=""
ORFS_INCLUDE_DIRS=""

for rel in "${RTL_REL_FILES[@]}"; do
    case "$rel" in
        /*)
            src="$rel"
            rel_path="${rel#/}"
            dst="$ORFS_SRC/external/$rel_path"
            orfs_ref="./designs/src/\$(DESIGN_NICKNAME)/external/$rel_path"
            ;;
        *)
            src="$SCRIPT_DIR/$rel"
            dst="$ORFS_SRC/$rel"
            orfs_ref="./designs/src/\$(DESIGN_NICKNAME)/$rel"
            ;;
    esac
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  RTL: $src → $dst"
    ORFS_VERILOG_FILES="${ORFS_VERILOG_FILES} $orfs_ref"
done

mapfile -t RTL_INCLUDE_DIRS < <(
    for rel in "${RTL_REL_FILES[@]}"; do
        case "$rel" in
            /*) printf 'external/%s\n' "$(dirname "${rel#/}")" ;;
            *)  dirname "$rel" ;;
        esac
    done | sort -u
)

for inc in "${RTL_INCLUDE_DIRS[@]}"; do
    ORFS_INCLUDE_DIRS="${ORFS_INCLUDE_DIRS} ./designs/src/\$(DESIGN_NICKNAME)/$inc"
done

for inc in $EXTRA_VERILOG_INCLUDE_DIRS; do
    case "$inc" in
        /*)
            rel_inc="external/${inc#/}"
            mkdir -p "$ORFS_SRC/$rel_inc"
            cp -r "$inc"/. "$ORFS_SRC/$rel_inc/"
            ORFS_INCLUDE_DIRS="${ORFS_INCLUDE_DIRS} ./designs/src/\$(DESIGN_NICKNAME)/$rel_inc"
            ;;
    esac
done

mkdir -p "$ORFS_DESIGN_DIR"

cp "$SDC_FILE" "$ORFS_CFG/constraint.sdc"
echo "  SDC: $SDC_FILE → $ORFS_CFG/constraint.sdc"

cat > "$ORFS_CFG/config.mk" << MKEOF
export DESIGN_NICKNAME = $RUN_NAME
export DESIGN_NAME = $TOP_MODULE
export PLATFORM    = $PLATFORM

export VERILOG_FILES = $ORFS_VERILOG_FILES
export VERILOG_INCLUDE_DIRS = $ORFS_INCLUDE_DIRS
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
