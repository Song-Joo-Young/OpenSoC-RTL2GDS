#!/bin/bash
# Part 14: Full flow — 한 번에 전체 실행
# Part 3~13을 이해한 후에 사용하세요!
source ../../env.sh
cd $ORFS/flow

echo "========== Full RTL-to-GDS Flow =========="
echo "Design: counter4 / PDK: sky130hd"
echo ""

# Clean
make clean_all DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk 2>/dev/null

# Full flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk

# congestion.rpt workaround가 필요하면 자동 처리
if [ ! -f results/sky130hd/counter4/base/5_2_route.odb ]; then
    mkdir -p reports/sky130hd/counter4/base
    touch reports/sky130hd/counter4/base/congestion.rpt
    make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk
fi

# GDS 생성
cat platforms/sky130hd/lef/sky130_fd_sc_hd.tlef \
    platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef \
    > results/sky130hd/counter4/base/merged.lef
klayout -zz \
  -rd design_name=counter4 \
  -rd in_def=./results/sky130hd/counter4/base/6_final.def \
  -rd in_files="./platforms/sky130hd/gds/sky130_fd_sc_hd.gds" \
  -rd out_file=./results/sky130hd/counter4/base/6_final.gds \
  -rd seal_file="" \
  -rd tech_file=./platforms/sky130hd/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py

echo ""
echo "========== 최종 결과 =========="
ls -lh results/sky130hd/counter4/base/6_final.gds
echo ""
cat reports/sky130hd/counter4/base/synth_stat.txt | grep "Number of cells"
cat reports/sky130hd/counter4/base/5_global_route.rpt | grep -A1 "report_design_area"
cat reports/sky130hd/counter4/base/5_global_route.rpt | grep "worst slack"
