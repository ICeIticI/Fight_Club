--[[
* This script will be the 'main' script for each client locally.
* This will depend on module scripts with different purposes to be used in this script for functionality.
]]

local UserInputService = game:GetService("UserInputService") -- Gets the user input

-- Modules
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables) -- To have access to the client's variables in this script:
local Animation_Manager = require(game.ReplicatedStorage.Shared.AnimationManager) -- Manages the animations of the character:
local LockOnSystem = require(game.ReplicatedStorage.Shared.LockOnSystem) -- Holds the mechanics for locking onto enemies
local BasicStriking = require(game.ReplicatedStorage.Shared.BasicStriking)
local ReceivingAndCountering = require(game.ReplicatedStorage.Shared.ReceivingAndCountering)

-- New Modules:

local attackCommand = require(game.ReplicatedStorage.Shared.attackCommand) -- Module that gets fired every time attack is inputted. Will go through a series of checks before allowing the player to actually attack, which will then sent to another module for the actual attack process.
local receiveCommand = require(game.ReplicatedStorage.Shared.receiveCommand) -- Module

GameVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(currentAttack, Protocol, sentAnimPair, sentValue, isAI)
    -- Manages the remote events the client receives.
    ReceivingAndCountering.Receive(currentAttack, Protocol, sentAnimPair, sentValue, isAI)
end)

if game.Players.LocalPlayer.Character then -- The player may load faster than the script, so this will ensure the player won't skip initializing
    -- Initializes the player
    Animation_Manager.manageAnimations() --We want to manage the animations of the player as soon as they spawn in.
    BasicStriking.manageHitboxes() -- We also want to manage the plr char's attack hitboxes when they spawn as well.
end

game.Players.LocalPlayer.CharacterAdded:Connect(function() -- runs when plr char spawns
    -- Initializes the player
    Animation_Manager.manageAnimations() --We want to manage the animations of the player as soon as they spawn in.
    BasicStriking.manageHitboxes() -- We also want to manage the plr char's attack hitboxes when they spawn as well.
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then -- May have lock on inputs for each system.
        -- Locks the player onto the enemy
        LockOnSystem.LockOn()
    
    elseif GameVariables.AttackInputs[input.UserInputType] or GameVariables.AttackInputs[input.KeyCode] then -- AttackInputs is a table of input types that are allowed in this context. The indexes of that table are actually the input types that we allow, so we can referance an index in that table by what the player inputed.
        -- The player will throw an attack
        BasicStriking.Attack(input)
        -- attackCommand:Call() -- Will replace BasicStriking.Attack()

    elseif GameVariables.BlockInputs[input.UserInputType] or GameVariables.BlockInputs[input.KeyCode] then
        -- The player will block
        ReceivingAndCountering.Block(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- The player will stop blocking
    ReceivingAndCountering.EndBlock(input)
end)