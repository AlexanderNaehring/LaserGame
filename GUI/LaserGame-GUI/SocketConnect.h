#ifndef CONNECT_H
#define CONNECT_H


#include <QObject>
#include <QDebug>
#include <QTcpSocket>
#include <QAbstractSocket>
#include <QTextEdit>

class SocketConnect : public QObject
{
    Q_OBJECT
public:
    explicit SocketConnect(QObject *parent = 0);
    QTcpSocket *socket;
    QString errorMsg;


public slots:
    void run();

signals:
    void connected();
    void disconnected();
    void bytesWritten(qint64 bytes);
    void readyRead();
    void errorOccurs();



private:


};

#endif // CONNECT_H
