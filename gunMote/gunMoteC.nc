#include "Radio-Message.h"
#include <UserButton.h>
 
module gunMoteC @safe()
{
  uses interface Boot;
  uses interface Leds;
  
  uses interface Timer<TMilli> as Timer1; // laser "on" timer
  uses interface Timer<TMilli> as Timer2; // wait for next shot timer
  
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;

  uses interface Notify<button_state_t>;
  uses interface HplMsp430GeneralIO as GIO;
}

implementation  {
  message_t pkt;
  bool busy = FALSE;
  int counter = 0;
  int max_bullets = 0;
  bool shoot_allowed = FALSE;

  event void Boot.booted() {
    call AMControl.start();
    call Notify.enable();
  }
  
  event void Notify.notify(button_state_t val) {    // press the button
    if(val == BUTTON_PRESSED && shoot_allowed) {
      call GIO.makeOutput();
      shoot_allowed = FALSE;
      call Timer2.startOneShot(250);    // when this timer fires the next shot is allowed
      counter++;
      if (counter <= max_bullets) {
        call GIO.set();
        call Timer1.startOneShot(200);
        // Sending this shot
        if (!busy) {
          Message* msgPtr = 
          (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          if (msgPtr == NULL) {
            return;
          }
          msgPtr->identifier = 3; // 3 = Shooting event and counter
          msgPtr->payload = counter;
          msgPtr->mote_id = 0;
          if (call AMSend.send(AM_BROADCAST_ADDR, 
              &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
            call Leds.led1On();     //start the shooting counter transmission
            call Leds.led0Off();    //first shot triggered
          }
        }
      }
    }
  }

  event void Timer1.fired(){
      call GIO.clr();
  }

  event void Timer2.fired(){
      shoot_allowed = TRUE;
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
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      // This is the "gun" mote
      if(msgPtr->identifier == 0) { //It should stop  
        max_bullets = 0;   //clear the bullets
      } else  { 
        if (msgPtr->identifier == 1) {  //start the game with certain number of bullets
          // call Leds.led2Toggle();
          max_bullets = msgPtr->payload;
          call Leds.led2Toggle();       //for debugging
          counter = 0;
          shoot_allowed = TRUE;
        }
      }
    }
    return msg;
  }
  
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led1Off();
    }
  }
  
}