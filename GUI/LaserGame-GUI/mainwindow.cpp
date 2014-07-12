#include "mainwindow.h"
#include "ui_mainwindow.h"


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);



//    SFProcess* serverProcess = new SFProcess;
//    serverProcess->program = "./sf";
//    serverProcess->arguments=" 8080 /dev/ttyUSB0 115200";
//    serverProcess->StartProcess();


    listenerProcess = new SFProcess;
    listenerConnected = false;
    senderProcess = new SFProcess;


    connect(senderProcess,SIGNAL(outputUpdate(QString)),this,SLOT(senderUpdate(QString)));
    connect(listenerProcess,SIGNAL(outputUpdate(QString)),this,SLOT(listenerUpdate(QString)));
//    connect(serverProcess,SIGNAL(outputUpdate(QString)),this,SLOT(serverUpdate(QString)));
    connect(ui->bulletSlider,SIGNAL(valueChanged(int)),this,SLOT(BSlider2Num(int)));

    gameTime = new QTime(0,0);
    UITimer = new QTimer;
    connect(UITimer,SIGNAL(timeout()),this,SLOT(timerUpdate()));

    THard = "0x01 0x01";
    TMedium = "0x03 0x02";
    TEasy = "0x99 0x01";
    T1Pattern = TEasy;
    T2Pattern = TMedium;
    T3Pattern = THard;
    Tmode = false;
    TmodeT1H = false;
    TmodeT2H = false;
    TmodeT3H = false;
    TmodeAllH = false;

    reload = Phonon::createPlayer(Phonon::NoCategory,Phonon::MediaSource("RELOAD.wav"));
    fire = Phonon::createPlayer(Phonon::NoCategory,Phonon::MediaSource("GUN_FIRE.wav"));
    hit = Phonon::createPlayer(Phonon::NoCategory,Phonon::MediaSource("HIT.wav"));
    ready = Phonon::createPlayer(Phonon::NoCategory,Phonon::MediaSource("READY.wav"));
    steady = Phonon::createPlayer(Phonon::NoCategory,Phonon::MediaSource("STEADY.wav"));

    //    hit->play();

    // initialize
    listenerProcess->program = "./sflisten";
    listenerProcess->arguments = " localhost 9001";
    if(!listenerProcess->StartProcess())
        ui->ListenerLog->append("Listener failed to start");
    else {
        ui->ListenerLog->append("Listener started");
        ui->connect->setText("Disconnect");
        listenerConnected = true;
    }
}

MainWindow::~MainWindow()
{
    listenerProcess->myProcess->close();
    delete ui;
}

bool MainWindow::sfsend(QString payload){
    senderProcess->program = "./sfsend";
    QString prefix = " localhost 9001 0x00 0xff 0xff 0xff 0xff 0x04 0x22 0x06 ";
    senderProcess->arguments = prefix + payload;
    if(!senderProcess->StartProcess()){
        return false;
    }
    else return true;
}


void MainWindow::senderUpdate(QString output)
{
    ui->senderLog->append("S: " + output);
}

void MainWindow::listenerUpdate(QString output)
{
    bool Hex2Int;
    output.remove(0,24);
    ui->ListenerLog->append("l: " + output);
    QStringList revPayload =output.split(" ",QString::SkipEmptyParts);
    // ui->ListenerLog->append("l: " + revPayload[0]+"l: " + revPayload[1]+"l: " + revPayload[2]+"l: " + revPayload[3]);
    int identifier = revPayload[0].toInt(&Hex2Int,16);
    int moteID = revPayload[1].toInt(&Hex2Int,16);
    int num = revPayload[2].toInt(&Hex2Int,16)+revPayload[3].toInt(&Hex2Int,16);
    qDebug() << " iden "<<identifier<<" mote "<<moteID<<" num "<<num;
    switch (identifier){
        case 5:
                ui->senderLog->append("Target "+QString::number(moteID)+" is set!");
                break;
        case 4:
                hit->play();
                if(Tmode){
                    if(moteID == 1){
                        ui->T1D->display("HHHHH");
                        TmodeT1H = true;
                        TmodeAllH = TmodeT1H && TmodeT2H && TmodeT3H; 
                        if(sfsend("0x00 0x01 0x00 0x00"))
                            ui->senderLog->append("Target 1 closed");
                        else ui->senderLog->append("Target 1 is closed unsuccessfully!");
                    }
                    if(moteID == 2){
                        ui->T2D->display("HHHHH");
                        TmodeT2H = true;
                        TmodeAllH = TmodeT1H && TmodeT2H && TmodeT3H; 
                        if(sfsend("0x00 0x02 0x00 0x00"))
                            ui->senderLog->append("Target 2 closed");
                        else ui->senderLog->append("Target 2 is closed unsuccessfully!");
                    }
                    if(moteID == 3){
                        ui->T3D->display("HHHHH");
                        TmodeT3H = true;
                        TmodeAllH = TmodeT1H && TmodeT2H && TmodeT3H; 
                        if(sfsend("0x00 0x03 0x00 0x00"))
                            ui->senderLog->append("Target 3 closed");
                        else ui->senderLog->append("Target 3 is closed unsuccessfully!");
                    }
                    ui->AllTD->display(ui->T1D->intValue()+ui->T2D->intValue()+ui->T3D->intValue());
                    ui->Accuracy->setValue(100*ui->AllTD->intValue() / ui->BulletD->intValue());

                }else{
                    if(moteID == 1)
                        ui->T1D->display(num);
                    if(moteID == 2)
                        ui->T2D->display(num);
                    if(moteID == 3)
                        ui->T3D->display(num);
                    ui->AllTD->display(ui->T1D->intValue()+ui->T2D->intValue()+ui->T3D->intValue());
                    ui->Accuracy->setValue(100*ui->AllTD->intValue() / ui->BulletD->intValue());
                }
                break;
        case 3: 
                fire->play(); 
                ui->BulletD->display(num);
                if(ui->BulletD->intValue() != 0)
                    ui->Accuracy->setValue(100*ui->AllTD->intValue() / ui->BulletD->intValue());
                break;
        default: break;
    }


}

