#include "Radio-Message.h"
// #include "Msp430Adc12.h"


configuration gunMoteAppC{}
implementation {
  components MainC, LedsC, gunMoteC;
  components SerialStartC;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  
  //components new SensirionSht11C() as TempRead;
  // components new AdcReadClientC() as Read;
  
  
  // components SerialActiveMessageC;
  // components new SerialAMSenderC(AM_ADC);
  // components new SerialAMReceiverC(AM_ADC);
  
  components ActiveMessageC;
  components new AMSenderC(AM_Message);
  components new AMReceiverC(AM_Message);
  components HplMsp430GeneralIOC as GIO;
  components UserButtonC;
  
  // gunMoteC.AdcConfigure <- Read;
  
  gunMoteC.Boot -> MainC;
  gunMoteC.Leds -> LedsC;
  gunMoteC.Timer1 -> Timer1;
  gunMoteC.Timer2 -> Timer2;
  
  // gunMoteC.Read -> Read;
  
  gunMoteC.Packet -> AMSenderC;
  gunMoteC.AMPacket -> AMSenderC;
  gunMoteC.AMControl -> ActiveMessageC;
  gunMoteC.AMSend -> AMSenderC;
  gunMoteC.Receive -> AMReceiverC;
  gunMoteC.GIO -> GIO.Port23;

  gunMoteC.Notify -> UserButtonC.Notify;
}

