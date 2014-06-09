#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration NullAppC{}
implementation {
  components MainC, LedsC, NullC;
  components new HamamatsuS10871TsrC() as LightRead;
  components UserButtonC;
  components PrintfC;
  components SerialStartC;
  components new TimerMilliC() as Timer1; 
  components new TimerMilliC() as Timer2; 
  components HplMsp430GeneralIOC as GIO;

  NullC.Boot -> MainC;
  NullC.Leds -> LedsC;
  NullC.LightRead -> LightRead;
  NullC.Notify -> UserButtonC.Notify;
  NullC.Timer1 -> Timer1;
  NullC.Timer2 -> Timer2;
  NullC.GIO -> GIO.Port23;
}

