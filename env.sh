#!/bin/bash
# OpenSoC-RTL2GDS 환경 변수 설정
# Usage: source env.sh

export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOCAL="$HOME/local"

# PATH (LD_LIBRARY_PATH는 설정하지 않음 — 시스템 Qt와 충돌 방지)
export PATH="$LOCAL/bin:$PATH"

# PDK
export PDK_ROOT="$PROJECT_ROOT/pdk"
export PDK="sky130A"

# OpenROAD-flow-scripts
export ORFS="$PROJECT_ROOT/tools/OpenROAD-flow-scripts"
export YOSYS_EXE="$ORFS/tools/install/yosys/bin/yosys"
export OPENROAD_EXE="/usr/bin/openroad"
export KLAYOUT_CMD="/usr/local/bin/klayout"
export EQUIVALENCE_CHECK=0
# QT_QPA_PLATFORM=offscreen 은 headless ORFS 실행 시에만 사용
# GUI를 쓸 때는 설정하지 않는다

# OpenRAM
export OPENRAM_HOME="$PROJECT_ROOT/tools/OpenRAM/compiler"
export OPENRAM_TECH="$PROJECT_ROOT/tools/OpenRAM/technology"
export PYTHONPATH="$OPENRAM_HOME:${PYTHONPATH:-}"

echo "[env] PROJECT_ROOT=$PROJECT_ROOT"
echo "[env] PDK=$PDK | ORFS=$ORFS"
echo "[env] YOSYS=$YOSYS_EXE"
echo "[env] tools → $LOCAL/bin"
