#include <QApplication>
#include <csignal>
#include <iostream>
#include "mainwindow.h"

// Global pointer to QApplication for signal handler
QApplication *g_app = nullptr;

void signalHandler(int signum) {
    std::cout << "\n[Signal] Caught signal " << signum << ", closing GUI...\n";
    if (g_app) {
        g_app->quit();
    }
}

int main(int argc, char **argv) {
    QApplication app(argc, argv);
    g_app = &app;
    
    // Install signal handlers for Ctrl+C (SIGINT) and Ctrl+\ (SIGQUIT)
    std::signal(SIGINT, signalHandler);
    std::signal(SIGTERM, signalHandler);
    
    MainWindow w;
    w.show();
    
    int result = app.exec();
    g_app = nullptr;
    return result;
}
