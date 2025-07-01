#!/bin/zsh

# This script recursively finds all Verilog and SystemVerilog files
# in the 'rtl' and 'tb' directories and formats them in-place
# using the settings from the .verible-verilog-format file.

echo "🔍 Finding and formatting Verilog files in ./rtl and ./tb..."

find rtl tb -name "*.v" -o -name "*.sv" | xargs verible-verilog-format --flagfile .verible-verilog-format --inplace

echo "✅ Formatting complete."
