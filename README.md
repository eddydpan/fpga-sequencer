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

This repo contains a **passive Qt GUI visualizer** for the FPGA sequencer with **3-bit pitch encoding per beat**.

**What this codebase does:**
- ✅ Parses UART messages encoding 3-bit pitch per beat (`BEAT <index> <pitch>`)
- ✅ Visualizes 16 beats with on/off state (green=active, gray=off)
- ✅ Shows pitch values on each beat button
- ✅ Real-time pitch graph display showing pitch over time
- ✅ Serial port selection (when Qt5SerialPort available)
- ✅ Save sequence to file functionality
- ✅ Auto-advancing beat display (62.5ms per beat, full sequence in 1 second)

**What this codebase does NOT do:**
- ❌ No internal sequencer logic or beat generation
- ❌ No LED blinking or audio output
- ❌ No onboard FPGA implementation (hardware lives elsewhere)

### New UART Protocol (3-bit pitch per beat)

**Message format:**
```
BEAT <index> <pitch>
```
- `index`: Beat position (0-15)
- `pitch`: 3-bit value (0-7)
  - 0 = Off (no sound)
  - 1-7 = Pitch values in one octave

**Example sequence from FPGA:**
```
BEAT 0 3    # Beat 0 with pitch 3
BEAT 2 5    # Beat 2 with pitch 5  
BEAT 4 7    # Beat 4 with pitch 7
BEAT 6 0    # Beat 6 off
```

Each BEAT command sets both the pitch for that beat position AND advances the sequencer to that beat.

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

**Method 2: Manual Commands**

Inject individual commands:

```bash
cd build
(echo "BEAT 0 5"; echo "BEAT 3 7"; echo "BEAT 6 2"; sleep 2) | ./src/fpga_sequencer_gui
```

**Method 3: Interactive Mode**

```bash
cd build
./tools/mock_uart_sender --interactive | ./src/fpga_sequencer_gui
```

Then type commands:
```
BEAT 0 3
BEAT 1 5
BEAT 2 7
play
quit
```

### GUI Features

- **Beat Grid**: 16 beat boxes (2 rows of 8)
  - Green background = pitch assigned (active)
  - Gray background = no pitch (off)
  - Yellow border = current beat
  - Shows beat number and pitch value (e.g., "0\nP3")
  
- **Pitch Graph**: Real-time visualization of pitch values over time

- **Serial Port**: Select `/dev/ttyUSB*` port to connect to real FPGA (requires Qt5SerialPort)

- **Save**: Export sequence state to text file

### Connecting to Real FPGA

When your FPGA UART is ready, replace stdin reading with `QSerialPort`:

1. Open serial port (e.g., `/dev/ttyUSB0` at 115200 baud)
2. Read newline-delimited messages
3. Pass to `UARTParser::parseLine()`

The `SequencerModel` and `UARTParser` are hardware-agnostic and ready for integration.