void MainWindow::serverUpdate(QString output)
{
//     ui->serverLog->append(" " + output);
}


void MainWindow::on_connect_clicked()
{
    if(!listenerConnected){
        listenerProcess->program = "./sflisten";
        listenerProcess->arguments = " localhost 9001";
        if(!listenerProcess->StartProcess())
            ui->ListenerLog->append("Listener failed to start");
        else {
            ui->ListenerLog->append("Listener started");
            ui->connect->setText("Disconnect");
            listenerConnected = true;
        }
    }
    else{
        listenerProcess->myProcess->close();
        ui->connect->setText("Connect");
        ui->ListenerLog->append("Listener Stopped");
        listenerConnected = false;
    }
}

void MainWindow::on_setT1_clicked()
{
    if(sfsend("0x02 0x01 0x00 0x00"))
        ui->senderLog->append("Setting Target 1.....");
    else ui->senderLog->append("Target 1 is set unsuccessful!");
}

void MainWindow::on_setT2_clicked()
{
    if(sfsend("0x02 0x02 0x00 0x00"))
        ui->senderLog->append("Setting Target 2.....");
    else ui->senderLog->append("Target 2 is set unsuccessful!");;
}

void MainWindow::on_setT3_clicked()
{
    if(sfsend("0x02 0x03 0x00 0x00"))
        ui->senderLog->append("Setting Target 3.....");
    else ui->senderLog->append("Target 3 is set unsuccessful!");
}

void MainWindow::BSlider2Num(int num){
    ui->bulletNum->setText(QString::number(num));
}

void MainWindow::on_consoleClear_clicked()
{
    ui->senderLog->clear();
    ui->ListenerLog->clear();
}


void MainWindow::on_bulletLoad_clicked()
{
    QString payload;
    bool String2Int;
    payload.setNum(ui->bulletNum->text().toUInt(&String2Int,10),16);
    if(sfsend("0x01 0x00 0x00 0x"+payload)){
        ui->senderLog->append(payload + " Bullets loaded!");
        reload->play();
    }
    else ui->senderLog->append("Bullets loadding unsuccessful!");
}

void MainWindow::on_T1E_clicked()
{
    T1Pattern = TEasy;
}

void MainWindow::on_T1M_clicked()
{
    T1Pattern = TMedium;
}

void MainWindow::on_T1H_clicked()
{
    T1Pattern = THard;
}
void MainWindow::on_T2E_clicked()
{
    T2Pattern = TEasy;
}

void MainWindow::on_T2M_clicked()
{
    T2Pattern = TMedium;
}

void MainWindow::on_T2H_clicked()
{
    T2Pattern = THard;
}
void MainWindow::on_T3E_clicked()
{
    T3Pattern = TEasy;
}

void MainWindow::on_T3M_clicked()
{
    T3Pattern = TMedium;
}

void MainWindow::on_T3H_clicked()
{
    T3Pattern = THard;
}

