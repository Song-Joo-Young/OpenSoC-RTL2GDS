# Tool Analysis: OpenROAD, ORFS, OpenRAM

> 이 프로젝트에서 사용하는 3대 핵심 도구의 내부 구조 분석

---

## 1. OpenROAD

> Repository: [The-OpenROAD-Project/OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD)

### 역할
RTL-to-GDS flow에서 **Synthesis 이후 모든 물리적 설계 단계**를 담당하는 unified 도구.
Floorplan → Placement → CTS → Routing → Finishing을 하나의 바이너리에서 실행.

### 내부 모듈 구조

```
src/
├── odb/          OpenDB — 설계 데이터베이스 (LEF/DEF 파싱, 셀/넷/핀 관리)
├── sta/          OpenSTA — 정적 타이밍 분석 엔진
├── dbSta/        DB-aware STA (OpenDB + OpenSTA 연동)
│
├── ifp/          Initialize Floorplan — 다이/코어 면적, 행 생성, 트랙 설정
├── ppl/          IO Placer — 핀 배치
├── pdn/          PDN Generator — 전원 네트워크 생성
├── mpl/          Macro Placer — SRAM 등 매크로 배치
│
├── gpl/          Global Placement (Replace 기반) — 분석적 배치
├── dpl/          Detailed Placement (OpenDP) — 합법화 + DRC 준수 배치
├── rsz/          Resizer — 버퍼 삽입, 셀 리사이징, 타이밍 최적화
│
├── cts/          Clock Tree Synthesis (TritonCTS) — H-tree, 클럭 분배
│
├── grt/          Global Routing (FastRoute 기반) — 라우팅 가이드 생성
├── drt/          Detailed Routing (TritonRoute 기반) — 실제 메탈 경로
├── rcx/          OpenRCX — 기생 저항/커패시턴스 추출
│
├── fin/          Finishing — 메탈 필, 최종 체크
├── ant/          Antenna Checker — 안테나 규칙 위반 검사
├── par/          TritonPart — 디자인 파티셔닝
├── gui/          GUI — 인터랙티브 시각화 (Qt 기반)
└── utl/          Utilities — 로깅, 메트릭스
```

### 핵심 Tcl 명령어

| 단계 | 명령어 | 모듈 |
|------|--------|------|
| 입력 | `read_lef`, `read_def`, `read_liberty` | odb, sta |
| Floorplan | `initialize_floorplan`, `make_tracks` | ifp |
| IO | `place_pins` | ppl |
| PDN | `pdngen` | pdn |
| Macro | `macro_placement`, `rtl_macro_placer` | mpl |
| Global Place | `global_placement` | gpl |
| Detail Place | `detailed_placement`, `check_placement` | dpl |
| Resize | `repair_timing`, `buffer_ports` | rsz |
| CTS | `clock_tree_synthesis` | cts |
| Global Route | `global_route`, `set_routing_layers` | grt |
| Detail Route | `detailed_route` | drt |
| Extraction | `estimate_parasitics` | rcx |
| Finish | `density_fill` | fin |
| 출력 | `write_def`, `write_db`, `write_verilog` | odb |

### 데이터 흐름

```
LEF + Liberty → [odb] → initialize_floorplan → place_pins → pdngen
→ global_placement → detailed_placement → repair_timing
→ clock_tree_synthesis → global_route → detailed_route
→ density_fill → write_def → [KLayout] → GDS
```

---

## 2. OpenROAD-flow-scripts (ORFS)

> Repository: [The-OpenROAD-Project/OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts)

### 역할
OpenROAD + Yosys를 조합하여 **RTL에서 GDS까지 자동화**하는 Makefile 기반 flow.
사용자는 RTL + SDC + config.mk만 제공하면 GDS가 나옴.

### 디렉토리 구조

```
flow/
├── Makefile              메인 flow 오케스트레이터 (42KB)
├── scripts/              Tcl 스크립트 (50+개)
│   ├── synth.sh          Yosys 합성 래퍼
│   ├── flow.sh           OpenROAD 실행 래퍼
│   ├── synth_preamble.tcl
│   ├── floorplan.tcl
│   ├── global_place.tcl
│   ├── detail_place.tcl
│   ├── cts.tcl
│   ├── global_route.tcl
│   ├── detail_route.tcl
│   ├── final_report.tcl
│   └── ...
├── platforms/            PDK별 설정
│   ├── sky130hd/         lib/, lef/, gds/, config.mk, pdn.tcl, ...
│   ├── gf180/
│   ├── asap7/
│   ├── nangate45/
│   └── ...
├── designs/
│   ├── src/              Verilog RTL 소스
│   └── {platform}/       플랫폼별 디자인 설정 (config.mk, constraint.sdc)
└── util/
    └── def2stream.py     DEF → GDS 변환 (KLayout 사용)
```

### Flow 단계 (Makefile targets)

