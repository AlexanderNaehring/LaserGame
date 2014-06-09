#include "printf.h"
#include <UserButton.h>
 
module TestC @safe()
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Read<uint16_t> as LightRead;
  uses interface Notify<button_state_t>;
  uses interface HplMsp430GeneralIO as GIO;
}
implementation
{
  int flag = 0;
  int tmp = 0;
  event void Boot.booted() {
    call Leds.led0On();
    call Timer1.startOneShot(500);
    call Timer2.startPeriodic(2000);
    call Notify.enable();
  }
  
  event void Timer1.fired(){
      call Leds.led1Toggle();
      flag = (flag == 0);
      call GIO.makeOutput();
      if (flag){
          call GIO.set();
          if(tmp)
             call Timer1.startOneShot(1);
           else
             call Timer1.startOneShot(2);
      }else{
          call GIO.clr();
          call Timer1.startOneShot(40);
      }

  }
  event void Timer2.fired()	{
     tmp = (tmp==0);
   }

  event void Notify.notify(button_state_t val) {
    if(val == BUTTON_PRESSED) {
      call Leds.led1Off();
      call LightRead.read();
    }
  }
  
  event void LightRead.readDone(error_t result, uint16_t val)  {
    if(result == SUCCESS) {
      call Leds.led1On();
      printf("The value read from light senor is %d\n",val);
  	  printfflush();
    }
  }
}

