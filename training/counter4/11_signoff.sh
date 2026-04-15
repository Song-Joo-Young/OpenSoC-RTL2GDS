#!/bin/bash
# Step 11: Sign-off — DRC + LVS
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== DRC (Magic) =========="
magic -d null -T sky130A << MAGICSCRIPT
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
      "\$PDK_ROOT/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl" \
      "$REPORTS/lvs_result.log"
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
echo "                → 'Circuits match uniquely' = PASS"
echo ""
echo "=========================================="
echo "  전체 RTL-to-GDS flow 완료!"
echo "  Design: $DESIGN_NAME / PDK: $PLATFORM"
echo "=========================================="
