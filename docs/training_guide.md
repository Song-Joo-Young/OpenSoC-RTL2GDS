# RTL-to-GDS Training Guide

> 기본 실습은 `training/01_counter4/`의 번호별 스크립트로 진행한다.
> 다음 실습은 `training/02_uart_tx/` 이며, 이후 동일한 흐름을 `03_alu`, `04_systolic`, `05_picorv32`, `06_soc`로 확장한다.

---

## 구성

```
Part 1:  개념         — RTL-to-GDS flow 개요
Part 2:  환경 구축     — 도구 설치, PDK 설정
Part 3:  RTL 작성      — 4-bit counter Verilog
Part 4:  Simulation    — Verilator 기능 검증
Part 5:  Synthesis     — RTL → gate-level netlist (Yosys)
Part 6:  Pre-Route STA — 합성 후 타이밍 확인 (OpenSTA)
Part 7:  Floorplan     — 칩 크기, 전원 네트워크 (OpenROAD)
Part 8:  Placement     — 셀 배치 (OpenROAD)
Part 9:  CTS           — 클럭 트리 합성 (OpenROAD)
Part 10: Routing       — 금속선 연결 (OpenROAD)
Part 11: Post-Route STA— SPEF 기반 최종 타이밍 (OpenSTA)
Part 12: GDS 생성      — 레이아웃 출력 (KLayout)
Part 13: Sign-off      — DRC/LVS 검증 (Magic/Netgen)
Part 14: Full flow     — 전부 한 번에
```

각 Part는 `training/01_counter4/` 안의 번호별 스크립트에 대응:

```
bash 00_clean.sh        Part 준비 (결과 초기화)
bash 01_sim.sh          Part 4
bash 02_setup_ORFS.sh   Part 5 준비
bash 03_synth.sh        Part 5
bash 04_sta.sh          Part 6
bash 05_floorplan.sh    Part 7
bash 06_place.sh        Part 8
bash 07_cts.sh          Part 9
bash 08_route.sh        Part 10
bash 09_sta_post.sh     Part 11
bash 10_gds.sh          Part 12
bash 11_signoff.sh      Part 13
bash 99_fullflow.sh     Part 14
```

다른 디자인에 적용하려면 `design.cfg`와 `rtl.f`를 수정하거나, 아래의 Design Tracks 명령을 그대로 사용한다.

---

## Quick Reproduction Matrix

모든 기본 재현 경로는 `SKY130HD` 기준이다. 먼저 한 번만 실행:

```bash
bash scripts/setup_tools.sh
bash scripts/setup_pdk.sh
source env.sh
```

| Design | 목적 | 로컬 검증 | Full flow | 결과 위치 |
|--------|------|----------|-----------|----------|
| `training/01_counter4` | 첫 실습용 4-bit counter | `cd training/01_counter4 && bash 01_sim.sh` | `cd training/01_counter4 && bash 99_fullflow.sh` | `$ORFS/flow/results/sky130hd/counter4/base/` |
| `training/02_uart_tx` | 멀티파일 UART TX + FIFO + ICG | `cd training/02_uart_tx && bash 01_sim.sh` | `cd training/02_uart_tx && bash 99_fullflow.sh` | `$ORFS/flow/results/sky130hd/uart_tx/base/` |
| `training/03_alu` | 8-bit pipelined ALU training track | `cd training/03_alu && bash 01_sim.sh` | `cd training/03_alu && bash 99_fullflow.sh` | `$ORFS/flow/results/sky130hd/alu/base/` |
| `designs/03_alu` | 8-bit pipelined ALU source-only path | `make -C designs/03_alu sim` | `cd $ORFS/flow && make DESIGN_CONFIG=./designs/sky130hd/alu/config.mk` | `$ORFS/flow/results/sky130hd/alu/base/` |
| `designs/04_systolic` | 2x2 systolic array | `make -C designs/04_systolic sim` | `cd $ORFS/flow && make DESIGN_CONFIG=./designs/sky130hd/systolic_2x2/config.mk` | `$ORFS/flow/results/sky130hd/systolic_2x2/base/` |
| `designs/05_picorv32` | PicoRV32 RISC-V core | - | `cd $ORFS/flow && make DESIGN_CONFIG=./designs/sky130hd/picorv32/config.mk` | `$ORFS/flow/results/sky130hd/picorv32/base/` |
| `designs/06_soc` | PicoRV32 + SRAM macro | - | `cd $ORFS/flow && make DESIGN_CONFIG=./designs/sky130hd/picosoc_mini/config.mk` | `$ORFS/flow/results/sky130hd/picosoc_mini/base/` |

