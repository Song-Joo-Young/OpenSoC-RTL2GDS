# Project Evaluation (2026-04-14)

> 이 문서는 독립적인 Claude 인스턴스가 프로젝트 전체를 평가한 결과입니다.
> 다른 Claude가 작업할 때 이 평가를 참고하여 우선순위와 개선점을 반영해 주세요.

---

## 1. 프로젝트 개요

두 개의 연관 프로젝트가 동시에 진행 중:

| 프로젝트 | 위치 | 목적 |
|----------|------|------|
| **OpenSoC-RTL2GDS** | `/home/jysong/PROJECT/` | 오픈소스 RTL-to-GDS 플로우 (SKY130/GF180) |
| **sram-lib-gen** | `/home/jysong/PROJECT/sram-lib-gen/` | VeeR EL2용 OpenRAM SRAM 라이브러리 생성 파이프라인 (FreePDK45) |

두 프로젝트는 **SRAM 매크로 통합**이라는 공통 목표를 공유하지만, 현재 독립적으로 진행되고 있음.

---

## 2. 진행 상황 요약

### OpenSoC-RTL2GDS (Phase 0~5 전부 Complete)

| Phase | Design | PDK | Area | Timing | GDS |
|-------|--------|-----|------|--------|-----|
| 1 | GCD (264셀) | sky130hd | 3,872 um2 | WNS -0.50ns (violation) | 904KB |
| 2 | Counter 8-bit | sky130hd / gf180mcu | 865 / 4,795 um2 | met / met | 342KB / DEF |
| 3 | ALU 8-bit pipelined | sky130hd | ~1,600 um2 | met | 750KB |
| 4 | PicoRV32 (RV32IMC) | sky130hd | 102,600 um2 | +4.75ns slack | 12MB |
| 5 | PicoRV32 + SRAM 2KB | sky130hd | 544,466 um2 | +7.02ns slack | 32MB |

### sram-lib-gen (Phase 1~4 Complete, Phase 5 대기)

| Phase | 내용 | 상태 |
|-------|------|------|
| 1 | 파이프라인 재사용성 리팩토링 | Complete |
| 2 | OpenRAM v1.2.49 설치 + 검증 | Complete |
| 3 | Priority 4개 SRAM 생성 + .lib/.db 변환 (24/24 성공) | Complete |
| 4 | 65개 래퍼 생성 + DC 합성 통합 테스트 (에러 없음) | Complete |
| 5 | 전체 65개 매크로 생성 + 메모리 활성화 면적 비교 | **대기** |

Priority SRAM 생성 결과:

| 매크로 | bits | 생성 시간 | area (um2) | .db 변환 |
|--------|------|----------|------------|----------|
| sram_128x25 | 3,200 | 9.4분 | 8,752 | OK |
| sram_512x71 | 36,352 | 5.6시간 | 55,234 | OK |
| sram_1024x39 | 39,936 | 1.3시간 | 61,854 | OK |
| sram_4096x39 | 159,744 | 6.0시간 | 221,572 | OK |

---

## 3. 잘 된 부분

### OpenSoC-RTL2GDS
1. **점진적 복잡도 증가**: GCD(264셀) -> Counter -> ALU -> PicoRV32(수천셀) -> SoC+SRAM 순서가 합리적
2. **환경 재현성**: 도구 버전 핀닝(ORFS b811251d2, Yosys 0.63, OpenROAD v2.0-16595)이 잘 되어 있음
3. **듀얼 PDK 비교**: Phase 2에서 SKY130 vs GF180 비교까지 완료
4. **Phase 2~5 모두 timing met**: Phase 1 이후 클럭을 적절히 조정하여 violation-free 달성
5. **SRAM 매크로 통합**: Phase 5에서 ORFS pre-built sky130ram으로 SoC+SRAM GDS 성공

