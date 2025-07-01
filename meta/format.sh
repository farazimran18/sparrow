#!/bin/zsh

# This script can be run from any location. It determines its own
# location to correctly find the rtl, tb, and config files.

# --- Script Configuration ---
# Get the directory where the script itself is located.
SCRIPT_DIR=${0:h}

# Define the project root, which is one level above the 'meta' directory.
PROJECT_ROOT="$SCRIPT_DIR/.."

# --- Main Logic ---
echo "Finding and formatting Verilog files..."

find "$PROJECT_ROOT/rtl" "$PROJECT_ROOT/tb" -name "*.v" -o -name "*.sv" | xargs verible-verilog-format --flagfile "$SCRIPT_DIR/.verible-verilog-format" --inplace

echo "Formatting complete."
