# Study Roadmap: 이 프로젝트를 보는 순서

> 이 프로젝트의 문서와 코드를 어떤 순서로 봐야 하는지 안내합니다.

---

## Level 1: 개념 잡기 (1~2시간)

**목표**: RTL-to-GDS가 뭔지, 어떤 도구를 쓰는지 이해

| 순서 | 읽을 것 | 핵심 내용 | 시간 |
|------|---------|----------|------|
| 1 | [blog_rtl_to_gds.md](blog_rtl_to_gds.md) Part 1~2 | 전체 flow 개요, 도구별 역할, 상용 도구 대응표 | 15분 |
| 2 | [OpenLane Paper](OpenLane_paper.pdf) | 실제 tapeout 사례 (striVe SoC), flow 다이어그램 | 30분 |
| 3 | [tool_analysis.md](tool_analysis.md) §1 OpenROAD | OpenROAD 내부 모듈 37개 구조 | 20분 |
| 4 | [evaluation.md](evaluation.md) | 프로젝트 전체 평가, 뭘 잘했고 뭘 놓쳤는지 | 15분 |

**이 단계 후 알게 되는 것:**
- Yosys = 합성, OpenROAD = PnR, Magic = DRC, Netgen = LVS
- OpenLane = 이걸 전부 자동화한 것
- STA가 왜 중요한지, DRC/LVS가 뭔지

---

## Level 2: 직접 따라하기 — 첫 GDS (2~3시간)

**목표**: 환경 설치부터 4-bit counter GDS까지 직접 수행

| 순서 | 할 것 | 핵심 |
|------|------|------|
| 1 | [getting_started.md](getting_started.md) Step 1~4 | 도구 빌드, PDK 설치, env.sh |
| 2 | [training_guide.md](training_guide.md) Part 3~4 | `01_counter4` RTL 작성 + Verilator sim |
| 3 | [training_guide.md](training_guide.md) Part 5~10 | Synthesis → GDS, 단계마다 결과 확인 |
| 4 | [blog_rtl_to_gds.md](blog_rtl_to_gds.md) Step 4 | OpenSTA로 타이밍 리포트 직접 읽기 |

**실습 파일:**
```
training/01_counter4/src/counter4.v      ← RTL (직접 수정해보기)
training/01_counter4/tb/tb_counter4.cpp  ← 테스트벤치
training/01_counter4/constraints/        ← SDC (clock period 바꿔보기)
```

**이 단계 후 할 수 있는 것:**
- 간단한 Verilog → GDS 전 과정
- STA 리포트에서 slack 읽기
- clock period 바꿔서 timing closure 실험

---

## Level 3: 디자인 분석 — 복잡도 비교 (1~2시간)

**목표**: 디자인 크기에 따라 flow 결과가 어떻게 달라지는지 이해

| 순서 | 볼 것 | 비교 포인트 |
|------|------|------------|
| 1 | `training/02_uart_tx/` | UART TX + FIFO + ICG: multi-file RTL, clock-gate 관찰 |
| 2 | `designs/03_alu/` | pipelined ALU: ~100 cells, pipeline 효과 |
| 3 | `designs/04_systolic/` | 2x2 systolic: 1605 cells, 곱셈기 power 지배 |
| 4 | `designs/05_picorv32/` | RISC-V CPU: ~3K cells, clock power 지배 |
| 5 | `designs/06_soc/` | SoC+SRAM: macro integration, SRAM power 50% |
| 6 | [progress.md](progress.md) | 전체 수치 비교 표 |

**이 단계에서 관찰할 것:**
```
                  Cells    Area       Power     특징
counter4:           11      235µm²   78.5µW    가장 간단
uart_tx:           192    2626µm²        -     FIFO + serializer + ICG
ALU:              ~100    1600µm²    0.66mW    pipeline
systolic:        1,605   17224µm²    7.73mW    곱셈기 → comb power 79%
PicoRV32:        ~3000  102600µm²   16.0mW    CPU → clock power 43%
SoC+SRAM:    3000+macro 544466µm²   18.2mW    macro → SRAM power 50%
```

---

## Level 4: Flow 심화 — ORFS vs OpenLane (2~3시간)

**목표**: 두 flow의 차이점을 이해하고, 실제 tapeout 가능한 flow 익히기

| 순서 | 읽을/할 것 | 핵심 |
|------|-----------|------|
| 1 | [dual_track_guide.md](dual_track_guide.md) | ORFS vs OpenLane 비교 표, 같은 디자인 양쪽 실행 |
| 2 | [tool_analysis.md](tool_analysis.md) §2 ORFS | Makefile 구조, 환경변수, 커스텀 디자인 추가법 |
| 3 | [tool_analysis.md](tool_analysis.md) §3 OpenRAM | SRAM compiler 내부, config 작성법 |
| 4 | `sram-lib-gen/docs/getting_started.md` | OpenRAM 실전 사용 예시 (FreePDK45) |

**이 단계 후 할 수 있는 것:**
- ORFS config.mk 직접 작성
- SRAM macro 포함 SoC flow 이해
- OpenLane config.json 작성

---

## Level 5: 확장 실험 (자유)

여기서부터는 관심사에 따라 선택:

### A. 타이밍 최적화
```bash
# counter4의 clock period를 줄여보기
# constraint.sdc: period 10 → 5 → 2 → 1.5
# 어디서 timing violation이 나는지 확인
```

### B. 다른 PDK
```bash
# 같은 디자인을 GF180으로
# config.mk에서 PLATFORM = gf180 으로 변경
# SKY130 vs GF180 area/power 비교
```

### C. OpenRAM SRAM 직접 생성
```bash
# sram-lib-gen/ 참고
# OpenRAM config 작성 → .lib/.lef/.gds 생성
# ORFS에 ADDITIONAL_LEFS/LIBS/GDS로 연결
```

### D. OpenLane으로 DRC/LVS clean GDS
```bash
# Docker or pip으로 OpenLane 2 설치
# config.json 작성
# python3 -m openlane config.json
# DRC/LVS 자동 signoff
```

### E. Synopsys 도구 비교
```bash
# Yosys vs DC: 합성 QoR 비교
# OpenSTA vs PrimeTime: 타이밍 비교
# OpenROAD vs Innovus: PnR 비교
```

---

## 파일 맵 — 무엇이 어디에 있는가

```
docs/
├── study_roadmap.md      ← 지금 보고 있는 이 문서 (학습 순서)
├── blog_rtl_to_gds.md    ← 포스팅용: 전체 flow + 실측 수치 + OpenSTA
├── training_guide.md     ← 실습용: Part 1~12 step-by-step
├── getting_started.md    ← 환경 구축 전용
├── dual_track_guide.md   ← ORFS vs OpenLane 비교
├── tool_analysis.md      ← OpenROAD/ORFS/OpenRAM 내부 구조
├── progress.md           ← Phase 0~6 수치 결과
└── evaluation.md         ← 독립 평가 + 개선 권장사항

designs/                  ← 디자인 소스 (난이도 순)
├── 02_uart_tx/           Level 2
├── 03_alu/               Level 3
├── 04_systolic/          Level 3
├── 05_picorv32/          Level 3
└── 06_soc/               Level 3~4

training/01_counter4/     ← Level 2 실습 전용
```

---

## 추천 일정 (주 단위)

| 주차 | 목표 | Level |
|------|------|-------|
| 1주 | 개념 + 첫 GDS (counter4) | 1~2 |
| 2주 | 디자인 비교 + STA 심화 | 3 |
| 3주 | ORFS 커스터마이징 + OpenLane 시도 | 4 |
| 4주~ | 관심 분야 확장 실험 | 5 |
