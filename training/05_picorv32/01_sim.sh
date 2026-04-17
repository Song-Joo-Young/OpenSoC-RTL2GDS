#!/bin/bash
# Step 1: Lint/Smoke Check — PicoRV32는 별도 로컬 testbench 대신 lint로 시작
set -e
source "$(dirname "$0")/design.cfg"

echo "========== Verilator Lint =========="
echo "RTL:  $RTL_FILES"
echo "Top:  $TOP_MODULE"
echo ""

verilator --lint-only -Wno-fatal \
  --top-module "$TOP_MODULE" \
  $RTL_FILES

echo ""
echo "PASS: picorv32 lint completed"
echo ""
echo "다음: bash 02_setup_ORFS.sh"
