#!/bin/bash
# Part 10: Routing — 금속선 연결
source ../../env.sh
cd $ORFS/flow

# ORFS 호환성 workaround
mkdir -p reports/sky130hd/counter4/base
touch reports/sky130hd/counter4/base/congestion.rpt

echo "========== Routing =========="
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk route

echo ""
echo "========== Routing 리포트 (타이밍/파워) =========="
cat reports/sky130hd/counter4/base/5_global_route.rpt 2>/dev/null | \
  grep -A20 "report_power\|report_design_area\|slack\|report_wns\|report_tns"

echo ""
echo "다음: bash 09_sta_post.sh"
