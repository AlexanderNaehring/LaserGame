#include "mainwindow.h"
#include "SocketConnect.h"
#include <QApplication>
#include <QThread>

int main(int argc, char *argv[])
{




    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    
    //test

    return a.exec();
}
