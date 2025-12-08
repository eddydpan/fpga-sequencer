# Two-Terminal Workflow & Binary Protocol

## Overview
The GUI now supports:
1. **Binary 7-bit protocol**: `<4-bit beat index><3-bit pitch>`
2. **Scrollable pitch graph**: Fixed-width view with horizontal scrollbar to see history
3. **Two-terminal workflow**: Run GUI in one terminal, inject data from another

## Quick Start (Two Terminals)

### Terminal 1: Start GUI
```bash
./run_gui.sh
```

This creates a named pipe and starts the GUI listening for commands.

### Terminal 2: Send Commands
```bash
./send_commands.sh
```

Then type commands interactively:
```
> BEAT 0 3
> 0000011
> 0100111
> quit
```

## Protocol Formats

### Text Format (backward compatible)
```
BEAT <index> <pitch>
```
Example: `BEAT 0 3` sets beat 0 to pitch 3

### Binary Format (NEW - matches your FPGA spec)
```
<4 bits: beat index><3 bits: pitch>
```

Examples:
- `0000011` = beat 0 (0000), pitch 3 (011)
- `0001000` = beat 1 (0001), pitch 0 (000) - turn off
- `0010100` = beat 2 (0010), pitch 4 (100)
- `0100111` = beat 4 (0100), pitch 7 (111)
- `1010110` = beat 10 (1010), pitch 6 (110)

The GUI automatically detects format:
- 7-character line of only "0" and "1" → binary format
- "BEAT" keyword → text format

## Pitch Graph Features

The pitch graph now:
- **Fixed width per sample**: Each beat update adds exactly 4 pixels
- **Auto-scrolls to "tail"**: Always shows most recent samples
- **Scrollable history**: Use horizontal scrollbar to view earlier pitches
- **No dynamic resizing**: Graph width grows with data, view window stays fixed

To see earlier pitch values, drag the horizontal scrollbar left.

## Alternative Methods

### Direct Piping
```bash
echo "0000011" | ./build/src/fpga_sequencer_gui
```

### Mock Sender (for testing)
```bash
# Text format demo
./build/tools/mock_uart_sender --demo | ./build/src/fpga_sequencer_gui

# Binary format demo
./build/tools/mock_uart_sender --demo-binary | ./build/src/fpga_sequencer_gui
```

### Quick Binary Test
```bash
./test_binary_protocol.sh
```

## FPGA Implementation

Your FPGA should send 7-bit sequences as ASCII over UART:

```verilog
// Pseudocode example
wire [3:0] beat_index;  // 0-15
wire [2:0] pitch;       // 0-7

// Send as 7 ASCII characters followed by newline
uart_tx("0" or "1" for beat_index[3]);
uart_tx("0" or "1" for beat_index[2]);
uart_tx("0" or "1" for beat_index[1]);
uart_tx("0" or "1" for beat_index[0]);
uart_tx("0" or "1" for pitch[2]);
uart_tx("0" or "1" for pitch[1]);
uart_tx("0" or "1" for pitch[0]);
uart_tx("\n");
```

Example UART output from FPGA:
```
0000011\n   // beat 0, pitch 3
0001000\n   // beat 1, pitch 0 (off)
0010100\n   // beat 2, pitch 4
```

## Example: Updating Beat 4 to Off

From your FPGA or Terminal 2:
```
0100000
```

This sends:
- `0100` = beat index 4
- `000` = pitch 0 (off)

The GUI will immediately:
1. Set beat 4 to pitch 0
2. Change beat 4's button to gray (inactive)
3. Add pitch=0 sample to the graph
4. Auto-scroll graph to show this new sample

