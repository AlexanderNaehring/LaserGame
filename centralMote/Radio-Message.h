#ifndef Message_H
#define Message_H

enum {
  AM_Message = 6
};

typedef nx_struct Message {
  nx_uint8_t identifier;  //0:stop, 1:start(with the number of bullets),2: set target ID and movement pattern, 3:shooting, 4:hitting, 
  nx_uint8_t mote_id;
  nx_uint16_t payload;
} Message;

#endif