권장 순서는 `01_counter4 -> 02_uart_tx -> 03_alu -> 04_systolic -> 05_picorv32 -> 06_soc` 이다.

---

## Part 1: 개념

### RTL-to-GDS란

디지털 회로의 동작 기술(Verilog RTL)을 반도체 제조용 레이아웃(GDS-II)으로 변환하는 과정.

```
Verilog RTL
    |
    v
Synthesis (Yosys)        -- RTL → gate netlist
    |
    v
STA (OpenSTA)            -- 타이밍 검증
    |
    v
Floorplan (OpenROAD)     -- 칩 면적, 전원
    |
    v
Placement (OpenROAD)     -- 셀 위치 결정
    |
    v
CTS (OpenROAD)           -- 클럭 분배
    |
    v
Routing (OpenROAD)       -- 금속선 연결
    |
    v
STA (OpenSTA + SPEF)     -- 최종 타이밍 (sign-off)
    |
    v
GDS (KLayout)            -- 레이아웃 파일
    |
    v
DRC/LVS (Magic/Netgen)   -- 제조 규칙 검증
```

### 도구와 상용 대응

| 도구 | 역할 | 상용 대응 |
|------|------|----------|
| Yosys | 합성 | Synopsys DC |
| OpenSTA | 타이밍 분석 | Synopsys PrimeTime |
| OpenROAD | PnR | Cadence Innovus |
| KLayout | GDS 뷰어/생성 | - |
| Magic | DRC + extraction | Mentor Calibre |
| Netgen | LVS | Mentor Calibre |
| Verilator | 시뮬레이션 | Synopsys VCS |

### PDK

공장이 제공하는 셀 라이브러리 + 공정 규칙. 이 가이드에서는 **SKY130** (SkyWater 130nm, 오픈소스)을 사용.

---

## Part 2: 환경 구축

### 시스템 요구사항

| 항목 | 최소 | 권장 |
|------|------|------|
| OS | Linux (RHEL 8 / Ubuntu 20.04+) | RHEL 8 / Ubuntu 22.04 |
| RAM | 16GB | 32GB+ |
| CPU | 4 cores | 8+ cores |
| Disk | 20GB | 50GB+ |

### 사전 패키지

```bash
# RHEL/CentOS
yum install -y git make gcc gcc-c++ python3 python3-pip \
  tcl-devel libX11-devel java-1.8.0-openjdk clang

# Ubuntu/Debian
apt install -y git make gcc g++ python3 python3-pip \
  tcl-dev tk-dev libx11-dev default-jdk clang
```

### 2-1. 프로젝트 클론

```bash
git clone git@github.com:Song-Joo-Young/OpenSoC-RTL2GDS.git
cd OpenSoC-RTL2GDS
```

### 2-2. 도구 빌드 (15-25분)

```bash
bash scripts/setup_tools.sh
```

빌드되는 것:
- Tk 8.6 (local, tk-devel 없을 때)
- Magic 8.3 (DRC, `--version` 지원)
- Netgen 1.5 (LVS)
- ORFS + Yosys 0.63 (clang 빌드)
- OpenRAM

### 2-3. PDK 설치 (40-80분)

```bash
bash scripts/setup_pdk.sh
```

SKY130 PDK를 open_pdks로 설치한다. Magic이 각 셀의 GDS를 내부 포맷으로 변환하므로 시간이 걸린다.
RF/analog 셀 관련 경고(`Cannot find file sky130_fd_pr__rf_*`)와 I/O 셀 경고(`Boundary is not closed`)는 디지털 flow에 무관하므로 무시.

설치 확인:
```bash
ls pdk/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/
# sky130_fd_sc_hd__tt_025C_1v80.lib 등이 있으면 성공
```

### 2-4. 환경 로드

```bash
source env.sh
```

매 터미널마다 실행 필요.

### 2-5. 검증

