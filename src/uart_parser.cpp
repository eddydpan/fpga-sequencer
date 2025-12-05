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
    }
}
