#!/bin/bash
# Part 8: Placement — 셀을 배치
source ../../env.sh
cd $ORFS/flow

echo "========== Placement =========="
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk place

echo ""
echo "========== Placement 리포트 =========="
cat reports/sky130hd/counter4/base/3_detailed_place.rpt 2>/dev/null || \
cat reports/sky130hd/counter4/base/3_resizer.rpt 2>/dev/null || echo "(리포트 없음)"

echo ""
echo "다음: bash 07_cts.sh"