```bash
$YOSYS_EXE -V           # Yosys 0.63
openroad -version        # v2.0-XXXXX
magic --version          # 8.3.XXX
sta -version             # 2.6.0
verilator --version      # Verilator 5.XXX
klayout -v               # KLayout 0.29.X
```

---

## Part 3: RTL 작성

`training/01_counter4/src/counter4.v`:

```verilog
module counter4 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
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

RTL filelist (`rtl.f`):
```
src/counter4.v
```

---

## Part 4: Simulation

```bash
cd training/01_counter4
bash 01_sim.sh
```

기대 출력:
```
Cycle  1: count= 1 OK
...
Cycle 16: count= 0 OK    <- 4-bit overflow
Enable=0 hold: count=4 OK
=== ALL TESTS PASSED ===
```

sim PASS가 아니면 RTL 수정 후 재실행.

---

## Part 5: Synthesis

### 준비: ORFS에 디자인 등록

```bash
bash 02_setup_ORFS.sh
```

`design.cfg`의 설정이 ORFS의 `config.mk`로 변환된다.

### 합성 실행

```bash
bash 03_synth.sh
```

출력되는 파일 경로를 확인한다:

```
[넷리스트]  $RESULTS/1_synth.v       -- gate-level Verilog
[합성 통계] $REPORTS/synth_stat.txt  -- 셀 종류/개수
[로그]      $LOGS/1_1_yosys.log
```

`$RESULTS`, `$REPORTS` 경로는 스크립트 실행 시 상단에 출력된다.
이후 모든 결과 파일도 동일한 `$RESULTS`, `$REPORTS` 디렉토리에 생성된다.

확인할 것:
- synth_stat.txt에서 FF 4개 (dfrtp), 전체 11개 셀 정도
- 에러 없이 완료

---

## Part 6: Pre-Route STA

```bash
bash 04_sta.sh
```

합성된 넷리스트 + Liberty + SDC로 타이밍 분석을 수행한다.

출력의 핵심:
```
data arrival time    -- 신호가 실제 걸리는 시간
data required time   -- 도달해야 하는 마감 시간
slack (MET)          -- 여유. 양수면 OK, 음수면 violation
```

- slack > 0: 다음 단계로 진행
- slack < 0: `constraints/constraint.sdc`에서 `CLOCK_PERIOD` 늘리기

입출력:
```
[입력] Liberty:  $LIBERTY (셀 타이밍 모델)
[입력] Netlist:  $RESULTS/1_synth.v
[입력] SDC:      constraints/constraint.sdc
```

### 실험 (optional)

SDC의 clock period를 `10.0` → `1.5`로 줄여서 violation을 직접 확인해볼 수 있다.

---

## Part 7: Floorplan

```bash
bash 05_floorplan.sh
```

칩 면적 결정, IO 핀 배치, 전원 네트워크(PDN), 탭셀 삽입을 수행한다.

`CORE_UTILIZATION`이 너무 높으면 PDN 에러 발생.
counter4 같은 작은 디자인은 `10%`, 큰 디자인은 `30-50%`.

결과 파일:
```
[ODB]    $RESULTS/2_floorplan.odb
[리포트] $REPORTS/2_floorplan_final.rpt   -- die 크기, utilization
[로그]   $LOGS/2_6_pdn.log
```

GUI 확인 (optional):
```bash
openroad -gui
# TCL 콘솔:
read_db $RESULTS/2_floorplan.odb
```

---

## Part 8: Placement

```bash
bash 06_place.sh
```

global placement → resizing → detailed placement 3단계.

결과 파일:
```
[ODB]    $RESULTS/3_place.odb
[리포트] $REPORTS/3_resizer.rpt          -- 버퍼 삽입, 셀 리사이징
[리포트] $REPORTS/3_detailed_place.rpt
```

GUI 확인 (optional):
```bash
openroad -gui
# read_db $RESULTS/3_place.odb
```

---

## Part 9: CTS

```bash
bash 07_cts.sh
```

모든 FF에 클럭을 균일하게 분배하는 버퍼 트리를 생성한다.
FF마다 클럭 도착 시간이 다르면(clock skew) setup/hold violation이 발생하므로 CTS가 필요.

결과 파일:
```
[ODB]    $RESULTS/4_cts.odb
[SDC]    $RESULTS/4_cts.sdc              -- propagated clock 반영
[리포트] $REPORTS/4_cts_final.rpt        -- skew, 버퍼 수
```

---

## Part 10: Routing

```bash
bash 08_route.sh
```

global routing → detailed routing → fill cell 삽입.
실제 metal 레이어(met1~met5)에 wire를 배치한다.

결과 파일:
```
[ODB]    $RESULTS/5_route.odb
[리포트] $REPORTS/5_global_route.rpt     -- timing, area, power 종합
[DRC]    $REPORTS/5_route_drc.rpt        -- routing DRC (0이어야 정상)
[Antenna]$REPORTS/drt_antennas.log
```

GUI 확인 (optional):
```bash
openroad -gui
# read_db $RESULTS/5_route.odb
# 레이어별 on/off로 met1~met5 확인
```

---

## Part 11: Post-Route STA

```bash
bash 09_sta_post.sh
```

라우팅 후 실제 배선의 R/C 기생값(SPEF)을 반영한 최종 타이밍 분석.
이것이 sign-off 기준이 되는 STA.

| | Part 6 (Pre-Route) | Part 11 (Post-Route) |
|---|---|---|
| 기생 값 | 추정 | SPEF 실측 |
| 정확도 | 참고용 | sign-off 기준 |

결과 파일:
```
[SPEF]    $RESULTS/6_final.spef          -- 배선 R/C
[Netlist] $RESULTS/6_final.v             -- CTS 버퍼 포함 최종 netlist
[DEF]     $RESULTS/6_final.def           -- GDS 변환 입력
```

---

## Part 12: GDS 생성

```bash
bash 10_gds.sh
```

DEF + standard cell GDS → 최종 GDS-II.
이 파일이 fab에 보내는 제조용 파일.

결과 파일:
```
[GDS]  $RESULTS/6_final.gds
```

GUI 확인:
```bash
klayout $RESULTS/6_final.gds
```

`$RESULTS` 경로는 스크립트 실행 시 상단에 출력되며, 예시:
```
/home/jysong/PROJECT/tools/OpenROAD-flow-scripts/flow/results/sky130hd/counter4/base/6_final.gds
```

KLayout에서 확인할 것:
- 줌인: 개별 셀(gate) 모양
- 레이어: met1, met2, poly 등 각 레이어 색상
- 줌아웃: 전체 die, PDN 스트랩, IO 핀

---

## Part 13: Sign-off

```bash
bash 11_signoff.sh
```

DRC (Magic): GDS를 읽어 공정 규칙 위반 검사.
LVS (Netgen): 레이아웃 netlist와 schematic netlist 비교.

결과 파일:
```
[DRC 입력]  $RESULTS/6_final.gds
[LVS 결과] $REPORTS/lvs_result.log       -- 'Circuits match uniquely' = PASS
```

DRC clean + LVS pass = 제조 가능한 설계.

---

## Part 14: Full flow

Part 5~13을 이해한 후, 한 줄로 전체 실행:

```bash
bash 99_fullflow.sh
```

counter4 기준 약 1분. 중간 결과는 `$RESULTS`, `$REPORTS`에 모두 남는다.

---

## Design Tracks

### Track A: `training/01_counter4`

가장 재현이 쉬운 입문 경로다. 번호별 스크립트가 이미 준비되어 있어 그대로 따라가면 된다.

```bash
cd training/01_counter4
bash 00_clean.sh
bash 01_sim.sh
bash 02_setup_ORFS.sh
bash 99_fullflow.sh
```

### Track B: `training/02_uart_tx`

멀티파일 RTL, `rtl.f`, FIFO, serializer, ICG를 한 번에 보는 예제다. `counter4` 다음 단계로 권장한다.

```bash
cd training/02_uart_tx
bash 00_clean.sh
bash 01_sim.sh
bash 02_setup_ORFS.sh
bash 99_fullflow.sh
```

### Track C: `training/03_alu`

2-stage pipeline 구조를 보는 디자인이다.

```bash
cd training/03_alu
bash 00_clean.sh
bash 01_sim.sh
bash 02_setup_ORFS.sh
bash 99_fullflow.sh
```

### Track D: `designs/04_systolic`

연산량이 커지면서 combinational power가 커지는 사례다.

```bash
make -C designs/04_systolic clean
make -C designs/04_systolic sim
source env.sh
cd "$ORFS/flow"
make DESIGN_CONFIG=./designs/sky130hd/systolic_2x2/config.mk clean_all
make DESIGN_CONFIG=./designs/sky130hd/systolic_2x2/config.mk
```

### Track E: `designs/05_picorv32`

검증된 외부 CPU RTL로 full RTL-to-GDS를 수행한다. 현재 저장소에는 별도 로컬 테스트벤치가 없다.

```bash
source env.sh
cd "$ORFS/flow"
make DESIGN_CONFIG=./designs/sky130hd/picorv32/config.mk clean_all
make DESIGN_CONFIG=./designs/sky130hd/picorv32/config.mk
```

### Track F: `designs/06_soc`

SRAM macro가 포함된 SoC 트랙이다. 학습 순서상 가장 마지막에 권장한다.

```bash
source env.sh
cd "$ORFS/flow"
make DESIGN_CONFIG=./designs/sky130hd/picosoc_mini/config.mk clean_all
make DESIGN_CONFIG=./designs/sky130hd/picosoc_mini/config.mk
```

공통 확인 포인트:
- 최종 GDS: `.../results/sky130hd/<design>/base/6_final.gds`
- 합성 통계: `.../reports/sky130hd/<design>/base/synth_stat.txt`
- 타이밍: `.../reports/sky130hd/<design>/base/5_global_route.rpt`

---

## design.cfg 변수 설명

다른 디자인에 적용할 때 수정하는 항목:

| 변수 | 설명 | counter4 기본값 |
|------|------|----------------|
| `DESIGN_NAME` | top module 이름 | `counter4` |
| `PLATFORM` | 기본 PDK | `sky130hd` |
| `RTL_FILELIST` | RTL filelist | `rtl.f` |
| `TOP_MODULE` | verilator top | `counter4` |
| `TB_FILE` | testbench | `tb/tb_counter4.cpp` |
| `SDC_FILE` | 타이밍 제약 | `constraints/constraint.sdc` |
| `CLOCK_PERIOD` | 클럭 주기 (ns) | `10.0` |
| `LIB_FILES` | Liberty | `platforms/.../sky130_fd_sc_hd__tt_025C_1v80.lib` |
| `CORE_UTILIZATION` | 면적 util (%) | `10` (소형), `30-50` (대형) |
| `PLACE_DENSITY` | 배치 밀도 | `0.2` (소형), `0.6` (대형) |

---

## Troubleshooting

| 증상 | 원인 | 해결 |
|------|------|------|
| PDN 에러 (`Insufficient width`) | CORE_UTILIZATION 너무 높음 | 10-20%로 낮추기 |
| congestion.rpt 에러 | ORFS 호환성 이슈 | `touch $REPORTS/congestion.rpt` (08_route.sh에 포함) |
| GUI-0070 에러 (`gui::load_drc`) | headless 환경에서 save_images 실패 | GDS 생성과 무관, 무시 |
| timing violation | clock period 너무 짧음 | SDC에서 period 늘리기 |
| `magic --version` 실패 | Tcl 없이 빌드됨 | `setup_tools.sh`가 Tk 포함 빌드 (해결됨) |
| `klayout` 파일 못 찾음 | 상대경로 사용 | 스크립트 출력의 절대경로 사용 |

---

## 다음 디자인

```bash
cp -r training/02_uart_tx training/my_design
cd training/my_design
# design.cfg, rtl.f, src/, tb/, constraints/ 수정
bash 00_clean.sh
bash 01_sim.sh
# ...
```

난이도 순서:
1. UART TX + FIFO + ICG (`training/02_uart_tx/`)
2. ALU (`designs/03_alu/`)
3. 2x2 Systolic Array (`designs/04_systolic/`)
4. PicoRV32 RISC-V (`designs/05_picorv32/`)
5. SoC + SRAM (`designs/06_soc/`)

기본 문서 경로는 `sky130hd` 하나만 다룬다. 다른 PDK 비교는 선택 실험으로만 추가하는 편이 재현성과 설치 시간을 모두 개선한다.
