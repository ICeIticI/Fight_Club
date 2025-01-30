--[[

* Module that controls what the character will do after getting
  counter-attacked after getting countered by an enemy.

* Either the enemy countered their left strike, or their right one.
  So depending on what side that was, they will play a syncronized
  countered animation.

]]

local ReceiveCounter = {}
ReceiveCounter.__index = ReceiveCounter

function ReceiveCounter:left() --[[ Method that controls what happens to the character after getting countered to the left ]]
    
end

function ReceiveCounter:right() --[[ Method that controls what happens to the character after getting countered to the right ]]
    
end

return ReceiveCounter