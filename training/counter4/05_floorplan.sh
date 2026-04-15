#!/bin/bash
# Part 7: Floorplan — 칩 크기 + 전원 네트워크
source ../../env.sh
cd $ORFS/flow

echo "========== Floorplan =========="
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk floorplan

echo ""
echo "========== Floorplan 리포트 =========="
cat reports/sky130hd/counter4/base/2_floorplan_final.rpt 2>/dev/null || echo "(리포트 없음)"

echo ""
echo "다음: bash 06_place.sh"
