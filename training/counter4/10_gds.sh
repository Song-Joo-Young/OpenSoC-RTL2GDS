#!/bin/bash
# Step 10: GDS 생성 — 최종 레이아웃
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== GDS 생성 =========="
echo ""
echo "입력:"
echo "  DEF (배치+배선):  $RESULTS/6_final.def"
echo "  셀 GDS:          platforms/$PLATFORM/gds/sky130_fd_sc_hd.gds"
echo "  Tech file:       platforms/$PLATFORM/sky130hd.lyt"
echo ""

cat platforms/$PLATFORM/lef/sky130_fd_sc_hd.tlef \
    platforms/$PLATFORM/lef/sky130_fd_sc_hd_merged.lef \
    > "$RESULTS/merged.lef"

klayout -zz \
  -rd design_name=$DESIGN_NAME \
  -rd in_def="$RESULTS/6_final.def" \
  -rd in_files="./platforms/$PLATFORM/gds/sky130_fd_sc_hd.gds" \
  -rd out_file="$RESULTS/6_final.gds" \
  -rd seal_file="" \
  -rd tech_file=./platforms/$PLATFORM/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py

echo ""
echo "========== 결과 파일 =========="
echo "  [GDS]  $RESULTS/6_final.gds"
ls -lh "$RESULTS/6_final.gds" 2>/dev/null | awk '{print "         크기: "$5}'
echo "         → fab에 보내는 최종 파일"
echo ""
echo "========== GUI로 확인 (꼭 해보세요!) =========="
echo "  klayout $RESULTS/6_final.gds"
echo ""
echo "  KLayout에서 해볼 것:"
echo "    - 줌인: 개별 셀(gate) 모양 관찰"
echo "    - 레이어: met1(파랑), met2(보라), poly(빨강) 등 각 레이어 의미"
echo "    - 줌아웃: 전체 칩 모양, PDN 스트랩, IO 핀 배치"
echo ""
echo "다음: bash 11_signoff.sh"
