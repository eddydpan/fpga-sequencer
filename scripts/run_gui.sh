#!/bin/bash
# Launch GUI to receive UART input via named pipe
# Use this in one terminal, then use send_commands.sh in another terminal

cd "$(dirname "$0")/../build"

FIFO="/tmp/fpga_sequencer_fifo"

echo "=== FPGA Sequencer GUI ==="
echo ""
echo "Two ways to send commands:"
echo ""
echo "1. Named Pipe (recommended for two terminals):"
echo "   This terminal: ./scripts/run_gui.sh"
echo "   Other terminal: ./scripts/send_commands.sh"
echo ""
echo "2. Direct pipe:"
echo "   echo 'BEAT 0 3' | ./build/src/fpga_sequencer_gui"
echo "   echo '0000011' | ./build/src/fpga_sequencer_gui"
echo ""

# Clean up old pipe if it exists
if [ -p "$FIFO" ]; then
    rm "$FIFO"
fi

# Create named pipe
mkfifo "$FIFO"
echo "Created named pipe: $FIFO"
echo "Listening for commands..."
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -f "$FIFO"
    exit 0
}

trap cleanup INT TERM

# Keep pipe open with background process and read from it
# This prevents blocking between commands
tail -f "$FIFO" | ./src/fpga_sequencer_gui &
GUI_PID=$!

# Wait for GUI to exit
wait $GUI_PID

# Cleanup
rm -f "$FIFO"
