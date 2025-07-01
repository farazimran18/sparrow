#!/bin/zsh

# This script can be run from any location. It determines its own
# location to correctly find the rtl and tb directories.

# Get the directory where the script itself is located.
SCRIPT_DIR=${0:h}

# Define the project root, which is one level above the 'meta' directory.
PROJECT_ROOT="$SCRIPT_DIR/.."

# --- Main Logic ---

echo "Linting Verilog files in ./rtl and ./tb..."
echo "=========================================="

# 1. Run the syntax checker on all files
echo "\nRunning Syntax Check (verible-verilog-syntax)..."
find "$PROJECT_ROOT/rtl" "$PROJECT_ROOT/tb" -name "*.v" -o -name "*.sv" | xargs verible-verilog-syntax

# 2. Run the linter on all files
echo "\nRunning Linter (verible-verilog-lint)..."
find "$PROJECT_ROOT/rtl" "$PROJECT_ROOT/tb" -name "*.v" -o -name "*.sv" | xargs verible-verilog-lint

echo "\n=========================================="
echo "Linting process complete."
