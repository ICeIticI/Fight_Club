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

function ReceiveStrike:lvl1Left()
    
end

function ReceiveStrike:lvl1Right()
    
end

function ReceiveStrike:underhandLeft()
    
end

function ReceiveStrike:underhandRight()
    
end

return ReceiveStrike