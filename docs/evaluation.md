# Project Evaluation (2026-04-14, Rev.2)

> 독립적인 Claude 인스턴스가 프로젝트 전체를 평가한 결과입니다.
> 다른 Claude가 작업할 때 이 문서를 참고하여 현재 상태, 품질, 개선점을 파악해 주세요.
>
> **Rev.2 변경사항**: OpenSoC Phase 0~5 전부 Complete 반영, 문서 4종 추가 반영,
> sram-lib-gen output 실물 확인, RTL/테스트벤치 코드 품질 평가 추가.

---

## 1. 프로젝트 구조

```
PROJECT/
├── designs/                  # 5개 Phase RTL 디자인 (전부 Complete)
│   ├── 01_gcd/               GCD (ORFS 내장 예제 사용)
│   ├── 02_counter/           8-bit parameterized up/down counter + Verilator TB
│   ├── 03_alu/               8-bit pipelined ALU (10 ops) + Verilator TB
│   ├── 04_picorv32/          PicoRV32 (YosysHQ, RV32I)
│   └── 05_soc/               PicoRV32 + sky130_sram_1rw1r_64x256_8 (2KB)
├── docs/                     # 문서 5종
│   ├── progress.md           Phase별 결과 수치/명령어 기록
│   ├── getting_started.md    환경 구축 ~ 첫 GDS 가이드
│   ├── training_guide.md     12-Part step-by-step 실습 튜토리얼
│   ├── tool_analysis.md      OpenROAD/ORFS/OpenRAM 내부 구조 분석
│   └── evaluation.md         이 파일 (독립 평가)
├── sram-lib-gen/             # VeeR EL2용 OpenRAM SRAM 라이브러리 파이프라인
│   ├── configs/              veer_el2 설계 설정 + FreePDK45 tech params
│   ├── openram/              OpenRAM v1.2.49 + 65개 config
│   ├── output/freepdk45/     4개 SRAM 출력 (lib/db/lef/gds/spice/verilog) + 65개 래퍼
│   ├── integration/          DC 합성 통합 TCL
│   ├── scripts/              자동화 스크립트 (gen, lib2db, wrapper, pipeline)
│   └── docs/                 실행 계획/리포트/가이드 6종
├── tools/                    ORFS, OpenRAM, Magic, Netgen, open_pdks
├── pdk/                      sky130A (빌드 완료)
├── scripts/                  setup_tools.sh, setup_pdk.sh
├── env.sh                    환경 변수 설정
└── README.md                 프로젝트 개요 + Quick Start + 도구/참조 목록
```

---

## 2. OpenSoC-RTL2GDS 평가

### 2-1. Phase별 결과 요약

| Phase | Design | Cells | PDK | Area | Power | Timing | GDS |
|-------|--------|-------|-----|------|-------|--------|-----|
| 1 | GCD | 264 | sky130hd | 3,872 um2 | 2.64mW | **WNS -0.50ns** | 904KB |
| 2 | Counter 8-bit | ~30 | sky130hd | 865 um2 | 0.27mW | met (+2.09ns) | 342KB |
| 2 | Counter 8-bit | ~30 | gf180 | 4,795 um2 | 5.86mW | met (+6.10ns) | DEF only |
| 3 | ALU 8-bit | ~100 | sky130hd | ~1,600 um2 | 0.66mW | met | 750KB |
| 4 | PicoRV32 | ~3000 | sky130hd | 102,600 um2 | 16.0mW | met (+4.75ns) | 12MB |
| 5 | SoC+SRAM | ~3000+macro | sky130hd | 544,466 um2 | 18.2mW | met (+7.02ns) | 32MB |

### 2-2. 잘 된 부분

**A. 점진적 복잡도 증가가 완벽히 실행됨**
- GCD(264셀) -> Counter(~30셀) -> ALU(~100셀) -> PicoRV32(~3000셀) -> SoC+SRAM
- Phase 1의 aggressive clock(2.5ns) 실험 후, Phase 2부터 적절한 clock(5~20ns)으로 조정
- Phase 2~5 전부 timing met with positive slack

