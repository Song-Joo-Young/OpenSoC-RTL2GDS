# OpenSoC-RTL2GDS

Open-source RTL-to-GDS flow using SKY130 / GF180 PDK.
작은 디자인부터 RISC-V SoC + SRAM까지 단계적으로 확장하는 프로젝트입니다.

## Progress

| Phase | Design | PDK | Area | Power | Timing | GDS |
|-------|--------|-----|------|-------|--------|-----|
| 1 | GCD (예제, 264 cells) | sky130hd | 3,872 µm² | 2.64mW | WNS -0.50ns | 904KB |
| 2 | Counter 8-bit | sky130hd / gf180 | 865 / 4,795 µm² | 0.27 / 5.86mW | met / met | 342KB / DEF |
| 3 | ALU 8-bit pipelined | sky130hd | ~1,600 µm² | 0.66mW | met | 750KB |
| 4 | PicoRV32 (RV32I) | sky130hd | 102,600 µm² | 16.0mW | +4.75ns | 12MB |
| 5 | PicoRV32 + SRAM 2KB | sky130hd | 544,466 µm² | 18.2mW | +7.02ns | 32MB |

## Quick Start

```bash
# 1. Clone
git clone git@github.com:Song-Joo-Young/OpenSoC-RTL2GDS.git
cd OpenSoC-RTL2GDS

# 2. 도구 빌드 (Magic, Netgen, Yosys)
bash scripts/setup_tools.sh

# 3. PDK 빌드 (SKY130)
bash scripts/setup_pdk.sh

# 4. 환경 로드
source env.sh

# 5. GCD 예제 실행 (첫 GDS)
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/gcd/config.mk
```

자세한 설치 및 실행 방법은 [Getting Started Guide](docs/getting_started.md)를 참고하세요.

## Tools & References

| Tool | Version | Purpose | Repository |
|------|---------|---------|------------|
| Yosys | 0.63 | RTL Synthesis | [YosysHQ/yosys](https://github.com/YosysHQ/yosys) |
| OpenROAD | v2.0 | Floorplan / Place / CTS / Route | [The-OpenROAD-Project/OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) |
| ORFS | b811251d2 | Automated RTL-to-GDS flow scripts | [The-OpenROAD-Project/OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) |
| KLayout | 0.29.7 | GDS viewer / DEF-to-GDS conversion | [KLayout/klayout](https://github.com/KLayout/klayout) |
| Magic | 8.3.636 | DRC (Design Rule Check) | [RTimothyEdwards/magic](https://github.com/RTimothyEdwards/magic) |
| Netgen | 1.5 | LVS (Layout vs Schematic) | [RTimothyEdwards/netgen](https://github.com/RTimothyEdwards/netgen) |
| open_pdks | latest | PDK installer (SKY130, GF180) | [RTimothyEdwards/open_pdks](https://github.com/RTimothyEdwards/open_pdks) |
| Verilator | 5.036 | RTL simulation (C++ testbench) | [verilator/verilator](https://github.com/verilator/verilator) |
| Icarus Verilog | - | RTL simulation (Verilog testbench) | [steveicarus/iverilog](https://github.com/steveicarus/iverilog) |
| OpenRAM | v1.2 | SRAM macro compiler | [VLSIDA/OpenRAM](https://github.com/VLSIDA/OpenRAM) |
| PicoRV32 | latest | RISC-V RV32IMC CPU (Phase 4-5) | [YosysHQ/picorv32](https://github.com/YosysHQ/picorv32) |

### SoC Frameworks (참고/확장용)

| Framework | Purpose | Repository |
|-----------|---------|------------|
| Chipyard | RISC-V SoC 설계 통합 프레임워크 (Chisel 기반) | [ucb-bar/chipyard](https://github.com/ucb-bar/chipyard) |
| Rocket Chip | RISC-V CPU generator (Chipyard 핵심 컴포넌트) | [chipsalliance/rocket-chip](https://github.com/chipsalliance/rocket-chip) |
| PULP Platform | 저전력 RISC-V SoC (SystemVerilog 기반) | [pulp-platform/pulpissimo](https://github.com/pulp-platform/pulpissimo) |
| LiteX | Python 기반 FPGA SoC builder | [enjoy-digital/litex](https://github.com/enjoy-digital/litex) |
| OpenLane | RTL-to-GDS flow (efabless/Google) | [The-OpenROAD-Project/OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) |

### PDK

| PDK | Node | Source |
|-----|------|--------|
| SKY130 | 130nm | [google/skywater-pdk](https://github.com/google/skywater-pdk) |
| GF180 | 180nm | [google/gf180mcu-pdk](https://github.com/google/gf180mcu-pdk) |
| ASAP7 | 7nm (predictive) | ORFS 내장 (`platforms/asap7/`) |

## Flow Overview

```
RTL (Verilog)
    │
    ▼
┌─────────┐     ┌──────────┐
│  Yosys  │────▶│ Synthesis│
└─────────┘     └────┬─────┘
                     │
                     ▼
              ┌──────────────┐
              │   OpenROAD   │
              │  Floorplan   │
              │  Placement   │
              │    CTS       │
              │   Routing    │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │   KLayout    │
              │  GDS merge   │
              └──────┬───────┘
                     │
                     ▼
                  GDS-II
```

## Directory Structure

```
designs/          RTL designs (git tracked)
  01_gcd/           GCD example
  02_counter/       Parameterized counter
  03_alu/           Pipelined ALU
  04_picorv32/      RISC-V CPU
  05_soc/           PicoRV32 + SRAM SoC
tools/            Open-source EDA tools (not tracked, cloned by setup scripts)
pdk/              Built PDK files (not tracked)
results/          Flow outputs (not tracked)
scripts/          Setup and automation scripts
docs/             Guides, progress logs, evaluation
sram-lib-gen/     OpenRAM SRAM generation example (reference, not tracked)
```

## Documentation

| 문서 | 내용 |
|------|------|
| [Getting Started](docs/getting_started.md) | 처음부터 끝까지 설치 + 첫 GDS 가이드 |
| [Tool Analysis](docs/tool_analysis.md) | OpenROAD / ORFS / OpenRAM 내부 구조 분석 |
| [Progress Log](docs/progress.md) | Phase별 결과 수치 및 실행 명령 |
| [Evaluation](docs/evaluation.md) | 독립 평가 결과 및 개선 권장사항 |

## Known Issues

- **Headless 환경**: ORFS 6_report 단계에서 Qt GUI crash 발생.
  `QT_QPA_PLATFORM=offscreen`으로 해결 (env.sh에 포함).
- **GCD timing**: Phase 1 GCD는 aggressive clock (2.5ns)으로 인해 setup violation 존재.
  의도적으로 tight constraint를 실험한 것이며, Phase 2부터 적절한 clock으로 조정.
- **GF180 GDS**: Phase 2에서 GF180은 DEF까지만 생성. GDS merge는 미완성.
- **DRC/LVS**: Magic DRC, Netgen LVS는 도구 설치 완료. flow 자동화는 추후 추가 예정.

## Related Projects

- [sram-lib-gen](sram-lib-gen/): OpenRAM 기반 SRAM 라이브러리 생성 파이프라인 (FreePDK45).
  VeeR EL2용 SRAM 매크로 자동 생성 및 DC 합성 통합 예제.

## License

이 프로젝트는 학습 및 연구 목적입니다. 각 오픈소스 도구의 라이선스를 따릅니다.
