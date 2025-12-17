#include "mainwindow.h"
#include "sequencer_model.h"
#include "uart_parser.h"
#include "pitch_graph_widget.h"

#include <QPushButton>
#include <QComboBox>
#include <QLabel>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QGroupBox>
#include <QSocketNotifier>
#include <QFileDialog>
#include <QMessageBox>
#include <QFile>
#include <QTextStream>
#ifdef HAVE_QSERIALPORT
#include <QSerialPortInfo>
#endif
#include <unistd.h>
#include <iostream>

MainWindow::MainWindow(QWidget *parent) 
    : QMainWindow(parent), m_isConnected(false), m_pitchGraph(nullptr), 
      m_beatTimer(nullptr), m_stdinNotifier(nullptr) {
    
    setWindowTitle("FPGA Sequencer Visualizer");
    resize(1200, 600);  // Wider window for side-by-side layout
    
    m_model = std::make_unique<SequencerModel>(NUM_BEATS);
    m_parser = std::make_unique<UARTParser>(m_model.get());
    
    buildUI();

    // Model callbacks - set AFTER buildUI() so widgets exist
    m_model->onBeatChanged = [this](int beat) {
        updateBeatDisplay(beat);
        if (m_pitchGraph) {
            int pitch = m_model->getBeatPitch(beat);
            if (pitch > 0) {
                m_pitchGraph->addPitchSample(pitch, beat);
            }
        }
    };

    m_model->onBeatPitchChanged = [this](int beat, int pitch) {
        std::cout << "[GUI] Beat " << beat << " → Pitch " << pitch << "\n";
        updateBeatDisplay(m_model->currentBeat());
    };

    // Beat timer: Use calculated MS_PER_BEAT
    m_beatTimer = new QTimer(this);
    connect(m_beatTimer, &QTimer::timeout, this, &MainWindow::onTimerTick);
    m_beatTimer->start(MS_PER_BEAT);

    // Listen on stdin for testing (mock UART)
    m_stdinNotifier = new QSocketNotifier(STDIN_FILENO, QSocketNotifier::Read, this);
    connect(m_stdinNotifier, &QSocketNotifier::activated, this, &MainWindow::onStdinReady);

    std::cout << "=== FPGA Sequencer GUI ===\n";
    std::cout << "Timing: " << NUM_BEATS << " beats in " << PERIOD << "s = " 
              << BEATS_PER_SECOND << " BPS (" << MS_PER_BEAT << "ms per beat)\n";
    std::cout << "Listening on stdin for UART messages.\n";
    std::cout << "Protocol: BEAT <index> <pitch>\n";
    std::cout << "  pitch: 0=off, 1-7=pitch values\n\n";
}

