#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTimer>
#include <QDataStream>
#include <SFProcess.h>
#include <QSound>
#include <phonon/phonon>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    bool sfsend(QString);


    
private slots:

    void senderUpdate(QString);
    void listenerUpdate(QString);
    void serverUpdate(QString);
    void BSlider2Num(int);
    // void slotProcessError(QProcess::ProcessError);

//    void senderStartError();
//    void listenerStartError();
//    void serverStartError();

    void on_connect_clicked();

    void on_setT1_clicked();

    void on_setT2_clicked();

    void on_setT3_clicked();

    void on_consoleClear_clicked();

    void on_bulletLoad_clicked();

    void on_T1E_clicked();

    void on_T1M_clicked();

    void on_T1H_clicked();

    void on_T2E_clicked();

    void on_T2M_clicked();

    void on_T2H_clicked();

    void on_T3E_clicked();

    void on_T3M_clicked();

    void on_T3H_clicked();

    void on_CmodeStart_clicked();

    void on_CmodeStop_clicked();

private:
    SFProcess* senderProcess;
    SFProcess* serverProcess;
    SFProcess* listenerProcess;

    Ui::MainWindow *ui;
    bool listenerConnected;
//    QTimer* gameTimer = new QTimer;
//    QTimer* UITimer = new QTimer;
    QString payload;
    QString T1Pattern,T2Pattern,T3Pattern,THard,TMedium,TEasy;
    double accuracy;
    int bullets;
    Phonon::MediaObject *reload;
    Phonon::MediaObject *fire;
    Phonon::MediaObject *hit;


};

#endif // MAINWINDOW_H
