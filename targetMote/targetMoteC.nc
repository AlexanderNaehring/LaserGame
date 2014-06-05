#include "targetMote.h"
 
module targetMoteC  {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer;
  uses interface Read<uint16_t> as Read;
  
  uses interface AMSend as Send;
  uses interface SplitControl as ActiveMessage;
  uses interface Receive as Receive;
}

implementation  {
  message_t pkt;
  bool busy = FALSE;
  bool Serialbusy = FALSE;
  int counter = 0;

  event void Boot.booted() {
    call ActiveMessage.start();
  }
  
  event void SerialAMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Leds.led0On();
      call AMControl.start();
    } else {
      call SerialAMControl.start();
    }
  }
  
  event void AMControl.startDone(error_t err) {
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
  
  
  // This is only for the mote connected to PC
  event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {
    
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      
      if (!busy) {
        Message* msgPtr2 = 
	      (Message*)(call SerialPacket.getPayload(&pkt, sizeof(Message)));
        if (msgPtr2 == NULL) {
	        return;
        }
        
        msgPtr2->identifier = 1;  // 1 = interval in payload // 2 = temperature in payload
        msgPtr2->payload = msgPtr->payload;
        
        // forward interval to remote MOTE over wireless connection
        if (call AMSend.send(AM_BROADCAST_ADDR, 
            &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;  // send of wireless
          call Leds.led1On();
        }
      }
      
    }
    return msg;
  }
  
  // Receiver OTA
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      // This is the "remote" mote
      if(msgPtr->identifier == 1) { //expect interval in payload  
      
        // stop all running timers and start new timer
        call TemperatureTimer.stop();
        call TemperatureTimer.startPeriodic(msgPtr->payload);  //
        
      // This is fore the mote connected to the PC
      } else  { // if(msgPtr->identifier == 2)  expect temperature in payload
        // Forward the temp over SF (pc)
        if (!Serialbusy) {
          Message* msgPtr2 = 
	        (Message*)(call SerialPacket.getPayload(&pkt, sizeof(Message)));
          if (msgPtr2 == NULL) {
	          return;
          }
          msgPtr2->identifier = 2;  // 1 = interval in payload // 2 = temperature in payload
          msgPtr2->payload = msgPtr->payload;
          if (call SerialAMSend.send(AM_BROADCAST_ADDR, 
              &pkt, sizeof(Message)) == SUCCESS) {
            Serialbusy = TRUE;  // send on Serial
            call Leds.led1On();
          }
        }
      }
    }
    return msg;
  }
  
  event void TemperatureTimer.fired() {
    // star Temp measure
    call Leds.led2On();
    call TempRead.read();
  }
  
  event void TempRead.readDone(error_t result, uint16_t val)  {
    if(result == SUCCESS) {
      call Leds.led2Off();
      if (!busy) {
        Message* msgPtr = 
	      (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
        if (msgPtr == NULL) {
	        return;
        }
        msgPtr->identifier = 2; // 2 = temperature value in payload
        msgPtr->payload = val;
        if (call AMSend.send(AM_BROADCAST_ADDR, 
            &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;
          call Leds.led1On();
        }
      }
    }
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
