#pragma once

#include <QMainWindow>
#include <QString>
#include <QTimer>
#include <QSocketNotifier>
#ifdef HAVE_QSERIALPORT
#include <QSerialPort>
#endif
#include <vector>
#include <memory>
#include "sequencer_model.h"
#include "uart_parser.h"

class QPushButton;
class QComboBox;
class QLabel;
class PitchGraphWidget;

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);

private slots:
    void onStdinReady();
    void onSerialDataReady();
    void onConnectClicked();
    void onSaveClicked();
    void onTimerTick();
    void refreshSerialPorts();

private:
    void buildUI();
    void updateBeatDisplay(int beat);
    void updateStateDisplay(uint16_t state);
    
    std::unique_ptr<SequencerModel> m_model;
    std::unique_ptr<UARTParser> m_parser;
#ifdef HAVE_QSERIALPORT
    std::unique_ptr<QSerialPort> m_serialPort;
#endif
    
    std::vector<QPushButton*> m_beatButtons;
    PitchGraphWidget *m_pitchGraph;
    QComboBox *m_portCombo;
    QPushButton *m_connectBtn;
    QPushButton *m_saveBtn;
    QLabel *m_statusLabel;
    QTimer *m_beatTimer;
    
    QSocketNotifier *m_stdinNotifier;
    std::string m_stdinBuffer;
    QString m_serialBuffer;
    
    bool m_isConnected;
};
