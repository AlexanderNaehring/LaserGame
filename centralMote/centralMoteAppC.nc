#include "Radio-Message.h"
// #include "Msp430Adc12.h"

//#define NEW_PRINTF_SEMANTICS
//#include "printf.h"

configuration centralMoteAppC{}
implementation {
  components MainC, LedsC, centralMoteC;
  components SerialStartC;
  components new TimerMilliC() as Timer;
  
  
  components SerialActiveMessageC;
  components new SerialAMSenderC(AM_Message);
  components new SerialAMReceiverC(AM_Message);
  
  components ActiveMessageC;
  components new AMSenderC(AM_Message);
  components new AMReceiverC(AM_Message);
  
  centralMoteC.Boot -> MainC;
  centralMoteC.Leds -> LedsC;
  
  centralMoteC.SerialPacket -> SerialAMSenderC;
  centralMoteC.SerialAMPacket -> SerialAMSenderC;
  centralMoteC.SerialAMControl -> SerialActiveMessageC;
  centralMoteC.SerialAMSend -> SerialAMSenderC;
  centralMoteC.SerialReceive -> SerialAMReceiverC;
  
  centralMoteC.Packet -> AMSenderC;
  centralMoteC.AMPacket -> AMSenderC;
  centralMoteC.AMControl -> ActiveMessageC;
  centralMoteC.AMSend -> AMSenderC;
  centralMoteC.Receive -> AMReceiverC;
}

