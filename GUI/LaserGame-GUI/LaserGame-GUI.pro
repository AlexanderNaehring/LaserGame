#-------------------------------------------------
#
# Project created by QtCreator 2014-07-10T01:42:45
#
#-------------------------------------------------

QT       += core gui\
         network

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = LaserGame-GUI
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    SocketConnect.cpp \
    SendProcess.cpp \
    ListenProcess.cpp

HEADERS  += mainwindow.h \
    SocketConnect.h \
    SendProcess.h \
    ListenProcess.h

FORMS    += mainwindow.ui
