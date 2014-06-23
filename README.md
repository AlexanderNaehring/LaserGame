LaserGame
----

SMEAGOL project

- Initialize: 
	1. send msg with identifier == 0 __(stop all)__
	2. send msg with identifier == 1, payload == number of bullets __(init the gunMote, targetMotes initialized uniformly)__
	3. send msg with identifier == 2, ID == 1/2/3, payload = [movement_pattern] __(assign ID to the targetMote whose button is pressed as well as its movement pattern)__

----

- Game mode: 
	Timing mode: 