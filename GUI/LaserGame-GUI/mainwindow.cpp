#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "SocketConnect.h"


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    listenerProcess.StartProcess();

//    connect(sender, SIGNAL(connected()), this, SLOT(connected()));
//    connect(sender, SIGNAL(disconnected()), this, SLOT(disconnected()));
//    connect(sender, SIGNAL(readyRead()), this, SLOT(readyRead()));
//    connect(sender, SIGNAL(bytesWritten(qint64)), this, SLOT(bytesWritten(qint64)));

//    connect(listener->socket, SIGNAL(connected()), this, SLOT(listener_connected()));
//    connect(listener->socket, SIGNAL(disconnected()), this, SLOT(listener_disconnected()));
//    connect(listener->socket, SIGNAL(readyRead()), this, SLOT(listener_readyRead()));
//    connect(listener, SIGNAL(errorOccurs()), this, SLOT(listener_fail()));
//    connect(this->listenTimer, SIGNAL(timeout()), listener, SLOT(run()));

    //QThread threadListener;
    //Qthread threadSender;

   // listener->moveToThread(&threadListener);
    //listenTimer->moveToThread(&threadListener);
    //sender->moveToThread(&threadSender);

    //threadListener.start();


}

MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::on_pushButton_clicked()
{

    //listenTimer->timeout();
//    listener->run();

}


void MainWindow::on_pushButton_2_clicked()
{
    ui->connectStatus->clear();
}

void MainWindow::listener_connected(){


}

void MainWindow::listener_disconnected(){
    ui->connectStatus->append("Listener disconnected");
}

void MainWindow::listener_readyRead(){
    ui->connectStatus->append("Listener Reading");
    ui->receiveMsg->append(listener->socket->readAll());
}

void MainWindow::listener_fail(){
    ui->connectStatus->append("Listener connect error: "+this->listener->socket->errorString());
}

void MainWindow::sender_sent(){
    ui->connectStatus->append("Command sent!");
}

void MainWindow::on_pushButton_3_clicked()
{
    listener->socket->abort();
}

void MainWindow::on_pushButton_4_clicked()
{
    sender->run();
    QByteArray receiveMsg = "00 FF FF FF FF 02 04 06";
    receiveMsg.append(ui->sendMsg->text());
    sender->socket->write(receiveMsg);
}

void MainWindow::on_pushButton_5_clicked()
{
    ui->receiveMsg->clear();
}
