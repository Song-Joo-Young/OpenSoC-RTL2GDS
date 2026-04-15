#!/bin/bash
# PDK 빌드 스크립트 (SKY130 + GF180)
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

# SKY130만 빌드 (GF180은 선택, SETUP_GF180=1 환경변수로 활성화)
echo "[1/2] Configuring open_pdks (SKY130${SETUP_GF180:+ + GF180})..."
if [ "${SETUP_GF180:-0}" = "1" ]; then
    ./configure --prefix="$PDK_DEST" --enable-sky130-pdk --enable-gf180mcu-pdk
else
    ./configure --prefix="$PDK_DEST" --enable-sky130-pdk
fi

echo "[2/2] Building PDK (this takes a while, ~30-60 min)..."
make -j"$NPROC"
make install

echo "============================================"
echo " PDK setup complete!"
echo " SKY130: $PDK_DEST/sky130A/"
echo " GF180:  $PDK_DEST/gf180mcuA/"
echo "============================================"
