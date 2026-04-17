# Project Evaluation (2026-04-17, Rev.3)

> 현재 워크스페이스 기준으로 문서/디렉토리 정합성을 다시 맞춘 평가 메모입니다.
> 이전 Rev.2의 일부 내용은 당시 별도 작업공간 상태를 반영하고 있어, 현재 저장소 트리와 맞지 않는 항목을 정리했습니다.

---

## 1. 현재 저장소 스냅샷

### 최상위 구조

```
PROJECT/
├── designs/                  # 01_gcd, 02_uart_tx, 03_alu, 04_systolic, 05_picorv32, 06_soc, legacy_counter
├── training/                 # 01_counter4, 02_uart_tx, 03_alu, 04_systolic
├── docs/                     # Markdown 7종 + OpenLane_paper.pdf
├── scripts/                  # setup_tools.sh, setup_pdk.sh
├── sram-lib-gen/             # OpenRAM 기반 SRAM library generation pipeline
├── tools/                    # ORFS, OpenRAM, Magic, Netgen, Tk 등
├── pdk/                      # setup 후 생성되는 PDK 파일
├── results/                  # flow 결과물
├── env.sh
├── README.md
├── AGENTS.md
└── CLAUDE.md
```

### 문서 상태

- `README.md`: 프로젝트 개요, quick start, design matrix, tool summary
- `docs/training_guide.md`: `training/01_counter4`부터 `training/04_systolic`까지 번호별 실습 흐름
- `docs/study_roadmap.md`: 읽기 순서와 학습 경로
- `docs/dual_track_guide.md`: ORFS vs OpenLane 비교 실험
- `docs/progress.md`: Phase 0~6 결과 기록
- `docs/tool_analysis.md`: OpenROAD / ORFS / OpenRAM 구조 설명
- `docs/blog_rtl_to_gds.md`: 블로그형 walkthrough
- `sram-lib-gen/docs/*.md`: 별도 SRAM pipeline 문서 세트

---

## 2. 잘 맞는 점

### A. 학습 경로가 실제 디렉토리와 잘 대응됨

- `training/01_counter4`, `02_uart_tx`, `03_alu`, `04_systolic`가 실제로 존재하고 번호별 스크립트도 정리되어 있다.
- `designs/05_picorv32`, `designs/06_soc`는 training 스크립트 대신 ORFS 디자인 설정으로 직접 재현하는 구조가 일관적이다.

### B. 문서와 결과 로그의 핵심 수치는 서로 대체로 맞는다

- `README.md`의 Progress 표와 `docs/progress.md`의 Phase 요약이 큰 틀에서 일치한다.
- Phase 6 (`04_systolic`)가 `progress.md`에 반영되어 있고, 상위 문서도 해당 단계까지 안내할 수 있는 상태다.

### C. 별도 서브프로젝트 `sram-lib-gen/`도 실제로 존재한다

- 이전 문서에서 "없는 디렉토리"로 오해될 수 있었던 `sram-lib-gen/`은 현재 워크스페이스에 실제 존재한다.
- 해당 경로의 `getting_started.md`, `execution_report.md`, `CLAUDE.md`도 읽을 수 있으며 상위 문서에서 참고 대상으로 연결해도 무리가 없다.

---

## 3. 현재 기준 주요 리스크

### [HIGH] DRC/LVS는 여전히 실행 기록이 약함

- `docs/progress.md`에는 GDS까지의 결과는 잘 정리되어 있지만, Magic DRC / Netgen LVS의 완료 기록은 여전히 약하다.
- `training_guide.md`에는 sign-off 단계가 설명되어 있으므로, 실제 실행 로그와 결과를 `progress.md`에 보강하면 완결성이 올라간다.

### [MEDIUM] 일부 문서는 과거 스냅샷을 섞어 설명한다

- 과거 버전 문서는 `getting_started.md` 같은 현재 루트 `docs/`에 없는 파일을 전제로 쓰여 있었고, phase naming도 예전 구조(`02_counter`, `04_picorv32`)를 섞어 사용했다.
- 이번 Rev.3에서는 현 저장소 기준으로 정리했지만, 앞으로도 문서 수정 시 실제 디렉토리 기준 확인이 필요하다.

### [MEDIUM] 빌드 결과물 디렉토리는 문서상 "tracked source"와 분리해서 봐야 한다

- `tools/`, `pdk/`, `results/` 아래에는 벤더/생성 산출물이 많다.
- 문서에서 이 경로들을 "저장소가 직접 관리하는 소스"처럼 쓰면 혼동이 생긴다.

---

## 4. 문서 품질 평가

| 문서 | 평가 | 메모 |
|------|------|------|
| `README.md` | A | 첫 진입점으로 충분함. 구조/학습경로/도구가 한 번에 보임 |
| `docs/training_guide.md` | A | 실습 문서로 가장 중요함. 실제 스크립트 흐름과 연결성이 좋음 |
| `docs/study_roadmap.md` | A- | 읽는 순서가 명확함. 루트 문서 구조와 계속 맞춰야 함 |
| `docs/dual_track_guide.md` | B+ | 비교 관점은 좋음. OpenLane 환경 전제가 있으므로 실제 실행 전 조건 확인 필요 |
| `docs/progress.md` | B+ | 숫자 기록은 좋음. sign-off 결과 보강 여지 있음 |
| `docs/tool_analysis.md` | A- | 학습용 참고자료로 유용함 |
| `sram-lib-gen/docs/getting_started.md` | A- | 별도 파이프라인 입문 문서로 충분히 상세함 |

---

## 5. 권장 다음 작업

1. `docs/progress.md`에 DRC/LVS 실행 결과를 추가해 Phase 4~6의 sign-off 상태를 명확히 남긴다.
2. 새 문서를 추가할 때는 먼저 실제 경로 존재 여부를 확인하고, `docs/study_roadmap.md`와 `README.md`의 링크 표를 함께 갱신한다.
3. `training/*`와 `designs/*`의 역할 차이를 README에 유지한다.
   `training/`은 guided flow, `designs/`는 소스/Makefile/ORFS 재현 경로.

---

## 6. 이번 Rev.3에서 정리한 사항

- 현재 없는 루트 `docs/getting_started.md` 참조 제거
- `training/04_systolic` 경로 반영
- `training/03_alu`, `training/04_systolic`를 학습 경로에 반영
- `sram-lib-gen/` 존재 여부를 현재 워크스페이스 기준으로 재확인
- 문서 수, 디렉토리 구조, 단계 이름을 현 트리에 맞게 업데이트
