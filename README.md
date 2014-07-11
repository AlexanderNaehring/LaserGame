LaserGame
----

A SMEAGOL project.

----

- Game mode: 
	- Default mode: if we skip the init step 3, start with default mode: all targetMote will close when there is a hit.
	- Timing mode: all motes open and close periodically and the hit counter will be sent to centralMote. all targetMotes will be closed when time is up.

----

- Initialization: 
	1. send msg with identifier == 0 __(stop all)__
    2. send msg with identifier == 2, ID == 1/2/3, 
	3. send msg with identifier == 1, mote_id == 0 payload == number of bullets __(init the gunMote)__
	4. send msg with identifier == 1, mote_id == [1|2|3]] payload1 == opentimeslot payload2 == closeslot __(init the target_mote, payloads set to 0 is default mode)__

>identifier:  0:stop,  1:start(with the number of bullets and movement pattern),  2: set target ID ,  3:shooting,  4:hitting

----

- Leds behavier:
	- led0: ON when booted, OFF when first shot/hit accomplished.
	- led1: ON when start to send msg, OFF when sending is done.
	- led3: ON when press the button on targetMote(assign ID), OFF when ID is assigned.

int targetOpenTime = 1000;
  int targetClosedTime = 5000;