// Mock UART Sender - Simulates FPGA sending UART messages to GUI
// Usage: ./mock_uart_sender | ../build/bin/fpga_sequencer_gui

#include <iostream>
#include <thread>
#include <chrono>
#include <string>

void sendCommand(const std::string &cmd) {
    std::cout << cmd << std::endl;
    std::cout.flush();
}

void demonstrateSequence() {
    std::cerr << "=== Mock UART Sender ===\n";
    std::cerr << "Simulating FPGA sequencer output...\n\n";
    
    // Initialize sequence: set some tones
    std::cerr << "Setting up beat pattern...\n";
    sendCommand("TONE 0 3");
    sendCommand("TONE 2 5");
    sendCommand("TONE 4 7");
    sendCommand("TONE 6 2");
    sendCommand("TONE 8 4");
    sendCommand("TONE 10 6");
    sendCommand("TONE 12 1");
    sendCommand("TONE 14 3");
    
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
    
    // Simulate beat progression
    std::cerr << "\nPlaying sequence (beat every 500ms)...\n";
    for (int i = 0; i < 32; ++i) { // 2 loops of 16 beats
        int beat = i % 16;
        sendCommand("BEAT " + std::to_string(beat));
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
    }
    
    std::cerr << "\nSequence complete.\n";
}

void interactiveMode() {
    std::cerr << "=== Interactive UART Mode ===\n";
    std::cerr << "Commands:\n";
    std::cerr << "  TONE <beat> <tone>  - Set tone (0-7) for beat (0-15)\n";
    std::cerr << "  BEAT <n>            - Set current beat (0-15)\n";
    std::cerr << "  play                - Auto-play sequence\n";
    std::cerr << "  quit                - Exit\n\n";
    
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
    } else if (argc > 1 && std::string(argv[1]) == "--interactive") {
        interactiveMode();
    } else {
        std::cerr << "Usage:\n";
        std::cerr << "  " << argv[0] << " --demo | <path_to_gui>\n";
        std::cerr << "  " << argv[0] << " --interactive | <path_to_gui>\n";
        std::cerr << "\nExamples:\n";
        std::cerr << "  " << argv[0] << " --demo | ./build/bin/fpga_sequencer_gui\n";
        std::cerr << "  echo 'TONE 0 5' | ./build/bin/fpga_sequencer_gui\n";
        std::cerr << "  echo 'BEAT 3' | ./build/bin/fpga_sequencer_gui\n";
        return 1;
    }
    
    return 0;
}
