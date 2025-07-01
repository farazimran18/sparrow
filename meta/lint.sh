#!/bin/zsh

bender script flist > filelist.f

echo "\n2. Running Verilator lint..."
verilator --lint-only -Wall -f filelist.f

echo "\n3. Running Verible syntax check..."
cat filelist.f | xargs verible-verilog-syntax

echo "\n4. Running Verible lint..."
cat filelist.f | xargs verible-verilog-lint

rm filelist.f
