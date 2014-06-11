#include "ADC.h"
#include "Msp430Adc12.h"

//#define NEW_PRINTF_SEMANTICS
//#include "printf.h"

configuration gunMoteAppC{}
implementation {
  components MainC, LedsC, gunMoteC;
  components SerialStartC;
  components new TimerMilliC() as Timer;
  
  //components new SensirionSht11C() as TempRead;
  components new AdcReadClientC() as Read;
  
  
  components SerialActiveMessageC;
  components new SerialAMSenderC(AM_ADC);
  components new SerialAMReceiverC(AM_ADC);
  
  components ActiveMessageC;
  components new AMSenderC(AM_ADC);
  components new AMReceiverC(AM_ADC);
  
  gunMoteC.AdcConfigure <- Read;
  
  gunMoteC.Boot -> MainC;
  gunMoteC.Leds -> LedsC;
  gunMoteC.TemperatureTimer -> Timer;
  
  gunMoteC.Read -> Read;
  
  gunMoteC.SerialPacket -> SerialAMSenderC;
  gunMoteC.SerialAMPacket -> SerialAMSenderC;
  gunMoteC.SerialAMControl -> SerialActiveMessageC;
  gunMoteC.SerialAMSend -> SerialAMSenderC;
  gunMoteC.SerialReceive -> SerialAMReceiverC;
  
  gunMoteC.Packet -> AMSenderC;
  gunMoteC.AMPacket -> AMSenderC;
  gunMoteC.AMControl -> ActiveMessageC;
  gunMoteC.AMSend -> AMSenderC;
  gunMoteC.Receive -> AMReceiverC;
}

