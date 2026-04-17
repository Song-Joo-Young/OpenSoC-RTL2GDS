# First-User Walkthrough

`training/01_counter4` 기준으로, 처음 들어온 사용자가 실제로 어디까지 막힘 없이 따라갈 수 있는지 점검하기 위한 체크리스트입니다.

이 문서는 두 용도로 씁니다.

1. README만 보고 처음 실행하는 사용자의 동선을 검증
2. 문서와 스크립트 사이에서 생기는 friction point를 빠르게 기록

---

## Scope

기준 경로:

```bash
bash scripts/setup_tools.sh
bash scripts/setup_pdk.sh
source env.sh
bash training/01_counter4/01_sim.sh
bash training/01_counter4/99_fullflow.sh
```

성공 기준:

- simulation PASS
- ORFS 결과 디렉토리 생성
- `6_final.def` 생성
- `6_final.gds` 생성
- 사용자가 다음 단계로 무엇을 봐야 하는지 문서만 읽고 이해 가능

참고:

- curated 첫 실습은 `training/01_counter4`
- 사용자 임의 RTL용 일반화 템플릿은 `runs/template_rtl`

---

## Preflight Checklist

### Repository 이해

- [ ] `README.md`만 읽고 이 저장소의 목적이 이해된다
- [ ] `training/`과 `designs/`의 역할 차이가 이해된다
- [ ] 첫 실행 경로가 `training/01_counter4`라는 점이 명확하다

### Environment 준비

- [ ] `bash scripts/setup_tools.sh`가 선행되어야 한다는 점이 명확하다
- [ ] `bash scripts/setup_pdk.sh`가 시간이 가장 오래 걸린다는 점이 명확하다
- [ ] `source env.sh`를 매 새 shell에서 다시 해야 한다는 점이 명확하다

---

## Walkthrough

### Step 1. Tool Setup

```bash
bash scripts/setup_tools.sh
```

사용자가 알아야 하는 것:

- Tk, Magic, Netgen, ORFS, Yosys, OpenRAM 준비 단계다
- 네트워크와 빌드 시간이 필요하다
- 실패 시 `magic --version`이 먼저 정상인지 확인해야 한다

체크:

- [ ] 스크립트 종료 후 다음 단계가 `setup_pdk.sh`로 안내된다
- [ ] `magic`, `netgen`, ORFS/Yosys 준비가 로그상 드러난다

### Step 2. PDK Setup

```bash
bash scripts/setup_pdk.sh
```

사용자가 알아야 하는 것:

- 가장 오래 걸리는 단계다
- 일부 RF/analog 경고가 나와도 digital flow에는 치명적이지 않을 수 있다
- 최종적으로 `sky130_fd_sc_hd` 라이브러리 설치 여부가 핵심이다

체크:

- [ ] 완료 후 `pdk/share/pdk/sky130A/`가 존재한다
- [ ] 표준셀 `.lib` 디렉토리가 비어 있지 않다

### Step 3. Environment Load

```bash
source env.sh
```

체크:

- [ ] `PROJECT_ROOT`, `ORFS`, `YOSYS_EXE`가 출력된다
- [ ] 사용자는 이 단계가 매 shell마다 필요하다는 점을 이해한다

### Step 4. Functional Simulation

```bash
bash training/01_counter4/01_sim.sh
```

기대 결과:

- Verilator 빌드 성공
- 테스트벤치 PASS

체크:

- [ ] `=== ALL TESTS PASSED ===`를 확인할 수 있다
- [ ] 실패하면 RTL 또는 testbench 문제라는 점이 자연스럽다

### Step 5. End-to-End Flow

```bash
bash training/01_counter4/99_fullflow.sh
```

실제로 내부에서 하는 일:

1. ORFS 결과 정리
2. `congestion.rpt` workaround 생성
3. `synth -> floorplan -> place -> cts -> route`
4. `do-6_report`까지 실행해 `6_final.def` 확보
5. KLayout로 `6_final.gds` 수동 merge

체크:

- [ ] 최종적으로 `tools/OpenROAD-flow-scripts/flow/results/sky130hd/counter4/base/6_final.gds`가 생긴다
- [ ] `reports/.../synth_stat.txt`와 `5_global_route.rpt`를 사용자가 찾을 수 있다
- [ ] README 또는 training guide를 통해 “왜 ORFS 기본 finish가 아니라 수동 GDS merge를 하는지” 이해할 수 있다

---

## Expected Output Locations

| Artifact | Path |
|----------|------|
| synthesis stats | `tools/OpenROAD-flow-scripts/flow/reports/sky130hd/counter4/base/synth_stat.txt` |
| route timing report | `tools/OpenROAD-flow-scripts/flow/reports/sky130hd/counter4/base/5_global_route.rpt` |
| final DEF | `tools/OpenROAD-flow-scripts/flow/results/sky130hd/counter4/base/6_final.def` |
| final GDS | `tools/OpenROAD-flow-scripts/flow/results/sky130hd/counter4/base/6_final.gds` |

---

## Current Friction Points

### 1. GDS 생성은 ORFS 기본 finish 단계를 그대로 쓰지 않는다

- 현재 training full flow는 ORFS 내부 finish에 전적으로 의존하지 않고, `6_final.def` 이후 KLayout merge를 별도로 수행한다.
- 이 사유를 README와 training guide에서 계속 유지해 주는 것이 좋다.

### 2. `congestion.rpt` placeholder workaround가 숨어 있다

- 사용자는 이것이 ORFS 호환성 workaround인지, 필수 flow step인지 혼동할 수 있다.
- 문서에 “사용자가 이해할 필요는 없지만 현재는 자동화 보정”이라고 적어두는 편이 낫다.

### 3. Sign-off는 완전 자동이 아니다

- `11_signoff.sh`에서 DRC는 바로 가능하지만, LVS는 layout SPICE가 있을 때만 실제 Netgen 비교를 돈다.
- 따라서 현재 기준 “full flow”는 엄밀히 말해 GDS 중심의 full flow이고, sign-off 자동화는 부분적이다.

### 4. Headless와 GUI 사용 시 기대 동작 차이

- headless 서버에서는 `QT_QPA_PLATFORM=offscreen`이 필요할 수 있다.
- 반대로 로컬 GUI에서 KLayout을 직접 보고 싶다면 이 변수를 강제하지 않는 현재 방식이 맞다.

---

## Pass / Fail Summary Template

새 사용자가 실제로 따라가 본 뒤 아래 표만 채워도 문서 품질을 다시 판단할 수 있습니다.

| Item | Pass? | Note |
|------|-------|------|
| README만 보고 첫 경로 이해 |  |  |
| tool setup 수행 가능 |  |  |
| pdk setup 수행 가능 |  |  |
| env load 이해 가능 |  |  |
| counter4 sim PASS |  |  |
| counter4 fullflow GDS 생성 |  |  |
| 결과 경로 찾기 쉬움 |  |  |
| sign-off 범위 이해 가능 |  |  |
