# RTL-to-GDS Training Guide

> 처음부터 끝까지 따라하면서 배우는 오픈소스 칩 설계 실습 가이드.
> 각 Step을 순서대로 수행하면 직접 만든 RTL에서 GDS-II 레이아웃까지 도달합니다.

---

## 이 가이드의 구성

```
Part 1: 개념 이해        — RTL-to-GDS flow가 뭔지, 왜 필요한지
Part 2: 환경 구축        — 도구 설치, PDK 설정
Part 3: 첫 RTL 작성      — 가장 간단한 디자인 (4-bit counter)
Part 4: Simulation       — 내가 만든 RTL이 맞는지 검증
Part 5: Synthesis        — RTL → Gate-level netlist
Part 6: Floorplan        — 칩의 크기와 모양 결정
Part 7: Placement        — 셀을 바닥에 배치
Part 8: CTS              — 클럭 트리 구성
Part 9: Routing          — 금속선 연결
Part 10: GDS 생성        — 최종 레이아웃 출력
Part 11: Sign-off        — DRC/LVS 검증
Part 12: 다음 단계       — 더 복잡한 디자인으로 확장
```

---

## Part 1: 개념 이해

### RTL-to-GDS란?

디지털 회로 설계에서 "아이디어 → 실제 칩"으로 가는 과정입니다:

```
    사람이 하는 것                   도구가 하는 것
    ──────────                     ──────────────
    회로 동작을                      Synthesis
    Verilog로 기술     ──────▶     (논리 게이트로 변환)
    (RTL)                              │
                                       ▼
                                  Floorplan
                                  (칩 면적 설정)
                                       │
                                       ▼
                                  Placement
                                  (셀 위치 결정)
                                       │
                                       ▼
                                  Clock Tree Synthesis
                                  (클럭 분배 네트워크)
                                       │
                                       ▼
                                  Routing
                                  (금속선 연결)
                                       │
                                       ▼
                                  Sign-off
                                  (DRC/LVS 검증)
                                       │
                                       ▼
                                  GDS-II 파일
                                  (공장에 보내는 파일)
```

### 사용하는 도구들

| 단계 | 도구 | 하는 일 |
|------|------|---------|
| RTL 작성 | 텍스트 에디터 | Verilog 코드 작성 |
| Simulation | Verilator / iverilog | RTL 기능 검증 |
| Synthesis | Yosys | Verilog → 게이트 넷리스트 변환 |
| Floorplan ~ Routing | OpenROAD | 물리적 레이아웃 생성 |
| GDS merge | KLayout | DEF → GDS 변환 |
| DRC | Magic | 제조 규칙 위반 검사 |
| LVS | Netgen | 레이아웃 vs 회로도 일치 확인 |

### PDK (Process Design Kit)란?

공장(foundry)이 제공하는 "레시피":
- **Standard Cell Library**: AND, OR, FF 등의 기본 게이트 (.lib, .lef, .gds)
- **Technology Rules**: 금속선 폭, 간격 등 제조 규칙
- **SPICE Models**: 트랜지스터 전기적 특성

이 가이드에서는 **SKY130** (SkyWater 130nm) 오픈소스 PDK를 사용합니다.

---

## Part 2: 환경 구축

### 2-1. 프로젝트 클론

```bash
git clone git@github.com:Song-Joo-Young/OpenSoC-RTL2GDS.git
cd OpenSoC-RTL2GDS
```

### 2-2. 도구 빌드

```bash
# Magic, Netgen, ORFS, OpenRAM 자동 빌드
bash scripts/setup_tools.sh

# ORFS용 Yosys 빌드 (clang 필수)
cd tools/OpenROAD-flow-scripts/tools/yosys
make -j$(nproc) CC=clang CXX=clang++ PREFIX=../install/yosys
make install CC=clang CXX=clang++ PREFIX=../install/yosys
cd ../../../..
```

### 2-3. PDK 설치

```bash
bash scripts/setup_pdk.sh
```

### 2-4. 환경 로드

```bash
source env.sh
```

> 매 터미널마다 `source env.sh` 실행 필요

### 2-5. 검증