**B. RTL 코드 품질이 좋음**
- `counter.v`: parameterized WIDTH, up/down/load/enable, zero/max_val 플래그 — 교육 목적에 적합한 기능 범위
- `alu.v`: 2-stage pipeline, 10개 연산, carry/zero 플래그 — pipeline 개념 학습에 적합
- `picosoc_mini.v`: 깔끔한 address decode, 32->64비트 SRAM 매핑, GPIO peripheral — SoC 설계의 핵심 요소를 최소한으로 보여줌

**C. 테스트벤치가 실용적**
- Verilator C++ TB로 counter 6개 테스트(count up/down, load, zero/max flag, enable hold)
- ALU TB 8개 테스트(ADD/SUB/AND/OR/XOR/NOT + zero flag + carry overflow)
- 둘 다 PASS 확인됨 (progress.md에 기록)

**D. 듀얼 PDK 비교 완료 (Phase 2)**
- SKY130(130nm) vs GF180(180nm): area 5.5x, power 22x 차이를 수치로 보여줌
- 동일 디자인으로 공정 노드 비교라는 교육적 가치 높음

**E. SoC+SRAM 매크로 통합 성공 (Phase 5)**
- ORFS pre-built sky130_sram_1rw1r_64x256_8 매크로 사용
- macro placement halo/channel 설정, ADDITIONAL_LEFS/LIBS/GDS 연동
- SRAM이 전체 power의 50.4% 차지 — 실제 SoC에서의 메모리 비중을 보여줌

**F. 문서가 매우 충실**
- `training_guide.md`: 12-Part, RTL 개념부터 DRC/LVS까지 step-by-step. SDC 해설, 자주 하는 실수 테이블 포함
- `getting_started.md`: 빈 서버에서 첫 GDS까지. ORFS 버전 핀닝, troubleshooting 5개 포함
- `tool_analysis.md`: OpenROAD 20+ 모듈 구조, ORFS Makefile target 분석, OpenRAM 내부 구조, 3개 도구 통합 다이어그램
- `README.md`: Progress table, Quick Start, 도구 버전 핀닝, ORFS vs OpenLane 비교, SoC framework 참조, Known Issues

**G. 프로젝트 관리 우수**
- Git 히스토리가 Phase별로 깔끔 (10 commits, 의미 있는 메시지)
- `.gitignore`가 적절 (build/, tools/, pdk/, results/ 제외)
- env.sh에 QT_QPA_PLATFORM=offscreen 등 workaround 포함

### 2-3. 개선점

#### [HIGH] DRC/LVS 미실행

**현상**: 5개 Phase 전부 GDS 생성까지만 완료. Magic DRC, Netgen LVS 실행 기록 없음.
Phase 5에서 antenna violation 5 net / 8 pin 보고되었으나 해결 미확인.
training_guide.md Part 11에 DRC/LVS 명령어가 문서화되어 있지만, 실제 실행은 안 함.

**영향**: RTL-to-GDS 플로우의 **마지막 10%가 빠져 있음**. sign-off 없이는 "GDS 생성"이지 "tapeout-ready"가 아님.

**권장**:
- 최소 Phase 4(PicoRV32), Phase 5(SoC+SRAM)에 대해 DRC/LVS 실행
- README Known Issues에 "DRC/LVS 추후 자동화 예정"이라고 기록되어 있으나, 수동이라도 한 번은 돌려야 플로우 완결성 확보
- training_guide.md Part 11의 명령어를 직접 실행하여 결과를 progress.md에 추가

#### [MEDIUM] Phase 1 GCD 타이밍 위반 방치

**현상**: WNS=-0.50ns, 40개 setup violation. README에 "의도적으로 aggressive clock 실험"이라고 기록.

**평가**: 교육 목적으로는 오히려 좋음 (타이밍 위반이 뭔지 보여줌). 하지만 **violation-free 버전도 같이 보여주면 비교 학습 가치**가 있음.

**권장**: (낮은 우선순위) clock 5~10ns로 재실행한 clean 결과를 progress.md에 병기

