#!/bin/bash
# 모든 결과 삭제 — 처음부터 다시 하고 싶을 때
source ../../env.sh
cd $ORFS/flow

echo "========== Cleaning counter4 results =========="
rm -rf results/sky130hd/counter4
rm -rf reports/sky130hd/counter4
rm -rf logs/sky130hd/counter4
rm -rf objects/sky130hd/counter4
echo "Done. 처음부터 다시: bash 03_synth.sh"
