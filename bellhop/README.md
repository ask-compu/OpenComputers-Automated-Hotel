# Software for the Bellhop Robot
**storepaths.lua** Will create a paths database, modify it before running to change the paths.

**bellhop.lua** Should be run after OpenOS boots up, this is what actually does the bellhop functionality.

REQUIREMENTS
---------------------------------------
[nav](https://github.com/Akuukis/RobotColorWars-Minecraft/blob/master/lib/nav.lua) - can be installed via oppm.

[locationservice](https://github.com/OpenPrograms/EvaKnievel-Programs/tree/master/locationService) - can be installed via oppm.

A navigation upgrade.

A sign i/o upgrade.

A chat upgrade. (from computronics)

A radar upgrade. (from computronics)

A wireless modem card.

An inventory upgrade.

A pickaxe in the tool slot.

The first inventory slot should contain wood doors (whatever type of door you want placed for reserved rooms).

The second inventory slot should contain iron doors (whatever type of door you want placed for vacant rooms)/.

Edit line 171 (`map:go({posNeg(13),-58,69,0})`) to change the homing coordinates, this is relative to the center of the map used to craft the navigation upgrade. The bellhop program goes to the homing location before doing anything else, all hardcoded `To` paths assume the homing location as a starting point and all hardcoded `From` paths assume the homing location as an ending point.
