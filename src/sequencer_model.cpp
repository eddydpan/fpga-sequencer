#include "sequencer_model.h"

SequencerModel::SequencerModel(int beats)
    : m_beats(beats), m_current(0), m_pitches(beats, 0) {}

void SequencerModel::setBeatPitch(int beat, int pitch) {
    if (beat < 0 || beat >= m_beats) return;
    if (pitch < 0 || pitch > 7) return; // 3 bits = 0-7
    m_pitches[beat] = pitch;
    if (onBeatPitchChanged) onBeatPitchChanged(beat, pitch);
}

int SequencerModel::getBeatPitch(int beat) const {
    if (beat < 0 || beat >= m_beats) return 0;
    return m_pitches[beat];
}

bool SequencerModel::isBeatActive(int beat) const {
    return getBeatPitch(beat) > 0;
}

void SequencerModel::setCurrentBeat(int beat) {
    if (beat < 0 || beat >= m_beats) return;
    m_current = beat;
    if (onBeatChanged) onBeatChanged(m_current);
}

int SequencerModel::currentBeat() const { return m_current; }