```
make synth        → 1_synth.odb          [Yosys]
make floorplan    → 2_floorplan.odb      [OpenROAD: ifp, ppl, mpl, pdn, tap]
make place        → 3_place.odb          [OpenROAD: gpl, rsz, dpl]
make cts          → 4_cts.odb            [OpenROAD: cts, rsz, dpl]
make route        → 5_route.odb          [OpenROAD: grt, drt, fill]
make finish       → 6_final.gds          [OpenROAD: report + KLayout: GDS merge]
```

세부 단계:
```
1_synth          Yosys RTL 합성
2_1_floorplan    코어 면적 설정
2_2_floorplan_io IO 핀 배치
2_3_floorplan_tdms TDMS 배치 (선택)
2_4_floorplan_macro 매크로 배치
2_5_floorplan_tapcell 탭셀 삽입
2_6_floorplan_pdn  전원 네트워크
3_1~3_5_place    Global/Detail placement + resize
4_1_cts          클럭 트리 합성
5_1_grt          글로벌 라우팅
5_2_route        디테일 라우팅
5_3_fillcell     필러 셀 삽입
6_report         최종 리포트 + GDS 생성
```

### 핵심 환경 변수

| 변수 | 용도 | 예시 |
|------|------|------|
| `DESIGN_CONFIG` | 디자인 설정 파일 경로 | `./designs/sky130hd/gcd/config.mk` |
| `DESIGN_NAME` | 톱 모듈 이름 | `gcd` |
| `PLATFORM` | 타겟 PDK | `sky130hd` |
| `VERILOG_FILES` | RTL 소스 파일 | `./designs/src/gcd/gcd.v` |
| `SDC_FILE` | 타이밍 제약 | `./designs/sky130hd/gcd/constraint.sdc` |
| `CORE_UTILIZATION` | 코어 면적 대비 셀 비율 (%) | `40` |
| `PLACE_DENSITY` | 배치 밀도 | `0.6` |
| `ADDITIONAL_LEFS` | 매크로 LEF 파일 | SRAM macro용 |
| `ADDITIONAL_LIBS` | 매크로 Liberty 파일 | SRAM macro용 |
| `ADDITIONAL_GDS` | 매크로 GDS 파일 | SRAM macro용 |
| `EQUIVALENCE_CHECK` | eqy 등가 검증 on/off | `0` |
| `MACRO_PLACE_HALO` | 매크로 주변 여백 | `10 10` |

### 커스텀 디자인 추가 방법

```bash
# 1. RTL 배치
mkdir -p flow/designs/src/my_design/
cp my_module.v flow/designs/src/my_design/

# 2. 플랫폼별 config 생성
mkdir -p flow/designs/sky130hd/my_design/
cat > flow/designs/sky130hd/my_design/config.mk <<'EOF'
export DESIGN_NAME = my_module
export PLATFORM    = sky130hd
export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/my_module.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc
export CORE_UTILIZATION = 40
export EQUIVALENCE_CHECK = 0
EOF

# 3. SDC 작성
cat > flow/designs/sky130hd/my_design/constraint.sdc <<'EOF'
create_clock [get_ports clk] -name core_clock -period 10.0
set_input_delay  2.0 -clock core_clock [all_inputs]
set_output_delay 2.0 -clock core_clock [all_outputs]
EOF

# 4. 실행
make DESIGN_CONFIG=./designs/sky130hd/my_design/config.mk
```

---

## 3. OpenRAM

