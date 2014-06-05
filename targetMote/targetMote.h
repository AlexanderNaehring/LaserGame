#ifndef TARGETMOTE_H
#define TARGETMOTE_H

enum {
  AM_LASERRADIO = 6
};

typedef nx_struct Message {
  nx_uint8_t identifier;
  nx_uint16_t payload;
} Message;

#endif