```bash
# 각 도구가 실행되는지 확인
$YOSYS_EXE -V                    # Yosys 0.63 (...)
openroad -version                 # v2.0-XXXXX
echo "quit" | magic -d null     # (non-Tcl build: 아무 에러 없이 종료)
netgen                            # Netgen 1.5...
verilator --version               # Verilator 5.XXX
klayout -v                        # KLayout 0.29.X
```

---

## Part 3: 첫 RTL 작성

가장 간단한 디자인을 만듭니다: **4-bit counter**.

### 3-1. 디렉토리 생성

```bash
mkdir -p training/counter4/{src,tb,constraints}
cd training/counter4
```

### 3-2. RTL 작성

파일: `src/counter4.v`
```verilog
module counter4 (
    input  wire       clk,
    input  wire       rst_n,    // active-low reset
    input  wire       en,       // count enable
    output reg  [3:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'b0000;
        else if (en)
            count <= count + 1'b1;
    end

endmodule
```

**코드 해설:**
- `always @(posedge clk)` — 클럭 상승 에지마다 실행
- `rst_n` — active-low 리셋 (0이면 리셋)
- `en` — 1이면 카운트, 0이면 유지
- `count` — 4비트이므로 0~15 반복

---

## Part 4: Simulation

RTL이 의도대로 동작하는지 확인합니다.

### 4-1. 테스트벤치 작성 (Verilator용)

파일: `tb/tb_counter4.cpp`
```cpp
#include "Vcounter4.h"
#include "verilated.h"
#include <cstdio>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcounter4* dut = new Vcounter4;

    // Helper: 한 클럭 사이클
    auto tick = [&]() {
        dut->clk = 0; dut->eval();
        dut->clk = 1; dut->eval();
    };

    // 리셋
    dut->rst_n = 0; dut->en = 0;
    tick(); tick();
    printf("After reset: count=%d (expected 0)\n", dut->count);

    // 카운트 시작
    dut->rst_n = 1; dut->en = 1;
    for (int i = 0; i < 20; i++) {
        tick();
        printf("Cycle %2d: count=%2d", i+1, dut->count);
        if (dut->count == ((i+1) & 0xF))
            printf(" OK\n");
        else {
            printf(" FAIL (expected %d)\n", (i+1) & 0xF);
            return 1;
        }
    }

    // enable=0 이면 멈추는지
    dut->en = 0;
    int saved = dut->count;
    tick(); tick();
    if (dut->count == saved)
        printf("Enable=0 hold: OK (count=%d)\n", dut->count);
    else {
        printf("Enable=0 hold: FAIL\n");
        return 1;
    }

    printf("\n=== ALL TESTS PASSED ===\n");
    dut->final();
    delete dut;
    return 0;
}
```

### 4-2. 빌드 및 실행

```bash
# 빌드
verilator --cc --exe --build -Wno-fatal \
  -Mdir build --top-module counter4 \
  src/counter4.v tb/tb_counter4.cpp

# 실행
./build/Vcounter4
```

**기대 출력:**
```
After reset: count=0 (expected 0)
Cycle  1: count= 1 OK
Cycle  2: count= 2 OK
...
Cycle 16: count= 0 OK   ← 15 다음에 0으로 overflow
...
Enable=0 hold: OK (count=4)

=== ALL TESTS PASSED ===
```

> **여기서 멈추고 확인하세요!**
> Sim이 PASS가 아니면 RTL에 버그가 있는 것입니다.
> GDS까지 가봤자 의미 없으니 여기서 반드시 수정하세요.

---

## Part 5: Synthesis

RTL을 실제 게이트(AND, OR, FF 등)로 변환합니다.

### 5-1. SDC 작성

파일: `constraints/constraint.sdc`
```tcl
# 클럭 정의: 10ns 주기 = 100MHz
create_clock [get_ports clk] -name core_clock -period 10.0

# 입출력 딜레이
set_input_delay  2.0 -clock core_clock [all_inputs]
set_output_delay 2.0 -clock core_clock [all_outputs]
```

**SDC 해설:**
- `-period 10.0` — 클럭 주기 10ns (= 100MHz). 이 값이 타이밍 목표가 됩니다.
- `set_input_delay 2.0` — 외부에서 신호가 도착하는 데 2ns 걸린다고 가정
- 처음에는 clock을 느리게(10~20ns) 설정하는 것을 권장. timing violation 나면 늘리세요.

