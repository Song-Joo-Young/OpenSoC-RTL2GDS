# Progress Log

## Phase 0: 환경 구축
- **시작일**: 2026-04-14
- **상태**: Complete

### Checklist
- [x] Git 초기화 + remote 연결
- [x] Magic 빌드 (local, $HOME/local/bin/magic, X11 only, no Tcl/Tk)
- [x] Netgen 빌드 (local, $HOME/local/bin/netgen)
- [x] open_pdks → SKY130 설치 ($PROJECT_ROOT/pdk/share/pdk/sky130A)
- [ ] open_pdks → GF180 설치 (configure에 포함되었으나 아직 미검증)
- [x] OpenROAD-flow-scripts clone (checkout: b811251d2, 2024-10-16 호환)
- [x] OpenRAM clone + Python deps 설치
- [x] Yosys 0.63 빌드 (clang 19, ORFS 내장 소스)
- [x] env.sh 검증

### Notes
- 시스템 OpenROAD: v2.0-16595 (2024-10-16 빌드)
- ORFS는 해당 날짜에 맞는 커밋(b811251d2)으로 체크아웃
- Yosys는 ORFS 내장 소스에서 clang으로 빌드 (GCC 8 filesystem 링크 오류 회피)
- EQUIVALENCE_CHECK=0 필수 (eqy 미설치)
- headless 환경: GUI 리포트 단계에서 Qt crash → GDS는 KLayout으로 수동 생성

---

## Phase 1: GCD 예제 → 첫 GDS
- **시작일**: 2026-04-14
- **상태**: Complete

### 결과
- **GDS**: `tools/OpenROAD-flow-scripts/flow/results/sky130hd/gcd/base/6_final.gds` (904KB)
- **PDK**: sky130hd
- **Clock period**: 2.5ns (400MHz target)
- **Cells**: 264
- **Area**: 3872 µm² (61% utilization)
- **Power**: 2.64mW total (Sequential 31%, Combinational 52%, Clock 17%)
- **Timing**: setup violations 존재 (slack -0.496ns on resp_msg[14])

### Flow 단계별 결과
| Stage | Status | File |
|-------|--------|------|
| 1_synth | ✅ | 1_synth.odb |
| 2_floorplan | ✅ | 2_floorplan.odb |
| 3_place | ✅ | 3_place.odb |
| 4_cts | ✅ | 4_1_cts.odb |
| 5_route | ✅ | 5_route.odb |
| 6_final | ✅ | 6_final.gds (904KB) |

### ORFS 실행 명령
```bash
source env.sh
cd $ORFS/flow
make DESIGN_CONFIG=./designs/sky130hd/gcd/config.mk \
  YOSYS_EXE=../tools/install/yosys/bin/yosys \
  OPENROAD_EXE=/usr/bin/openroad \
  KLAYOUT_CMD=/usr/local/bin/klayout \
  EQUIVALENCE_CHECK=0
```
