#!/bin/bash
# Step 9: Post-Route STA — SPEF 포함 최종 타이밍
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Post-Route STA (SPEF) =========="
sta -exit << STASCRIPT
read_liberty $LIBERTY
read_verilog $RESULTS/6_final.v
link_design $DESIGN_NAME
read_sdc $ORFS_CFG/constraint.sdc
read_spef $RESULTS/6_final.spef

puts "\n=== Post-Route Setup ==="
report_checks -path_delay max
puts "\n=== Post-Route Hold ==="
report_checks -path_delay min
puts "\n=== Summary ==="
report_tns
report_wns
STASCRIPT

echo ""
echo "========== 결과 파일 =========="
echo "  [SPEF]           $RESULTS/6_final.spef"
echo "                   → 실제 배선의 R/C 기생값. sign-off STA의 핵심 입력"
echo "  [Final netlist]  $RESULTS/6_final.v"
echo "                   → 라우팅 후 최종 넷리스트 (CTS 버퍼 포함)"
echo "  [Final DEF]      $RESULTS/6_final.def"
echo "                   → 최종 배치+배선 정보 (GDS 변환 입력)"
echo ""
echo "  Pre-Route STA (04_sta.sh):  wire-load 추정값 기반"
echo "  Post-Route STA (이 결과):   SPEF 실측값 ← sign-off 기준"
echo ""
echo "다음: bash 10_gds.sh"
