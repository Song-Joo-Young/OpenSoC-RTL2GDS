#!/bin/bash
# Part 9: CTS — 클럭 트리 합성
source ../../env.sh
cd $ORFS/flow

echo "========== Clock Tree Synthesis =========="
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk cts

echo ""
echo "========== CTS 리포트 =========="
cat reports/sky130hd/counter4/base/4_cts_final.rpt 2>/dev/null || echo "(리포트 없음)"

echo ""
echo "다음: bash 08_route.sh"
