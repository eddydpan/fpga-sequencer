#ifndef UART_PARSER_H
#define UART_PARSER_H

#include <string>
#include <functional>
#include <cstdint>

class SequencerModel;

class UARTParser {
public:
    explicit UARTParser(SequencerModel *model);

    // Parse a single line of UART message
    void parseLine(const std::string &line);

    // Callbacks for external handling (optional)
    std::function<void(int beat, int pitch)> onBeatReceived;

private:
    SequencerModel *m_model;
};

#endif // UART_PARSER_H
