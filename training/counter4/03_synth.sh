#!/bin/bash
# Part 5: Synthesis — RTL을 게이트로 변환
source ../../env.sh
cd $ORFS/flow

echo "========== Synthesis =========="
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk synth

echo ""
echo "========== 합성 통계 =========="
cat reports/sky130hd/counter4/base/synth_stat.txt

echo ""
echo "========== 넷리스트 (앞 30줄) =========="
head -30 results/sky130hd/counter4/base/1_synth.v

echo ""
echo "다음: bash 04_sta.sh"
