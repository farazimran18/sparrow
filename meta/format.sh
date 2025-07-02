#!/bin/zsh

SCRIPT_DIR=${0:h}
PROJECT_ROOT="$SCRIPT_DIR/.."

find "$PROJECT_ROOT/rtl" "$PROJECT_ROOT/tb" -name "*.v" -o -name "*.sv" | xargs verible-verilog-format --flagfile "$SCRIPT_DIR/.verible-verilog-format" --inplace
