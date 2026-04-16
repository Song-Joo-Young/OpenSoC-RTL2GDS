#!/bin/bash
# Step 5: Floorplan — 칩 크기 + 전원 네트워크
source "$(dirname "$0")/design.cfg"
cd "$ORFS_FLOW"

echo "========== Floorplan =========="
echo ""
echo "내부적으로 실행되는 OpenROAD 명령:"
echo "  initialize_floorplan -utilization $CORE_UTILIZATION"
echo "  place_pins -hor_layers met3 -ver_layers met2"
echo "  pdngen (전원 네트워크 생성)"
echo "  tapcell (well tap 삽입)"
echo ""

$MAKE_CMD floorplan

echo ""
echo "========== 결과 파일 =========="
echo "  [Floorplan ODB] $RESULTS/2_floorplan.odb"
echo "                  → 코어 면적, IO 핀 위치, PDN이 포함된 데이터베이스"
echo "  [Floorplan SDC] $RESULTS/2_floorplan.sdc"
echo "  [리포트]        $REPORTS/2_floorplan_final.rpt"
echo "                  → die 크기, core 면적, utilization 확인"
echo "  [PDN 로그]      $LOGS/2_6_pdn.log"
echo ""
echo "========== GUI로 확인 (optional) =========="
echo "  openroad -gui 실행 후 TCL 콘솔에 입력:"
echo "    read_lef platforms/$PLATFORM/lef/sky130_fd_sc_hd.tlef"
echo "    read_lef platforms/$PLATFORM/lef/sky130_fd_sc_hd_merged.lef"
echo "    read_def $RESULTS/2_floorplan.odb"
echo "  → PDN(전원 링/스트랩), 핀 위치, die 크기를 시각적으로 확인"
echo ""
echo "다음: bash 06_place.sh"
