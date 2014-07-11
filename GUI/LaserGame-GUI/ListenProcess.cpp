#include "ListenProcess.h"

void ListenProcess::StartProcess()
{
//    QString program = "./sflisten localhost 8080";
//    QStringList arguments;
//    arguments.append("loclhost 8080");
    // Add any arguments you want to be passed

    myProcess = new QProcess(this);
    connect(myProcess, SIGNAL(readyReadStandardOutput()), this, SLOT(readStandardOutput()));
    myProcess->start("./sflisten localhost 8080");
    qDebug() << "it works up to now";
}

void ListenProcess::readStandardOutput()
{
    QByteArray processOutput;
    processOutput = myProcess->readAllStandardOutput();
    qDebug() << "Output was " << QString(processOutput.);
}

