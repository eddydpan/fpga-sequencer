#include "uart_parser.h"
#include "sequencer_model.h"
#include <sstream>
#include <iostream>

UARTParser::UARTParser(SequencerModel *model) : m_model(model) {}

void UARTParser::parseLine(const std::string &line) {
    if (line.empty()) return;

    std::istringstream iss(line);
    std::string cmd;
    iss >> cmd;

    if (cmd == "BEAT") {
        // Format: BEAT <beat_index> <pitch>
        // pitch is 3 bits: 0=off, 1-7=pitch values
        int beat, pitch;
        if (iss >> beat >> pitch) {
            m_model->setBeatPitch(beat, pitch);
            m_model->setCurrentBeat(beat);
            if (onBeatReceived) onBeatReceived(beat, pitch);
        }
    } else if (cmd.length() == 7 && (cmd.find_first_not_of("01") == std::string::npos)) {
        // Binary format: 7 bits = 4-bit beat index + 3-bit pitch
        // Example: "0000011" = beat 0, pitch 3
        //          "0100000" = beat 4, pitch 0 (off)
        int beat = std::stoi(cmd.substr(0, 4), nullptr, 2);  // First 4 bits
        int pitch = std::stoi(cmd.substr(4, 3), nullptr, 2); // Last 3 bits
        
        m_model->setBeatPitch(beat, pitch);
        if (onBeatReceived) onBeatReceived(beat, pitch);
    }
}