### sram-lib-gen
1. **재사용 가능한 파이프라인**: `--design` 인자로 다중 디자인 지원, design_config.json 중앙 설정
2. **포트 매핑 정확성**: WE/ME 극성 반전(active-high -> active-low)이 65개 래퍼 전부에서 검증됨
3. **PVT 코너 커버리지**: 매크로당 6개 PVT 코너(FF/SS/TT, 1.0V/1.1V, 0C/25C/100C) 생성
4. **DC 합성까지 end-to-end 검증**: .lib -> .db -> 래퍼 -> DC 합성 에러 없이 통과
5. **상세한 문서화**: execution_plan, execution_report, getting_started, reusability_guide 등

---

## 4. 개선점 및 우려사항

### [HIGH] DRC/LVS 검증 누락

**현상**: 5개 Phase 모두 GDS를 생성했지만, Magic DRC나 Netgen LVS를 실행한 기록이 없음.
Phase 5에서 antenna violation 5건이 보고되었으나 해결 여부 불명.

**영향**: "GDS를 만들었다"와 "제조 가능한 GDS를 만들었다"는 완전히 다름. RTL-to-GDS 플로우의 완결성이 부족.

**권장 조치**:
- 각 Phase의 완료 기준에 **DRC clean + LVS pass**를 필수 조건으로 추가
- 최소한 Phase 4(PicoRV32)와 Phase 5(SoC+SRAM)에 대해 DRC/LVS 실행
- antenna violation 해결 또는 waiver 문서화

### [HIGH] sram-lib-gen 메모리 비활성화 상태

**현상**: VeeR EL2의 DCCM/ICCM/ICache가 전부 ENABLE=0이므로, DC 합성 면적 비교에서 behavioral vs SRAM 차이가 0.

**영향**: sram-lib-gen Phase 4까지의 작업이 "통합 가능함"은 증명했지만 "실제 면적 개선"은 미검증.

**권장 조치**:
- VeeR config 재생성 (DCCM_ENABLE=1, ICCM_ENABLE=1, ICACHE_ENABLE=1)
- 메모리 활성화 상태에서 behavioral vs SRAM 면적/power 비교
- 이것이 sram-lib-gen Phase 5의 핵심 목표

### [HIGH] 두 프로젝트 간 PDK/기술 불일치

**현상**:
- OpenSoC-RTL2GDS: **SKY130** (130nm, 오픈소스 PDK)
- sram-lib-gen: **FreePDK45** (45nm, 상용 도구 DC/HSPICE 사용)

**영향**: 두 프로젝트의 SRAM 결과를 직접 비교하거나 통합할 수 없음. OpenSoC의 Phase 5는 ORFS pre-built sky130ram을 사용했고, sram-lib-gen의 OpenRAM 결과물은 FreePDK45 기반.

**권장 조치**:
- 두 프로젝트의 관계를 명확히 정의 (독립 연구 vs 통합 목표)
- 만약 통합이 목표라면, sram-lib-gen에서 SKY130 타겟 추가 또는 OpenSoC에서 FreePDK45 플로우 추가
- 아니면 각각의 목적을 문서에 명시 (OpenSoC = 오픈소스 플로우 학습, sram-lib-gen = 상용 플로우 SRAM 최적화)

### [MEDIUM] Phase 1 GCD 타이밍 위반 미해결

**현상**: Phase 1 GCD에서 WNS=-0.50ns, setup violation 40개가 존재.

**영향**: Phase 2부터는 클럭을 완화하여 해결했으므로 실질적 문제는 아니지만, 기록상 Phase 1이 "violation 있는 상태로 Complete"로 남아 있음.

**권장 조치**:
- progress.md에 Phase 1의 타이밍 상태를 명시 (의도적으로 aggressive한 타겟이었음을 기록)
- 또는 클럭 5~10ns로 재실행하여 clean 결과 확보 (선택)

### [MEDIUM] sram-lib-gen 대형 매크로 리스크

