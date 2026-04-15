#!/bin/bash
# Part 13: Sign-off — DRC + LVS
source ../../env.sh
cd $ORFS/flow

echo "========== DRC (Magic) =========="
magic -d null -T sky130A << 'MAGICSCRIPT'
gds read results/sky130hd/counter4/base/6_final.gds
load counter4
select top cell
drc check
drc count
quit
MAGICSCRIPT

echo ""
echo "========== LVS (Netgen) =========="
if [ -f results/sky130hd/counter4/base/6_final.spice ]; then
    netgen -batch lvs \
      "results/sky130hd/counter4/base/6_final.spice counter4" \
      "results/sky130hd/counter4/base/6_final.v counter4" \
      $PDK_ROOT/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl \
      reports/sky130hd/counter4/base/lvs_result.log
    echo ""
    tail -20 reports/sky130hd/counter4/base/lvs_result.log
else
    echo "SPICE 넷리스트 없음 — Magic extraction 필요 (생략)"
fi

echo ""
echo "=========================================="
echo "  축하합니다! 전체 RTL-to-GDS flow 완료!"
echo "=========================================="
echo ""
echo "전체 한 번에 돌리기: bash 99_fullflow.sh"