#### [MEDIUM] GF180 GDS 미완성

**현상**: Phase 2 GF180은 DEF까지만 생성. GDS merge 미완.

**권장**: GF180 GDS까지 완료하거나, progress.md에 "DEF only" 상태를 명확히 기록 (현재 기록됨)

#### [LOW] Phase 4~5 Verilator 시뮬레이션 없음

**현상**: Phase 2~3은 자체 RTL + Verilator TB가 있지만, Phase 4(PicoRV32)와 Phase 5(SoC)는 기능 검증 기록 없음.

**평가**: PicoRV32는 이미 검증된 IP이므로 합리적 판단. 하지만 picosoc_mini.v의 address decode/SRAM 매핑 로직은 자체 작성이므로 시뮬레이션이 있으면 더 좋음.

#### [LOW] designs/ 내 build artifacts 커밋 가능성

**현상**: `designs/02_uart_tx/build/`, `designs/03_alu/build/` 디렉토리에 Verilator 빌드 출력물(`.o`, `.a`, 바이너리)이 존재.
`.gitignore`에 `**/build/` 패턴이 있는지 확인 필요.

---

## 3. sram-lib-gen 평가

### 3-1. 진행 상태

| Phase | 내용 | 상태 |
|-------|------|------|
| 1 | 파이프라인 재사용성 리팩토링 (design_config.json, --design 인자) | Complete |
| 2 | OpenRAM v1.2.49 설치 + sram_128x25 smoke test | Complete |
| 3 | Priority 4개 SRAM 생성 + 24개 .lib -> 24개 .db 변환 (100%) | Complete |
| 4 | 65개 래퍼 .sv 생성 + DC 합성 통합 (에러 없이 성공) | Complete |
| 5 | 전체 65개 매크로 생성 + 메모리 활성화 면적 비교 | **대기** |

### 3-2. Priority SRAM 결과 (실물 확인됨)

| 매크로 | bits | 생성 시간 | area (um2) | bit density | PVT corners |
|--------|------|----------|------------|-------------|-------------|
| sram_128x25 | 3,200 | 9.4분 | 8,752 | 2.73 um2/bit | 6/6 .db OK |
| sram_512x71 | 36,352 | 5.6시간 | 55,234 | 1.52 um2/bit | 6/6 .db OK |
| sram_1024x39 | 39,936 | 1.3시간 | 61,854 | 1.55 um2/bit | 6/6 .db OK |
| sram_4096x39 | 159,744 | 6.0시간 | 221,572 | 1.39 um2/bit | 6/6 .db OK |

**참고**: bit density가 클수록 비효율. 소형 SRAM(128x25)은 제어 로직 오버헤드로 2.73um2/bit,
대형(4096x39)은 bitcell array 비중이 커서 1.39um2/bit으로 효율적. 이는 예상대로.

### 3-3. 실물 output 구조 확인

```
output/freepdk45/
├── lib/      24개 .lib (4 매크로 x 6 PVT: FF/SS/TT x 1.0V/1.1V x 0C/25C/100C)
├── db/       24개 .db (lc_shell 변환 완료)
├── lef/      4개 .lef (매크로 추상화)
├── gds/      4개 .gds (물리 레이아웃)
├── spice/    4개 .sp + 4개 .lvs.sp + stimuli
├── verilog/  65개 개별 래퍼 .sv + 1개 통합 mem_lib_sram.sv
└── *.v       4개 behavioral verilog + *.log + *.html (datasheet)
```

### 3-4. 잘 된 부분

**A. 래퍼 코드가 정확함**
- `ram_4096x39.sv` 확인: VeeR 포트(ADR/D/Q/WE/ME/CLK) -> OpenRAM 포트(addr0/din0/dout0/web0/csb0/clk0)
- `~WE` -> `web0`, `~ME` -> `csb0` 극성 반전 정확
- 테스트 핀(TEST1, RME, RM, LS, DS, SD, TEST_RNM, BC1, BC2) 무시, `ROP = ME` 할당
- 65개 래퍼 전부 동일 패턴으로 일관성 유지