**현상**: 65개 매크로 중 sram_32768x39(1.28Mbit), sram_16384x39(640Kbit) 등 대형 매크로가 OpenRAM 한계를 초과할 가능성.

**영향**: Phase 5 전체 배치 생성 시 일부 실패 예상. 현재 리스크 레지스터에 기록되어 있음.

**권장 조치**:
- 실패 시 behavioral fallback 또는 뱅크 분할 전략을 코드로 미리 준비
- 대형 매크로부터 먼저 테스트하여 실패를 조기 발견

### [MEDIUM] sram-lib-gen EL2_RAM_BE (byte-enable) 미해결

**현상**: 65개 EL2_RAM 외에 64개 EL2_RAM_BE(byte-enable) 변형이 있으나, OpenRAM이 byte-enable을 네이티브 지원하지 않음. 일부는 width가 142, 284-bit으로 매우 넓음.

**영향**: VeeR EL2 전체 메모리 서브시스템 대체가 불완전.

**권장 조치**:
- read-modify-write 래퍼 로직 구현 또는
- byte-enable SRAM을 word-enable SRAM + 외부 마스킹 로직으로 분해
- 처리 방안을 Phase 5 전에 결정

### [LOW] 헤드리스 환경 자동화 미흡

**현상**: ORFS의 GUI 리포트 단계에서 Qt crash가 발생하여 GDS를 KLayout으로 수동 생성.

**권장 조치**: `env.sh`에 `export QT_QPA_PLATFORM=offscreen` 추가 또는 ORFS Makefile에서 report 스킵

### [LOW] OpenSoC GF180 GDS 미완성

**현상**: Phase 2에서 GF180 비교를 했지만 DEF만 생성되고 GDS는 미생성.

**권장 조치**: 중요도가 낮으면 현재 상태로 두되, progress.md에 "DEF only" 상태를 명시

---

## 5. 권장 우선순위 (다음 작업)

| 순위 | 프로젝트 | 작업 | 이유 |
|------|----------|------|------|
| 1 | sram-lib-gen | Phase 5: 전체 65개 매크로 생성 + 메모리 활성화 면적 비교 | 핵심 미완료 작업. behavioral vs SRAM 면적 차이를 수치로 보여줘야 프로젝트 가치 입증 |
| 2 | OpenSoC | Phase 4~5 DRC/LVS 실행 | RTL-to-GDS 플로우 완결성 확보 |
| 3 | sram-lib-gen | EL2_RAM_BE 처리 방안 결정 | 64개 byte-enable 매크로 전략 필요 |
| 4 | 공통 | 두 프로젝트 관계 명확화 (PDK 불일치 해소 또는 독립 목적 문서화) | 향후 혼동 방지 |
| 5 | OpenSoC | 헤드리스 환경 자동화 | 반복 실행 효율성 |

---

## 6. 아키텍처 관점 총평

**OpenSoC-RTL2GDS**는 교육/데모 목적의 오픈소스 RTL-to-GDS 플로우로서 **Phase 5까지 완주한 것은 상당한 성과**. GCD부터 SoC+SRAM까지 점진적 확장이 잘 구성되어 있고, 환경 재현성도 우수. 다만 DRC/LVS sign-off 없이 GDS 생성에서 멈춘 것이 플로우 완결성의 빈틈.

**sram-lib-gen**은 상용 ASIC 설계 플로우에 실질적으로 필요한 SRAM 라이브러리 자동화를 잘 구축. 파이프라인 재사용성, 포트 매핑 자동화, PVT 커버리지가 특히 잘 되어 있음. **Phase 5(전체 매크로 + 메모리 활성화 비교)를 완료하면 프로젝트의 핵심 가치(면적 절감 수치)가 증명됨.**

두 프로젝트를 잇는 핵심 질문: **최종 목표가 SKY130 오픈소스 플로우에서의 SRAM 통합인지, FreePDK45 상용 플로우에서의 VeeR 최적화인지**를 명확히 해야 향후 작업 방향이 정해짐.
