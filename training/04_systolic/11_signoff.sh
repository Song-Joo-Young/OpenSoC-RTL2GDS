#!/bin/bash
# Step 11: Sign-off — DRC + LVS
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
LVS_STATUS="SKIPPED (layout SPICE missing)"
if [ -f "$RESULTS/6_final.spice" ]; then
    netgen -batch lvs \
      "$RESULTS/6_final.spice $DESIGN_NAME" \
      "$RESULTS/6_final.v $DESIGN_NAME" \
      "$NETGEN_SETUP" \
      "$REPORTS/lvs_result.log"
    LVS_STATUS="DONE"
    echo ""
    tail -5 "$REPORTS/lvs_result.log"
else
    echo "  SPICE 넷리스트 없음 — Magic extraction 필요 (생략)"
fi

echo ""
echo "========== 결과 파일 =========="
echo "  [DRC 입력]    $RESULTS/6_final.gds"
echo "                → DRC는 GDS를 직접 읽어서 공정 규칙 검사"
echo "  [LVS 입력 1]  $RESULTS/6_final.spice (layout netlist)"
echo "  [LVS 입력 2]  $RESULTS/6_final.v (schematic netlist)"
echo "  [LVS 결과]    $REPORTS/lvs_result.log"
echo "  [LVS 상태]    $LVS_STATUS"
echo "                → layout SPICE가 있을 때만 Netgen 비교 수행"
echo ""
echo "=========================================="
echo "  전체 RTL-to-GDS flow 완료!"
echo "  Design: $DESIGN_NAME / PDK: $PLATFORM"
echo "=========================================="
