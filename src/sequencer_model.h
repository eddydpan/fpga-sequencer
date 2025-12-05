#ifndef SEQUENCER_MODEL_H
#define SEQUENCER_MODEL_H

#include <vector>
#include <functional>
#include <cstdint>

// Passive model: stores state received from FPGA via UART
// Protocol: Each beat has 3-bit pitch value (0-7, where 0=off, 1-7=pitches)
class SequencerModel {
public:
    explicit SequencerModel(int beats = 16);

    // Set pitch for a specific beat (0=off, 1-7=pitch)
    void setBeatPitch(int beat, int pitch);
    int getBeatPitch(int beat) const;

    // Check if specific beat is active (pitch > 0)
    bool isBeatActive(int beat) const;

    void setCurrentBeat(int beat);
    int currentBeat() const;

    int numBeats() const { return m_beats; }

    // Callbacks for GUI updates
    std::function<void(int)> onBeatChanged;
    std::function<void(int beat, int pitch)> onBeatPitchChanged;

private:
    int m_beats;
    int m_current;
    std::vector<int> m_pitches; // 3-bit pitch per beat (0-7)
};

#endif // SEQUENCER_MODEL_H