**B. 파이프라인 재사용성 우수**
- `--design` 인자로 다중 디자인 지원
- `design_config.json`에 포트 매핑, 도구 경로, 기술 파라미터 중앙화
- `config_helper.py`로 shell script에서 JSON 읽기 가능
- 새 디자인 추가 시 config 3개 파일만 작성하면 됨

**C. DC 합성 end-to-end 검증 완료**
- .db 로딩, mem_lib_sram.sv 분석, elaborate, compile_ultra 전부 에러 없이 통과
- 18분 합성 소요 (VeeR EL2 전체)

**D. 문서화 수준 높음**
- execution_plan.md: 체크리스트 + 리스크 레지스터 + 타임라인
- execution_report.md: Phase별 실행 결과 + 해결한 이슈 상세
- CLAUDE.md: 파이프라인 명령어, 서버 환경, 포트 매핑 테이블, 아키텍처 설명

### 3-5. 개선점

#### [HIGH] Phase 5 미완료 — 핵심 가치 미증명

**현상**: 65개 매크로 중 4개만 생성. VeeR의 DCCM/ICCM/ICache가 전부 ENABLE=0이므로 behavioral vs SRAM 면적 차이가 **0 um2**.

**영향**: 프로젝트의 존재 이유("behavioral RAM을 실제 SRAM으로 교체하여 현실적 면적/전력 확보")가 아직 수치로 입증되지 않음.

**권장**:
1. VeeR config 재생성 (DCCM_ENABLE=1, ICCM_ENABLE=1, ICACHE_ENABLE=1)
2. 메모리 활성화 상태에서 behavioral vs SRAM 면적/power 비교
3. 최소한 priority 4개 매크로만으로도 비교 가능 (전체 65개 대기 불필요)

#### [HIGH] 대형 매크로 리스크

**현상**: sram_32768x39(1.28Mbit), sram_16384x39(640Kbit) 등이 OpenRAM 한계 초과 가능.
sram_4096x39 생성에 이미 6시간 소요.

**예상**: 32768x39는 수십 시간 ~ 실패 가능. sram_8192x71(582Kbit), sram_8192x68(557Kbit)도 리스크.

**권장**:
- 대형 매크로(depth >= 8192)부터 먼저 테스트하여 실패를 조기 발견
- 실패 시 뱅크 분할 전략(2x sram_16384x39 -> sram_32768x39) 준비
- behavioral fallback도 옵션으로 유지

#### [MEDIUM] EL2_RAM_BE (byte-enable) 64개 미처리

**현상**: 65개 EL2_RAM은 래퍼 완료. 64개 EL2_RAM_BE(byte-enable)는 OpenRAM이 네이티브 미지원.
일부 width가 142, 284-bit으로 매우 넓어 OpenRAM 한계 초과 가능.

**권장**: 
- read-modify-write 래퍼 또는 word-enable + 외부 마스킹 로직으로 분해
- Phase 5 전에 방안 결정 필요

#### [MEDIUM] 100C 코너 음수 delay

**현상**: OpenRAM analytical model에서 100C PVT 코너에 음수 delay 생성.
execution_report에 "합성에 영향 없음"으로 기록.

**평가**: TT_1p1V_25C가 합성 대상이므로 당장 문제 없음. 하지만 multi-corner STA를 하게 되면 이슈 발생 가능.

---

## 4. 두 프로젝트 간 관계 평가

### PDK / 기술 노드 불일치

| | OpenSoC-RTL2GDS | sram-lib-gen |
|--|---|---|
| **PDK** | SKY130 (130nm, 오픈소스) | FreePDK45 (45nm, academic) |
| **합성 도구** | Yosys + OpenROAD (오픈소스) | Synopsys DC (상용) |
| **SRAM 소스** | ORFS pre-built sky130ram | OpenRAM 직접 생성 |
| **타겟 디자인** | GCD -> Counter -> ALU -> PicoRV32 -> SoC | VeeR EL2 RISC-V |
| **목적** | 오픈소스 플로우 학습/교육 | 상용 ASIC 설계에서 SRAM 최적화 |

