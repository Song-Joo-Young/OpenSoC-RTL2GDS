# Getting Started Guide

> 이 문서는 처음부터 끝까지, 아무것도 없는 Linux 서버에서
> RTL-to-GDS flow를 구축하고 첫 GDS를 뽑기까지의 전 과정을 설명합니다.

---

## 이 프로젝트가 하는 일

오픈소스 EDA 도구만으로 디지털 회로 설계의 전체 흐름을 수행합니다:

```
Verilog RTL → Synthesis → Floorplan → Placement → CTS → Routing → GDS-II
```

작은 예제(GCD)부터 시작해서, 직접 만든 RTL, RISC-V CPU, SoC+SRAM까지 단계적으로 확장합니다.

---

## 전제 조건

### 시스템 요구사항

| 항목 | 최소 | 권장 |
|------|------|------|
| OS | Linux (RHEL 8 / Ubuntu 20.04+) | RHEL 8 / Ubuntu 22.04 |
| RAM | 16GB | 32GB+ |
| CPU | 4 cores | 8+ cores |
| Disk | 20GB | 50GB+ |
| X11 headers | libX11-devel | 필수 (Magic 빌드용) |

### 사전 설치 필요 (시스템 패키지)

```bash
# RHEL/CentOS
sudo yum install -y git make gcc gcc-c++ python3 python3-pip \
  tcl-devel libX11-devel java-1.8.0-openjdk clang

# Ubuntu/Debian
sudo apt install -y git make gcc g++ python3 python3-pip \
  tcl-dev tk-dev libx11-dev default-jdk clang
```

아래 도구들이 **이미 시스템에 설치**되어 있으면 빌드를 건너뛸 수 있습니다:
- OpenROAD (`openroad -version`)
- Verilator (`verilator --version`)
- KLayout (`klayout -v`)

---

## Step 1: 프로젝트 클론

```bash
git clone git@github.com:Song-Joo-Young/OpenSoC-RTL2GDS.git
cd OpenSoC-RTL2GDS
```

---

## Step 2: 도구 빌드

### 자동 설치 (권장)

```bash
bash scripts/setup_tools.sh
```

이 스크립트는 다음을 수행합니다:
1. **Magic** — DRC 도구. `$HOME/local/bin/magic`에 설치
2. **Netgen** — LVS 도구. `$HOME/local/bin/netgen`에 설치
3. **OpenROAD-flow-scripts (ORFS)** — RTL-to-GDS 자동화 스크립트
4. **OpenRAM** — SRAM macro compiler

모든 도구는 `$HOME/local/`에 설치되므로 **sudo 불필요**.

### Yosys 빌드 (ORFS용)

ORFS는 자체 Yosys가 필요합니다. 시스템 Yosys와 버전이 안 맞을 수 있으므로:

```bash
cd tools/OpenROAD-flow-scripts/tools/yosys
make clean
make -j$(nproc) CC=clang CXX=clang++ \
  PREFIX=../install/yosys
make install CC=clang CXX=clang++ \
  PREFIX=../install/yosys
```

> **참고**: GCC 8에서 `std::filesystem` 링크 오류가 발생하면 반드시 `clang`으로 빌드하세요.

### ORFS 버전 핀닝 (중요!)

시스템 OpenROAD 버전과 ORFS 버전이 일치해야 합니다.
시스템 OpenROAD 빌드 날짜를 확인하고, 해당 시점의 ORFS 커밋을 사용하세요:

```bash
# 시스템 OpenROAD 버전 확인
openroad -version
# 출력 예: v2.0-16595-g2f10d9354

# ORFS 내부에서 해당 커밋 날짜 찾기
cd tools/OpenROAD-flow-scripts/tools/OpenROAD
git log --format="%ad" --date=short 2f10d9354 -1
# 출력 예: 2024-10-16

# ORFS를 해당 날짜의 커밋으로 체크아웃
cd ../..
git log --oneline --before="2024-10-20" | head -1
git checkout <해당_커밋>
```

이 프로젝트에서 검증된 조합: **ORFS b811251d2 + OpenROAD v2.0-16595 + Yosys 0.63**

---

## Step 3: PDK 설치

```bash
bash scripts/setup_pdk.sh
```

