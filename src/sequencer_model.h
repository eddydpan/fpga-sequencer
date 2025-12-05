#ifndef SEQUENCER_MODEL_H
#define SEQUENCER_MODEL_H

#include <vector>
#include <functional>

// Passive model: stores state received from FPGA via UART
// No internal timing/sequencing - GUI only displays what FPGA sends
class SequencerModel {
public:
    explicit SequencerModel(int beats = 16);

    void setToneForBeat(int beat, int tone);
    int getToneForBeat(int beat) const;

    void setCurrentBeat(int beat);
    int currentBeat() const;

    int numBeats() const { return m_beats; }

    // Callback invoked when current beat changes (for GUI update)
    std::function<void(int)> onBeatChanged;

    // Callback invoked when tone changes (for GUI update)
    std::function<void(int beat, int tone)> onToneChanged;

private:
    int m_beats;
    int m_current;
    std::vector<int> m_tones; // tone id per beat (0-7)
};

#endif // SEQUENCER_MODEL_H
