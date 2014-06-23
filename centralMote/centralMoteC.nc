#include "Radio-Message.h"
//#include "printf.h"
// #include <UserButton.h>
// #include "Msp430Adc12.h"

module centralMoteC @safe()
{
  uses interface Boot;
  uses interface Leds;
  
  // uses interface Timer<TMilli> as TemperatureTimer;
  //uses interface Read<uint16_t> as TempRead;
  
  // uses interface Read<uint16_t> as Read;
  // provides interface AdcConfigure<const msp430adc12_channel_config_t*>;
  
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;
  
  uses interface Read<uint16_t> as LightRead;
  
  uses interface Packet as SerialPacket;
  uses interface AMPacket as SerialAMPacket;
  uses interface AMSend as SerialAMSend;
  uses interface SplitControl as SerialAMControl;
  uses interface Receive as SerialReceive;

}

implementation  {
  message_t pkt;
  bool busy = FALSE;
  bool Serialbusy = FALSE;
  int counter = 0;



  event void Boot.booted() {
    call SerialAMControl.start();
  }
  
  event void SerialAMControl.startDone(error_t err) {   //start Serial AM
    if (err == SUCCESS) {
      call Leds.led0On();
      call AMControl.start();
    } else {
      call SerialAMControl.start();
    }
  }
  
  event void AMControl.startDone(error_t err) {   // start AM
    if (err == SUCCESS) {
      call Leds.led0Off();
    } else {
      call AMControl.start();
    }
  }
  
  event void AMControl.stopDone(error_t err) {
  }
  event void SerialAMControl.stopDone(error_t err) {
  }
  
  
  // This is only for the mote connected to PC PC ---> CentralMote
  event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
        call Leds.led2Toggle();     //for debugging
      if (!busy) {
        Message* msgPtr2 =          // get msg from PC
	      (Message*)(call SerialPacket.getPayload(&pkt, sizeof(Message)));
        if (msgPtr2 == NULL) {
	        return;
        }
        msgPtr2->identifier = msgPtr->identifier;      //set value to AM packet
        msgPtr2->payload = msgPtr->payload;
        if (call AMSend.send(AM_BROADCAST_ADDR,       //forward msg from PC to other motes
            &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;                                // sending wirelessly
          call Leds.led1On();
        }
      }
      
    }
    return msg;
  }
  
  // Receiver OTA     Other motes ----> centralmote
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      // This is the "gun" mote
      if(msgPtr->identifier == 2) { // 
        if (!Serialbusy) {
          Message* msgPtr2 =    //receive the trigger event and number of bullets left from the gumMote 
          (Message*)(call SerialPacket.getPayload(&pkt, sizeof(Message)));
          if (msgPtr2 == NULL) {
            return;
          }
          msgPtr2->identifier = msgPtr->identifier;  
          msgPtr2->payload = msgPtr->payload;
          if (call SerialAMSend.send(AM_BROADCAST_ADDR,   //send the payload(bullets) to the computer
              &pkt, sizeof(Message)) == SUCCESS) {
            Serialbusy = TRUE;  // sending to SerialForwarder
            call Leds.led1On();
          }
        }
      } else if(msgPtr->identifier == 3){ // Message from the targets, It is a hitting
        // Forward the counter over SF (pc)
        
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

  event void SerialAMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      Serialbusy = FALSE;
      call Leds.led0Off();
      call Leds.led1Off();
    }
  }
  
}
