#!/bin/zsh

echo "\n2. Running Verilator lint..."
verilator --lint-only -Wall -f tb/filelist.f

echo "\n3. Running Verible syntax check..."
cat tb/filelist.f | xargs verible-verilog-syntax

echo "\n4. Running Verible lint..."
cat tb/filelist.f | xargs verible-verilog-lint