void MainWindow::buildUI() {
    QWidget *central = new QWidget(this);
    auto *mainLayout = new QHBoxLayout(central);  // Horizontal split
    mainLayout->setSpacing(10);
    mainLayout->setContentsMargins(10, 10, 10, 10);

    // === LEFT SIDE: Controls and Beat Grid ===
    auto *leftPanel = new QWidget(central);
    auto *leftLayout = new QVBoxLayout(leftPanel);
    leftLayout->setSpacing(15);
    
    // === Serial Port Controls ===
    auto *controlGroup = new QGroupBox("Serial Port Connection", leftPanel);
    auto *controlLayout = new QHBoxLayout(controlGroup);
    
    m_portCombo = new QComboBox(controlGroup);
    
    QPushButton *refreshBtn = new QPushButton("Refresh", controlGroup);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshSerialPorts);
    
    m_connectBtn = new QPushButton("Connect", controlGroup);
    connect(m_connectBtn, &QPushButton::clicked, this, &MainWindow::onConnectClicked);
    
    m_statusLabel = new QLabel("Disconnected (using stdin)", controlGroup);
    m_statusLabel->setStyleSheet("color: #888;");
    
    refreshSerialPorts();
    
    controlLayout->addWidget(new QLabel("Port:"));
    controlLayout->addWidget(m_portCombo);
    controlLayout->addWidget(refreshBtn);
    controlLayout->addWidget(m_connectBtn);
    controlLayout->addWidget(m_statusLabel);
    controlLayout->addStretch();
    
    leftLayout->addWidget(controlGroup);

    // === 4x4 Beat Display Grid ===
    auto *beatGroup = new QGroupBox(QString("16-Beat Sequencer (%1 BPS, %2ms/beat)")
                                       .arg(BEATS_PER_SECOND)
                                       .arg(MS_PER_BEAT), leftPanel);
    auto *beatLayout = new QGridLayout(beatGroup);
    beatLayout->setSpacing(10);
    
    // Create 4x4 grid of buttons
    for (int i = 0; i < 16; ++i) {
        QPushButton *btn = new QPushButton(QString::number(i), beatGroup);
        btn->setFixedSize(120, 120);  // Larger buttons
        btn->setEnabled(false);
        btn->setStyleSheet("font-size: 20px; font-weight: bold;");
        int row = i / 4;  // 4 buttons per row
        int col = i % 4;
        beatLayout->addWidget(btn, row, col);
        m_beatButtons.push_back(btn);
    }
    leftLayout->addWidget(beatGroup);

    // === Save and Reset Buttons ===
    m_saveBtn = new QPushButton("Save Sequence to File", leftPanel);
    m_saveBtn->setFixedHeight(40);
    connect(m_saveBtn, &QPushButton::clicked, this, &MainWindow::onSaveClicked);
    leftLayout->addWidget(m_saveBtn);
    
    m_resetBtn = new QPushButton("Reset All Beats", leftPanel);
    m_resetBtn->setFixedHeight(40);
    m_resetBtn->setStyleSheet("QPushButton { background-color: #d9534f; color: white; font-weight: bold; }");
    connect(m_resetBtn, &QPushButton::clicked, this, &MainWindow::onResetClicked);
    leftLayout->addWidget(m_resetBtn);
    
    leftPanel->setMaximumWidth(600);  // Limit left panel width
    mainLayout->addWidget(leftPanel);

    // === RIGHT SIDE: Pitch Graph ===
    auto *rightPanel = new QWidget(central);
    auto *rightLayout = new QVBoxLayout(rightPanel);
    
    auto *graphGroup = new QGroupBox("Pitch Visualization", rightPanel);
    auto *graphLayout = new QVBoxLayout(graphGroup);
    m_pitchGraph = new PitchGraphWidget(graphGroup);
    m_pitchGraph->setMinimumSize(400, 500);
    graphLayout->addWidget(m_pitchGraph);
    rightLayout->addWidget(graphGroup);
    
    mainLayout->addWidget(rightPanel, 1);  // Give right side stretch factor

    setCentralWidget(central);
}

void MainWindow::refreshSerialPorts() {
    m_portCombo->clear();
    m_portCombo->addItem("(Mock stdin for testing)");
    
#ifdef HAVE_QSERIALPORT
    for (const auto &info : QSerialPortInfo::availablePorts()) {
        m_portCombo->addItem(info.portName() + " - " + info.description(), 
                             info.portName());
    }
#else
    m_portCombo->addItem("(Serial ports disabled - Qt5SerialPort not installed)");
    m_portCombo->setEnabled(false);
    m_connectBtn->setEnabled(false);
#endif
}

