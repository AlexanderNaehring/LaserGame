TargetMote Readme

responsibilities of target mote (chronological):
  - receive start signal from central mote
  - from now on, read light sensor and start controlling the servo (-> moving targets)
  - if a short light burst is sensed, trigger a "hit"
  - send "hit" to central mote
  - when receive "STOP" from central mote, deactivate servo control, stop reading light sensor
