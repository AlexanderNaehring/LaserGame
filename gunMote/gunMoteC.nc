#include "ADC.h"
//#include "printf.h"
#include <UserButton.h>
#include "Msp430Adc12.h"

Haha this is rocking and roll
Haha this is rocking and roll
Haha this is rocking and roll
Haha this is rocking and roll
Haha this is rocking and roll
Haha this is rocking and roll
 
module ADCC @safe()
{
  uses interface Boot;
  uses interface Leds;
  
  uses interface Timer<TMilli> as TemperatureTimer;
  //uses interface Read<uint16_t> as TempRead;
  
  uses interface Read<uint16_t> as Read;
  provides interface AdcConfigure<const msp430adc12_channel_config_t*>;
  
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;
  
  
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


  const msp430adc12_channel_config_t config = {
  INPUT_CHANNEL_A0, // channel ADC0
  REFERENCE_VREFplus_AVss, // range Vss to Vref+ 
  REFVOLT_LEVEL_2_5, // Vref is 2.5 V
  SHT_SOURCE_ACLK, // ACLK as hold clock source 
  SHT_CLOCK_DIV_1, // ADC12 clock divider of 1 
  SAMPLE_HOLD_4_CYCLES, // sampling duration is 4 clock cycles 
  SAMPCON_SOURCE_SMCLK, // SAMPCON clock source is SMCLK 
  SAMPCON_CLOCK_DIV_1}; // SAMPCON clock divider of 1
  
  async command const msp430adc12_channel_config_t* AdcConfigure.getConfiguration() {
    return &config;
  }



  event void Boot.booted() {
    call SerialAMControl.start();
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
    call Read.read();
  }
  
  
  event void Read.readDone(error_t result, uint16_t val)  {
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
