#ifndef LISTENPROCESS_H
#define LISTENPROCESS_H

#include <QObject>
#include <QProcess>
#include <QDebug>


class ListenProcess : public QObject
{
    Q_OBJECT
public:
    ListenProcess() : QObject() {}
    void StartProcess();
private slots:
    void readStandardOutput();
private:
    QProcess *myProcess;
};

#endif // LISTENPROCESS_H
