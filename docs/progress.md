# Progress Log

## Phase 0: 환경 구축
- **시작일**: 2026-04-14
- **상태**: Complete

### Checklist
- [x] Git 초기화 + remote 연결
- [x] Magic 빌드 (local, `$HOME/local/bin/magic`)
- [x] Netgen 빌드 (local, `$HOME/local/bin/netgen`)
- [x] open_pdks → SKY130 설치 (`$PROJECT_ROOT/pdk/share/pdk/sky130A`)
- [x] OpenROAD-flow-scripts clone (`b811251d2`)
- [x] OpenRAM clone + Python deps 설치
- [x] Yosys 0.63 빌드
- [x] env.sh 검증

### Notes
- 시스템 OpenROAD: `v2.0-16595`
- headless 환경에서는 GUI 리포트 대신 KLayout 수동 merge 경로 사용
- 기본 재현 경로는 SKY130 only

---

## Phase 1: Counter4
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- 4-bit counter training design
- Verilator simulation: PASS

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 10.0ns |
| Timing | met |
| Area | 235 µm² |
| GDS | 114KB |

---

## Phase 2: UART TX + FIFO + ICG
- **시작일**: 2026-04-15
- **상태**: Complete

### Design
- Multi-file UART TX with FIFO, serializer, and integrated clock gate
- Verilator simulation: PASS

### SKY130 결과
| Metric | Value |
|--------|-------|
| Timing | met |
| Area | 2,626 µm² |
| GDS | 791KB |

---

## Phase 3: ALU
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- 8-bit pipelined ALU
- 2-stage pipeline
- Verilator simulation: PASS

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 5.0ns |
| Timing | met |
| Area | ~1,600 µm² |
| Total Power | 0.663mW |
| GDS | 750KB |

---

## Phase 4: 2x2 Systolic Array
- **시작일**: 2026-04-15
- **상태**: Complete

### Design
- 2x2 systolic array for matrix multiplication
- Verilator simulation: PASS

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 10.0ns |
| Slack | +4.024ns |
| Cells | 1,605 |
| Area | 17,224 µm² |
| Total Power | 7.73mW |
| GDS | 2.5MB |

### Key Observations
- Combinational power dominates
- Multiplier logic drives most of the dynamic power

---

## Phase 5: PicoRV32
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- PicoRV32 RISC-V core
- Verilator lint/smoke check: PASS

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 10.0ns |
| Slack | +4.750ns |
| Area | 102,600 µm² |
| Endpoints | 3,274 |
| Total Power | 16.0mW |
| GDS | 12MB |

### Key Observations
- Clock power share is large
- CPU-scale RTL-to-GDS path is reproducible in the current training flow

---

## Phase 6: SoC + SRAM
- **시작일**: 2026-04-14
- **상태**: Complete

### Design
- PicoRV32 + SRAM macro
- ORFS pre-built `sky130ram` integration

### SKY130 결과
| Metric | Value |
|--------|-------|
| Clock period | 20.0ns |
| Slack | +7.022ns |
| Area | 544,466 µm² |
| Total Power | 18.2mW |
| GDS | 32MB |

### Key Observations
- SRAM macro dominates area and power
- This is the first macro-integrated flow in the repository
