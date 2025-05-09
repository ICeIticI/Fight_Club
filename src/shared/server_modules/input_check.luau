--[[ 

* Whenever a client produces input, it will be sent to this server module.

* This server script will handle doing the checking on whether or not the client is allowed to do an action.

* If they pass all the checks, then this module will call on another module for doing the desired action.

]]

-- Modules:

local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Input_Check = {}

-- User Input Types
local AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.Touch] = true, [Enum.KeyCode.ButtonB] = true} -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
local BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true}
local GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true}
local LockOnInputs = {[Enum.KeyCode.Q] = true, [Enum.KeyCode.ButtonL2] = true} -- May have LockOnInputs for each system


local input_check_FUNCTION = game.ReplicatedStorage:WaitForChild("input_check_FUNCTION")

input_check_FUNCTION.OnServerInvoke = function(plr, input)
    if LockOnInputs[input.UserInputType] or LockOnInputs[input.KeyCode] then

        local characterObject = characters:GetCharacterByPlayer(plr)
        if not characterObject then return end

        if not characterObject.isAttacking 
        and not characterObject.isGettingHit 
        and not characterObject.pairedPlaying 
        and not characterObject.isDodging
        and not characterObject.isBlocking 
        and not characterObject.waitingToAttack
        then -- the player should not be able to lock off when in action, whether thats attacking, blocking, dodging, countering, etc
        
        -- Passed the lock-on check. Activate the lock-on code:
            return "LockOnInput"
        end
    elseif AttackInputs[input.UserInputType] or AttackInputs[input.KeyCode] then
        -- print("attack input")
        
    elseif BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode] then
        -- print("block input")

    -- elseif GrappleInputs[input.UserInputType] or GrappleInputs[input.KeyCode] then

    end
end

return Input_Check