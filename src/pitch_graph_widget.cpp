#include "pitch_graph_widget.h"
#include <QPainter>
#include <QPen>
#include <QScrollBar>

// Canvas that draws the pitch graph
PitchGraphCanvas::PitchGraphCanvas(QWidget *parent) : QWidget(parent) {
    setMinimumHeight(150);
}

void PitchGraphCanvas::addPitchSample(int pitch, int beat) {
    m_samples.push_back({beat, pitch});
    
    // Keep only last 4 seconds of data (64 beats at 62.5ms each = 4 seconds)
    // Use MAX_SAMPLES for buffer
    if (m_samples.size() > MAX_SAMPLES) {
        m_samples.erase(m_samples.begin(), m_samples.begin() + (m_samples.size() - MAX_SAMPLES));
    }
    
    // Resize canvas to fit all samples
    int totalWidth = m_samples.size() * SAMPLE_WIDTH;
    setMinimumWidth(totalWidth);
    
    update();
}

void PitchGraphCanvas::clear() {
    m_samples.clear();
    setMinimumWidth(200); // Reset to default
    update();
}

void PitchGraphCanvas::paintEvent(QPaintEvent *) {
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);

    // Background
    painter.fillRect(rect(), QColor(30, 30, 40));

    if (m_samples.empty()) {
        painter.setPen(Qt::gray);
        painter.drawText(rect(), Qt::AlignCenter, "Pitch Graph (0-7)\nScroll to see history");
        return;
    }

    // Draw grid lines for pitch levels
    painter.setPen(QPen(QColor(60, 60, 70), 1, Qt::DashLine));
    for (int i = 0; i <= 7; ++i) {
        int y = height() - (i * height() / 8);
        painter.drawLine(0, y, width(), y);
        
        // Label pitch levels on left
        painter.setPen(QColor(100, 100, 110));
        painter.drawText(5, y - 2, QString::number(i));
        painter.setPen(QPen(QColor(60, 60, 70), 1, Qt::DashLine));
    }

    // Draw pitch line
    if (m_samples.size() > 1) {
        painter.setPen(QPen(QColor(0, 200, 255), 2));
        
        for (size_t i = 1; i < m_samples.size(); ++i) {
            int x1 = (i - 1) * SAMPLE_WIDTH;
            int x2 = i * SAMPLE_WIDTH;
            int y1 = height() - (m_samples[i - 1].pitch * height() / 8);
            int y2 = height() - (m_samples[i].pitch * height() / 8);
            painter.drawLine(x1, y1, x2, y2);
        }
    }

    // Draw current pitch label in top-right
    if (!m_samples.empty()) {
        int currentPitch = m_samples.back().pitch;
        painter.setPen(Qt::white);
        QFont font = painter.font();
        font.setBold(true);
        painter.setFont(font);
        painter.drawText(width() - 120, 20, QString("Pitch: %1").arg(currentPitch));
    }
}

// Scrollable container
PitchGraphWidget::PitchGraphWidget(QWidget *parent) : QScrollArea(parent) {
    m_canvas = new PitchGraphCanvas(this);
    setWidget(m_canvas);
    setWidgetResizable(false);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOn);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setMinimumHeight(180);
    setMaximumHeight(220);
}

void PitchGraphWidget::addPitchSample(int pitch, int beat) {
    m_canvas->addPitchSample(pitch, beat);
    
    // Auto-scroll to show the "tail" (most recent samples)
    QScrollBar *hbar = horizontalScrollBar();
    hbar->setValue(hbar->maximum());
}

void PitchGraphWidget::clear() {
    m_canvas->clear();
}
