# Scripts

Helper scripts for testing and using the FPGA Sequencer GUI.

## Main Scripts

- **`run_gui.sh`** - Start GUI with named pipe listener (Terminal 1)
- **`send_commands.sh`** - Interactive command sender (Terminal 2)
- **`demo.sh`** - Comprehensive demo showing all features

## Test Scripts

- **`test_two_terminal.sh`** - Test the two-terminal workflow automatically
- **`test_binary_protocol.sh`** - Test 7-bit binary protocol
- **`test_gui.sh`** - Basic GUI functionality test

## Usage

From project root:
```bash
# Two-terminal workflow
./scripts/run_gui.sh          # Terminal 1
./scripts/send_commands.sh    # Terminal 2

# Quick demo
./scripts/demo.sh

# Run tests
./scripts/test_two_terminal.sh
```
