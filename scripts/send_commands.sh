#!/bin/bash
# Helper to send commands to running GUI via named pipe

FIFO="/tmp/fpga_sequencer_fifo"

# Check if pipe exists
if [ ! -p "$FIFO" ]; then
    echo "Error: Named pipe not found!"
    echo "Please start the GUI first with: ./scripts/run_gui.sh"
    exit 1
fi

echo "=== FPGA Sequencer Command Sender ==="
echo ""
echo "Send commands to GUI (both text and binary formats supported):"
echo ""
echo "Examples:"
echo "  BEAT 0 3     - Text format: set beat 0 to pitch 3"
echo "  0000011      - Binary format: beat 0, pitch 3"
echo "  0100111      - Binary format: beat 4, pitch 7"
echo "  0100000      - Binary format: beat 4, pitch 0 (off)"
echo ""
echo "Type 'help' for more info, 'quit' to exit"
echo ""

while true; do
    read -p "> " cmd
    
    case "$cmd" in
        quit|exit)
            break
            ;;
        help)
            echo ""
            echo "Text Format:   BEAT <index> <pitch>"
            echo "Binary Format: <4-bit beat><3-bit pitch>"
            echo ""
            echo "Beat index: 0-15 (4 bits)"
            echo "Pitch: 0-7 (3 bits, 0=off)"
            echo ""
            ;;
        "")
            ;;
        *)
            # Write directly to FIFO (don't use exec redirection)
            echo "$cmd" > "$FIFO" &
            echo "Sent: $cmd"
            ;;
    esac
done

echo "Exiting..."
