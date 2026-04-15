# Dual-Track RTL-to-GDS Guide: ORFS vs OpenLane

> 동일한 디자인을 **Track A (ORFS 수동)** 와 **Track B (OpenLane 자동)** 두 경로로 동시에 진행하면서
> 각 단계의 차이점을 비교합니다.

---

## 왜 2-Track인가?

| | Track A: ORFS (수동) | Track B: OpenLane (자동) |
|---|---|---|
| **장점** | 각 단계를 직접 제어, 내부 이해 | DRC/LVS 자동, tapeout 검증된 flow |
| **단점** | DRC/LVS 수동, 설정 복잡 | 내부가 블랙박스처럼 느껴질 수 있음 |
| **적합한 경우** | 학습, 커스터마이징, 디버깅 | 실제 제작, 빠른 반복, sign-off |

**이 가이드의 목표**: 같은 RTL을 두 flow로 돌려보고, 결과(area, timing, power, GDS)를 비교

---

## Step 0: 환경 확인

### Track A: ORFS

```bash
source env.sh

# 확인
$YOSYS_EXE -V                    # Yosys 0.63
openroad -version                 # v2.0-16595
sta -version                      # 2.6.0
echo "quit" | magic -d null       # OK
klayout -v                        # 0.29.7
```

### Track B: OpenLane 2

```bash
# Docker 방식 (권장)
docker pull efabless/openlane2:2.3.10

# 또는 pip 방식
pip3 install openlane
python3.12 -m openlane --version  # 2.3.10
```

---

## Step 1: RTL 준비 (공통)

동일한 RTL을 양쪽에서 사용합니다.

```bash
# 이미 만들어진 training 디자인 사용
cat training/counter4/src/counter4.v
```

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

---

## Step 2: Simulation (공통)

```bash
cd training/counter4
verilator --cc --exe --build -Wno-fatal \
  -Mdir build --top-module counter4 \
  src/counter4.v tb/tb_counter4.cpp
./build/Vcounter4
# → ALL TESTS PASSED
```

---

## Step 3: Synthesis

### Track A: ORFS (Yosys via Makefile)

```bash
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk synth
cat reports/sky130hd/counter4/base/synth_stat.txt
```

config.mk:
```makefile
export DESIGN_NAME = counter4
export PLATFORM    = sky130hd
export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/counter4.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc
export CORE_UTILIZATION  = 10
export EQUIVALENCE_CHECK = 0
```

### Track B: OpenLane

```bash
mkdir -p openlane_run/counter4
cd openlane_run/counter4
cp ../../training/counter4/src/counter4.v .
```

config.json:
```json
{
    "DESIGN_NAME": "counter4",
    "VERILOG_FILES": "dir::*.v",
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": 10.0,
    "FP_CORE_UTIL": 20,
    "PL_TARGET_DENSITY_PCT": 30,
    "DIE_AREA": "0 0 50 50",
    "FP_SIZING": "absolute"
}
```

Docker 실행:
```bash
docker run --rm \
  -v $(pwd):/work \
  -v $HOME/.volare:/home/jysong/.volare \
  -w /work \
  efabless/openlane2:2.3.10 \
  python3 -m openlane config.json
```

### 비교 포인트

| 항목 | Track A (ORFS) | Track B (OpenLane) |
|------|---|---|
| 설정 파일 | config.mk (Makefile 변수) | config.json (JSON) |
| 합성 도구 | Yosys (ORFS 빌드) | Yosys (Docker 내장) |
| 실행 방식 | `make ... synth` | 자동 (flow 일부) |
| 결과 위치 | `results/sky130hd/counter4/base/` | `runs/RUN_*/` |

---

## Step 4: STA (Static Timing Analysis)

### Track A: OpenSTA standalone

```bash
cd $ORFS/flow
sta -exit << 'STASCRIPT'
read_liberty platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog results/sky130hd/counter4/base/1_synth.v
link_design counter4
read_sdc designs/sky130hd/counter4/constraint.sdc

puts "=== Setup Analysis ==="
report_checks -path_delay max

puts "\n=== Hold Analysis ==="
report_checks -path_delay min

puts "\n=== Summary ==="
report_tns
report_wns
report_power
STASCRIPT
```

### Track B: OpenLane

OpenLane은 STA를 flow 내에서 자동 실행합니다.
결과는 `runs/RUN_*/reports/` 에서 확인:
- `synthesis/checks.rpt` — post-synth STA
- `routing/checks.rpt` — post-route STA

### 비교 포인트

| 항목 | Track A | Track B |
|------|---------|---------|
| STA 도구 | OpenSTA (standalone) | OpenSTA (OpenROAD 내장) |
| 실행 시점 | 원하는 시점에 수동 실행 | 각 단계 후 자동 실행 |
| Liberty | 직접 지정 | PDK에서 자동 로드 |
| Multi-corner | 수동 스크립트 필요 | 자동 (ss/tt/ff) |

---

## Step 5: PnR (Floorplan → Route)

### Track A: ORFS (단계별)

```bash
# 개별 단계 실행
make ... synth
make ... floorplan
make ... place
make ... cts
make ... route

# 또는 한 번에
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk

# congestion.rpt workaround
touch reports/sky130hd/counter4/base/congestion.rpt
make DESIGN_CONFIG=./designs/sky130hd/counter4/config.mk
```

### Track B: OpenLane

```bash
# 전체 flow 한 번에 (synth + PnR + DRC + LVS + GDS)
docker run --rm \
  -v $(pwd):/work \
  -w /work \
  efabless/openlane2:2.3.10 \
  python3 -m openlane config.json
```

### 비교 포인트

