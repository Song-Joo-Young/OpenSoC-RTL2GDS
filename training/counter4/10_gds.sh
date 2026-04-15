#!/bin/bash
# Step 10: GDS 생성 — 최종 레이아웃
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== GDS 생성 =========="

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
echo "  [GDS]        $RESULTS/6_final.gds"
ls -lh "$RESULTS/6_final.gds" 2>/dev/null | awk '{print "               → 크기: "$5}'
echo "               → 제조용 최종 파일. 이걸 fab에 보내면 칩이 만들어짐"
echo "  [입력 DEF]   $RESULTS/6_final.def"
echo "               → 배치+배선 정보 (KLayout이 읽어서 GDS로 변환)"
echo "  [입력 GDS]   platforms/$PLATFORM/gds/sky130_fd_sc_hd.gds"
echo "               → standard cell 라이브러리 GDS (셀 도형 정보)"
echo ""
echo "  GUI로 열기:  klayout $RESULTS/6_final.gds"
echo ""
echo "다음: bash 11_signoff.sh"
