#include "sequencer_model.h"

SequencerModel::SequencerModel(int beats)
    : m_beats(beats), m_current(0), m_tones(beats, 0) {}

void SequencerModel::setToneForBeat(int beat, int tone) {
    if (beat < 0 || beat >= m_beats) return;
    m_tones[beat] = tone;
    if (onToneChanged) onToneChanged(beat, tone);
}

int SequencerModel::getToneForBeat(int beat) const {
    if (beat < 0 || beat >= m_beats) return 0;
    return m_tones[beat];
}

void SequencerModel::setCurrentBeat(int beat) {
    if (beat < 0 || beat >= m_beats) return;
    m_current = beat;
    if (onBeatChanged) onBeatChanged(m_current);
}

int SequencerModel::currentBeat() const { return m_current; }
