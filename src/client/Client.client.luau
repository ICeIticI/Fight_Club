--[[
* This script will be the 'main' script for each client locally.
* This will depend on module scripts with different purposes to be used in this script for functionality.
]]

local UserInputService = game:GetService("UserInputService") -- Gets the user input

-- Modules
-- local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables) -- To have access to the client's variables in this script:
-- local Animation_Manager = require(game.ReplicatedStorage.Shared.AnimationManager) -- Manages the animations of the character:
-- local LockOnSystem = require(game.ReplicatedStorage.Shared.LockOnSystem) -- Holds the mechanics for locking onto enemies
-- local BasicStriking = require(game.ReplicatedStorage.Shared.BasicStriking)
-- local ReceivingAndCountering = require(game.ReplicatedStorage.Shared.ReceivingAndCountering)
-- local UIManager = require(game.ReplicatedStorage.Shared.UIManager)

-- New Modules:

local lockOn = require(game.ReplicatedStorage.Shared.client_modules.lockOn)

-- New Remote Events/Functions:

local input_check_FUNCTION = game.ReplicatedStorage:WaitForChild("input_check_FUNCTION")

-- GameVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(currentAttack, Protocol, sentAnimPair, sentValue, isAI)
--     -- Manages the remote events the client receives.

--     -- while not GameVariables.initialized do task.wait() end -- We dont want anything being managed before the GameVariables initialization finished, setting variables for the character spawn
    
--     -- ReceivingAndCountering.Receive(currentAttack, Protocol, sentAnimPair, sentValue, isAI)
-- end)

if game.Players.LocalPlayer.Character then -- The player may load faster than the script, so this will ensure the player won't skip initializing
    -- Initializes the player

    -- while not GameVariables.initialized do task.wait() end -- We dont want anything being managed before the GameVariables initialization finished, setting variables for the character spawn

    -- Animation_Manager.manageAnimations() --We want to manage the animations of the player as soon as they spawn in.
    -- BasicStriking.manageHitboxes() -- We also want to manage the plr char's attack hitboxes when they spawn as well.
    -- UIManager.Init()
end

game.Players.LocalPlayer.CharacterAdded:Connect(function() -- runs when plr char spawns
    -- Initializes the player

    -- while not GameVariables.initialized do task.wait() end -- We dont want anything being managed before the GameVariables initialization finished, setting variables for the character spawn

    -- Animation_Manager.manageAnimations() --We want to manage the animations of the player as soon as they spawn in.
    -- BasicStriking.manageHitboxes() -- We also want to manage the plr char's attack hitboxes when they spawn as well.
    -- UIManager.Init()
end)

-- User Input Types
local AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.Touch] = true, [Enum.KeyCode.ButtonB] = true} -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
local BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true}
local GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true}
local LockOnInputs = {[Enum.KeyCode.Q] = true, [Enum.KeyCode.ButtonL2] = true} -- May have LockOnInputs for each system


UserInputService.InputBegan:Connect(function(input)

    
    local inputTable = {} -- Because the server wont let us send the input object, we need to create a table representing input that are strings
    inputTable.UserInputType = input.UserInputType
    inputTable.KeyCode = input.KeyCode
    
    -- Making sure the given input is what we're looking for. This can get exploited since its on the client, but all that will do is make the server performance lessen.
    if (LockOnInputs[input.UserInputType] or LockOnInputs[input.KeyCode])
    or (AttackInputs[input.UserInputType] or AttackInputs[input.KeyCode])
    or (BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode])
    -- or (GrappleInputs[input.UserInputType] or GrappleInputs[input.KeyCode]) 
    then
        -- print(inputTable)
        if input_check_FUNCTION:InvokeServer(inputTable) == "LockOnInput" then
            -- Player pressed a button to lock on, got approved by the server, and now we can lock on:
            lockOn.Lock()
            
        end
    end



    -- while not GameVariables.initialized do task.wait() end -- We dont want anything being managed before the GameVariables initialization finished, setting variables for the character spawn

    -- if GameVariables.LockOnInputs[input.KeyCode] then -- May have lock on inputs for each system.
    --     -- Locks the player onto the enemy
    --     LockOnSystem.LockOn()
    
    -- elseif GameVariables.AttackInputs[input.UserInputType] or GameVariables.AttackInputs[input.KeyCode] then -- AttackInputs is a table of input types that are allowed in this context. The indexes of that table are actually the input types that we allow, so we can referance an index in that table by what the player inputed.
    
    --     if input.UserInputType == Enum.UserInputType.MouseButton1 and GameVariables.lockOnDebounce.Value and GameVariables.player.Name == "Player2" then -- for testing
    --         warn("2 seconds till attack...")
    --         task.wait(2) -- FOR TESTING BRACING BLOCKS, COUNTERS AND PARRYS. DELETE WHEN DONE!!!
    --     end
        
    --     -- The player will throw an attack
    --     BasicStriking.Attack(input)


    --     -- attackCommand:Call() -- Will replace BasicStriking.Attack()

    -- elseif GameVariables.BlockInputs[input.UserInputType] or GameVariables.BlockInputs[input.KeyCode] then
    --     -- The player will block
    --     ReceivingAndCountering.Block(input)
    --     -- receiveCommand:CallBlock(input)
    -- end
end)

UserInputService.InputEnded:Connect(function(input)
    
    -- while not GameVariables.initialized do task.wait() end -- We dont want anything being managed before the GameVariables initialization finished, setting variables for the character spawn
    
    -- if GameVariables.BlockInputs[input.UserInputType] or GameVariables.BlockInputs[input.KeyCode] then
    --     -- The player will stop blocking
    --     ReceivingAndCountering.EndBlock(input)
    --     -- receiveCommand:CallEndBlock(input)
    -- end
end)