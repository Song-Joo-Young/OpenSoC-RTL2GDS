# RTL-to-GDS Training Guide

> 처음부터 끝까지 따라하면서 배우는 오픈소스 칩 설계 실습 가이드.
> 각 Step을 순서대로 수행하면 직접 만든 RTL에서 GDS-II 레이아웃까지 도달합니다.

---

## 이 가이드의 철학

**이 가이드는 "단계별"을 원칙으로 합니다.** 한 번에 GDS까지 돌리는 것이 아니라,
**각 단계를 따로 실행하고, 결과를 읽고, 다음으로 넘어가는** 방식입니다.

왜?

```
[❌ 한 번에 돌리기]  make DESIGN_CONFIG=...
  → 30초 후 GDS 나옴
  → 그런데 synth가 어떤 셀을 쓰는지, floorplan 크기가 어떻게 결정되는지,
    CTS가 왜 필요한지, timing slack이 뭔지... 전혀 이해 못함
  → 디버깅 불가능

[✓ 단계별 돌리기]   make ... synth  →  cat synth_stat.txt
                    make ... floorplan  →  DEF 열어보기
                    make ... place  →  위치 확인
                    ...
  → 각 단계에서 "뭐가 만들어졌나"를 직접 확인
  → 이해가 쌓임 → 디버깅 가능 → 나중에 "한 번에"로 넘어가도 불안하지 않음
```

**Part 12에 도달하면 이 단계들을 "한 번에" 실행하게 됩니다.**
하지만 Part 3~11을 먼저 한 번씩 해보세요.

## 이 가이드의 구성

```
[학습 단계 — 단계별 실행]
Part 1:  개념 이해        — RTL-to-GDS flow가 뭔지, 왜 필요한지
Part 2:  환경 구축        — 도구 설치, PDK 설정
Part 3:  첫 RTL 작성      — 가장 간단한 디자인 (4-bit counter)
Part 4:  Simulation       — 내가 만든 RTL이 맞는지 검증
Part 5:  Synthesis        — RTL → Gate-level netlist
Part 6:  STA (합성 직후)  — 타이밍이 맞는지 먼저 확인
Part 7:  Floorplan        — 칩의 크기와 모양 결정
Part 8:  Placement        — 셀을 바닥에 배치
Part 9:  CTS              — 클럭 트리 구성
Part 10: Routing          — 금속선 연결
Part 11: Post-Route STA   — 실제 기생값으로 최종 타이밍 확인
Part 12: GDS 생성         — 최종 레이아웃 출력
Part 13: Sign-off         — DRC/LVS 검증

[숙련 단계 — 한 번에]
Part 14: Full flow 한 방에 + 다음 디자인
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
$YOSYS_EXE -V                     # Yosys 0.63 (...)
openroad -version                  # v2.0-XXXXX
magic --version                    # 8.3.XXX
verilator --version                # Verilator 5.XXX
klayout -v                         # KLayout 0.29.X
```

### 2-6. 스크립트 방식 (권장)

이 가이드의 모든 단계는 `training/counter4/` 디렉토리의 **번호별 스크립트**로 실행합니다.
디렉토리 이동 없이 한 곳에서 전부 수행:

```bash
cd training/counter4/

bash 00_clean.sh        # 결과 초기화
bash 01_sim.sh          # Part 4: Simulation
bash 02_setup_ORFS.sh   # Part 5 준비: ORFS에 디자인 등록
bash 03_synth.sh        # Part 5: Synthesis (결과: 셀 통계 + 넷리스트)
bash 04_sta.sh          # Part 6: Pre-Route STA (결과: slack)
bash 05_floorplan.sh    # Part 7: Floorplan
bash 06_place.sh        # Part 8: Placement
bash 07_cts.sh          # Part 9: CTS
bash 08_route.sh        # Part 10: Routing (결과: 타이밍/면적/파워)
bash 09_sta_post.sh     # Part 11: Post-Route STA (SPEF 포함)
bash 10_gds.sh          # Part 12: GDS 생성
bash 11_signoff.sh      # Part 13: DRC/LVS
bash 99_fullflow.sh     # Part 14: 전부 한 번에
```

**다른 디자인에 적용하려면**: `design.cfg`만 수정

| 변수 | 의미 | 예시 |
|------|------|------|
| `DESIGN_NAME` | top module 이름 | `counter4` |
| `RTL_FILELIST` | RTL filelist 경로 | `rtl.f` |
| `TB_FILE` | 테스트벤치 | `tb/tb_counter4.cpp` |
| `SDC_FILE` | 타이밍 제약 | `constraints/constraint.sdc` |
| `CLOCK_PERIOD` | 클럭 주기 (ns) | `10.0` |
| `LIB_FILES` | Liberty (.lib) | `platforms/.../sky130_fd_sc_hd__tt_025C_1v80.lib` |
| `CORE_UTILIZATION` | 면적 utilization | `10` (소형), `40` (대형) |
| `PLACE_DENSITY` | 배치 밀도 | `0.2` (소형), `0.6` (대형) |

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

