--[[
Local Script

* This module runs when the character presses attack

* The module is also used to do logical checks before initiating any attack, such as if they're already attacking, or if they're getting
  hit.

]]

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local strike = require(game.ReplicatedStorage.Shared.attacking.strike)


-- Variables:

local attackCooldown = 1 -- Variable that will prevent the player from being to spam punches at an insane speed. The value it equals depends on the attack being currently thrown.
local canAttack = true

local AttackCommand = {}
AttackCommand.__index = AttackCommand

function AttackCommand:Call() --[[ Whenever the player presses attack, this function should be called, which will do all the checks to make sure the player CAN attack, and if they can, then this will call on one of the attacks from the attack modules. ]]
    
    -- Check to make sure the player can attack before calling a module
    if canAttack then
        -- We can attack
        print("Call attack module!")
        
        canAttack = false
        task.wait(attackCooldown)
        canAttack = true
    end

end

return AttackCommand