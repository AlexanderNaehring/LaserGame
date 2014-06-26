#include "Radio-Message.h"
#include <UserButton.h>
 
module targetMoteC @safe()
{
  uses interface Boot;
  uses interface Leds;
  
  uses interface Timer<TMilli> as LightTimer;   //the frequency of light measuring
  uses interface Timer<TMilli> as ServoTimer1;  // sending control bits to servo, always running
  uses interface Timer<TMilli> as ServoTimer2;  // controlling intervals, only running if game runs
  
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
  int game_mode = 0;          //0 for default mode, 1 for custom mode
  int hit_counter = 0;          //hit counter
  bool status_flag = FALSE;       //1 for open, 0 for close;
  int mote_id = FALSE;       //ID of the mote;
  bool id_wait = FALSE;       //T for Waiting for the ID;
  int servoTimerFlag = 1;
  int servoPosition = 2;
  int targetOpenTime;
  int targetClosedTime;

  event void Boot.booted() {
    call Leds.led1On();
    call AMControl.start();
    call LightTimer.startPeriodic(100);   //the frequency for light sensor
    call Notify.enable();   //enable the button
    call ServoTimer1.startOneShot(1);
    
  }

  // Receiver OTA
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      // This is the "gun" mote
      if(msgPtr->identifier == 0) { //It should stop  
        hit_counter = 0;
        call LightTimer.stop();
        status_flag = FALSE;  // stop the servotimers

      }else if (msgPtr->identifier == 1 && msgPtr->mote_id == mote_id){  //start the game and set Movement

        call GIO.makeOutput(); 
        status_flag = TRUE;   
        targetOpenTime = msgPtr->payload1*1000;       //read custom pattern
        targetClosedTime = msgPtr->payload2*1000;   
        if(targetOpenTime == 0)             // no payload, default pattern
          targetOpenTime = 5000;
        if(targetClosedTime == 0) 
          targetClosedTime = 1000;
        call ServoTimer2.startOneShot(1);    
          //defaut game mode if no id for targetMotes assigned.

      }else if (msgPtr->identifier == 2){   //assign mote ID 
          if (id_wait){
            mote_id = (int)msgPtr->mote_id;   //assign mote ID
            game_mode = 1;
            id_wait = FALSE;
            call Leds.led2Off(); // assigned.
            call GIO.makeOutput();    // <-  Movement pattern ->
            status_flag = FALSE;     
            servoPosition = 2;
          }
      }
    }
    return msg;
  }
  
  event void Notify.notify(button_state_t val) {    // press the button to assign ID to the mote
          call Leds.led2On();     //ready to be assigned
          id_wait = TRUE;
  }

  event void LightTimer.fired(){  //read from light sensor in a certain frequency
      call LightRead.read();
    
  }

// It's a hit or not
  event void LightRead.readDone(error_t result, uint16_t val)  {
    if(result == SUCCESS) {
      if(val >= 1000) {       // Yeah, it is a hit!
        shot = TRUE;
        hit_counter++;
        // if (game_mode = 0){
        // //close the target
          
        // }else if (game_mode = 1){
          //sending this hit
          if (!busy) {
            Message* msgPtr = 
            (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
            if (msgPtr == NULL) {
              return;
            }
            msgPtr->identifier = 4; // 4 = hiting event and counter
            msgPtr->payload2 = hit_counter;
            msgPtr->payload1 = 0;
            msgPtr->mote_id = mote_id;
            if (call AMSend.send(AM_BROADCAST_ADDR, 
                &pkt, sizeof(Message)) == SUCCESS) {
              busy = TRUE;
              call Leds.led1On();     //start the hit counter transmission
              call Leds.led0Off();    //first hit triggered
            }
          }
        // }
      }         
    }
  }

  event void ServoTimer1.fired() {
    if(servoTimerFlag) {
      servoTimerFlag = 0;
      call GIO.clr();
      call ServoTimer1.startOneShot(40);
    } else {
      servoTimerFlag = 1;
      call GIO.set();
      if (status_flag)
        call ServoTimer1.startOneShot(servoPosition);
      else 
        call ServoTimer1.startOneShot(2);
    }
  }

  event void ServoTimer2.fired() {    //not used up to now
    if(status_flag)
     if(servoPosition == 1) {
        servoPosition = 2;
        call ServoTimer2.startOneShot(targetClosedTime);
     }  else  {
        servoPosition = 1;
        call ServoTimer2.startOneShot(targetOpenTime);
     }
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


  
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led1Off();
    }
  }

  
}
