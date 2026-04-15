#!/bin/bash
# 오픈소스 EDA 도구 빌드 스크립트
# Usage: bash scripts/setup_tools.sh
set -e

LOCAL="$HOME/local"
mkdir -p "$LOCAL"
NPROC=$(nproc)

echo "============================================"
echo " OpenSoC-RTL2GDS: Tool Setup"
echo " Install prefix: $LOCAL"
echo " Parallel jobs: $NPROC"
echo "============================================"

cd "$(dirname "$0")/../tools"

# --- Step 1: Magic ---
echo "[1/4] Building Magic..."
if [ ! -d magic ]; then
    git clone https://github.com/RTimothyEdwards/magic.git magic
fi
cd magic
make distclean 2>/dev/null || true
./configure --prefix="$LOCAL" --without-tcl --without-opengl
make -j"$NPROC"
make install
cd ..
echo "[1/4] Magic installed: $([ -x $LOCAL/bin/magic ] && echo "OK ($LOCAL/bin/magic)" || echo 'FAILED')"

# --- Step 2: Netgen ---
echo "[2/4] Building Netgen..."
if [ ! -d netgen ]; then
    git clone https://github.com/RTimothyEdwards/netgen.git netgen
fi
cd netgen
make distclean 2>/dev/null || true
./configure --prefix="$LOCAL"
make -j"$NPROC"
mkdir -p "$LOCAL/lib/netgen/python"
make install
cd ..
echo "[2/4] Netgen installed."

# --- Step 3: OpenROAD-flow-scripts ---
echo "[3/4] Cloning OpenROAD-flow-scripts..."
if [ ! -d OpenROAD-flow-scripts ]; then
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
fi
echo "[3/4] ORFS ready."

# --- Step 4: OpenRAM ---
echo "[4/4] Setting up OpenRAM..."
if [ ! -d OpenRAM ]; then
    git clone https://github.com/VLSIDA/OpenRAM.git
fi
cd OpenRAM
pip3 install --user -r requirements.txt 2>/dev/null || true
cd ..
echo "[4/4] OpenRAM ready."

echo "============================================"
echo " Tool setup complete!"
echo " Run: source env.sh"
echo "============================================"
