#pragma once

#include <QMainWindow>
#include <QString>
#include <vector>
#include <memory>
#include "sequencer_model.h"
#include "uart_parser.h"

class QPushButton;
class QSocketNotifier;

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);

private slots:
    void onStdinReady();

private:
    void buildUI();
    void updateBeatDisplay(int beat);
    void updateToneDisplay(int beat, int tone);
    QString getToneColorStyle(int tone);

    std::unique_ptr<SequencerModel> m_model;
    std::unique_ptr<UARTParser> m_parser;
    std::vector<QPushButton*> m_buttons;
    QSocketNotifier *m_stdinNotifier;
    std::string m_stdinBuffer;
};
