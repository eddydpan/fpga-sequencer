#ifndef PITCH_GRAPH_WIDGET_H
#define PITCH_GRAPH_WIDGET_H

#include <QScrollArea>
#include <QWidget>
#include <vector>

class PitchGraphCanvas : public QWidget {
    Q_OBJECT
public:
    explicit PitchGraphCanvas(QWidget *parent = nullptr);
    
    void addPitchSample(int pitch, int beat);
    void clear();

protected:
    void paintEvent(QPaintEvent *event) override;

private:
    struct Sample {
        int beat;
        int pitch;
    };
    std::vector<Sample> m_samples;
    static constexpr int SAMPLE_WIDTH = 4; // pixels per sample
    static constexpr int VISIBLE_SAMPLES = 50; // samples in "tail" view
    static constexpr int MAX_SAMPLES = 250; // 4 seconds at 62.5ms = ~64 samples, give buffer
};

class PitchGraphWidget : public QScrollArea {
    Q_OBJECT
public:
    explicit PitchGraphWidget(QWidget *parent = nullptr);

    void addPitchSample(int pitch, int beat);
    void clear();

private:
    PitchGraphCanvas *m_canvas;
};

#endif // PITCH_GRAPH_WIDGET_H
