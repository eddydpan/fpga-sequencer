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
        int beat;
        if (iss >> beat) {
            m_model->setCurrentBeat(beat);
            if (onBeatReceived) onBeatReceived(beat);
        }
    } else if (cmd == "TONE") {
        int beat, tone;
        if (iss >> beat >> tone) {
            m_model->setToneForBeat(beat, tone);
            if (onToneReceived) onToneReceived(beat, tone);
        }
    } else if (cmd == "TEMPO") {
        int ms;
        if (iss >> ms) {
            // FPGA sends tempo but GUI doesn't use it (no internal timing)
            if (onTempoReceived) onTempoReceived(ms);
        }
    }
}
