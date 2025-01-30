--[[

* Module that manages what reaction the character does when they get struck
  with a strike

* On hooks & jabs, the character will do 2 generic reactions: a receive
  animation from the left, and to the right

* On overhands & underhands, they will repel backwards while also respectively
  looking either left or right depending on what direction they got hit

]]

local ReceiveStrike = {}
ReceiveStrike.__index = ReceiveStrike

function ReceiveStrike:lvl1Left() --[[ Method that will make the character react to a left level1 such as for a left hook ]]
    
end

function ReceiveStrike:lvl1Right() --[[ Method that will make the character react to a right level1 such as for a right hook ]]
    
end

function ReceiveStrike:underhandLeft() --[[ Method that will make the character react & repel backwards from a left underhand (a level2 attack) ]]
    
end

function ReceiveStrike:underhandRight() --[[ Method that will make the character react & repel backwards from a right underhand (a level2 attack) ]]
    
end

return ReceiveStrike