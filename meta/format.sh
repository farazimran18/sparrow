#!/bin/zsh

SCRIPT_DIR=${0:h}

bender script flist > filelist.f
cat filelist.f | xargs verible-verilog-format --flagfile "$SCRIPT_DIR/.verible-verilog-format" --inplace

rm filelist.f
rm Bender.lock
