# Generic RTL Run Template

이 디렉토리는 `training/*` 예제와 별도로, 사용자가 임의의 RTL을 training 방식으로 태워보기 위한 일반화된 run workspace 입니다.

의도는 단순합니다.

1. `training/`은 저장소가 제공하는 curated example로 유지
2. `runs/`는 사용자가 외부 RTL, 실험용 RTL, 사내 RTL을 꽂아 넣는 작업 공간으로 사용

## Quick Start

```bash
cp -r runs/template_rtl runs/my_design
cd runs/my_design
```

그 다음 아래만 수정하면 됩니다.

1. `design.cfg`
2. `rtl.f`
3. `src/`
4. `constraints/constraint.sdc`
5. 필요하면 `tb/`

## Minimal Flow

테스트벤치가 없는 real RTL도 돌릴 수 있게 simulation은 optional 입니다.

```bash
source ../../env.sh
bash 00_clean.sh
bash 01_sim.sh        # ENABLE_SIM=1일 때만 실제 실행
bash 02_setup_ORFS.sh
bash 99_fullflow.sh
```

## Recommended Edit Points

### `design.cfg`

- `DESIGN_NAME`: ORFS 결과 디렉토리 이름과 top module 이름
- `TOP_MODULE`: Verilator top module
- `RTL_FILELIST`: filelist 경로
- `TB_FILE`: testbench 경로
- `ENABLE_SIM`: `1`이면 Verilator simulation, `0`이면 skip
- `SDC_FILE`: SDC 경로
- `CLOCK_PERIOD`: 목표 주기
- `CORE_UTILIZATION`, `PLACE_DENSITY`: floorplan tuning

### `rtl.f`

run 디렉토리 기준 상대경로로 RTL 파일을 적습니다.

예:

```text
src/my_top.v
src/my_submodule.v
```

### `constraint.sdc`

최소한 clock은 지정해야 합니다.

```tcl
create_clock [get_ports clk] -name core_clock -period 10.0
set_input_delay  2.0 -clock core_clock [all_inputs]
set_output_delay 2.0 -clock core_clock [all_outputs]
```

## Common Modes

### A. Simulation 가능한 경우

- `ENABLE_SIM=1`
- `tb/` 아래 C++ testbench 작성
- `bash 01_sim.sh`로 기능 검증 후 flow 진행

### B. Simulation 없이 바로 합성하는 경우

- `ENABLE_SIM=0`
- `bash 01_sim.sh`는 안내만 출력하고 skip
- 바로 `bash 02_setup_ORFS.sh` 진행

## Output Locations

- ORFS config: `tools/OpenROAD-flow-scripts/flow/designs/<platform>/<design>/config.mk`
- reports: `tools/OpenROAD-flow-scripts/flow/reports/<platform>/<design>/base/`
- results: `tools/OpenROAD-flow-scripts/flow/results/<platform>/<design>/base/`

## Notes

- 현재 템플릿은 `sky130hd`를 기본값으로 둡니다.
- macro LEF/LIB/GDS가 있으면 `design.cfg`의 optional 변수로 추가할 수 있습니다.
- ORFS 내장 finish를 그대로 쓰지 않고 KLayout merge를 한 번 더 수행하는 현재 저장소 흐름을 그대로 따릅니다.
