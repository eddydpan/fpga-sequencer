#include "mainwindow.h"
#include "sequencer_model.h"
#include "uart_parser.h"

#include <QPushButton>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QLabel>
#include <QSocketNotifier>
#include <unistd.h>
#include <iostream>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
    m_model = std::make_unique<SequencerModel>(16); // 16 beats for 4x4 keypad
    m_parser = std::make_unique<UARTParser>(m_model.get());
    buildUI();

    // Update display when FPGA sends new beat
    m_model->onBeatChanged = [this](int beat) {
        updateBeatDisplay(beat);
    };

    // Update display when FPGA sends tone assignment
    m_model->onToneChanged = [this](int beat, int tone) {
        updateToneDisplay(beat, tone);
    };

    // Listen on stdin for UART messages
    m_stdinNotifier = new QSocketNotifier(STDIN_FILENO, QSocketNotifier::Read, this);
    connect(m_stdinNotifier, &QSocketNotifier::activated, this, &MainWindow::onStdinReady);

    std::cout << "=== FPGA Sequencer GUI ===\n";
    std::cout << "Listening on stdin for UART messages.\n";
    std::cout << "Protocol: BEAT <0-15> | TONE <beat> <tone>\n";
    std::cout << "Example: echo 'TONE 0 5' | ./fpga_sequencer_gui\n\n";
}

void MainWindow::buildUI() {
    QWidget *central = new QWidget(this);
    auto *mainLayout = new QVBoxLayout(central);

    // Title
    QLabel *title = new QLabel("FPGA Sequencer Visualizer (16 Beats)", central);
    title->setStyleSheet("font-size: 18px; font-weight: bold;");
    mainLayout->addWidget(title);

    // Grid layout for 16 beats (4x4)
    auto *gridWidget = new QWidget(central);
    auto *gridLayout = new QHBoxLayout(gridWidget);
    
    for (int i = 0; i < 16; ++i) {
        QPushButton *b = new QPushButton(QString::number(i), central);
        b->setFixedSize(60, 60);
        b->setEnabled(false); // Display-only, no user interaction
        gridLayout->addWidget(b);
        m_buttons.push_back(b);
        
        // Add row break every 4 beats for better visibility
        if ((i + 1) % 4 == 0 && i < 15) {
            gridLayout->addSpacing(20);
        }
    }
    
    mainLayout->addWidget(gridWidget);

    // Legend
    QLabel *legend = new QLabel("Colors = Tones (0=none, 1-7=rainbow). Yellow border = current beat.", central);
    legend->setStyleSheet("font-size: 12px; color: #666;");
    mainLayout->addWidget(legend);

    setCentralWidget(central);
}

void MainWindow::updateBeatDisplay(int beat) {
    for (size_t i = 0; i < m_buttons.size(); ++i) {
        if ((int)i == beat) {
            // Highlight current beat with yellow border
            int tone = m_model->getToneForBeat(i);
            QString baseStyle = getToneColorStyle(tone);
            m_buttons[i]->setStyleSheet(baseStyle + "; border: 4px solid yellow;");
        } else {
            int tone = m_model->getToneForBeat(i);
            m_buttons[i]->setStyleSheet(getToneColorStyle(tone));
        }
    }
}

void MainWindow::updateToneDisplay(int beat, int tone) {
    if (beat < 0 || beat >= (int)m_buttons.size()) return;
    
    bool isCurrent = (beat == m_model->currentBeat());
    QString baseStyle = getToneColorStyle(tone);
    if (isCurrent) {
        m_buttons[beat]->setStyleSheet(baseStyle + "; border: 4px solid yellow;");
    } else {
        m_buttons[beat]->setStyleSheet(baseStyle);
    }
    std::cout << "[GUI] Beat " << beat << " → Tone " << tone << "\n";
}

QString MainWindow::getToneColorStyle(int tone) {
    if (tone == 0) {
        return "background-color: #ddd; color: black;"; // No tone = gray
    }
    // Map tones 1-7 to rainbow (red → purple)
    int hue = ((tone - 1) * 300) / 7; // 0° red → 300° magenta
    return QString("background-color: hsl(%1, 80%, 60%); color: white; font-weight: bold;").arg(hue);
}

void MainWindow::onStdinReady() {
    char buf[256];
    ssize_t n = read(STDIN_FILENO, buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = '\0';
        m_stdinBuffer += buf;

        // Process complete lines
        size_t pos;
        while ((pos = m_stdinBuffer.find('\n')) != std::string::npos) {
            std::string line = m_stdinBuffer.substr(0, pos);
            m_stdinBuffer.erase(0, pos + 1);
            if (!line.empty()) {
                std::cout << "Parsing: " << line << "\n";
                m_parser->parseLine(line);
            }
        }
    }
}
