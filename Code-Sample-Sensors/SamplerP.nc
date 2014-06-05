module SamplerP
{
  uses {
    interface Boot;
    interface Leds;
    interface SplitControl as SerialSplitControl;
    interface AMSend;
    interface Timer<TMilli>;
    interface Read<uint16_t>[uint8_t id];
  }
}

implementation
{
  uint8_t sensor_no = 0;  // The sensor currently being sampled
  uint8_t retry_no = 0;   // Number of retries so far
  
  message_t msg;
  Entry* entry;

  event void Boot.booted()
  {
    entry = call AMSend.getPayload(&msg, sizeof(Entry));
    entry->counter = 0;
    call SerialSplitControl.start();
  }

  event void SerialSplitControl.startDone(error_t error)
  {
    call Timer.startOneShot(SAMPLE_INTERVAL);
  }
  
  task void write()
  {
    if ((retry_no <= RETRY_NO)) {
      if (call AMSend.send(AM_BROADCAST_ADDR, &msg, sizeof(Entry)) != SUCCESS) {
        retry_no++;
        post write();
      } 
    } else {
      call Timer.startOneShot(SAMPLE_INTERVAL);   // Sleep until next sampling
    }
  }
  
  task void sample()
  {
    if (sensor_no < SENSORS_NO) {
      if (call Read.read[sensor_no]() != SUCCESS) {
        entry->values[sensor_no] = INVALID_SAMPLE_VALUE;
        sensor_no++;
        post sample();   // Samples the next sensor
      }
    } else {
      // Writes sensor samples collected in this session to flash
      retry_no = 0;
      post write();
    }
  }
  
  /**
   * Starts sampling all sensors
   */
  event void Timer.fired()
  {
    entry->counter++;
    call Leds.led1Toggle();
    sensor_no = 0;
    post sample();   // Samples the first sensor
  }
  
  event void Read.readDone[uint8_t id](error_t error, uint16_t val)
  {
    // Caches the sampled value
    entry->values[sensor_no] = (error == SUCCESS) ? val : INVALID_SAMPLE_VALUE;
    sensor_no++;
    post sample();   // Samples the next sensor
  }
  
  event void AMSend.sendDone(message_t* amsg, error_t error)
  {
    if (error == SUCCESS) {
      call Timer.startOneShot(SAMPLE_INTERVAL);  // Sleep until next sampling
    } else {
      retry_no++;
      post write();
    }
  }

  event void SerialSplitControl.stopDone(error_t error) {}
  default command error_t Read.read[uint8_t id]() { return FAIL; }
}
