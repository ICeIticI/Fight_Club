--[[ 

* This script manages the code behind when the character counter-attacks an
  enemy.

* What direction the enemy attacked the character is important, as the
  character will do a counter-attack starting on that specific arm (either 
  left or right), so for that reason we have left and right counter attacks

]]

local Counter = {}
Counter.__index = Counter

function Counter:left() --[[ Will counter-attack the enemy's left attack ]]
    
end

function Counter:right() --[[ Will counter-attack the enemy's right attack ]]
    
end

return Counter