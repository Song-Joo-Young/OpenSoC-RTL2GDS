#!/bin/bash

# RTL 복사
mkdir -p $ORFS/flow/designs/src/counter4
cp src/counter4.v $ORFS/flow/designs/src/counter4/

# Config 생성
mkdir -p $ORFS/flow/designs/sky130hd/counter4
cp constraints/constraint.sdc $ORFS/flow/designs/sky130hd/counter4/

cat > $ORFS/flow/designs/sky130hd/counter4/config.mk << 'EOF'
export DESIGN_NAME = counter4
export PLATFORM    = sky130hd

export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/counter4.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION  = 40
export EQUIVALENCE_CHECK = 0
EOF
