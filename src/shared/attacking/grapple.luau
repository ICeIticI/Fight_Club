--[[
    
* This script will manage the grapple functionality of the character

* If the character grapples an enemy and doesn't get broken free & countered
(in the receiveGrapple module), then they will be able to repeatedly hit the
enemy until the enemy breaks free

* The player could also throw/shove the enemy if they press block in a
direction, or release by pressing block alone

* If the player gets the enemy to low/no HP, then they can "finish" them off,
which will essentially be a lvl 3 attack in a grapple.



* NOTE: This feature won't be avaliable in the first alpha. Get basics down
first.

]]

local Grapple = {}

return Grapple