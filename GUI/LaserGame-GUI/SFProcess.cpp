#include "SFProcess.h"

QProcess::ProcessState SFProcess::StartProcess()
{
    myProcess = new QProcess(this);
    connect(myProcess, SIGNAL(readyReadStandardOutput()), this, SLOT(readStandardOutput()));
    myProcess->start(program + arguments);
    return (myProcess->state());

}

void SFProcess::readStandardOutput()
{
    processOutput = myProcess->readAllStandardOutput();
    outputUpdate(processOutput);
}

