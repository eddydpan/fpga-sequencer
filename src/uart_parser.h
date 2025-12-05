#ifndef UART_PARSER_H
#define UART_PARSER_H

#include <string>
#include <functional>

class SequencerModel;

class UARTParser {
public:
    explicit UARTParser(SequencerModel *model);

    // Parse a single line of UART message
    void parseLine(const std::string &line);

    // Callbacks for external handling (optional)
    std::function<void(int beat)> onBeatReceived;
    std::function<void(int beat, int tone)> onToneReceived;
    std::function<void(int ms)> onTempoReceived;

private:
    SequencerModel *m_model;
};

#endif // UART_PARSER_H
