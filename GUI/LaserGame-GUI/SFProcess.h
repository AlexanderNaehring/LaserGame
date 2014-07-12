#ifndef PROCESS_H
#define SFPROCESS_H

#include <QObject>
#include <QProcess>
#include <QDebug>


class SFProcess : public QObject
{
    Q_OBJECT
public:
    SFProcess() : QObject() {}
    QProcess::ProcessState StartProcess();
    QByteArray processOutput;
    QString program;
    QString arguments;
    QProcess *myProcess;

private slots:
    void readStandardOutput();

signals:
    void outputUpdate(QString);
    void startError();
private:
//    QProcess *myProcess;
};

#endif // SFPROCESS_H
