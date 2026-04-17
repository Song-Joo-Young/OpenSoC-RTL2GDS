#!/bin/bash
set -e
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

MAGIC_RC="$PDK_ROOT/share/pdk/sky130A/libs.tech/magic/sky130A.magicrc"
NETGEN_SETUP="$PDK_ROOT/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl"
MAGIC_PDK_ROOT="$PDK_ROOT/share/pdk"

if [ ! -f "$RESULTS/6_final.gds" ]; then
    echo "ERROR: missing GDS input: $RESULTS/6_final.gds"
    echo "Run bash 10_gds.sh or bash 99_fullflow.sh first."
    exit 1
fi

echo "========== DRC (Magic) =========="
PDK_ROOT="$MAGIC_PDK_ROOT" magic -dnull -noconsole -rcfile "$MAGIC_RC" << MAGICSCRIPT
gds read $RESULTS/6_final.gds
load $DESIGN_NAME
select top cell
drc check
drc count
quit
MAGICSCRIPT

echo ""
echo "========== LVS (Netgen) =========="
if [ -f "$RESULTS/6_final.spice" ]; then
    netgen -batch lvs \
      "$RESULTS/6_final.spice $DESIGN_NAME" \
      "$RESULTS/6_final.v $DESIGN_NAME" \
      "$NETGEN_SETUP" \
      "$REPORTS/lvs_result.log"
    tail -5 "$REPORTS/lvs_result.log"
else
    echo "  SPICE 넷리스트 없음 — Magic extraction 필요 (생략)"
fi