| 항목 | Track A | Track B |
|------|---------|---------|
| 단계 제어 | 개별 make target | 자동 (config로 제어) |
| 중간 결과 확인 | `results/` 직접 확인 | `runs/RUN_*/` 확인 |
| PDN 문제 | 수동 해결 (utilization 조정) | 자동 조정 |
| congestion.rpt | workaround 필요 | 불필요 |
| GUI crash | QT_QPA_PLATFORM 설정 필요 | Docker 내 자동 처리 |

---

## Step 6: GDS 생성

### Track A: KLayout 수동

```bash
cat platforms/sky130hd/lef/sky130_fd_sc_hd.tlef \
    platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef \
    > results/sky130hd/counter4/base/merged.lef

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

### Track B: OpenLane

자동 생성. `runs/RUN_*/final/gds/counter4.gds` 에 출력.

---

## Step 7: DRC/LVS

### Track A: 수동 (Magic + Netgen)

```bash
# DRC
magic -d null -T sky130A << 'EOF'
gds read results/sky130hd/counter4/base/6_final.gds
load counter4
select top cell
drc check
drc count
quit
EOF

# LVS
netgen -batch lvs \
  "results/.../6_final.spice counter4" \
  "results/.../6_final.v counter4" \
  $PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \
  lvs_result.log
```

### Track B: OpenLane

**자동 실행.** 결과:
- `runs/RUN_*/reports/signoff/drc.rpt`
- `runs/RUN_*/reports/signoff/lvs.rpt`
- DRC clean이 아니면 flow가 경고/에러를 발생

### 비교 포인트

| 항목 | Track A | Track B |
|------|---------|---------|
| DRC | Magic 수동 | Magic 자동 |
| LVS | Netgen 수동 | Netgen 자동 |
| Antenna check | OpenROAD (flow 중) | 자동 + 수정 |
| Sign-off 기준 | 직접 판단 | flow가 pass/fail 판정 |

---

## Step 8: 결과 비교

최종 결과를 나란히 비교합니다.

### counter4 on SKY130 (실측 결과 — Track A)

| Metric | Track A (ORFS) | Track B (OpenLane) |
|--------|---|---|
| Cells | 11 | (실행 후 기입) |
| Area | 235 µm² | |
| Clock period | 10ns | 10ns |
| Setup slack | +8.85ns | |
| Hold slack | +0.51ns | |
| Total power | 78.5µW | |
| GDS size | 114KB | |
| DRC | (수동 필요) | (자동) |
| LVS | (수동 필요) | (자동) |

---

## 실행 순서 요약

```
                    ┌── Track A: ORFS ──┐    ┌── Track B: OpenLane ──┐
                    │                    │    │                       │
Step 1: RTL ────────┼────── 공통 ────────┼────┤                       │
Step 2: Sim ────────┼────── 공통 ────────┼────┤                       │
                    │                    │    │                       │
Step 3: Synth ──────┤ make ... synth     │    │ python -m openlane    │
Step 4: STA ────────┤ sta (standalone)   │    │ (자동)                │
Step 5: PnR ────────┤ make ... (단계별)  │    │ (자동)                │
Step 6: GDS ────────┤ klayout (수동)     │    │ (자동)                │
Step 7: DRC/LVS ────┤ magic/netgen (수동)│    │ (자동)                │
                    │                    │    │                       │
Step 8: 비교 ───────┴────────────────────┴────┴───────────────────────┘
```

---

## 따라하기 체크리스트

### Track A (ORFS)
- [ ] `source env.sh`
- [ ] Verilator sim PASS
- [ ] `make ... synth` → synth_stat.txt 확인
- [ ] `sta` standalone → slack 확인
- [ ] `make ... floorplan place cts`
- [ ] `touch congestion.rpt && make ... route`
- [ ] KLayout GDS 생성
- [ ] Magic DRC
- [ ] Netgen LVS

### Track B (OpenLane)
- [ ] Docker image pull 완료
- [ ] config.json 작성
- [ ] `docker run ... python3 -m openlane config.json`
- [ ] `runs/RUN_*/` 결과 확인
- [ ] DRC/LVS 리포트 확인
- [ ] GDS 확인

### 비교
- [ ] 결과 표 작성 (cells, area, timing, power, GDS)
- [ ] DRC/LVS 결과 비교
- [ ] flow 소요 시간 비교
- [ ] 어떤 상황에서 어떤 flow가 적합한지 결론

---

## 다음으로 할 수 있는 것

### 난이도 순서
1. **counter4** (이 가이드) — 가장 간단, flow 검증용
2. **8-bit ALU** (`designs/03_alu/`) — 조합+순차 혼합
3. **PicoRV32** (`designs/04_picorv32/`) — 실제 CPU
4. **SoC + SRAM** (`designs/05_soc/`) — macro 포함

### 실험 아이디어
- 같은 디자인으로 **clock period 줄여보기** (10ns → 5ns → 2ns)
- **다른 PDK**로 비교 (sky130hd vs gf180 vs asap7)
- **OpenRAM SRAM** 직접 생성하여 SoC에 통합
- **Synopsys DC/PT** 결과와 오픈소스 결과 비교

---

## 참고 문서

| 문서 | 내용 |
|------|------|
| [Training Guide](training_guide.md) | Part별 상세 설명 (개념 포함) |
| [Blog Post](blog_rtl_to_gds.md) | 전체 flow 포스팅용 (실측 수치) |
| [Tool Analysis](tool_analysis.md) | OpenROAD/ORFS/OpenRAM 내부 구조 |
| [Getting Started](getting_started.md) | 환경 구축 상세 |
| [Evaluation](evaluation.md) | 프로젝트 평가 + 개선점 |