void MainWindow::on_CmodeStart_clicked()
{
    QEventLoop loop;
    Tmode = false;
    ui->T1D->display(0);
    ui->T2D->display(0);
    ui->T3D->display(0);
    ui->AllTD->display(0);
    ui->BulletD->display(0);
    ui->Accuracy->setValue(0);

    ui->CmodeStart->setDisabled(true);
    ui->CmodeStop->setDisabled(true);
    ui->timeMode->setDisabled(true);

    if(sfsend("0x01 0x01 "+T1Pattern))                                   //send T1 pattern
        ui->senderLog->append("Setting Target Pattern 1.....");
    else ui->senderLog->append("Target 1 is set unsuccessful!");

    QTimer::singleShot(1000, &loop, SLOT(quit()));
    loop.exec();

    if(sfsend("0x01 0x02 "+T2Pattern))                                   //send T2 pattern
        ui->senderLog->append("Setting Target Pattern 2.....");
    else ui->senderLog->append("Target 2 is set unsuccessful!");
    ready->play();

    QTimer::singleShot(1500, &loop, SLOT(quit()));
    loop.exec();

    if(sfsend("0x01 0x03 "+T3Pattern))                                   //send T3 pattern
        ui->senderLog->append("Setting Target Pattern 3.....");
    else ui->senderLog->append("Target 3 is set unsuccessful!");
    steady->play();


    QTimer::singleShot(1500, &loop, SLOT(quit()));
    loop.exec();

    QString payload = QString::number(ui->bulletNum->text().toInt(),16); //send bullet
    if(sfsend("0x01 0x00 0x00 "+payload)){
        ui->senderLog->append("<b>"+payload + "</b> Bullets loaded!");
        reload->play();
    }
    else ui->senderLog->append("Bullets loadding unsuccessful!");

    ui->senderLog->append("<b>Game started !<b>");
    ui->CmodeStop->setDisabled(false);

}

void MainWindow::on_CmodeStop_clicked()
{
    if(sfsend("0x00 0x00 0x00 0x00")) {
        ui->senderLog->append("<b>Game Stopped.<b>");
        ui->CmodeStart->setDisabled(false);
        ui->timeMode->setDisabled(false);
    }                                  //Stop all
    else ui->senderLog->append("Game didn't stop successfully!");;
}

void MainWindow::on_TmodeStart_clicked()
{
    
    QEventLoop loop;

    gameTime = new QTime(0,0);
    ui->T1D->display("-----");
    ui->T2D->display("-----");
    ui->T3D->display("-----");
    ui->AllTD->display(0);
    ui->BulletD->display(0);
    ui->Accuracy->setValue(0);
    ui->timerDisplay->display("00:00");
    TmodeAllH = TmodeT1H = TmodeT2H = TmodeT3H = false; 

    ui->TmodeStart->setDisabled(true);
    ui->TmodeStop->setDisabled(true);
    ui->classicMode->setDisabled(true);

    if(sfsend("0x01 0x01 "+TEasy))                                   //send T1 pattern
        ui->senderLog->append("Setting Target Pattern 1.....");
    else ui->senderLog->append("Target 1 is set unsuccessful!");

    QTimer::singleShot(1000, &loop, SLOT(quit()));
    loop.exec();

    if(sfsend("0x01 0x02 "+TMedium))                                   //send T2 pattern
        ui->senderLog->append("Setting Target Pattern 2.....");
    else ui->senderLog->append("Target 2 is set unsuccessful!");
    ready->play();

    QTimer::singleShot(1500, &loop, SLOT(quit()));
    loop.exec();

    if(sfsend("0x01 0x03 "+THard))                                   //send T3 pattern
        ui->senderLog->append("Setting Target Pattern 3.....");
    else ui->senderLog->append("Target 3 is set unsuccessful!");
    steady->play();

    QTimer::singleShot(1500, &loop, SLOT(quit()));
    loop.exec();

    if(sfsend("0x01 0x00 0x00 0xff")){
        ui->senderLog->append("<b> 255 </b> Bullets loaded!");
        reload->play();
    }
    else ui->senderLog->append("Bullets loadding unsuccessful!");

    UITimer->start(1000);
    Tmode = true;
    ui->senderLog->append("<b>Game started !<b>");
    ui->TmodeStop->setDisabled(false);
}

void MainWindow::timerUpdate(){
    *gameTime = gameTime->addSecs(1);
    time = gameTime->toString("mm:ss");
    ui->timerDisplay->display(time);

    if(TmodeAllH){
        if(sfsend("0x00 0x00 0x00 0x00")) {
        UITimer->stop();
        ui->senderLog->append("<b>Game Stopped.<b>");
        ui->TmodeStart->setDisabled(false);
        ui->classicMode->setDisabled(false);
        Tmode = false;
        }                                  //Stop all
        else ui->senderLog->append("Game didn't stop successfully!");
     }
}


void MainWindow::on_TmodeStop_clicked()
{
    if(sfsend("0x00 0x00 0x00 0x00")) {
        UITimer->stop();
        ui->senderLog->append("<b>Game Stopped.<b>");
        ui->TmodeStart->setDisabled(false);
        ui->classicMode->setDisabled(false);
        Tmode = false;
    }                                  //Stop all
    else ui->senderLog->append("Game didn't stop successfully!");


}
