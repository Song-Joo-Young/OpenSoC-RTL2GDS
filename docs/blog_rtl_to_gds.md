# 오픈소스 도구로 RTL에서 GDS까지: 4-bit Counter 칩 설계 전 과정

> 오픈소스 EDA 도구만으로 Verilog RTL을 작성하고, 실제 반도체 제조용 GDS-II 파일까지
> 만드는 전체 과정을 단계별로 기록합니다.

---

## 목차

1. [전체 Flow 개요](#1-전체-flow-개요)
2. [사용 도구](#2-사용-도구)
3. [Step 1: RTL 설계](#step-1-rtl-설계)
4. [Step 2: 기능 검증 (Simulation)](#step-2-기능-검증-simulation)
5. [Step 3: 논리 합성 (Synthesis)](#step-3-논리-합성-synthesis)
6. [Step 4: 정적 타이밍 분석 (STA)](#step-4-정적-타이밍-분석-sta)
7. [Step 5: 플로어플랜 (Floorplan)](#step-5-플로어플랜-floorplan)
8. [Step 6: 배치 (Placement)](#step-6-배치-placement)
9. [Step 7: 클럭 트리 합성 (CTS)](#step-7-클럭-트리-합성-cts)
10. [Step 8: 라우팅 (Routing)](#step-8-라우팅-routing)
11. [Step 9: 기생 성분 추출 + STA](#step-9-기생-성분-추출--post-route-sta)
12. [Step 10: GDS 생성](#step-10-gds-생성)
13. [Step 11: Physical Verification (DRC/LVS)](#step-11-physical-verification-drclvs)
14. [결과 요약](#결과-요약)
15. [OpenLane과의 관계](#openlane과의-관계)

---

## 1. 전체 Flow 개요

반도체 설계에서 "RTL-to-GDS"란 사람이 작성한 하드웨어 기술(RTL)을
공장에서 제조 가능한 레이아웃 파일(GDS-II)로 변환하는 전체 과정입니다.

```
┌─────────────────────────────────────────────────────────────┐
│                    RTL-to-GDS Flow                          │
│                                                             │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                │
│  │ RTL 설계  │──▶│ Simulation│──▶│ Synthesis│                │
│  │ (Verilog) │   │(Verilator)│   │ (Yosys)  │                │
│  └──────────┘   └──────────┘   └────┬─────┘                │
│                                      │                      │
│                                      ▼                      │
│  ┌──────────┐   ┌──────────────────────────────────────┐   │
│  │   STA    │◀──│            OpenROAD                   │   │
│  │(OpenSTA) │──▶│  Floorplan → Place → CTS → Route     │   │
│  └──────────┘   └───────────────────┬──────────────────┘   │
│                                      │                      │
│                    ┌─────────────────┼─────────────────┐   │
│                    ▼                 ▼                 ▼    │
│              ┌──────────┐   ┌──────────┐   ┌──────────┐   │
│              │   GDS    │   │   DRC    │   │   LVS    │   │
│              │ (KLayout)│   │ (Magic)  │   │ (Netgen) │   │
│              └──────────┘   └──────────┘   └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 사용 도구

| 도구 | 버전 | 역할 | 상용 도구 대응 |
|------|------|------|--------------|
| [Yosys](https://github.com/YosysHQ/yosys) | 0.63 | RTL 합성 | Synopsys Design Compiler |
| [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) | 2.6.0 | 정적 타이밍 분석 | Synopsys PrimeTime |
| [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) | v2.0 | PnR (배치+배선) | Cadence Innovus |
| [KLayout](https://github.com/KLayout/klayout) | 0.29.7 | GDS 뷰어/생성 | Mentor Calibre (일부) |
| [Magic](https://github.com/RTimothyEdwards/magic) | 8.3 | DRC | Mentor Calibre DRC |
| [Netgen](https://github.com/RTimothyEdwards/netgen) | 1.5 | LVS | Mentor Calibre LVS |
| [Verilator](https://github.com/verilator/verilator) | 5.036 | RTL 시뮬레이션 | Synopsys VCS |
| [ORFS](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) | b811251 | Flow 자동화 | (자체 스크립트) |

**PDK**: [SkyWater SKY130](https://github.com/google/skywater-pdk) (130nm, 오픈소스)

---

## Step 1: RTL 설계

가장 간단한 동기식 회로를 만듭니다: **4-bit counter**.

```verilog
// counter4.v
module counter4 (
    input  wire       clk,      // 클럭
    input  wire       rst_n,    // 리셋 (active-low)
    input  wire       en,       // 카운트 enable
    output reg  [3:0] count     // 4-bit 출력
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'b0000;   // 리셋 → 0
        else if (en)
            count <= count + 1'b1;  // 1씩 증가
    end

endmodule
```

**이 회로의 특징:**
- 클럭 상승 에지에서 동작 (동기식)
- 비동기 리셋 (`negedge rst_n`)
- 4-bit이므로 0 → 15 → 0 반복 (overflow)
- 필요한 하드웨어: FF 4개 + Adder + MUX

---

## Step 2: 기능 검증 (Simulation)

**도구: Verilator**

RTL이 의도대로 동작하는지 시뮬레이션으로 확인합니다.
이 단계를 건너뛰고 합성하면, 버그가 있는 회로의 레이아웃을 만드는 것이 됩니다.

```bash
verilator --cc --exe --build -Wno-fatal \
  -Mdir build --top-module counter4 \
  src/counter4.v tb/tb_counter4.cpp

./build/Vcounter4
```

**결과:**
```
After reset: count=0 (expected 0)
Cycle  1: count= 1 OK
Cycle  2: count= 2 OK
...
Cycle 15: count=15 OK
Cycle 16: count= 0 OK    ← 4-bit overflow (15+1=0)
...
Enable=0 hold: count=4 OK

=== ALL TESTS PASSED ===
```

검증 항목:
- 리셋 후 0인가?
- 매 클럭마다 1씩 증가하는가?
- 15 → 0 overflow가 정상인가?
- enable=0이면 멈추는가?

---

## Step 3: 논리 합성 (Synthesis)

**도구: Yosys**

RTL(행위 기술)을 실제 게이트(AND, OR, FF 등)로 변환합니다.
이 과정에서 PDK의 Standard Cell Library를 사용합니다.

```bash
# ORFS를 통한 합성
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk synth
```

**합성 결과 확인:**
```bash
cat reports/sky130hd/counter4/base/synth_stat.txt
```

```
=== counter4 ===
   Number of wires:          12
   Number of wire bits:      15
   Number of cells:          11

   sky130_fd_sc_hd__dfrtp_1       4    ← D-FF with async reset (4-bit register)
   sky130_fd_sc_hd__ha_1          1    ← half adder
   sky130_fd_sc_hd__mux2_2        1    ← 2:1 MUX (enable 선택)
   sky130_fd_sc_hd__nand2_1       1    ← NAND gate
   sky130_fd_sc_hd__nand4_1       1    ← 4-input NAND
   sky130_fd_sc_hd__xnor2_1       2    ← XNOR gate (adder 일부)
   sky130_fd_sc_hd__xor2_1        1    ← XOR gate

   Chip area: 160.15 um²
   Sequential: 62.50% of area
```

**해석:**
- `dfrtp` × 4 = 4-bit register (D Flip-Flop with Reset, Total 100µm²)
- `ha` + `xor` + `xnor` = ripple carry adder (count + 1)
- `mux2` = enable 제어 (en ? count+1 : count)
- `nand2`, `nand4` = carry 로직
- 총 11개 셀, 160µm² → 4-bit counter에 최적화된 합성 결과
- 전체 면적의 62.5%가 FF (sequential 우세 → 간단한 로직)

**생성된 파일:**
- `results/.../1_synth.v` — gate-level netlist (Verilog)
- `results/.../1_synth.odb` — OpenROAD database

---

## Step 4: 정적 타이밍 분석 (STA)

**도구: OpenSTA**

합성된 넷리스트가 타이밍 제약(clock period)을 만족하는지 분석합니다.
STA는 모든 가능한 경로를 정적으로 검사하므로, 시뮬레이션보다 완전합니다.

### SDC (Synopsys Design Constraints)

```tcl
# constraint.sdc
create_clock [get_ports clk] -name core_clock -period 10.0
set_input_delay  2.0 -clock core_clock [all_inputs]
set_output_delay 2.0 -clock core_clock [all_outputs]
```

- `period 10.0` = 100MHz 목표
- `input_delay 2.0` = 외부 입력이 클럭 후 2ns에 도착
- `output_delay 2.0` = 출력이 클럭 전 2ns까지 안정되어야 함

### Standalone STA 실행

합성 직후, OpenROAD 없이 OpenSTA만으로 타이밍 확인:

```bash
sta -exit << 'EOF'
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/sky130hd/counter4/base/1_synth.v
link_design counter4
read_sdc designs/sky130hd/counter4/constraint.sdc

report_checks -path_delay max
report_checks -path_delay min
report_tns
report_wns
EOF
```

### STA 리포트 읽는 법

```
Startpoint: count[0]$_DFFE_PN0P_
            (rising edge-triggered flip-flop clocked by core_clock)
Endpoint:   count[1]$_DFFE_PN0P_
            (rising edge-triggered flip-flop clocked by core_clock)
Path Group: core_clock
Path Type: max (setup check)

  Delay    Time   Description
---------------------------------------------------------
   0.00    0.00   clock core_clock (rise edge)
   0.00    0.00   clock source latency
   0.00    0.00 ^ clk (in)
   0.12    0.12 ^ clkbuf_0_clk/X (sky130_fd_sc_hd__clkbuf_4)      ← CTS buffer
   0.13    0.25 ^ clkbuf_1_1__f_clk/X (sky130_fd_sc_hd__clkbuf_4) ← CTS buffer
   0.00    0.25 ^ count[0]$_DFFE_PN0P_/CLK (sky130_fd_sc_hd__dfrtp_1)
   0.42    0.67 v count[0]$_DFFE_PN0P_/Q → FF 출력 (0.42ns delay)
   0.30    0.97 v _14_/SUM (sky130_fd_sc_hd__ha_1)   ← half adder
   0.30    1.27 v _08_/X (sky130_fd_sc_hd__mux2_1)   ← enable mux
   0.00    1.27 v count[1]$_DFFE_PN0P_/D              ← 다음 FF 입력
           1.27   data arrival time

  10.00   10.00   clock core_clock (rise edge)
   0.12   10.12 ^ clkbuf_0_clk/X
   0.13   10.25 ^ clkbuf_1_0__f_clk/X
   0.00   10.25 ^ count[1]$_DFFE_PN0P_/CLK
  -0.12   10.12   library setup time
          10.12   data required time
---------------------------------------------------------
          10.12   data required time
          -1.27   data arrival time
---------------------------------------------------------
           8.85   slack (MET)
```

**핵심 해석:**
- **data arrival time** = 1.27ns — 데이터가 FF에 도달하는 시간
  - clock buffer delay (0.25ns) + FF CLK→Q (0.42ns) + adder (0.30ns) + mux (0.30ns)
- **data required time** = 10.12ns — 데이터가 도달해야 하는 마감 시간
- **slack = 8.85ns (MET)** — 여유 시간. 양수면 OK, 음수면 violation
- 이 디자인은 10ns clock에서 매우 여유로움 → `period 1.5`까지 줄여도 될 수 있음
- CTS buffer가 2단 (`clkbuf_0`, `clkbuf_1_x`)으로 clock skew를 0.00ns로 맞춤

### STA가 중요한 이유

| 검사 | 의미 | 위반 시 |
|------|------|---------|
| Setup check | 데이터가 클럭 전에 도착하는가 | 기능 오류 (잘못된 값 래치) |
| Hold check | 데이터가 클럭 후에도 유지되는가 | 기능 오류 (글리치) |
| Max transition | 신호 전환이 너무 느리지 않은가 | 신뢰성 문제 |
| Max capacitance | 출력 부하가 과하지 않은가 | 신뢰성/타이밍 문제 |

---

## Step 5: 플로어플랜 (Floorplan)

**도구: OpenROAD (ifp, pdn)**

칩의 물리적 크기를 결정하고, 전원 네트워크를 만듭니다.

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk floorplan
```

**이 단계에서 일어나는 일:**

1. **코어 면적 계산**: `CORE_UTILIZATION=40%` → 셀 면적의 2.5배
2. **행(Row) 생성**: standard cell을 배치할 격자 생성
3. **IO 핀 배치**: clk, rst_n, en, count[3:0]의 물리적 위치
4. **전원 네트워크**: VDD/VSS 링과 스트랩
5. **탭셀**: 웰 전위 고정을 위한 셀 삽입

---

## Step 6: 배치 (Placement)

**도구: OpenROAD (gpl, dpl, rsz)**

합성된 셀들을 행 위에 배치합니다.

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk place
```

**세부 과정:**
1. **Global Placement** (gpl) — 최적 위치 대략 결정 (wirelength 최소화)
2. **Resizing** (rsz) — 타이밍을 맞추기 위해 셀 크기 조정, 버퍼 삽입
3. **Detailed Placement** (dpl) — 행에 맞춰 합법적(legal) 위치로 조정

---

## Step 7: 클럭 트리 합성 (CTS)

**도구: OpenROAD (cts/TritonCTS)**

모든 FF에 클럭을 균일하게 전달하는 버퍼 트리를 만듭니다.

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk cts
```

**왜 필요한가:**
- 클럭이 FF마다 다른 시간에 도착하면 = **clock skew**
- skew가 크면 setup/hold violation 발생
- CTS는 버퍼를 삽입하여 skew를 최소화

4-bit counter는 FF가 4개뿐이라 CTS가 간단하지만,
PicoRV32 같은 CPU에서는 수천 개 FF에 클럭을 분배해야 하므로 CTS가 핵심 단계가 됩니다.

---

## Step 8: 라우팅 (Routing)

**도구: OpenROAD (grt/FastRoute, drt/TritonRoute)**

셀 간의 논리적 연결을 실제 금속선으로 만듭니다.

```bash
touch reports/sky130hd/counter4/base/congestion.rpt
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk route
```

**세부 과정:**
1. **Global Routing** — 각 넷이 어떤 영역을 지나갈지 대략 결정
2. **Detailed Routing** — 실제 메탈 레이어에 트랙 할당, DRC 준수
3. **Fill Cell** — 빈 공간에 더미 셀 삽입 (제조 균일성)

SKY130에서 사용 가능한 메탈 레이어:
- li1 (local interconnect)
- met1 ~ met5 (metal 1~5)

---

## Step 9: 기생 성분 추출 + Post-Route STA

**도구: OpenROAD (rcx), OpenSTA**

라우팅 후 실제 금속선의 저항(R)과 커패시턴스(C)를 추출하고,
이를 반영한 정확한 타이밍 분석을 수행합니다.

```bash
# SPEF 추출 (ORFS에서 자동 수행)
# 결과: results/.../6_final.spef

# Post-route STA
sta -exit << 'EOF'
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/sky130hd/counter4/base/6_final.v
link_design counter4
read_sdc designs/sky130hd/counter4/constraint.sdc
read_spef results/sky130hd/counter4/base/6_final.spef

report_checks -path_delay max -format full_clock_expanded
report_checks -path_delay min
report_tns
report_wns
report_power
EOF
```

**Pre-route vs Post-route STA:**

| 구분 | Pre-route | Post-route |
|------|-----------|------------|
| 기생 성분 | 추정값 (estimated) | 실제 추출값 (SPEF) |
| 정확도 | 낮음 | 높음 |
| 시점 | Placement 후 | Routing 후 |
| 결과 기준 | 참고용 | **Sign-off 기준** |

---

## Step 10: GDS 생성

**도구: KLayout**

DEF(배치 정보) + Standard Cell GDS → 최종 GDS-II 합성

```bash
# Merged LEF 생성
cat platforms/sky130hd/lef/sky130_fd_sc_hd.tlef \
    platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef \
    > results/sky130hd/counter4/base/merged.lef

# DEF → GDS
klayout -zz \
  -rd design_name=counter4 \
  -rd in_def=./results/sky130hd/counter4/base/6_final.def \
  -rd in_files="./platforms/sky130hd/gds/sky130_fd_sc_hd.gds" \
  -rd out_file=./results/sky130hd/counter4/base/6_final.gds \
  -rd seal_file="" \
  -rd tech_file=./platforms/sky130hd/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py
```

**GDS-II 파일이란:**
- 반도체 공장(fab)에 보내는 최종 파일
- 각 레이어(metal, poly, diffusion 등)의 기하학적 도형 정보
- 이 파일로 마스크를 만들어 웨이퍼에 패터닝

---

## Step 11: Physical Verification (DRC/LVS)

### DRC (Design Rule Check)

**도구: Magic**

제조 공정의 물리적 규칙(최소 폭, 최소 간격 등)을 위반하지 않는지 검사합니다.

```bash
magic -dnull -noconsole -T sky130A << 'EOF'
gds read results/sky130hd/counter4/base/6_final.gds
load counter4
select top cell
drc check
drc count
EOF
```

### LVS (Layout vs Schematic)

**도구: Netgen**

레이아웃에서 추출한 넷리스트가 원래 설계(schematic)와 일치하는지 확인합니다.

```bash
netgen -batch lvs \
  "results/sky130hd/counter4/base/6_final.spice counter4" \
  "results/sky130hd/counter4/base/6_final.v counter4" \
  $PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \
  reports/sky130hd/counter4/base/lvs_result.log
```

**DRC clean + LVS pass = 제조 가능한 설계**

---

## 결과 요약

### 4-bit Counter on SKY130 (130nm)

| 항목 | 값 |
|------|-----|
| RTL | 15줄 Verilog |
| 합성 셀 수 | 11개 (FF 4개 + 논리 7개) |
| Clock period | 10ns (100MHz) |
| Critical path delay | 1.27ns |
| Setup slack | +8.85ns (MET) |
| Hold slack | +0.51ns (MET) |
| WNS / TNS | 0.00 / 0.00 (violation 없음) |
| Area | 235 µm² (16% utilization) |
| Total Power | 0.0785mW (78.5µW) |
| - Sequential | 34.3µW (43.7%) |
| - Combinational | 21.7µW (27.6%) |
| - Clock | 22.5µW (28.7%) |
| Slew/Cap/Fanout violation | 0 / 0 / 0 |
| GDS 크기 | 114KB |

### 전체 Flow 소요 시간

| 단계 | 소요 시간 |
|------|----------|
| RTL 작성 | 5분 |
| Simulation | 3초 |
| Synthesis | 1초 |
| Floorplan | 1초 |
| Placement | 1초 |
| CTS | 1초 |
| Routing | 2초 |
| GDS 생성 | 1초 |
| **총합** | **~10초** (도구 실행만) |

---

## OpenLane과의 관계

이 글에서는 ORFS + 개별 도구를 수동으로 실행하여 각 단계를 이해했습니다.

**OpenLane**은 동일한 도구들을 사용하지만:
- DRC/LVS까지 **자동 실행**
- Design exploration (최적 설정 탐색)
- Google MPW shuttle을 통한 **실제 tapeout 실적** 다수

| | 이 가이드 (ORFS) | OpenLane |
|---|---|---|
| 목적 | 학습, 각 단계 이해 | 실제 칩 제작 |
| DRC/LVS | 수동 실행 | 자동 |
| 설정 | config.mk + SDC | config.json |
| Tapeout 실적 | 없음 | striVe SoC 등 다수 |

**추천 경로:**
1. 이 가이드로 flow 이해 → 2. OpenLane으로 자동화 → 3. 실제 tapeout (Google MPW 등)

---

## 참고 자료

- [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) — PnR 엔진
- [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) — 타이밍 분석
- [Yosys](https://github.com/YosysHQ/yosys) — RTL 합성
- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) — Flow 자동화
- [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) / [OpenLane 2](https://github.com/efabless/openlane2) — 완성형 RTL-to-GDS
- [OpenRAM](https://github.com/VLSIDA/OpenRAM) — SRAM 컴파일러
- [SKY130 PDK](https://github.com/google/skywater-pdk) — 오픈소스 130nm PDK
- [Magic](https://github.com/RTimothyEdwards/magic) — DRC
- [Netgen](https://github.com/RTimothyEdwards/netgen) — LVS
- [KLayout](https://github.com/KLayout/klayout) — GDS 뷰어
- [Verilator](https://github.com/verilator/verilator) — RTL 시뮬레이터
- [OpenLane Paper (ICCAD 2020)](https://doi.org/10.1145/3400302.3415735) — striVe SoC tapeout