이 스크립트는 [open_pdks](https://github.com/RTimothyEdwards/open_pdks)를 사용하여
SKY130 PDK를 `pdk/` 디렉토리에 설치합니다.

> **소요 시간**: 30분~1시간 (네트워크 속도에 따라 다름)
>
> **참고**: ORFS에는 자체 sky130hd platform 파일(lib/lef/gds)이 포함되어 있으므로,
> ORFS flow 실행 자체는 open_pdks 설치 없이도 가능합니다.
> open_pdks는 Magic DRC, Netgen LVS 등에 필요합니다.

---

## Step 4: 환경 변수 로드

```bash
source env.sh
```

출력 예:
```
[env] PROJECT_ROOT=/home/user/OpenSoC-RTL2GDS
[env] PDK=sky130A | ORFS=/home/user/OpenSoC-RTL2GDS/tools/OpenROAD-flow-scripts
[env] YOSYS=/home/user/OpenSoC-RTL2GDS/tools/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
[env] tools → /home/user/local/bin
```

> **매 터미널 세션마다** `source env.sh`를 실행해야 합니다.

---

## Step 5: 첫 GDS 생성 (GCD 예제)

```bash
cd $ORFS/flow

# RTL → GDS 전체 flow 실행
make DESIGN_CONFIG=./designs/sky130hd/gcd/config.mk

# congestion.rpt 이슈 발생 시:
touch reports/sky130hd/gcd/base/congestion.rpt
make DESIGN_CONFIG=./designs/sky130hd/gcd/config.mk

# GDS 수동 생성 (headless 환경에서 6_report GUI crash 시):
cat platforms/sky130hd/lef/sky130_fd_sc_hd.tlef \
    platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef \
    > results/sky130hd/gcd/base/merged.lef

klayout -zz \
  -rd design_name=gcd \
  -rd in_def=./results/sky130hd/gcd/base/6_final.def \
  -rd in_files="./platforms/sky130hd/gds/sky130_fd_sc_hd.gds" \
  -rd out_file=./results/sky130hd/gcd/base/6_final.gds \
  -rd seal_file="" \
  -rd tech_file=./platforms/sky130hd/sky130hd.lyt \
  -rd layer_map="" \
  -rm ./util/def2stream.py
```

### 결과 확인

```bash
# GDS 파일 확인
ls -lh results/sky130hd/gcd/base/6_final.gds

# 리포트 확인
cat reports/sky130hd/gcd/base/synth_stat.txt    # 합성 통계
cat reports/sky130hd/gcd/base/5_global_route.rpt # timing/power

# KLayout으로 GDS 시각화 (GUI 환경에서)
klayout results/sky130hd/gcd/base/6_final.gds
```

---

## Step 6: 직접 RTL로 GDS 만들기

### 6-1. RTL 작성

`designs/` 아래에 디자인 디렉토리를 만듭니다:

```bash
mkdir -p designs/my_design/{src,constraints,tb}
```

Verilog RTL을 `src/`에, SDC를 `constraints/`에 작성합니다.

### 6-2. Verilator로 기능 검증

```bash
verilator --cc --exe --build -Wno-fatal \
  -Mdir build --top-module my_module \
  src/my_module.v tb/tb_my_module.cpp
./build/Vmy_module
```

### 6-3. ORFS config 작성

ORFS의 `flow/designs/` 내에 config를 만듭니다:

```bash
# RTL 복사
mkdir -p $ORFS/flow/designs/src/my_design
cp designs/my_design/src/*.v $ORFS/flow/designs/src/my_design/

# Platform config
mkdir -p $ORFS/flow/designs/sky130hd/my_design
```

`config.mk` 예:
```makefile
export DESIGN_NAME = my_module
export PLATFORM    = sky130hd

export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/my_module.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION  = 40
export TNS_END_PERCENT   = 100
export EQUIVALENCE_CHECK = 0
```

`constraint.sdc` 예:
```tcl
create_clock [get_ports clk] -name core_clock -period 10.0
set_input_delay  2.0 -clock core_clock [all_inputs]
set_output_delay 2.0 -clock core_clock [all_outputs]
```

### 6-4. Flow 실행

```bash
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/my_design/config.mk
```

---

## SRAM Macro 포함 SoC 만들기

ORFS에 pre-built sky130 SRAM macro가 포함되어 있습니다:

```
platforms/sky130ram/sky130_sram_1rw1r_64x256_8/
  ├── sky130_sram_1rw1r_64x256_8.lef
  ├── sky130_sram_1rw1r_64x256_8_TT_1p8V_25C.lib
  ├── sky130_sram_1rw1r_64x256_8.gds
  └── sky130_sram_1rw1r_64x256_8.v
```

`config.mk`에 macro를 추가합니다:

```makefile
SRAM_DIR = $(PLATFORM_DIR)/../sky130ram/sky130_sram_1rw1r_64x256_8
export ADDITIONAL_LEFS = $(SRAM_DIR)/sky130_sram_1rw1r_64x256_8.lef
export ADDITIONAL_LIBS = $(SRAM_DIR)/sky130_sram_1rw1r_64x256_8_TT_1p8V_25C.lib
export ADDITIONAL_GDS  = $(SRAM_DIR)/sky130_sram_1rw1r_64x256_8.gds

export MACRO_PLACE_HALO    = 10 10
export MACRO_PLACE_CHANNEL = 20 20
```

Phase 5의 `designs/05_soc/src/picosoc_mini.v`를 참고하세요.

---

## Troubleshooting

### congestion.rpt 에러
```
Error: detail_route.tcl, 5 could not read "congestion.rpt"
```
**해결**: `touch reports/{platform}/{design}/base/congestion.rpt` 후 `make` 재실행

### Qt GUI crash (6_report)
```
Command terminated by signal 6
```
**해결**: `export QT_QPA_PLATFORM=offscreen` (env.sh에 포함됨).
GDS는 KLayout으로 수동 생성 (Step 5 참조).

### Yosys `read_liberty` 에러
```
Unknown option or option in arguments
```
**해결**: 시스템 Yosys와 ORFS 버전 불일치. ORFS 내장 Yosys를 빌드하세요 (Step 2).

### ORFS `eliminate_dead_logic` / `match_cell_footprint` 에러
**해결**: OpenROAD와 ORFS 버전 불일치. ORFS를 시스템 OpenROAD 빌드 날짜에 맞는 커밋으로 체크아웃 (Step 2).

### GCC `std::filesystem` 링크 에러
```
undefined reference to `std::filesystem::__cxx11::path::_M_split_cmpts()'
```
**해결**: GCC 대신 clang으로 빌드. `make CC=clang CXX=clang++`

---

## 다음 단계

- **DRC/LVS 실행**: Magic으로 DRC, Netgen으로 LVS 검증
- **Clock frequency 실험**: SDC clock period 조정하여 timing closure 연습
- **OpenRAM으로 SRAM 직접 생성**: `sram-lib-gen/` 참고
- **다른 PDK**: GF180, ASAP7 등으로 동일 디자인 비교
- **Synopsys 도구 연동**: DC/PT 결과와 오픈소스 결과 비교
