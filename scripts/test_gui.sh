#!/bin/bash
# Quick test script for UART → GUI visualization

cd "$(dirname "$0")/../build" || exit 1

echo "=== FPGA Sequencer GUI Test ==="
echo ""
echo "Running mock UART sender with GUI for 3 seconds."
echo "The GUI will parse UART commands and update the display."
echo "Check the console output to verify parsing."
echo ""

timeout 3 ./tools/mock_uart_sender --demo 2>&1 | timeout 3 ./src/fpga_sequencer_gui 2>&1

echo ""
echo "Test complete! Output above shows UART parsing."
echo ""
echo "To run with actual display (requires X/Wayland):"
echo "  cd build"
echo "  ./tools/mock_uart_sender --demo | ./src/fpga_sequencer_gui"

