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
	2. send msg with identifier == 1, payload == number of bullets __(init the gunMote, targetMotes initialized uniformly)__
    3. send msg with identifier == 2, ID == 1/2/3, payload = [movement_pattern] __(assign ID to the targetMote whose button is pressed, payload is its movement pattern)__ _

----

- Leds behavier:
	- led0: ON when booted, OFF when first shot/hit accomplished.
	- led1: ON when start to send msg, OFF when sending is done.
