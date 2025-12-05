# FPGA Sequencer
3 December 2025

## Project Description
Our core objective is to develop a functional Digital Beat Sequencer implemented in SystemVerilog on the iceBlinkPico. Our MVP consists of three integrated subsystems: the Core Sequencer Logic, the Audio Output, and the Visual Output. For the core logic, we will use a 4x4 Keypad Matrix to program the memory addresses of a 16-step sequence, determining which beats trigger a sound. The audio output will be monophonic; a rotary encoder will set the tone by mapping user input to one of eight selectable pitches within a single octave. This tone is generated as a basic digital square wave and output directly to a buzzer or small speaker, bypassing the need for a DAC. However, it will likely need to go through a buffer or level-shifter to be able to drive the speaker. Finally, for visual output, the onboard LED will mark the tempo by blinking with each beat, and the integrated RGB LED will dynamically change color—mapping from red to purple across the octave—to indicate the specific pitch currently being played.

Post-MVP, we will expand on each subsystem:
The sequencer logic could use more bits to store more data and save punch-in effects and filtering to the sequence.
An additional button could be added to play/pause audio output.
The audio output could integrate a DAC to create a larger variety of waveforms such as triangle, sine, and saw. This stretch goal could be done using direct digital synthesis (DDS) or a wavetable. Increasing the variety of waveforms will increase the number of bits stored in the sequencer logic.
The audio output could combine waves so that multiple sounds can be played at once (polyphony). If using square waves, this could be done by summing the waves using the OR operation. If using digital waves that are greater than 1-bit, the waves could be summed and normalized. Being able to play multiple sounds at once would increase the number of bits stored in the sequencer logic.
For visual feedback, we could expand from using just the onboard LEDs to sending our audio output over UART to visualize on a laptop interface. By bringing in more resources in the laptop, we could write a script to record a sound file of the audio sent over serial and have it played back with a standard audio player.
Digital signal processing could be implemented in the audio feedback system so that effects such as low-pass, high-pass, or band-pass filters can be applied to the sequence.

## Bill of Materials:
4x4 keypad matrix: 
https://www.amazon.com/Tegg-Matrix-Button-Arduino-Raspberry/dp/B07QKCQGXS 
6 Rotary Encoders: https://a.co/d/9N2CXG3 
Buzzer/Small speaker: https://a.co/d/gRcDAPn 
iceBlinkPico FPGA

## Qt Visual Interface & TDD

This repo contains a **passive Qt GUI visualizer** for the FPGA sequencer. The GUI **does not implement any sequencer logic** - it only displays data received from the FPGA over UART.

**What this codebase does:**
- ✅ Parses UART messages (`BEAT <n>`, `TONE <beat> <tone>`) from FPGA
- ✅ Visualizes 16 beats with color-coded tones (rainbow mapping)
- ✅ Highlights current beat with yellow border
- ✅ Provides mock UART tool for testing without hardware

**What this codebase does NOT do:**
- ❌ No internal sequencer logic, timing, or beat generation
- ❌ No LED blinking or audio output
- ❌ No onboard FPGA implementation (that lives in hardware)

### Build Instructions

```bash
mkdir -p build && cd build
cmake .. -DBUILD_TESTS=ON
cmake --build . --parallel 4
```

### Run Tests

```bash
cd build
ctest --output-on-failure
```

### Usage

**Method 1: Mock UART Tool (Automated Demo)**

Run the GUI and pipe mock UART data from the demo tool:

```bash
cd build
./tools/mock_uart_sender --demo | ./src/fpga_sequencer_gui
```

This will:
1. Set up a beat pattern with various tones
2. Advance through beats every 500ms
3. Display in the GUI with colors and highlighting

**Method 2: Manual UART Injection**

Inject individual commands via echo/pipe:

```bash
# Start GUI and pipe commands
cd build
(echo "TONE 0 5"; echo "TONE 3 7"; echo "BEAT 0"; sleep 1; echo "BEAT 3") | ./src/fpga_sequencer_gui
```

**Method 3: Interactive Mode**

```bash
cd build
./tools/mock_uart_sender --interactive | ./src/fpga_sequencer_gui
```

Then type commands interactively:
```
TONE 0 5
TONE 1 3
BEAT 0
BEAT 1
play
quit
```

### UART Protocol

Messages sent from FPGA → GUI (newline-delimited ASCII):

- `BEAT <index>` - Set current beat (0-15), highlighted in yellow
- `TONE <beat> <tone>` - Assign tone (0-7) to beat position
  - Tone 0 = no sound (gray)
  - Tones 1-7 = rainbow colors (red → magenta)

Example sequence from FPGA:
```
TONE 0 3
TONE 2 5
TONE 4 7
BEAT 0
BEAT 1
BEAT 2
...
```

### Connecting to Real FPGA

When your FPGA UART is ready, replace stdin reading with `QSerialPort`:

1. Open serial port (e.g., `/dev/ttyUSB0` at 115200 baud)
2. Read newline-delimited messages
3. Pass to `UARTParser::parseLine()`

The `SequencerModel` and `UARTParser` are hardware-agnostic and ready for integration.

