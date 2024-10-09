--[[
* This script will be the 'main' script for each client locally.
* This will depend on module scripts with different purposes to be used in this script for functionality.
]]

local UserInputService = game:GetService("UserInputService") -- Gets the user input

-- To have access to the client's variables in this script:
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
-- Manages the animations of the character:
local Animation_Manager = require(game.ReplicatedStorage.Shared.AnimationManager)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    print("Animation manager initializing")
    Animation_Manager.manageAnimations()
end)

