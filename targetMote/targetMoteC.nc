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
  int game_mode = 0;          //0 for default mode, 1 for custom mode
  int hit_counter = 0;          //hit counter
  int status_flag = 0;       //1 for open, 0 for close;
  int mote_id = FALSE;       //ID of the mote;
  bool id_wait = FALSE;       //T for Waiting for the ID;
  int tmp = 1;

  event void Boot.booted() {
    call Leds.led1On();
    call AMControl.start();
    call LightTimer.startPeriodic(100);   //the frequency for light sensor
    call Notify.enable();   //enable the button

    call GIO.makeOutput();            //test the servo
          call GIO.set();
          call ServoTimer1.startOneShot(1);
          call GIO.set();
          call ServoTimer1.startOneShot(40);
          call GIO.set();
          call ServoTimer1.startOneShot(3);
  }

  // Receiver OTA
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      // This is the "gun" mote
      if(msgPtr->identifier == 0) { //It should stop  
        hit_counter = 0;
        call LightTimer.stop();

      // <-To be implemented->
       // close the target;

      }else if (msgPtr->identifier == 1){  //start the game

          //defaut game mode if no id for targetMotes assigned.

      }else if (msgPtr->identifier == 2){  //assign mote ID and Movement
          if (id_wait){
            mote_id = (int)msgPtr->mote_id;   //assign mote ID
            game_mode = 1;
            id_wait = FALSE;
            call Leds.led2Off(); // assigned.

            // <-  Movement pattern ->

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
        if (game_mode = 0){
        //close the target
          
        }else if (game_mode = 1){
          //sending this hit
          if (!busy) {
            Message* msgPtr = 
            (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
            if (msgPtr == NULL) {
              return;
            }
            msgPtr->identifier = 4; // 4 = hiting event and counter
            msgPtr->payload = hit_counter;
            msgPtr->mote_id = mote_id;
            if (call AMSend.send(AM_BROADCAST_ADDR, 
                &pkt, sizeof(Message)) == SUCCESS) {
              busy = TRUE;
              call Leds.led1On();     //start the hit counter transmission
              call Leds.led0Off();    //first hit triggered
            }
          }
        }
      }         
    }
  }

  event void ServoTimer1.fired() {
      call GIO.clr();
  }

  event void ServoTimer2.fired() {    //not used up to now
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


  
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led1Off();
    }
  }

  
}
