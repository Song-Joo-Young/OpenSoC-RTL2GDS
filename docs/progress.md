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

---

## Phase 2: Custom RTL (Counter) → GDS
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- Parameterized 8-bit up/down counter with load, enable, zero/max flags
- Verilator simulation: PASS (22 cycles, 6 test cases)

### SKY130 vs GF180 비교

| Metric | SKY130 (130nm) | GF180 (180nm) |
|--------|---------------|---------------|
| Clock period | 5.0ns (200MHz) | 10.0ns (100MHz) |
| Slack | +2.093ns | +6.097ns |
| Area | 865 µm² (54%) | 4795 µm² (49%) |
| Total Power | 0.267mW | 5.86mW |
| GDS size | 342KB | (DEF only) |

### Key Observations
- GF180은 180nm이므로 area 5.5x 더 큼
- GF180 power 22x 더 높음 (공정+전압 차이)
- 둘 다 timing met with positive slack

---

## Phase 3: ALU (timing closure 연습)
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- 8-bit pipelined ALU: ADD/SUB/AND/OR/XOR/NOT/SHR/SHL/SLT/SEQ
- 2-stage pipeline (input register → ALU core → output register)
- Verilator simulation: PASS (8 test cases)

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 5.0ns (200MHz) |
| Timing | met (positive slack) |
| Area | ~1600 µm² |
| Total Power | 0.663mW |
| GDS | 750KB |

---

## Phase 4: PicoRV32 RISC-V Core
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- PicoRV32: 오픈소스 RISC-V RV32IMC CPU (YosysHQ, MIT license)
- 3049 lines RTL

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 10.0ns (100MHz) |
| Slack | +4.750ns |
| Area | 102,600 µm² (49% util) |
| Endpoints | 3,274 |
| Total Power | 16.0mW |
| GDS | 12MB |

### Key Observations
- 실제 RISC-V CPU의 full RTL-to-GDS 달성
- timing met with significant positive slack (+4.75ns)
- Power: Sequential 47%, Clock 43%, Combinational 10%
- clock power가 높은 이유: 3274개 FF에 clock tree 분배

---

## Phase 5: SoC + SRAM (OpenRAM)
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- PicoRV32 (RV32I, barrel shifter) + sky130_sram_1rw1r_64x256_8 (2KB)
- 간단한 address decoder + GPIO peripheral
- SRAM macro: ORFS pre-built sky130ram 사용

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 20.0ns (50MHz) |
| Slack | +7.022ns |
| Area | 544,466 µm² (33% util) |
| Endpoints | 3,257 |
| Total Power | 18.2mW |
| - Macro (SRAM) | 9.16mW (50.4%) |
| - Clock | 4.21mW (23.2%) |
| - Sequential | 3.41mW (18.7%) |
| GDS | 32MB |
| Antenna violations | 5 net, 8 pin |

### Key Observations
- SRAM macro가 전체 power의 50% 차지
- macro placement 자동화 성공 (halo/channel 설정)
- 32MB GDS — SRAM cell 데이터가 대부분
