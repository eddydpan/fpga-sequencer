# FPGA Sequencer
Arianne Fong, Amanda Chang, Laurel Cox, Eddy Pan
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

