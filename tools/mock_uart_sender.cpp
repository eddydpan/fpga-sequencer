// Mock UART Sender - Simulates FPGA sending UART messages to GUI
// Usage: ./mock_uart_sender | ../build/bin/fpga_sequencer_gui

#include <iostream>
#include <thread>
#include <chrono>
#include <string>
#include <bitset>

void sendCommand(const std::string &cmd) {
    std::cout << cmd << std::endl;
    std::cout.flush();
}

std::string toBinary(int beat, int pitch) {
    std::bitset<4> beatBits(beat);
    std::bitset<3> pitchBits(pitch);
    return beatBits.to_string() + pitchBits.to_string();
}

void demonstrateSequence() {
    std::cerr << "=== Mock UART Sender ===\n";
    std::cerr << "Simulating FPGA sequencer output...\n\n";
    
    // Initialize sequence: set pitches for some beats
    std::cerr << "Setting up beat pattern with pitches (3-bit per beat)...\n";
    sendCommand("BEAT 0 3");    // Beat 0, pitch 3
    sendCommand("BEAT 2 5");    // Beat 2, pitch 5
    sendCommand("BEAT 4 7");    // Beat 4, pitch 7
    sendCommand("BEAT 6 2");    // Beat 6, pitch 2
    sendCommand("BEAT 8 4");    // Beat 8, pitch 4
    sendCommand("BEAT 10 6");   // Beat 10, pitch 6
    sendCommand("BEAT 12 1");   // Beat 12, pitch 1
    sendCommand("BEAT 14 3");   // Beat 14, pitch 3
    
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
    
    // Simulate beat progression (sequencer cycles through beats)
    std::cerr << "\nPlaying sequence (beat every 62ms, full sequence in 1 second)...\n";
    for (int i = 0; i < 32; ++i) { // 2 loops of 16 beats
        int beat = i % 16;
        // FPGA would send current beat with its stored pitch
        // For demo, we'll just send beat advance (pitch already set)
        std::this_thread::sleep_for(std::chrono::milliseconds(62));
    }
    
    std::cerr << "\nSequence complete.\n";
}

void demonstrateBinarySequence() {
    std::cerr << "=== Mock UART Sender (Binary Format) ===\n";
    std::cerr << "Simulating FPGA UART output with 7-bit binary protocol...\n";
    std::cerr << "Format: <4-bit beat index><3-bit pitch>\n\n";
    
    int pattern[][2] = {
        {0, 3},   // 0000011
        {1, 0},   // 0001000 (turn off beat 1)
        {2, 4},   // 0010100
        {4, 7},   // 0100111
        {6, 2},   // 0110010
        {8, 5},   // 1000101
        {10, 6},  // 1010110
        {12, 1},  // 1100001
    };
    
    for (auto &p : pattern) {
        std::string binary = toBinary(p[0], p[1]);
        std::cerr << "Sending beat " << p[0] << ", pitch " << p[1] 
                  << " -> " << binary << "\n";
        sendCommand(binary);
        std::this_thread::sleep_for(std::chrono::milliseconds(400));
    }
    
    std::cerr << "\nBinary demonstration complete.\n";
}

void interactiveMode() {
    std::cerr << "=== Interactive UART Mode ===\n";
    std::cerr << "Commands:\n";
    std::cerr << "  BEAT <index> <pitch>  - Text format: Set beat (0-15) with pitch (0-7)\n";
    std::cerr << "  <7-bit binary>        - Binary format: 4-bit index + 3-bit pitch\n";
    std::cerr << "                          Example: 0000011 = beat 0, pitch 3\n";
    std::cerr << "                                   0100000 = beat 4, pitch 0 (off)\n";
    std::cerr << "  play                  - Auto-play text sequence\n";
    std::cerr << "  quit                  - Exit\n\n";
    
    std::string line;
    while (std::getline(std::cin, line)) {
        if (line == "quit" || line == "exit") break;
        if (line == "play") {
            demonstrateSequence();
            continue;
        }
        if (!line.empty()) {
            sendCommand(line);
        }
    }
}

int main(int argc, char **argv) {
    if (argc > 1 && std::string(argv[1]) == "--demo") {
        demonstrateSequence();
    } else if (argc > 1 && std::string(argv[1]) == "--demo-binary") {
        demonstrateBinarySequence();
    } else if (argc > 1 && std::string(argv[1]) == "--interactive") {
        interactiveMode();
    } else {
        std::cerr << "Usage:\n";
        std::cerr << "  " << argv[0] << " --demo | <path_to_gui>\n";
        std::cerr << "  " << argv[0] << " --demo-binary | <path_to_gui>\n";
        std::cerr << "  " << argv[0] << " --interactive | <path_to_gui>\n";
        std::cerr << "\nExamples:\n";
        std::cerr << "  " << argv[0] << " --demo | ./build/src/fpga_sequencer_gui\n";
        std::cerr << "  " << argv[0] << " --demo-binary | ./build/src/fpga_sequencer_gui\n";
        std::cerr << "  echo '0000011' | ./build/src/fpga_sequencer_gui  # beat 0, pitch 3\n";
        std::cerr << "  echo 'BEAT 3 7' | ./build/src/fpga_sequencer_gui\n";
        std::cerr << "\nProtocol:\n";
        std::cerr << "  Text:   BEAT <index> <pitch>\n";
        std::cerr << "  Binary: <4-bit beat><3-bit pitch> (7 bits total)\n";
        std::cerr << "    index: 0-15 (beat position)\n";
        std::cerr << "    pitch: 0-7 (0=off, 1-7=pitch values)\n";
        std::cerr << "\nBinary Examples:\n";
        std::cerr << "  0000011 = beat 0, pitch 3\n";
        std::cerr << "  0100000 = beat 4, pitch 0 (off)\n";
        std::cerr << "  1010110 = beat 10, pitch 6\n";
        return 1;
    }
    
    return 0;
}