### 5-2. ORFS에 디자인 등록

```bash
# RTL 복사
mkdir -p $ORFS/flow/designs/src/counter4
cp src/counter4.v $ORFS/flow/designs/src/counter4/

# Config 생성
mkdir -p $ORFS/flow/designs/sky130hd/counter4
cp constraints/constraint.sdc $ORFS/flow/designs/sky130hd/counter4/

cat > $ORFS/flow/designs/sky130hd/counter4/config.mk << 'EOF'
export DESIGN_NAME = counter4
export PLATFORM    = sky130hd

export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/counter4.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION  = 40
export EQUIVALENCE_CHECK = 0
EOF
```

### 5-3. Synthesis 실행

```bash
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk synth
```

### 5-4. 결과 확인

```bash
# 합성 통계 — 사용된 셀 종류와 개수
cat reports/sky130hd/counter4/base/synth_stat.txt

# 생성된 넷리스트 (게이트 레벨 Verilog)
head -30 results/sky130hd/counter4/base/1_synth.v
```

**확인할 것:**
- 셀 수가 합리적인가? (4-bit counter면 10~30개 정도)
- FF가 4개인가? (4-bit register)
- 에러 없이 완료되었는가?

---

## Part 6: Floorplan

칩의 물리적 크기와 전원 네트워크를 설정합니다.

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk floorplan
```

**이 단계에서 일어나는 일:**
1. 코어 면적 계산 (CORE_UTILIZATION=40% → 셀이 면적의 40% 차지)
2. IO 핀 배치 (clk, rst_n, en, count[3:0])
3. 전원 링/스트랩 생성 (VDD, VSS)
4. 탭셀 삽입 (웰 접합 방지)

---

## Part 7: Placement

게이트(셀)들을 바닥에 배치합니다.

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk place
```

**이 단계에서 일어나는 일:**
1. Global Placement — 대략적 위치 결정 (wirelength 최소화)
2. Resizing — 타이밍 맞추기 위해 셀 크기 조정
3. Detailed Placement — 행(row)에 맞춰 정확한 위치 확정

---

## Part 8: Clock Tree Synthesis (CTS)

모든 FF에 클럭을 고르게 분배하는 트리를 만듭니다.

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk cts
```

**왜 필요한가:**
클럭이 FF마다 다른 시간에 도착하면 (clock skew) 회로가 오작동합니다.
CTS는 버퍼를 삽입하여 모든 FF에 클럭이 동시에 도착하도록 합니다.

---

## Part 9: Routing

셀들을 금속선(wire)으로 실제로 연결합니다.

```bash
# congestion report 준비 (ORFS 호환성 이슈)
touch reports/sky130hd/counter4/base/congestion.rpt

make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk route
```

**이 단계에서 일어나는 일:**
1. Global Routing — 경로의 대략적 방향 결정
2. Detailed Routing — 실제 메탈 레이어에 선 그리기
3. Fill cell 삽입 — 빈 공간 채우기 (제조 균일성)

### 결과 확인

```bash
# 타이밍 리포트
cat reports/sky130hd/counter4/base/5_global_route.rpt

# 확인할 것:
# - Clock slack이 양수인가? → timing met
# - DRC violation이 0인가?
# - Antenna violation이 0인가?
```

---

## Part 10: GDS 생성

최종 레이아웃 파일을 만듭니다.

```bash
# merged LEF 생성
cat platforms/sky130hd/lef/sky130_fd_sc_hd.tlef \
    platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef \
    > results/sky130hd/counter4/base/merged.lef

# DEF → GDS 변환
klayout -zz \
  -rd design_name=counter4 \
  -rd in_def=./results/sky130hd/counter4/base/6_final.def \
  -rd in_files="./platforms/sky130hd/gds/sky130_fd_sc_hd.gds" \
  -rd out_file=./results/sky130hd/counter4/base/6_final.gds \
  -rd seal_file="" \
  -rd tech_file=./platforms/sky130hd/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py

