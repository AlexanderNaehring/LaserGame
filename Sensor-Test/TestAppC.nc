#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration TestAppC{}
implementation {
  components MainC, LedsC, TestC;
  components new HamamatsuS10871TsrC() as LightRead;
  components UserButtonC;
  components PrintfC;
  components SerialStartC;
  components new TimerMilliC() as Timer1; 
  components new TimerMilliC() as Timer2; 
  components HplMsp430GeneralIOC as GIO;

  TestC.Boot -> MainC;
  TestC.Leds -> LedsC;
  TestC.LightRead -> LightRead;
  TestC.Notify -> UserButtonC.Notify;
  TestC.Timer1 -> Timer1;
  TestC.Timer2 -> Timer2;
  TestC.GIO -> GIO.Port23;
}

