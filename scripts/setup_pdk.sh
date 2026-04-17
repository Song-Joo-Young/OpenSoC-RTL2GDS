#!/bin/bash
# PDK 빌드 스크립트 (SKY130 전용)
# Prerequisites: Magic must be installed first
# Usage: bash scripts/setup_pdk.sh
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDK_DEST="$PROJECT_ROOT/pdk"
NPROC=$(nproc)

# Magic이 $HOME/local/bin에 설치되어 있으므로 PATH에 추가
export PATH="$HOME/local/bin:$PATH"

# Magic 설치 확인
if ! command -v magic >/dev/null 2>&1; then
    echo "ERROR: 'magic' not found in PATH."
    echo "Run 'bash scripts/setup_tools.sh' first."
    exit 1
fi
echo "Using magic: $(which magic)"

echo "============================================"
echo " OpenSoC-RTL2GDS: PDK Setup"
echo " Destination: $PDK_DEST"
echo "============================================"

cd "$PROJECT_ROOT/tools"

# --- open_pdks ---
if [ ! -d open_pdks ]; then
    git clone https://github.com/RTimothyEdwards/open_pdks.git
fi

cd open_pdks

echo "[1/2] Configuring open_pdks (SKY130 only)..."
./configure --prefix="$PDK_DEST" --enable-sky130-pdk

echo "[2/2] Building PDK (default SKY130, ~30-60 min)..."
# RF/analog cell 일부가 누락되어 make가 실패할 수 있으나 digital flow에는 영향 없음.
# 실패해도 install 단계로 진행하여 가능한 만큼 설치.
make -j"$NPROC" || echo "WARNING: make had errors (likely missing RF/analog cells — OK for digital flow)"
make install || echo "WARNING: make install had errors — checking result..."

# 핵심 파일이 설치되었는지 검증 (digital flow에 필수)
SC_LIB="$PDK_DEST/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib"
if [ -d "$SC_LIB" ] && [ -n "$(ls -A "$SC_LIB" 2>/dev/null)" ]; then
    echo "============================================"
    echo " PDK setup complete!"
    echo " SKY130: $PDK_DEST/share/pdk/sky130A/"
    echo " Standard cells: OK ($SC_LIB)"
    echo "============================================"
else
    echo "ERROR: sky130_fd_sc_hd not installed at $SC_LIB"
    echo "Try: cd tools/open_pdks && make install"
    exit 1
fi
