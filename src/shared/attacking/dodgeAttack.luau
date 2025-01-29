--[[

* This script will run the code following a dodge when a character 
  presses attack afterwards, performing a dodge attack.

* When dodging in a certain direction, it will pull a random dodge attack
  of that direction

]]

local DodgeAttack = {}
DodgeAttack.__index = DodgeAttack

function DodgeAttack:left() --[[ Will make the player do a dodge attack after dodging left based on the left dodge attacks ]]
    
end

function DodgeAttack:right() --[[ Will make the player do a dodge attack after dodging right based on the right dodge attacks ]]
    
end

function DodgeAttack:back() --[[ Will make the player do a dodge attack after dodging back based on the back dodge attacks ]]
    
end


return DodgeAttack