export CORE_UTILIZATION  = 10
export PLACE_DENSITY     = 0.2
export EQUIVALENCE_CHECK = 0
EOF
```

> **주의**: counter4처럼 작은 디자인은 `CORE_UTILIZATION=10`, `PLACE_DENSITY=0.2`로
> 낮춰야 PDN(전원 네트워크) 단계에서 에러가 안 납니다.
> 큰 디자인(PicoRV32 등)은 30~50%가 적절.

### 5-3. Synthesis 실행 (약 5초)

**스크립트 방식**: `bash 03_synth.sh` (권장 — 결과도 자동 출력)

또는 수동:

```bash
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk synth
```

### 5-4. 결과 확인 — 반드시 하세요

```bash
# ① 합성 통계 — 어떤 게이트가 몇 개 쓰였는가
cat reports/sky130hd/counter4/base/synth_stat.txt
```

**예상 출력:**
```
=== counter4 ===
   Number of cells:          11
   sky130_fd_sc_hd__dfrtp_1       4    ← D-FF with async reset (4-bit register!)
   sky130_fd_sc_hd__ha_1          1    ← half adder
   sky130_fd_sc_hd__mux2_2        1    ← enable mux
   sky130_fd_sc_hd__xnor2_1       2    ← adder 로직
   sky130_fd_sc_hd__xor2_1        1
   sky130_fd_sc_hd__nand2_1       1
   sky130_fd_sc_hd__nand4_1       1
```

```bash
# ② 생성된 게이트 레벨 넷리스트 보기
head -50 results/sky130hd/counter4/base/1_synth.v
```

**이 단계에서 이해해야 할 것:**
- RTL `count + 1` → 실제로는 `ha_1` + `xor2_1` + `xnor2_1`로 변환됨
- RTL `always @(posedge clk)` → `dfrtp_1` (D-FF) 4개
- RTL `if (en)` → `mux2_2` 하나

**체크리스트:**
- [ ] FF 개수 = 4 (4-bit register이므로)
- [ ] 전체 셀 10~30개 (counter4 정도 크기)
- [ ] 에러 메시지 없음

> **잠깐 멈춰서 확인**: 셀 수가 예상과 다르면, RTL이 이상하거나 SDC가 엉망일 수 있습니다.

---

## Part 6: STA (Static Timing Analysis) — 합성 직후

**왜 지금?** Placement/Route 하기 전에 **"그 clock period로 이 디자인이 가능한지"** 먼저 확인.
위반이 있으면 SDC를 고치거나 디자인을 수정해야 합니다.

### 6-1. OpenSTA standalone 실행 (약 2초)

```bash
cd $ORFS/flow
sta -exit << 'STASCRIPT'
# Liberty 로드 (PDK standard cell 타이밍 모델)
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# 합성 결과 Verilog 로드
read_verilog results/sky130hd/counter4/base/1_synth.v
link_design counter4

# SDC 제약
read_sdc designs/sky130hd/counter4/constraint.sdc

# 리포트
puts "=== Setup Analysis ==="
report_checks -path_delay max

puts "=== Summary ==="
report_tns
report_wns
STASCRIPT
```

### 6-2. 결과 해석 — 핵심!

출력 끝부분:
```
          1.27   data arrival time      ← 신호가 실제 걸리는 시간
          10.12   data required time    ← 도달해야 하는 마감 시간
-----------------------------------------------------------
          8.85   slack (MET)            ← 여유 시간 (양수면 OK)
```

**봐야 할 숫자:**
- **slack > 0 (MET)** → 타이밍 만족. 다음 단계 진행 가능.
- **slack < 0 (VIOLATED)** → 위반. SDC의 clock period를 늘리거나 RTL 수정.

**Critical path (가장 오래 걸리는 경로)** 도 나옵니다:
```
FF/Q (0.42ns) → half adder (0.30ns) → mux (0.30ns) → FF/D
```
→ "adder와 mux가 타이밍의 병목이구나"를 알 수 있음.

### 6-3. 실험해보기 (선택, 추천)

SDC를 바꿔서 clock period를 극단적으로 줄여보세요:
```tcl
# constraint.sdc
create_clock [get_ports clk] -name core_clock -period 1.5  ← 1.5ns (667MHz)
```
그리고 synth + STA 다시 돌리면 **slack이 음수**로 변합니다. 이게 violation입니다.
원상 복구: `period 10.0`

---

## Part 7: Floorplan

칩의 물리적 크기와 전원 네트워크를 설정합니다.

### 7-1. 실행 (약 2~5초)

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk floorplan
```