> Repository: [VLSIDA/OpenRAM](https://github.com/VLSIDA/OpenRAM)

### 역할
**SRAM 매크로 컴파일러**. 주어진 크기(word_size × num_words) 설정으로
타이밍 모델(.lib), 레이아웃(.gds), 추상화(.lef), 넷리스트(.v, .sp)를 자동 생성.

### 디렉토리 구조

```
OpenRAM/
├── sram_compiler.py      SRAM 생성 진입점
├── rom_compiler.py       ROM 생성 진입점
├── compiler/             핵심 엔진
│   ├── sram.py           최상위 SRAM 클래스
│   ├── sram_config.py    크기/구조 계산
│   ├── sram_factory.py   컴포넌트 팩토리
│   ├── modules/          30+ 서브 모듈
│   │   ├── bitcell_array.py
│   │   ├── decoder.py
│   │   ├── sense_amp_array.py
│   │   ├── precharge_array.py
│   │   ├── control_logic.py
│   │   └── ...
│   ├── base/             기반 클래스
│   │   ├── design.py     계층적 설계 클래스
│   │   ├── verilog.py    Verilog 출력
│   │   ├── lef.py        LEF 출력
│   │   └── ...
│   ├── characterizer/    SPICE 기반 타이밍/파워 추출
│   └── router/           내부 라우팅
│
├── technology/           PDK별 구현
│   ├── freepdk45/        FreePDK 45nm
│   ├── sky130/           SkyWater 130nm
│   │   ├── custom/       커스텀 비트셀, 레플리카 셀
│   │   └── tech/         디자인 룰, 레이어 정의
│   ├── gf180mcu/         GlobalFoundries 180nm
│   ├── scn3me_subm/      SCMOS 3-metal
│   └── scn4m_subm/       SCMOS 4-metal
│
├── macros/               프리빌트 매크로 템플릿
├── tests/                테스트 슈트
└── docs/                 문서
```

### SRAM 내부 구조 (생성되는 것)

```
         ┌──────────────────────────────────────┐
         │              SRAM Bank               │
         │                                      │
         │  ┌──────────┐  ┌──────────────────┐  │
         │  │ Row       │  │                  │  │
         │  │ Decoder   │  │  Bitcell Array   │  │
         │  │           │  │  (NxM 6T cells)  │  │
         │  └──────────┘  │                  │  │
         │                 └──────────────────┘  │
         │  ┌──────────────────────────────────┐ │
         │  │ Precharge + Sense Amp + Write    │ │
         │  │ Driver + Column Mux              │ │
         │  └──────────────────────────────────┘ │
         │  ┌──────────────────────────────────┐ │
         │  │ Control Logic (clk, csb, web)    │ │
         │  └──────────────────────────────────┘ │
         └──────────────────────────────────────┘
```

### Config 파일 작성법

```python
# sram_config.py 예시
word_size = 32          # 워드 폭 (비트)
num_words = 256         # 워드 수
num_rw_ports = 1        # Read-Write 포트 수
num_r_ports = 0         # Read-only 포트 수
num_w_ports = 0         # Write-only 포트 수

tech_name = "sky130"    # 타겟 PDK
nominal_temperature = 25
supply_voltages = [1.8]
process_corners = ["TT"]

output_name = "sram_256x32"
output_path = "./output"

# SPICE 시뮬레이터 (타이밍 추출용)
spice_name = "ngspice"  # 또는 "hspice"
```

### 실행 방법

```bash
# 환경 설정
export OPENRAM_HOME=/path/to/OpenRAM/compiler
export OPENRAM_TECH=/path/to/OpenRAM/technology
export PDK_ROOT=/path/to/pdk    # sky130 사용 시

# SRAM 생성
python3 $OPENRAM_HOME/../sram_compiler.py my_config.py

# 또는 직접
python3 sram_compiler.py -t sky130 -o my_sram my_config.py
```

### 출력 파일

| 파일 | 용도 | ASIC flow 사용 위치 |
|------|------|---------------------|
| `.lib` | 타이밍/파워 모델 (Liberty) | Synthesis, STA |
| `.lef` | 추상 레이아웃 (핀 위치, 면적) | Floorplan, PnR |
| `.gds` | 물리적 레이아웃 | GDS merge (최종) |
| `.v` | Verilog behavioral 모델 | Simulation, Synthesis (blackbox) |
| `.sp` | SPICE 넷리스트 | LVS, 시뮬레이션 |

### Sky130에서의 사용

```bash
# PDK 설치 (OpenRAM 내장)
cd OpenRAM
make sky130-pdk       # SkyWater PDK 다운로드
make sky130-install   # OpenRAM용 설치

# Config 예시 (sky130)
word_size = 64
num_words = 256
tech_name = "sky130"
supply_voltages = [1.8]
process_corners = ["TT"]
```

### ORFS 통합 방법

OpenRAM 출력물을 ORFS에 연결:

```makefile
# config.mk에 추가
SRAM_DIR = /path/to/openram/output
export ADDITIONAL_LEFS = $(SRAM_DIR)/my_sram.lef
export ADDITIONAL_LIBS = $(SRAM_DIR)/my_sram_TT_1p8V_25C.lib
export ADDITIONAL_GDS  = $(SRAM_DIR)/my_sram.gds
```

RTL에서 SRAM 인스턴스를 blackbox로 선언하고, OpenRAM이 생성한 `.v` 모델의 포트에 맞춰 연결.

---

## 3개 도구의 통합 관계

```
                    ┌───────────┐
                    │  OpenRAM  │
                    │  .lib     │
                    │  .lef     │──────────┐
                    │  .gds     │          │
                    │  .v       │          │
                    └───────────┘          │
                                          ▼
RTL (.v) ──▶ ┌──────────────────────────────────────┐
SDC (.sdc)   │        ORFS (Makefile + scripts)      │
             │                                        │
             │  Yosys ──▶ OpenROAD ──▶ KLayout       │
             │  (synth)   (PnR)        (GDS merge)   │
             │                                        │
             └────────────────────────────────────────┘
                                          │
                                          ▼
                                       GDS-II
```

1. **OpenRAM** → SRAM macro의 .lib/.lef/.gds/.v 생성
2. **ORFS** → Makefile로 전체 flow 자동화, OpenRAM 출력물을 ADDITIONAL_* 변수로 연결
3. **OpenROAD** → ORFS가 호출하는 실제 PnR 엔진
