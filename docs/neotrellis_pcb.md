# Understanding Interacting with the NeoTrellis PCB

This document is how I am organizing my thoughts for mapping out the interaction between the iceBlinkPico FPGA and the NeoTrellis PCB -- Eddy

## Understanding

### Seesaw Chip -- what is it
The NeoTrellis PCB is controlled by a **Seesaw Chip**--similar to a mini computer that just has memory-mapped registers. For example, it'll take in a memory command like "0x1011" and it knows to map it to do a certain instruction like "read in the status of the button at index 15".

Interacting with the PCB means interacting with the Seesaw chip. This requires using the **I2C protocol** to send data over serial.


A serial message must send the first bytes: `0x2e` which is the address of the NeoTrellis board. `0x2E` is the "slavic address" of the seesaw chip. In other words, if we had more devices that were connected to this I2C master (the FPGA), we would need to know which device we actually want to send our data to. These first bits, `0x2E` is like saying, "NeoTrellis Board, I'm talking to you"

#### Writing to LEDs
Next, I need to specify the Seesaw Register Address. The register uses a two-byte format:
- First byte: Module base address (0x0E = SEESAW_NEOPIXEL_BASE)
- Second byte: Function address (0x04 = SEESAW_NEOPIXEL_BUF)

So I would send `0x0E04` to specify the LED buffer, then send the R,G,B values like `0xFFFF00` to send `YELLOW` (R=FF, G=FF, B=00).

#### Reading in the button address
Allegedly, there is a pin for the interrupts. I haven't yet seen this pin, but if we had it, we would be able to use it to recognize when a button is pressed. Instead, we'll have to poll at a constant rate the seesaw chip for the button states by asking for them over I2C.  
These button states are **not** from reading all the buttons individually. Instead, the Seesaw chip handles a bit of state tracking: the `0x1010` register (Module 0x10 = SEESAW_KEYPAD_BASE, Function 0x10 = SEESAW_KEYPAD_FIFO) is where the Seesaw chip keeps track of a **queue of latest button presses**. Say we poll the `0x1010` register, asking for all the new button presses. After we've gotten our data, we press two buttons and poll again, those two button presses will be added to the FIFO stack and will stay there until we poll again.