#!/bin/bash
# Part 12: GDS 생성 — 최종 레이아웃
source ../../env.sh
cd $ORFS/flow

echo "========== GDS 생성 =========="

# merged LEF 생성
cat platforms/sky130hd/lef/sky130_fd_sc_hd.tlef \
    platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef \
    > results/sky130hd/counter4/base/merged.lef

# DEF → GDS 변환
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
echo "========== 결과 =========="
ls -lh results/sky130hd/counter4/base/6_final.gds

echo ""
echo "GUI에서 보기: klayout results/sky130hd/counter4/base/6_final.gds"
echo ""
echo "다음: bash 11_signoff.sh"
