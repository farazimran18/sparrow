#!/bin/zsh

SCRIPT_DIR=${0:h}

cat tb/filelist.f | xargs verible-verilog-format --flagfile "$SCRIPT_DIR/.verible-verilog-format" --inplace
