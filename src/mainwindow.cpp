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
    resize(900, 700);
    
    m_model = std::make_unique<SequencerModel>(16);
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

    // Beat timer: 16 beats in 1 second = 62.5ms per beat
    m_beatTimer = new QTimer(this);
    connect(m_beatTimer, &QTimer::timeout, this, &MainWindow::onTimerTick);
    m_beatTimer->start(62); // ~62.5ms

    // Listen on stdin for testing (mock UART)
    m_stdinNotifier = new QSocketNotifier(STDIN_FILENO, QSocketNotifier::Read, this);
    connect(m_stdinNotifier, &QSocketNotifier::activated, this, &MainWindow::onStdinReady);

    std::cout << "=== FPGA Sequencer GUI ===\n";
    std::cout << "Listening on stdin for UART messages.\n";
    std::cout << "Protocol: BEAT <index> <pitch>\n";
    std::cout << "  pitch: 0=off, 1-7=pitch values\n\n";
}

void MainWindow::buildUI() {
    QWidget *central = new QWidget(this);
    auto *mainLayout = new QVBoxLayout(central);
    mainLayout->setSpacing(15);

    // === Serial Port Controls ===
    auto *controlGroup = new QGroupBox("Serial Port Connection", central);
    auto *controlLayout = new QHBoxLayout(controlGroup);
    
    m_portCombo = new QComboBox(controlGroup);
    
    QPushButton *refreshBtn = new QPushButton("Refresh", controlGroup);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshSerialPorts);
    
    m_connectBtn = new QPushButton("Connect", controlGroup);
    connect(m_connectBtn, &QPushButton::clicked, this, &MainWindow::onConnectClicked);
    
    m_statusLabel = new QLabel("Disconnected (using stdin)", controlGroup);
    m_statusLabel->setStyleSheet("color: #888;");
    
    // Populate ports AFTER widgets are created
    refreshSerialPorts();
    
    controlLayout->addWidget(new QLabel("Port:"));
    controlLayout->addWidget(m_portCombo);
    controlLayout->addWidget(refreshBtn);
    controlLayout->addWidget(m_connectBtn);
    controlLayout->addWidget(m_statusLabel);
    controlLayout->addStretch();
    
    mainLayout->addWidget(controlGroup);

    // === Pitch Graph ===
    auto *graphGroup = new QGroupBox("Pitch Over Time", central);
    auto *graphLayout = new QVBoxLayout(graphGroup);
    m_pitchGraph = new PitchGraphWidget(graphGroup);
    graphLayout->addWidget(m_pitchGraph);
    mainLayout->addWidget(graphGroup);

    // === Beat Display ===
    auto *beatGroup = new QGroupBox("16-Beat Sequencer (Each beat encodes 3-bit pitch)", central);
    auto *beatLayout = new QGridLayout(beatGroup);
    beatLayout->setSpacing(10);
    
    for (int i = 0; i < 16; ++i) {
        QPushButton *btn = new QPushButton(QString::number(i), beatGroup);
        btn->setFixedSize(100, 100);
        btn->setEnabled(false);
        btn->setStyleSheet("font-size: 18px; font-weight: bold;");
        beatLayout->addWidget(btn, i / 8, i % 8);
        m_beatButtons.push_back(btn);
    }
    mainLayout->addWidget(beatGroup);

    // === Save Button ===
    m_saveBtn = new QPushButton("Save Sequence to File", central);
    m_saveBtn->setFixedHeight(40);
    connect(m_saveBtn, &QPushButton::clicked, this, &MainWindow::onSaveClicked);
    mainLayout->addWidget(m_saveBtn);

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
        m_serialPort->setBaudRate(QSerialPort::Baud115200);
        
        if (m_serialPort->open(QIODevice::ReadOnly)) {
            connect(m_serialPort.get(), &QSerialPort::readyRead, 
                    this, &MainWindow::onSerialDataReady);
            m_isConnected = true;
            m_connectBtn->setText("Disconnect");
            m_statusLabel->setText("Connected to " + portName);
            m_statusLabel->setStyleSheet("color: green;");
            m_stdinNotifier->setEnabled(false);
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
    
    m_serialBuffer += m_serialPort->readAll();
    
    int pos;
    while ((pos = m_serialBuffer.indexOf('\n')) != -1) {
        QString line = m_serialBuffer.left(pos).trimmed();
        m_serialBuffer.remove(0, pos + 1);
        
        if (!line.isEmpty()) {
            std::cout << "[Serial] " << line.toStdString() << "\n";
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
    
    for (size_t i = 0; i < m_beatButtons.size(); ++i) {
        if (!m_beatButtons[i]) continue; // Skip null pointers
        
        int pitch = m_model->getBeatPitch(i);
        bool isCurrent = ((int)i == beat);
        
        QString style = "font-size: 18px; font-weight: bold;";
        QString text = QString::number(i);
        
        if (pitch > 0) {
            text += QString("\nP%1").arg(pitch);
        }
        
        if (isCurrent && pitch > 0) {
            // Current beat with pitch: green with yellow border
            style += " background-color: #00FF00; color: black; border: 4px solid yellow;";
        } else if (isCurrent) {
            // Current beat, no pitch: dark with yellow border
            style += " background-color: #444; color: white; border: 4px solid yellow;";
        } else if (pitch > 0) {
            // Has pitch but not current: green
            style += " background-color: #00AA00; color: white;";
        } else {
            // No pitch, not current: dark gray
            style += " background-color: #222; color: #666;";
        }
        
        m_beatButtons[i]->setText(text);
        m_beatButtons[i]->setStyleSheet(style);
    }
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