void MainWindow::onConnectClicked() {
#ifdef HAVE_QSERIALPORT
    if (m_isConnected) {
        // Disconnect
        if (m_serialPort) {
            m_serialPort->close();
            m_serialPort.reset();
        }
        m_isConnected = false;
        m_connectBtn->setText("Connect");
        m_statusLabel->setText("Disconnected (using stdin)");
        m_statusLabel->setStyleSheet("color: #888;");
        m_stdinNotifier->setEnabled(true);
    } else {
        // Connect
        if (m_portCombo->currentIndex() == 0) {
            QMessageBox::information(this, "Mock Mode", 
                "Using stdin for mock UART. Pipe data or use mock_uart_sender.");
            return;
        }
        
        QString portName = m_portCombo->currentData().toString();
        m_serialPort = std::make_unique<QSerialPort>(portName);
        m_serialPort->setBaudRate(QSerialPort::Baud9600);  // Match FPGA baud rate
        m_serialPort->setDataBits(QSerialPort::Data8);
        m_serialPort->setParity(QSerialPort::NoParity);
        m_serialPort->setStopBits(QSerialPort::OneStop);
        m_serialPort->setFlowControl(QSerialPort::NoFlowControl);
        
        if (m_serialPort->open(QIODevice::ReadOnly)) {
            connect(m_serialPort.get(), &QSerialPort::readyRead, 
                    this, &MainWindow::onSerialDataReady);
            m_isConnected = true;
            m_connectBtn->setText("Disconnect");
            m_statusLabel->setText("Connected to " + portName);
            m_statusLabel->setStyleSheet("color: green;");
            m_stdinNotifier->setEnabled(false);
            std::cout << "[Serial] Connected to " << portName.toStdString() 
                      << " at 9600 baud\n";
        } else {
            QMessageBox::critical(this, "Connection Error", 
                "Failed to open " + portName + ": " + m_serialPort->errorString());
        }
    }
#else
    QMessageBox::information(this, "Not Available", 
        "Serial port support not compiled. Install Qt5SerialPort and rebuild.");
#endif
}

void MainWindow::onSerialDataReady() {
#ifdef HAVE_QSERIALPORT
    if (!m_serialPort) return;
    
    QByteArray data = m_serialPort->readAll();
    
    // Debug: Print all incoming bytes to stdout
    std::cout << "[Serial] Received " << data.size() << " bytes: ";
    for (unsigned char byte : data) {
        // Print as hex and decimal
        std::cout << "0x" << std::hex << (int)byte << std::dec 
                  << "(" << (int)byte << ") ";
    }
    std::cout << "\n";
    
    // Also print as ASCII if printable
    std::cout << "[Serial] ASCII interpretation: ";
    for (unsigned char byte : data) {
        if (byte >= 32 && byte <= 126) {
            std::cout << (char)byte;
        } else {
            std::cout << ".";
        }
    }
    std::cout << "\n";
    
    // Extract upper/lower nibbles (rotary position and button index)
    for (unsigned char byte : data) {
        int upper_nibble = (byte >> 4) & 0x0F;  // Rotary position (pitch)
        int lower_nibble = byte & 0x0F;         // Button index (beat)
        
        // Check for sync message (0xFF = period complete)
        if (byte == 0xFF) {
            std::cout << "[Serial] SYNC: Period completed, resetting to beat 0\n";
            m_model->setCurrentBeat(0);
            continue;
        }
        
        std::cout << "[Serial] Parsed: Rotary=" << upper_nibble 
                  << ", Button=" << lower_nibble << "\n";
        
        // Update the model with the new pitch for this beat
        if (lower_nibble < 16) {  // Valid beat index
            m_model->setBeatPitch(lower_nibble, upper_nibble);
            std::cout << "[Serial] Set beat " << lower_nibble 
                      << " to pitch " << upper_nibble << "\n";
        }
    }
    
    m_serialBuffer += data;
    
    int pos;
    while ((pos = m_serialBuffer.indexOf('\n')) != -1) {
        QString line = m_serialBuffer.left(pos).trimmed();
        m_serialBuffer.remove(0, pos + 1);
        
        if (!line.isEmpty()) {
            std::cout << "[Serial Line] " << line.toStdString() << "\n";
            m_parser->parseLine(line.toStdString());
        }
    }
#endif
}

void MainWindow::onStdinReady() {
    char buf[256];
    ssize_t n = read(STDIN_FILENO, buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = '\0';
        m_stdinBuffer += buf;

        size_t pos;
        while ((pos = m_stdinBuffer.find('\n')) != std::string::npos) {
            std::string line = m_stdinBuffer.substr(0, pos);
            m_stdinBuffer.erase(0, pos + 1);
            if (!line.empty()) {
                std::cout << "[Stdin] " << line << "\n";
                m_parser->parseLine(line);
            }
        }
    }
}

void MainWindow::onTimerTick() {
    int nextBeat = (m_model->currentBeat() + 1) % 16;
    m_model->setCurrentBeat(nextBeat);
}

