# Repository Guidelines

## Scope and Working Style
This repository is an RTL-to-GDS training workspace built around Verilog, Verilator, and OpenROAD-flow-scripts. `AGENTS.md` is the shared instruction file for both Claude and Codex. Prefer small, verifiable edits. Do not rewrite generated outputs or vendor code unless the task explicitly targets them.

## Project Structure & Module Organization
Main designs live in `designs/`, grouped by phase such as `02_counter`, `03_alu`, `04_picorv32`, and `05_soc`. Each design typically uses `src/` for RTL, `tb/` for C++ Verilator benches, and `constraints/constraint.sdc` for timing constraints. Guided flow examples live in `training/`, especially `training/counter4/`. Setup scripts are in `scripts/`, reference material in `docs/`, and external tools in `tools/`.

## Build, Test, and Development Commands
Initialize the environment before flow work:
```bash
bash scripts/setup_tools.sh
bash scripts/setup_pdk.sh
source env.sh
```
For RTL validation, use per-design simulation targets:
```bash
make -C designs/02_counter sim
make -C designs/03_alu sim
```
For guided runs, use:
```bash
bash training/counter4/01_sim.sh
bash training/counter4/99_fullflow.sh
```
Run the smallest relevant check first, then escalate to a full flow only when RTL, constraints, or ORFS scripts change.

## Coding Style & Naming Conventions
Keep module names, filenames, and top modules aligned, for example `counter.v`, `tb_counter.cpp`, and `counter`. Follow the existing layout instead of introducing new directory patterns. Shell scripts should stay POSIX-friendly `bash`, with lowercase snake_case names. Keep Makefile targets simple and conventional: `sim`, `clean`, and design-specific flow targets.

## Testing Guidelines
Primary verification is Verilator simulation. Testbenches should follow `tb_<design>.cpp`. When changing RTL, run the corresponding `make -C designs/<name> sim` or training simulation script. When changing constraints or ORFS flow scripts, run the affected step script and record whether the change impacts timing, area, or GDS generation.

## Commit & Pull Request Guidelines
Recent commits use short bracketed prefixes such as `[fix]`, `[docs]`, and `[training]`. Keep that format. PRs should state what changed, which commands were run, and whether outputs are functional, documentation-only, or flow-affecting.

## Agent-Specific Instructions
Before editing, read the local `README.md`, relevant `Makefile`, and nearby scripts for the target design. Prefer touching tracked source files under `designs/`, `training/`, `scripts/`, and `docs/`. Do not commit `build/`, `results/`, `pdk/`, `*.gds`, or tool install directories under `tools/`. Use `QT_QPA_PLATFORM=offscreen` only for headless ORFS reporting; do not bake it into normal GUI workflows.