### 7-2. 이 단계에서 일어나는 일

1. **코어 면적 계산**: `CORE_UTILIZATION=40%` → 셀 면적의 2.5배 크기로 die 설정
2. **IO 핀 배치**: clk, rst_n, en, count[3:0] 핀을 die 가장자리에 배치
3. **전원 네트워크**: VDD/VSS 링과 수직/수평 스트랩 (전류 공급용)
4. **탭셀 삽입**: 일정 간격으로 well tap 삽입 (latch-up 방지)

### 7-3. 결과 확인

```bash
cat reports/sky130hd/counter4/base/2_floorplan_final.rpt
```

**이런 것 나옵니다:**
- Die size (X x Y)
- Core area (셀이 배치될 영역)
- Pin 위치

> **Tip**: 너무 작으면 PDN 스트랩이 안 들어가서 에러. counter4처럼 작은 디자인은
> `CORE_UTILIZATION = 10`, `PLACE_DENSITY = 0.2`로 낮춰야 할 수 있습니다.

---

## Part 8: Placement

게이트(셀)들을 코어 영역에 배치합니다.

### 8-1. 실행 (약 3~10초)

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk place
```

### 8-2. 3단계 세부 과정

```
[8-2-1] Global Placement (gpl)
        → 각 셀의 대략적 위치 결정
        → 목표: wirelength 최소화 (분석적 최적화)

[8-2-2] Resizing (rsz)
        → 타이밍 위반 있으면 셀 크기 업사이즈, 버퍼 삽입
        → Placement 이후 더 정확한 타이밍 기반

[8-2-3] Detailed Placement (dpl)
        → 셀들을 row(행)에 정확히 정렬
        → Legal placement (overlap 없음, DRC 준수)
```

### 8-3. 결과 확인

```bash
cat reports/sky130hd/counter4/base/3_detailed_place.rpt
# 또는
cat reports/sky130hd/counter4/base/3_resizer.rpt
```

---

## Part 9: Clock Tree Synthesis (CTS)

모든 FF에 클럭을 고르게 분배하는 버퍼 트리를 만듭니다.

### 9-1. 왜 필요한가?

클럭이 FF마다 도착 시간이 다르면 (**clock skew**) setup/hold violation이 발생합니다.

```
[CTS 없이]
        clk ──────────────────────────▶ FF1  (0.1ns)
            ─────────────────────────▶ FF2  (0.3ns)   ← 0.2ns 차이 발생
            ────────────────────▶ FF3       (0.5ns)   ← 위반 가능

[CTS 적용]
        clk ──▶ [buf] ──▶ [buf] ──▶ FF1  (0.25ns)
                   │
                   ├──▶ [buf] ────▶ FF2  (0.25ns)   ← 모두 0.25ns
                   │
                   └──▶ [buf] ────▶ FF3  (0.25ns)
```

### 9-2. 실행 (약 2~5초)

```bash
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk cts
```

### 9-3. 결과 확인

```bash
cat reports/sky130hd/counter4/base/4_cts_final.rpt
```

**확인 포인트:**
- 삽입된 clock buffer 개수
- Clock skew (작을수록 좋음, <0.1ns 권장)

---

## Part 10: Routing

셀들을 실제 금속선(metal wire)으로 연결합니다.

### 10-1. 실행 (약 5~30초, 작은 디자인 기준)

```bash
# ORFS 호환성 이슈 workaround
touch reports/sky130hd/counter4/base/congestion.rpt

make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk route
```

### 10-2. 2단계 과정

```
[10-2-1] Global Routing (grt)
         → 각 넷이 지나갈 대략적 영역 결정
         → congestion(혼잡도) 예측

[10-2-2] Detailed Routing (drt)
         → 실제 metal 레이어에 선 그리기
         → DRC 완전 준수 (spacing, width 등)
         → Fill cell 삽입 (빈 공간 채움)
```

### 10-3. 결과 확인

```bash
cat reports/sky130hd/counter4/base/5_global_route.rpt
```

**봐야 할 것:**
- **Clock slack > 0** → timing met
- **Antenna violations = 0** → antenna rule 준수
- **Design area + utilization**

SKY130에서 사용하는 메탈 레이어: li1, met1, met2, met3, met4, met5

---

## Part 11: Post-Route STA (기생 성분 포함 최종 타이밍)

**Part 6의 STA vs Part 11의 STA 차이:**

| | Part 6 (Pre-Route) | Part 11 (Post-Route) |
|---|---|---|
| 기생 성분 | 추정치 (wire-load model) | 실제 추출값 (SPEF) |
| 정확도 | 낮음 (~50%) | **Sign-off 수준** (>99%) |
| 시점 | 합성 직후 | 라우팅 후 |

### 11-1. ORFS가 자동으로 생성한 SPEF 확인

```bash
ls results/sky130hd/counter4/base/6_final.spef
```

### 11-2. Post-Route STA 실행 (약 2~5초)

```bash
cd $ORFS/flow
sta -exit << 'STASCRIPT'
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/sky130hd/counter4/base/6_final.v
link_design counter4
read_sdc designs/sky130hd/counter4/constraint.sdc
read_spef results/sky130hd/counter4/base/6_final.spef    ← 핵심!