void MainWindow::updateBeatDisplay(int beat) {
    if (m_beatButtons.empty()) return; // Safety check
    
    // Map pitches 1-8 to musical notes C4-C5
    const char* noteNames[9] = {
        "REST",  // pitch 0
        "C4",    // pitch 1
        "D4",    // pitch 2
        "E4",    // pitch 3
        "F4",    // pitch 4
        "G4",    // pitch 5
        "A5",    // pitch 6
        "B5",    // pitch 7
        "C5"     // pitch 8
    };
    
    for (size_t i = 0; i < m_beatButtons.size(); ++i) {
        if (!m_beatButtons[i]) continue; // Skip null pointers
        
        int pitch = m_model->getBeatPitch(i);
        bool isCurrent = ((int)i == beat);
        
        QString style = "font-size: 20px; font-weight: bold;";
        QString text = QString::number(i);
        
        if (pitch > 0 && pitch <= 8) {
            text += QString("\n%1").arg(noteNames[pitch]);
        } else if (pitch == 0) {
            // Don't show REST text to keep it clean
        }
        
        // HSV color mapping: pitch 1-8 maps across the color spectrum
        QString bgColor;
        if (pitch == 0) {
            bgColor = "#333";  // Dark gray for no pitch (rest)
        } else if (pitch >= 1 && pitch <= 8) {
            // Map pitch 1-8 to 8 evenly spaced hues across 360 degrees
            // Pitch 1=0°, 2=45°, 3=90°, 4=135°, 5=180°, 6=225°, 7=270°, 8=315°
            int hue = ((pitch - 1) * 360) / 8;  // 0, 45, 90, 135, 180, 225, 270, 315
            int saturation = 200;  // High saturation for vivid colors
            int value = 180;       // Medium-high brightness
            
            QColor color = QColor::fromHsv(hue, saturation, value);
            bgColor = color.name();
        } else {
            // Invalid pitch value - show as dark gray
            bgColor = "#333";
        }
        
        if (isCurrent) {
            // Current beat: add yellow border and brighten color
            if (pitch > 0) {
                style += QString(" background-color: %1; color: white; border: 4px solid yellow;").arg(bgColor);
            } else {
                style += " background-color: #444; color: white; border: 4px solid yellow;";
            }
        } else {
            // Not current beat
            if (pitch > 0) {
                style += QString(" background-color: %1; color: white;").arg(bgColor);
            } else {
                style += " background-color: #222; color: #666;";
            }
        }
        
        m_beatButtons[i]->setText(text);
        m_beatButtons[i]->setStyleSheet(style);
    }
}

void MainWindow::onResetClicked() {
    std::cout << "[GUI] Resetting all beats to 0\n";
    
    // Clear all beat pitches in the model
    for (int i = 0; i < NUM_BEATS; ++i) {
        m_model->setBeatPitch(i, 0);
    }
    
    // Reset current beat to 0
    m_model->setCurrentBeat(0);
    
    // Update display
    updateBeatDisplay(0);
    
    std::cout << "[GUI] Reset complete\n";
}

void MainWindow::onSaveClicked() {
    QString filename = QFileDialog::getSaveFileName(this, "Save Sequence", 
        "", "Text Files (*.txt);;All Files (*)");
    
    if (filename.isEmpty()) return;
    
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QMessageBox::critical(this, "Save Error", "Could not open file for writing.");
        return;
    }
    
    QTextStream out(&file);
    out << "FPGA Sequencer State\n";
    out << "====================\n\n";
    
    out << "Beat Data (3 bits per beat for pitch):\n";
    for (int i = 0; i < 16; ++i) {
        int pitch = m_model->getBeatPitch(i);
        out << QString("  Beat %1: Pitch %2 %3\n")
            .arg(i, 2)
            .arg(pitch)
            .arg(pitch > 0 ? QString("(0b%1)").arg(pitch, 3, 2, QChar('0')) : "(OFF)");
    }
    
    out << "\nActive Beats:\n";
    for (int i = 0; i < 16; ++i) {
        if (m_model->isBeatActive(i)) {
            out << QString("  Beat %1: Pitch %2\n").arg(i).arg(m_model->getBeatPitch(i));
        }
    }
    
    file.close();
    QMessageBox::information(this, "Saved", "Sequence saved to " + filename);
}
