#!/bin/bash
# Test the two-terminal workflow by simulating both terminals

FIFO="/tmp/fpga_sequencer_fifo"

echo "=== Testing Two-Terminal Workflow ==="
echo ""
echo "This test simulates both terminals to verify the pipe works"
echo ""

# Clean up old pipe
rm -f "$FIFO"

# Create named pipe
mkfifo "$FIFO"
echo "Created named pipe: $FIFO"

# Start GUI in background with tail keeping pipe open
cd "$(dirname "$0")/../build"
tail -f "$FIFO" | ./src/fpga_sequencer_gui &
GUI_PID=$!
echo "Started GUI (PID: $GUI_PID)"

sleep 1

# Send test commands
echo ""
echo "Sending test commands..."
{
    echo "0000011"  # beat 0, pitch 3
    sleep 0.5
    echo "0010101"  # beat 2, pitch 5
    sleep 0.5
    echo "0100111"  # beat 4, pitch 7
    sleep 0.5
    echo "BEAT 6 2" # beat 6, pitch 2 (text format)
    sleep 0.5
    echo "0100000"  # beat 4, pitch 0 (turn off)
    sleep 2
} > "$FIFO"

echo ""
echo "Commands sent! GUI should show:"
echo "  ✓ Beat 0 = pitch 3 (green)"
echo "  ✓ Beat 2 = pitch 5 (green)"
echo "  ✓ Beat 4 = OFF (gray)"
echo "  ✓ Beat 6 = pitch 2 (green)"
echo ""
echo "Closing GUI..."

# Kill GUI
kill $GUI_PID 2>/dev/null
wait $GUI_PID 2>/dev/null

# Cleanup
rm -f "$FIFO"

echo ""
echo "Test complete!"
echo ""
echo "To use manually:"
echo "  Terminal 1: ./scripts/run_gui.sh"
echo "  Terminal 2: ./scripts/send_commands.sh"
