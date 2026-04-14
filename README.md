# OpenSoC-RTL2GDS

Open-source RTL-to-GDS flow using SKY130 / GF180 PDK.

## Goal

오픈소스 도구만으로 RTL → Synthesis → PnR → DRC/LVS → GDS 전체 파이프라인 구축.
작은 디자인부터 RISC-V SoC + SRAM까지 단계적으로 확장.

## Progress

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | 환경 구축 (도구 + PDK + Git) | Done |
| 1 | GCD 예제 → 첫 GDS (904KB, sky130hd) | Done |
| 2 | Custom RTL → GDS (SKY130 + GF180) | - |
| 3 | ALU (timing closure 연습) | - |
| 4 | PicoRV32 RISC-V core | - |
| 5 | SoC + SRAM (OpenRAM) | - |

## Tools

| Tool | Purpose |
|------|---------|
| Yosys | Synthesis |
| OpenROAD | Floorplan / Place / CTS / Route |
| OpenROAD-flow-scripts | Automated RTL-to-GDS flow |
| KLayout | GDS viewer |
| Magic | DRC |
| Netgen | LVS |
| Verilator | RTL simulation |
| OpenRAM | SRAM macro compiler |

## Setup

```bash
source env.sh
```

## Directory Structure

```
designs/      RTL designs (tracked)
tools/        Open-source EDA tools (submodules)
pdk/          Built PDK files (not tracked)
results/      Flow outputs (not tracked)
scripts/      Automation scripts
docs/         Notes and progress logs
```