**평가**: 두 프로젝트는 **목적이 다르며, 이것은 문제가 아님**.
- OpenSoC: "오픈소스 도구로 RTL-to-GDS 전체 플로우를 구축할 수 있음"을 보여주는 교육 프로젝트
- sram-lib-gen: "상용 DC 합성에서 behavioral RAM을 OpenRAM SRAM으로 교체하면 면적이 얼마나 바뀌는지"를 보여주는 실용 프로젝트

**README에서 이 관계가 잘 정리되어 있음**: "sram-lib-gen/: OpenRAM 기반 SRAM 라이브러리 생성 파이프라인 (FreePDK45). VeeR EL2용 SRAM 매크로 자동 생성 및 DC 합성 통합 예제."

**잠재적 통합점**: OpenSoC Phase 5에서 ORFS pre-built sky130ram 대신 OpenRAM으로 직접 생성한 sky130 SRAM을 사용하면 두 프로젝트가 연결됨. 하지만 이것은 선택적 확장이지 필수는 아님.

---

## 5. 코드 품질 세부 평가

### RTL 코드 (designs/)

| 파일 | 라인 | 평가 |
|------|------|------|
| `counter.v` | 32 | 깔끔. parameterized, 비동기 리셋, 모든 기능이 minimal하게 구현됨 |
| `alu.v` | 64 | 좋음. 2-stage pipeline이 명확. carry bit를 위한 extra-width alu_out 처리가 올바름 |
| `picosoc_mini.v` | 111 | 좋음. address decode 간결, 32->64 SRAM 매핑이 올바름. sram_ready_r 핸드셰이크 정확 |
| `picorv32.v` | 3049 | 외부 IP (YosysHQ). MIT 라이선스. 검증된 코드 |

**개선 가능 사항** (minor):
- `alu.v:45-46`: SLT/SEQ의 `{{WIDTH{1'b0}}, 1'b1}`에서 중괄호 중첩이 읽기 어려울 수 있음. 교육 코드이므로 가독성을 위해 `{(WIDTH+1){1'b0}} | 1` 같은 표현도 고려
- `picosoc_mini.v`: mem_wstrb가 0일 때 read로 간주하는 PicoRV32 convention에 의존. 주석이 있으면 좋음

### 테스트벤치 (tb/)

| 파일 | 테스트 수 | 커버리지 |
|------|----------|----------|
| `tb_counter.cpp` | 6 | count up, count down, load, zero flag, max_val flag, enable hold |
| `tb_alu.cpp` | 8 | ADD, SUB, AND, OR, XOR, NOT, zero flag, carry overflow |

**평가**: 교육 목적으로 충분. 실무에서는 boundary value, pipeline flush, reset timing 등 추가 필요하나 이 프로젝트 범위에서는 적절.

### 래퍼 코드 (sram-lib-gen/output/)

- 65개 래퍼 전부 동일 패턴, 자동 생성(`generate_wrapper_v.py`)
- `~WE` / `~ME` 극성 반전이 65/65 확인됨
- 테스트 핀 미연결은 올바른 판단 (OpenRAM에 해당 핀 없음)

---

## 6. 문서 품질 평가

| 문서 | 대상 독자 | 품질 | 비고 |
|------|----------|------|------|
| `README.md` | 모든 사용자 | **A** | Progress table, Quick Start, 도구 비교, Known Issues, 참조 링크 완비 |
| `training_guide.md` | 초보자 | **A** | RTL 개념 → DRC/LVS까지 12 Part. 코드 해설, FAQ, 체크리스트 포함 |
| `getting_started.md` | 설치자 | **A-** | ORFS 버전 핀닝 설명이 특히 유용. Troubleshooting 섹션 실용적 |
| `tool_analysis.md` | 중급 이상 | **A** | OpenROAD 모듈별 설명, ORFS Makefile 구조, OpenRAM 내부 아키텍처, 3개 도구 통합 다이어그램 |
| `progress.md` | 프로젝트 멤버 | **B+** | 수치 기록 좋음. Phase 2~5 간 기록 양에 차이가 있음 (Phase 1이 가장 상세) |
| sram-lib-gen `execution_report.md` | 프로젝트 멤버 | **A-** | Phase별 결과, 해결한 이슈, PVT 결과 테이블이 상세 |
| sram-lib-gen `CLAUDE.md` | Claude 인스턴스 | **A** | 파이프라인 명령어, 포트 매핑, 서버 환경, 아키텍처가 잘 정리됨 |

