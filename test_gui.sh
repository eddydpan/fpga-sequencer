#!/bin/bash
# Quick test script for UART → GUI visualization

cd "$(dirname "$0")/build" || exit 1

echo "=== FPGA Sequencer GUI Test ==="
echo ""
echo "This will run the mock UART sender and GUI for 5 seconds."
echo "You should see a Qt window with 16 beat boxes changing colors."
echo "Press Ctrl+C to stop early."
echo ""
echo "Starting in 2 seconds..."
sleep 2

timeout 5 ./tools/mock_uart_sender --demo | ./src/fpga_sequencer_gui

echo ""
echo "Test complete! If you saw a GUI window with colored boxes, it's working."
