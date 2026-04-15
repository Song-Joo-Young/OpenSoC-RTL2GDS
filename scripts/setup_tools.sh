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

# 이후 빌드에서 $LOCAL이 우선 검색되도록
export PATH="$LOCAL/bin:$PATH"
export LD_LIBRARY_PATH="$LOCAL/lib:${LD_LIBRARY_PATH:-}"
export CPATH="$LOCAL/include:${CPATH:-}"
export PKG_CONFIG_PATH="$LOCAL/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

cd "$(dirname "$0")/../tools"
TOOLS_DIR="$(pwd)"

# --- Step 0: Tk (local) — Magic Tcl 빌드용 ---
# 시스템에 tk-devel이 없고 sudo가 없을 때 Tk를 local에 빌드
if [ ! -f "$LOCAL/lib/tkConfig.sh" ] && [ ! -f /usr/lib64/tkConfig.sh ]; then
    echo "[0/4] Building Tk locally (tk-devel not found system-wide)..."
    TK_VER="8.6.14"
    if [ ! -d "tk$TK_VER" ]; then
        wget -q "https://prdownloads.sourceforge.net/tcl/tk$TK_VER-src.tar.gz"
        tar xf "tk$TK_VER-src.tar.gz"
        rm -f "tk$TK_VER-src.tar.gz"
    fi
    cd "tk$TK_VER/unix"
    ./configure --prefix="$LOCAL" --with-tcl=/usr/lib64 >/dev/null
    make -j"$NPROC" >/dev/null
    make install >/dev/null
    cd "$TOOLS_DIR"
    echo "[0/4] Tk installed → $LOCAL/lib/tkConfig.sh"
else
    echo "[0/4] Tk already available, skipping."
fi

# tkConfig.sh 위치 결정
if [ -f "$LOCAL/lib/tkConfig.sh" ]; then
    TK_CONFIG_DIR="$LOCAL/lib"
else
    TK_CONFIG_DIR="/usr/lib64"
fi

# --- Step 1: Magic (with Tcl/Tk for --version support, no OpenGL) ---
echo "[1/4] Building Magic (Tcl/Tk enabled, no OpenGL)..."
if [ ! -d magic ]; then
    git clone https://github.com/RTimothyEdwards/magic.git magic
fi
cd magic
make distclean 2>/dev/null || true
./configure --prefix="$LOCAL" \
    --with-tcl=/usr/lib64 --with-tk="$TK_CONFIG_DIR" \
    --without-opengl
make -j"$NPROC"
make install
cd ..

# 검증: magic --version 반드시 동작해야 open_pdks에서 에러 안남
if magic --version 2>&1 | grep -q "[0-9]\+\.[0-9]\+"; then
    echo "[1/4] Magic installed: $(magic --version 2>&1 | head -1)"
else
    echo "[1/4] ERROR: magic --version did not return a version string"
    magic --version 2>&1 || true
    exit 1
fi

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
echo "[2/4] Netgen installed: $LOCAL/bin/netgen"

# --- Step 3: OpenROAD-flow-scripts ---
echo "[3/4] Cloning OpenROAD-flow-scripts..."
if [ ! -d OpenROAD-flow-scripts ]; then
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
    # 시스템 OpenROAD v2.0-16595 (2024-10-16)에 맞춰 체크아웃
    cd OpenROAD-flow-scripts
    git checkout b811251d2 2>/dev/null || true
    cd ..
fi
echo "[3/4] ORFS ready."

# --- Step 3b: ORFS 내장 Yosys 빌드 (clang 필수) ---
if [ ! -x OpenROAD-flow-scripts/tools/install/yosys/bin/yosys ]; then
    echo "[3b/4] Building Yosys (clang) inside ORFS..."
    cd OpenROAD-flow-scripts/tools/yosys
    make clean 2>/dev/null || true
    make -j"$NPROC" CC=clang CXX=clang++ \
        PREFIX="$TOOLS_DIR/OpenROAD-flow-scripts/tools/install/yosys"
    make install CC=clang CXX=clang++ \
        PREFIX="$TOOLS_DIR/OpenROAD-flow-scripts/tools/install/yosys"
    cd "$TOOLS_DIR"
    echo "[3b/4] Yosys installed: $($TOOLS_DIR/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys -V 2>&1 | head -1)"
else
    echo "[3b/4] Yosys already built."
fi

# --- Step 4: OpenRAM ---
echo "[4/4] Setting up OpenRAM..."
if [ ! -d OpenRAM ]; then
    git clone https://github.com/VLSIDA/OpenRAM.git
fi
cd OpenRAM
pip3 install --user -r requirements.txt 2>/dev/null || true
cd ..
echo "[4/4] OpenRAM ready."

# pyyaml은 ORFS scripts/defaults.py에서 필요
pip3.11 install --user pyyaml 2>/dev/null || pip3 install --user pyyaml 2>/dev/null || true

echo "============================================"
echo " Tool setup complete!"
echo ""
echo " Next: bash scripts/setup_pdk.sh"
echo " Then: source env.sh"
echo "============================================"