**특기사항**: README의 ORFS vs OpenLane vs OpenLane2 비교, SoC framework 참조(Chipyard, PULP, LiteX) 섹션은 교육 프로젝트로서의 가치를 높임. "이 프로젝트 이후 어디로 가야 하는지"를 알려줌.

---

## 7. 종합 점수

| 영역 | 점수 | 코멘트 |
|------|------|--------|
| **플로우 완결성** | 8/10 | Phase 0~5 전부 GDS 완료. DRC/LVS만 빠짐 |
| **코드 품질** | 9/10 | RTL 깔끔, TB 실용적, 래퍼 정확 |
| **문서화** | 9.5/10 | README, Training Guide, Tool Analysis 모두 수준 높음 |
| **재현성** | 9/10 | env.sh, setup scripts, 버전 핀닝, troubleshooting |
| **교육적 가치** | 9.5/10 | 점진적 복잡도, 듀얼 PDK 비교, SoC+SRAM까지 도달 |
| **SRAM 파이프라인** | 7/10 | Phase 4까지 우수. Phase 5(핵심 가치 증명) 미완 |

---

## 8. 권장 다음 작업 (우선순위)

| 순위 | 프로젝트 | 작업 | 예상 소요 | 이유 |
|------|----------|------|----------|------|
| 1 | sram-lib-gen | **Phase 5 실행**: VeeR config 재생성(ENABLE=1) + priority 4개로 면적 비교 | 2~3시간 | 프로젝트 핵심 가치 증명. 전체 65개 없이도 priority 4개만으로 비교 가능 |
| 2 | OpenSoC | **DRC/LVS 실행**: Phase 5(SoC+SRAM)에 Magic DRC + Netgen LVS | 1시간 | training_guide Part 11에 명령어 이미 문서화. 실행만 하면 됨 |
| 3 | sram-lib-gen | **대형 매크로 테스트**: sram_8192x39 또는 sram_16384x39 1개 시도 | 8~24시간 | 실패 시 뱅크 분할 전략 필요. 조기 발견이 중요 |
| 4 | sram-lib-gen | **EL2_RAM_BE 처리 방안 결정** | 설계 결정 | 64개 byte-enable 매크로의 래퍼 전략 확정 |
| 5 | OpenSoC | **GF180 GDS 완성** (선택) | 30분 | Phase 2의 완결성. 낮은 우선순위 |

---

## 9. 이전 평가(Rev.1) 대비 해소된 항목

| 이전 지적 | 현재 상태 |
|----------|----------|
| "Phase 2 Counter 디렉토리가 비어 있음" | **해소**: counter.v + constraint.sdc + tb_counter.cpp 완성, 빌드/시뮬 완료 |
| "Phase 2~5 미완" | **해소**: 전부 Complete. GDS 생성 확인 |
| "GF180 지원 미검증" | **부분 해소**: Phase 2에서 GF180 DEF 생성 + SKY130 비교 완료. GDS는 미완 |
| "Phase 3->4->5 점프가 급격" | **해소**: 실제로 Phase 4(PicoRV32)를 성공적으로 완료. slack +4.75ns |
| "OpenRAM 통합 계획 부재" | **해소**: Phase 5에서 ORFS sky130ram 매크로 통합 성공. sram-lib-gen도 별도 진행 |
| "헤드리스 환경 workaround가 임시적" | **해소**: env.sh에 QT_QPA_PLATFORM=offscreen 포함, README Known Issues에 기록 |

**남은 항목**: DRC/LVS 미실행, sram-lib-gen Phase 5 미완 (위 섹션 8 참조)
