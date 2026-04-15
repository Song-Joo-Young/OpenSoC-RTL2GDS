#!/bin/bash

verilator --cc --exe --build -Wno-fatal \
  -Mdir build --top-module counter4 \
  src/counter4.v tb/tb_counter4.cpp

./build/Vcounter4