# 결과 확인
ls -lh results/sky130hd/counter4/base/6_final.gds
```

### GDS 시각화 (GUI 환경에서)

```bash
klayout results/sky130hd/counter4/base/6_final.gds
```

---

## Part 11: Sign-off (DRC/LVS)

### DRC (Design Rule Check)

제조 규칙 위반이 없는지 검사합니다.

```bash
export PDK_ROOT=/home/jysong/PROJECT/pdk/share/pdk

magic -d null -T sky130A << 'EOF'
gds read results/sky130hd/counter4/base/6_final.gds
load counter4
select top cell
drc check
drc count
quit
EOF
```

### LVS (Layout vs Schematic)

레이아웃이 넷리스트와 일치하는지 확인합니다.

```bash
netgen -batch lvs \
  "results/sky130hd/counter4/base/6_final.spice counter4" \
  "results/sky130hd/counter4/base/6_final.v counter4" \
  $PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \
  reports/sky130hd/counter4/base/lvs_result.log
```

---

## Part 12: 다음 단계

### 12-1. 한 번에 실행 (Full flow)

위의 Step 5~10을 한 줄로:

```bash
source env.sh && cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk
```

### 12-2. 타이밍 실험

clock period를 줄여보세요 (SDC 수정):
```tcl
# 10ns → 5ns → 2ns → 얼마까지 갈 수 있는가?
create_clock [get_ports clk] -name core_clock -period 5.0
```

### 12-3. 디자인 확장

난이도 순서:
1. **8-bit counter** — WIDTH 파라미터화 (`designs/02_counter/` 참고)
2. **ALU** — 조합+순차 혼합 (`designs/03_alu/` 참고)
3. **RISC-V CPU** — PicoRV32 (`designs/04_picorv32/` 참고)
4. **SoC + SRAM** — CPU + 메모리 통합 (`designs/05_soc/` 참고)

### 12-4. 다른 PDK로 비교

```bash
# GF180 (180nm) 으로 동일 디자인
mkdir -p $ORFS/flow/designs/gf180/counter4
# config.mk에서 PLATFORM = gf180 으로 변경
```

### 12-5. OpenLane으로 마이그레이션

ORFS에서 수동으로 배운 flow를 OpenLane으로 자동화:

```bash
# OpenLane 2 설치
pip3 install openlane

# PDK 설치 (volare)
python3 -m volare enable sky130

# config.json 작성
cat > config.json << 'EOF'
{
    "DESIGN_NAME": "counter4",
    "VERILOG_FILES": ["src/counter4.v"],
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": 10.0
}
EOF

# 실행 (DRC/LVS까지 자동)
python3 -m openlane config.json
```

---

## 핵심 체크리스트

각 단계를 완료했는지 확인하세요:

- [ ] Part 3: counter4.v 작성 완료
- [ ] Part 4: Verilator sim PASS
- [ ] Part 5: Synthesis — 셀 수 확인, 에러 없음
- [ ] Part 6: Floorplan — 코어 면적 생성됨
- [ ] Part 7: Placement — 셀 배치됨
- [ ] Part 8: CTS — 클럭 트리 생성됨
- [ ] Part 9: Routing — timing met (positive slack)
- [ ] Part 10: GDS 파일 생성됨
- [ ] Part 11: DRC clean, LVS pass

---

## 자주 하는 실수

| 실수 | 증상 | 해결 |
|------|------|------|
| clock period 너무 작음 | timing violation (negative slack) | SDC에서 period 늘리기 |
| reset 극성 잘못 | sim에서 동작 안 함 | active-low(rst_n) vs active-high(rst) 확인 |
| 모듈명 불일치 | synthesis 실패 | config.mk의 DESIGN_NAME = Verilog module 이름 |
| `source env.sh` 안 함 | 도구 못 찾음 | 매 터미널마다 실행 |
| congestion.rpt 없음 | detail_route 에러 | `touch reports/.../congestion.rpt` |

---

## 참고 자료

- [OpenLane Paper (ICCAD 2020)](docs/OpenLane_paper.pdf) — striVe SoC tapeout 사례
- [OpenROAD-flow-scripts Tutorial](https://openroad-flow-scripts.readthedocs.io/en/latest/tutorials/FlowTutorial.html)
- [SKY130 PDK Documentation](https://skywater-pdk.readthedocs.io/)
- [Tool Analysis](docs/tool_analysis.md) — OpenROAD, ORFS, OpenRAM 내부 구조
