#include "Radio-Message.h"
#include <UserButton.h>
 
module targetMoteC @safe()
{
  uses interface Boot;
  uses interface Leds;
  
  uses interface Timer<TMilli> as LightTimer;   //the frequency of light measuring
  uses interface Timer<TMilli> as ServoTimer1;
  uses interface Timer<TMilli> as ServoTimer2;
  
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;

  uses interface Read<uint16_t> as LightRead;

  uses interface Notify<button_state_t>;
  uses interface HplMsp430GeneralIO as GIO;
}

implementation  {
  message_t pkt;
  bool busy = FALSE;
  bool shot = FALSE;
  int counter = 0;
  int statusFlag = 0;       //1 for open, 0 for close;
  int idFlag = 0;       //1 for ID assigned, 0 for ID is not assigned;
  int tmp = 1;

  event void Boot.booted() {
    call Leds.led1On();
    call AMControl.start();
    call LightTimer.startPeriodic(100);   //the timer for light sensor
    call Notify.enable();

    call GIO.makeOutput();
          call GIO.set();
          call ServoTimer1.startOneShot(1);
          call GIO.set();
          call ServoTimer1.startOneShot(40);
          call GIO.set();
          call ServoTimer1.startOneShot(3);
          call Leds.led2Toggle();
  }
  
  event void Notify.notify(button_state_t val) {    // press the button

    //if we could use it

  }

  event void LightTimer.fired(){  //read from light sensor in a certain frequency
      call LightRead.read();
    
  }


  event void LightRead.readDone(error_t result, uint16_t val)  {
    if(result == SUCCESS) {
      if(val >= 1000) {       // Yeah, it is a hit!
          shot = TRUE;
          //close the target

          // call LightTimer.stop();       
          // call GIO.makeOutput();
          // call GIO.set();
          // call ServoTimer1.startOneShot(1);
          // call GIO.set();
          // call ServoTimer1.startOneShot(40);
          // call GIO.set();
          // call ServoTimer1.startOneShot(3);
          // call Leds.led2Toggle();
      }         
    }
  }

  event void ServoTimer1.fired() {
      call GIO.clr();
  }

  event void ServoTimer2.fired() {
     tmp = (tmp==0);
  }


  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Leds.led0On();
    } else {
      call AMControl.start();
    }
  }
  
  
  event void AMControl.stopDone(error_t err) {
  }


  // Receiver OTA
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
    // if (len == sizeof(Message)) {
    //   Message* msgPtr = (Message*)payload;
    //   // This is the "gun" mote
    //   if(msgPtr->identifier == 0) { //It should stop  
    //    // call Timer1.stop();
    //   } else  { 
    //     if (msgPtr->identifier == 1) {  //start the game with certain number of bullets
    //       // call Leds.led2Toggle();
    //       MaxBullets = msgPtr->payload;
    //       call Leds.led2Toggle();       //for debugging
    //       counter = 0;
    //     }
    //   }
    // }
    return msg;
  }
  
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led1Off();
    }
  }

  
}
