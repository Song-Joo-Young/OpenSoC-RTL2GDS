# CLAUDE.md

This file provides guidance to Claude Code when working in this repository. It complements `AGENTS.md`; if the two overlap, follow the more repository-specific rule and keep changes minimal.

## Repository Overview

This is an RTL-to-GDS training repository using Verilog RTL, Verilator simulation, and OpenROAD-flow-scripts. Most active work happens in `designs/`, `training/`, `scripts/`, and `docs/`.

## Where to Edit

- Edit tracked source and documentation files only.
- Prefer `designs/<phase>/src/`, `designs/<phase>/tb/`, `designs/<phase>/constraints/`, `training/`, `scripts/`, and `docs/`.
- Avoid changing vendored tool code under `tools/` unless the task explicitly targets tool setup or patching.

## Before Making Changes

Read the local context first:

```bash
sed -n '1,200p' README.md
sed -n '1,200p' designs/02_uart_tx/Makefile
sed -n '1,200p' training/01_counter4/01_sim.sh
```

For any design-specific task, inspect the nearest `Makefile`, RTL file, testbench, and flow script before editing.

## Validation

Use the smallest relevant check first.

```bash
source env.sh
make -C designs/02_uart_tx sim
make -C designs/03_alu sim
bash training/01_counter4/01_sim.sh
```

If RTL, constraints, or ORFS scripts change, run the affected simulation or flow step and report the exact command used.

## Output and Commit Boundaries

Do not commit generated files or local installs:

- `build/`
- `results/`
- `pdk/`
- `*.gds`
- `tools/OpenROAD-flow-scripts/`
- other tool build/install outputs under `tools/`

Keep commits focused. This repository uses short bracketed prefixes such as `[fix]`, `[docs]`, and `[training]`.

## Environment Notes

- Always `source env.sh` before ORFS or OpenRAM-related commands.
- Use `QT_QPA_PLATFORM=offscreen` only for headless ORFS reporting.
- Do not hardcode local machine paths into committed scripts unless the repository already depends on them and the task explicitly requires it.
