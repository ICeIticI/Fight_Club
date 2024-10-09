--[[
* This script will be the 'main' script for each client locally.
* This will depend on module scripts with different purposes to be used in this script for functionality.
]]

local UserInputService = game:GetService("UserInputService") -- Gets the user input

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables) -- To have access to the client's variables in this script:
local Animation_Manager = require(game.ReplicatedStorage.Shared.AnimationManager) -- Manages the animations of the character:
local LockOnSystem = require(game.ReplicatedStorage.Shared.LockOnSystem) -- Holds the mechanics for locking onto enemies
local BasicStriking = require(game.ReplicatedStorage.Shared.BasicStriking)


game.Players.LocalPlayer.CharacterAdded:Connect(function()
    print("Animation manager initializing")
    Animation_Manager.manageAnimations()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        -- Locks the player onto the enemy
        LockOnSystem.LockOn()
    
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- The player will throw an attack
    end
end)

