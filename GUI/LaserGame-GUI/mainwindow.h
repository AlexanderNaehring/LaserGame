#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTcpSocket>
#include "SocketConnect.h"
#include <QTimer>
#include <QThread>
#include <QDataStream>
#include <ListenProcess.h>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();


    
private slots:
    void on_pushButton_clicked();

    void on_pushButton_2_clicked();

    void listener_connected();

    void listener_disconnected();

    void listener_readyRead();

    void listener_fail();

    void sender_sent();


    void on_pushButton_3_clicked();

    void on_pushButton_4_clicked();

    void on_pushButton_5_clicked();

private:
    Ui::MainWindow *ui;
    SocketConnect* sender = new SocketConnect;
    SocketConnect* listener = new SocketConnect;
    QTimer *listenTimer = new QTimer(this);
    ListenProcess listenerProcess;
};

#endif // MAINWINDOW_H
