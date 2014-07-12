#include "Radio-Message.h"
// #include "Msp430Adc12.h"


configuration targetMoteAppC{}
implementation {

  components MainC, LedsC, targetMoteC;

  components new TimerMilliC() as LightTimer;
  components new TimerMilliC() as ServoTimer1;
  components new TimerMilliC() as ServoTimer2;

  components new HamamatsuS10871TsrC()  as LightRead;    //Light Sensor
  
  components ActiveMessageC;
  components new AMSenderC(AM_Message);
  components new AMReceiverC(AM_Message);
  components HplMsp430GeneralIOC as GIO;
  components UserButtonC;
  
  
  targetMoteC.Boot -> MainC;
  targetMoteC.Leds -> LedsC;

  targetMoteC.LightTimer -> LightTimer;
  targetMoteC.ServoTimer1 -> ServoTimer1;
  targetMoteC.ServoTimer2 -> ServoTimer2;
  
  targetMoteC.LightRead -> LightRead;

  targetMoteC.Packet -> AMSenderC;
  targetMoteC.AMPacket -> AMSenderC;
  targetMoteC.AMControl -> ActiveMessageC;
  targetMoteC.AMSend -> AMSenderC;
  targetMoteC.Receive -> AMReceiverC;
  targetMoteC.GIO -> GIO.Port23;

  targetMoteC.Notify -> UserButtonC.Notify;
}

