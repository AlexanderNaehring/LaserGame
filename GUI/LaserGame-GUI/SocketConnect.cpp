#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "SocketConnect.h"

SocketConnect::SocketConnect(QObject *parent) :
    QObject(parent)
{
    socket = new QTcpSocket(this);
}

void SocketConnect::run()
{

    socket->connectToHost("127.0.0.1", 8080);       //Server info

//    if(!socket->waitForDisconnected(9000))
//    {
//        errorOccurs();

//    }

}

//void SocketConnect::connected()
//{
//    socketStatus->append("SocketConnected!");

//    //socket->write("HEAD / HTTP/1.0\r\n\r\n\r\n\r\n");
//}

//void SocketConnect::disconnected()
//{
//    socketStatus->append("DisSocketConnected!");
//}

//void SocketConnect::bytesWritten(qint64 bytes)
//{
//    socketStatus->append("We sent: " + bytes);
//}

//void SocketConnect::readyRead()
//{
//    socketStatus->append("Reading...");
//    socketStatus->append(socket->readAll());
//}

//void SocketConnect::errorOccurs(){
//    errorMsg = "Error: " +socket->errorString();
//}
