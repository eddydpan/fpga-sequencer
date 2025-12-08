#!/bin/bash
# Test the binary protocol (7-bit format)

cd "$(dirname "$0")/../build"

echo "=== Testing Binary Protocol ==="
echo ""
echo "Sending binary commands (7-bit format: 4-bit beat + 3-bit pitch)"
echo ""

{
    sleep 0.5
    echo "0000011"  # beat 0, pitch 3
    sleep 0.3
    echo "0010101"  # beat 2, pitch 5
    sleep 0.3
    echo "0100111"  # beat 4, pitch 7
    sleep 0.3
    echo "0100000"  # beat 4, pitch 0 (turn off)
    sleep 0.3
    echo "1010110"  # beat 10, pitch 6
    sleep 2
} | ./src/fpga_sequencer_gui

echo ""
echo "Test complete. GUI should have shown:"
echo "  - Beat 0 with pitch 3 (green)"
echo "  - Beat 2 with pitch 5 (green)"
echo "  - Beat 4 with pitch 7 (green), then turned off (gray)"
echo "  - Beat 10 with pitch 6 (green)"
echo "  - Pitch graph showing all values with scrollbar"
