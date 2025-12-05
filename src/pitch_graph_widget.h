#ifndef PITCH_GRAPH_WIDGET_H
#define PITCH_GRAPH_WIDGET_H

#include <QWidget>
#include <vector>

class PitchGraphWidget : public QWidget {
    Q_OBJECT
public:
    explicit PitchGraphWidget(QWidget *parent = nullptr);

    void addPitchSample(int pitch, int beat); // pitch 0-7, beat 0-15
    void clear();

protected:
    void paintEvent(QPaintEvent *event) override;

private:
    struct Sample {
        int beat;
        int pitch;
    };
    std::vector<Sample> m_samples;
    static constexpr int MAX_SAMPLES = 100; // Show last 100 samples
};

#endif // PITCH_GRAPH_WIDGET_H
