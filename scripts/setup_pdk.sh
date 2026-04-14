#!/bin/bash
# PDK 빌드 스크립트 (SKY130 + GF180)
# Prerequisites: Magic must be installed first
# Usage: bash scripts/setup_pdk.sh
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDK_DEST="$PROJECT_ROOT/pdk"
NPROC=$(nproc)

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

echo "[1/2] Configuring open_pdks (SKY130 + GF180)..."
./configure \
    --prefix="$PDK_DEST" \
    --enable-sky130-pdk \
    --enable-gf180mcu-pdk

echo "[2/2] Building PDKs (this takes a while)..."
make -j"$NPROC"
make install

echo "============================================"
echo " PDK setup complete!"
echo " SKY130: $PDK_DEST/sky130A/"
echo " GF180:  $PDK_DEST/gf180mcuA/"
echo "============================================"
