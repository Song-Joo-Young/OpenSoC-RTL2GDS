# OpenSoC-RTL2GDS

Open-source RTL-to-GDS flow using SKY130 / GF180 PDK

Sample 디자인부터 RISC-V SoC 디자인까지 단계적으로 확장하는 프로젝트입니다.

## Progress

| Phase | Design | PDK | Area | Power | Timing | GDS |
|-------|--------|-----|------|-------|--------|-----|
| 1 | GCD (예제, 264 cells) | sky130hd | 3,872 µm² | 2.64mW | WNS -0.50ns | 904KB |
| 2 | Counter 8-bit | sky130hd / gf180 | 865 / 4,795 µm² | 0.27 / 5.86mW | met / met | 342KB / DEF |
| 3 | ALU 8-bit pipelined | sky130hd | ~1,600 µm² | 0.66mW | met | 750KB |
| 4 | PicoRV32 (RV32I) | sky130hd | 102,600 µm² | 16.0mW | +4.75ns | 12MB |
| 5 | PicoRV32 + SRAM 2KB | sky130hd | 544,466 µm² | 18.2mW | +7.02ns | 32MB |
| 6 | 2x2 Systolic Array | sky130hd | 17,224 µm² | 7.73mW | +4.02ns | 2.5MB |

## Quick Start

```bash
# 1. Clone                                            (<1분)
git clone git@github.com:Song-Joo-Young/OpenSoC-RTL2GDS.git
cd OpenSoC-RTL2GDS

# 2. 도구 빌드 (Tk, Magic, Netgen, Yosys)              (15~25분)
bash scripts/setup_tools.sh

# 3. PDK 빌드 (SKY130, open_pdks)                     (40~80분)
bash scripts/setup_pdk.sh

# 4. 환경 로드                                          (<1초)
source env.sh

# 5. GCD 예제 실행 — 첫 GDS                            (~1분)
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/gcd/config.mk
```

**처음 설치 + 첫 GDS까지 총 1~2시간** (주로 PDK 설치).
이후 새 디자인은 **수초~수분** (디자인 크기에 따라).

자세한 설치 및 실행 방법은 [Getting Started Guide](docs/getting_started.md)를 참고하세요.

## Tools & References

| Tool | Version | Purpose | Repository |
|------|---------|---------|------------|
| Yosys | 0.63 | RTL Synthesis | [YosysHQ/yosys](https://github.com/YosysHQ/yosys) |
| OpenROAD | v2.0 | Floorplan / Place / CTS / Route | [The-OpenROAD-Project/OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) |
| OpenSTA | 2.6.0 | Static Timing Analysis (standalone) | [The-OpenROAD-Project/OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) |
| ORFS | b811251d2 | Automated RTL-to-GDS flow scripts | [The-OpenROAD-Project/OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) |
| KLayout | 0.29.7 | GDS viewer / DEF-to-GDS conversion | [KLayout/klayout](https://github.com/KLayout/klayout) |
| Magic | 8.3.636 | DRC (Design Rule Check) | [RTimothyEdwards/magic](https://github.com/RTimothyEdwards/magic) |
| Netgen | 1.5 | LVS (Layout vs Schematic) | [RTimothyEdwards/netgen](https://github.com/RTimothyEdwards/netgen) |
| open_pdks | latest | PDK installer (SKY130, GF180) | [RTimothyEdwards/open_pdks](https://github.com/RTimothyEdwards/open_pdks) |
| Verilator | 5.036 | RTL simulation (C++ testbench) | [verilator/verilator](https://github.com/verilator/verilator) |
| Icarus Verilog | - | RTL simulation (Verilog testbench) | [steveicarus/iverilog](https://github.com/steveicarus/iverilog) |
| OpenRAM | v1.2 | SRAM macro compiler | [VLSIDA/OpenRAM](https://github.com/VLSIDA/OpenRAM) |
| PicoRV32 | latest | RISC-V RV32IMC CPU (Phase 4-5) | [YosysHQ/picorv32](https://github.com/YosysHQ/picorv32) |

### RTL-to-GDS Flows 비교

| Flow | 특징 | Repository |
|------|------|------------|
| **ORFS** (이 프로젝트) | Makefile 기반, 개별 단계 제어 가능, 학습/커스터마이징에 적합 | [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) |
| **OpenLane 1** | Tcl 기반 자동화, DRC/LVS 내장, Google MPW tapeout 실적 다수, 현재 maintenance mode | [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) |
| **OpenLane 2** | Python 기반 모듈 아키텍처, Step/Flow 추상화, Nix 패키징, OpenLane 1 후속 | [openlane2](https://github.com/efabless/openlane2) |

> **이 프로젝트와 OpenLane의 관계**: 이 프로젝트는 ORFS를 직접 사용하여 flow의 각 단계를
> 수동으로 이해하고 구축하는 것이 목적입니다. OpenLane은 동일한 도구(OpenROAD, Yosys, Magic, Netgen)를
> 사용하지만 DRC/LVS까지 자동화된 완성형 flow입니다.
> 향후 이 프로젝트의 디자인을 OpenLane으로 마이그레이션하여 DRC clean + LVS pass를 확보하는 것이 다음 목표입니다.

### SoC Frameworks (참고/확장용)

| Framework | Purpose | Repository |
|-----------|---------|------------|
| Chipyard | RISC-V SoC 설계 통합 프레임워크 (Chisel 기반) | [ucb-bar/chipyard](https://github.com/ucb-bar/chipyard) |
| Rocket Chip | RISC-V CPU generator (Chipyard 핵심 컴포넌트) | [chipsalliance/rocket-chip](https://github.com/chipsalliance/rocket-chip) |
| PULP Platform | 저전력 RISC-V SoC (SystemVerilog 기반) | [pulp-platform/pulpissimo](https://github.com/pulp-platform/pulpissimo) |
| LiteX | Python 기반 FPGA SoC builder | [enjoy-digital/litex](https://github.com/enjoy-digital/litex) |

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
┌─────────┐      ┌──────────┐
│  Yosys  │────▶ │ Synthesis│
└─────────┘      └────┬─────┘
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
| [Study Roadmap](docs/study_roadmap.md) | **시작점**: 이 프로젝트를 보는 순서 (Level 1~5) |
| [Training Guide](docs/training_guide.md) | Step-by-step 실습: RTL 작성부터 GDS까지 따라하기 |
| [Getting Started](docs/getting_started.md) | 환경 구축 + 첫 GDS 가이드 |
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
