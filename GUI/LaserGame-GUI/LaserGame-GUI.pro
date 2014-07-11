#-------------------------------------------------
#
# Project created by QtCreator 2014-07-10T01:42:45
#
#-------------------------------------------------

QT       += core gui\
         network\ phonon

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = LaserGame-GUI
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    SFProcess.cpp

HEADERS  += mainwindow.h \
    SendProcess.h \
    SFProcess.h

FORMS    += mainwindow.ui

RESOURCES = Resources.qrc
