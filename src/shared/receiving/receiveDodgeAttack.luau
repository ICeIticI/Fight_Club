--[[

* This module controls what reaction the character will do after getting
  dodge-attacked. Often, this may be syncronous animations between
  character and enemy.

* Even after getting hit after a dodge attack, the enemy will be able to
  have time to hit the character and start their combo.

]]

local ReceiveDodgeAttack = {}
ReceiveDodgeAttack.__index = ReceiveDodgeAttack

function ReceiveDodgeAttack:left() --[[ Method that will make the character do a reaction after getting dodge-attacked from the left ]]

end

function ReceiveDodgeAttack:right() --[[ Method that will make the character do a reaction after getting dodge-attacked from the right ]]
    
end

function ReceiveDodgeAttack:back() --[[ Method that will make the character do a reaction after the enemy dodged backwards for their dodge attack. ]]
    
end

return ReceiveDodgeAttack