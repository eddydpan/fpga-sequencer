# FPGA Sequencer GUI - Update Summary

## What's New

### 1. Binary Protocol Support ✅
The GUI now accepts 7-bit binary format matching your FPGA specification:
- **Format**: `<4-bit beat index><3-bit pitch>`
- **Example**: `0100000` = beat 4, pitch 0 (turn off beat 4)
- **Auto-detection**: GUI automatically recognizes binary vs text format

### 2. Scrollable Pitch Graph ✅
- **Fixed-width view**: No more dynamic resizing
- **Shows "tail"**: Auto-scrolls to display most recent pitch samples
- **Scrollable history**: Horizontal scrollbar to view earlier pitches
- **4 pixels per sample**: Each update adds one sample point

### 3. Two-Terminal Workflow ✅
Easy command injection from a second terminal:

**Terminal 1** (run once):
```bash
./run_gui.sh
```

**Terminal 2** (send commands):
```bash
./send_commands.sh
> 0000011      # beat 0, pitch 3
> 0100111      # beat 4, pitch 7
> 0100000      # beat 4, pitch 0 (off)
```

## Testing

### Quick Test
```bash
./test_binary_protocol.sh
```

### Mock FPGA Data
```bash
# Binary format demo
./build/tools/mock_uart_sender --demo-binary | ./build/src/fpga_sequencer_gui

# Text format demo (backward compatible)
./build/tools/mock_uart_sender --demo | ./build/src/fpga_sequencer_gui
```

## Protocol Examples

### Text Format (still supported)
```
BEAT 0 3
BEAT 4 7
BEAT 4 0
```

### Binary Format (NEW)
```
0000011    ← beat 0, pitch 3
0100111    ← beat 4, pitch 7  
0100000    ← beat 4, pitch 0 (turns off beat 4)
1010110    ← beat 10, pitch 6
```

## Files Changed
- `src/uart_parser.cpp` - Added binary format parsing
- `src/pitch_graph_widget.h/cpp` - Converted to scrollable canvas
- `tools/mock_uart_sender.cpp` - Added `--demo-binary` mode

## Files Added
- `run_gui.sh` - Start GUI with named pipe listener
- `send_commands.sh` - Interactive command sender
- `test_binary_protocol.sh` - Quick binary format test
- `TWO_TERMINAL_WORKFLOW.md` - Detailed documentation

## Next Steps

When you're ready to connect your FPGA:
1. Build your FPGA logic to output 7-bit binary sequences
2. Connect FPGA UART to your computer
3. Run GUI: `./build/src/fpga_sequencer_gui`
4. FPGA sends updates like `0000011\n` over UART
5. GUI updates in real-time!

The GUI will handle both text and binary formats, so you can test with either during development.
