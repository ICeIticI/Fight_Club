--[[

* Module that manages dodging an enemy, which if they do successfully, then
  the enemy will temporairly NOT be able to follow up with an attack

* It's possible the character can fail a dodge attack. If they dodge too
  early, then their iFrames will end and they can get struck. May or may not
  cause them to take more damage/temporairly not be able to parry, or
  something

]]

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)



local Dodge = {}
Dodge.__index = Dodge

function Dodge:left() --[[ Method that will cause the character to dodge to the left ]]
    GameVariables.FC_LeftDodgeTRACK:Play()
end

function Dodge:right() --[[ Method that will cause the character to dodge to the right ]]
    GameVariables.FC_RightDodgeTRACK:Play()
end

function Dodge:back() --[[ Method that will cause the character to dodge backwards ]]
    
end

return Dodge