puts "=== Post-Route Setup ==="
report_checks -path_delay max -format full_clock_expanded

puts "=== Hold ==="
report_checks -path_delay min

puts "=== Power ==="
report_power
STASCRIPT
```

### 11-3. Part 6 결과와 비교

**같은 디자인인데:**
- Pre-Route slack: +8.85ns (추정)
- Post-Route slack: +8.81ns (실제) — 더 작아짐

→ 기생 성분이 추가되면서 경로 지연이 조금 늘어남. 이게 **현실**입니다.
→ Pre-Route에서 slack이 작으면 Post-Route에서 violation 날 가능성 있으니
   여유(margin)를 두고 설계해야 함.

---

## Part 12: GDS 생성

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

## Part 13: Sign-off (DRC/LVS)

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

## Part 14: Full flow (한 번에) + 다음 디자인

### 14-1. 한 번에 실행 (Full flow)

Part 5~12를 한 단계씩 이해했다면, 이제 한 줄로 실행할 수 있습니다:

```bash
source env.sh && cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk
```

**이렇게 하면:**
- synth → floorplan → place → cts → route → finish 자동
- Counter4 기준 약 30초 ~ 1분
- 중간 결과는 `results/`, `reports/`, `logs/` 에 모두 남음

**왜 이제 가능한가?**
Part 3~13에서 각 단계의 **입력/출력/의미**를 이해했으므로, 에러가 나도 어느 단계에서 문제인지 바로 안다.
처음부터 한 번에 돌리면 블랙박스가 됩니다 — 학습이 아니라 "돌려보기"에 그침.

### 14-2. 타이밍 실험 (필수 추천)

clock period를 줄여가면서 한계를 찾아보세요:
```tcl
# constraints/constraint.sdc 수정 후 14-1 재실행
create_clock [get_ports clk] -name core_clock -period 10.0  # 원본
create_clock [get_ports clk] -name core_clock -period 5.0   # 빠르게
create_clock [get_ports clk] -name core_clock -period 2.0   # 더 빠르게
create_clock [get_ports clk] -name core_clock -period 1.5   # 여기서 violation 날 수도
```

**관찰 포인트:**
- 빨라지면 Area/Power는 어떻게 변하는가? (보통 증가)
- 언제부터 violation이 나는가?
- Violation을 해결하려면 무엇을 해야 하는가? (pipeline, logic restructuring)

### 14-3. 디자인 확장

난이도 순서:
1. **8-bit counter** — WIDTH 파라미터화 (`designs/02_counter/` 참고)
2. **ALU** — 조합+순차 혼합 (`designs/03_alu/` 참고)
3. **Systolic Array** — AI 하드웨어 기초 (`designs/06_systolic/` 참고)
4. **RISC-V CPU** — PicoRV32 (`designs/04_picorv32/` 참고)
5. **SoC + SRAM** — CPU + 메모리 통합 (`designs/05_soc/` 참고)

### 14-4. 다른 PDK로 비교

```bash
# GF180 (180nm) 으로 동일 디자인
mkdir -p $ORFS/flow/designs/gf180/counter4
# config.mk에서 PLATFORM = gf180 으로 변경
```

### 14-5. OpenLane으로 마이그레이션

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

각 단계를 **개별적으로** 실행하면서 완료 여부 확인:

- [ ] Part 3: counter4.v 작성 완료
- [ ] Part 4: Verilator sim PASS
- [ ] Part 5: Synthesis — `synth_stat.txt` 열어서 셀 확인
- [ ] Part 6: Pre-Route STA — slack > 0 확인
- [ ] Part 7: Floorplan — 코어 면적 생성됨
- [ ] Part 8: Placement — 셀 배치 완료
- [ ] Part 9: CTS — clock buffer 삽입 확인
- [ ] Part 10: Routing — timing met 재확인
- [ ] Part 11: Post-Route STA — SPEF 포함 최종 slack 확인
- [ ] Part 12: GDS 파일 생성됨 (`6_final.gds`)
- [ ] Part 13: DRC clean, LVS pass
- [ ] Part 14: `make` 한 번으로 전체 돌려보기 (이제 각 단계 이해 완료!)

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
