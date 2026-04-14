#!/bin/bash
# OpenSoC-RTL2GDS 환경 변수 설정
# Usage: source env.sh

export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOCAL="$HOME/local"

# PATH
export PATH="$LOCAL/bin:$PATH"
export LD_LIBRARY_PATH="$LOCAL/lib:${LD_LIBRARY_PATH:-}"

# PDK
export PDK_ROOT="$PROJECT_ROOT/pdk"
export PDK="sky130A"

# OpenROAD-flow-scripts
export ORFS="$PROJECT_ROOT/tools/OpenROAD-flow-scripts"

# OpenRAM
export OPENRAM_HOME="$PROJECT_ROOT/tools/OpenRAM/compiler"
export OPENRAM_TECH="$PROJECT_ROOT/tools/OpenRAM/technology"
export PYTHONPATH="$OPENRAM_HOME:${PYTHONPATH:-}"

echo "[env] PROJECT_ROOT=$PROJECT_ROOT"
echo "[env] PDK_ROOT=$PDK_ROOT (PDK=$PDK)"
echo "[env] ORFS=$ORFS"
echo "[env] tools → $LOCAL/bin"
