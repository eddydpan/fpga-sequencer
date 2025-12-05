#include "pitch_graph_widget.h"
#include <QPainter>
#include <QPen>

PitchGraphWidget::PitchGraphWidget(QWidget *parent) : QWidget(parent) {
    setMinimumHeight(150);
    setMaximumHeight(200);
}

void PitchGraphWidget::addPitchSample(int pitch, int beat) {
    m_samples.push_back({beat, pitch});
    if (m_samples.size() > MAX_SAMPLES) {
        m_samples.erase(m_samples.begin());
    }
    update();
}

void PitchGraphWidget::clear() {
    m_samples.clear();
    update();
}

void PitchGraphWidget::paintEvent(QPaintEvent *) {
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);

    // Background
    painter.fillRect(rect(), QColor(30, 30, 40));

    if (m_samples.empty()) {
        painter.setPen(Qt::gray);
        painter.drawText(rect(), Qt::AlignCenter, "Pitch Graph (0-7)");
        return;
    }

    // Draw grid lines
    painter.setPen(QPen(QColor(60, 60, 70), 1, Qt::DashLine));
    for (int i = 0; i <= 7; ++i) {
        int y = height() - (i * height() / 8); // Fix: divide by 8 for 0-7 range
        painter.drawLine(0, y, width(), y);
    }

    // Draw pitch line
    if (m_samples.size() > 1) {
        painter.setPen(QPen(QColor(0, 200, 255), 2));
        int xStep = std::max(1, width() / (int)(m_samples.size() - 1));
        
        for (size_t i = 1; i < m_samples.size(); ++i) {
            int x1 = (i - 1) * xStep;
            int x2 = i * xStep;
            int y1 = height() - (m_samples[i - 1].pitch * height() / 8);
            int y2 = height() - (m_samples[i].pitch * height() / 8);
            painter.drawLine(x1, y1, x2, y2);
        }
    }

    // Draw current pitch label
    if (!m_samples.empty()) {
        int currentPitch = m_samples.back().pitch;
        painter.setPen(Qt::white);
        painter.drawText(10, 20, QString("Current Pitch: %1").arg(currentPitch));
    }
}
