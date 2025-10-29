--[[
* This server script will act as a 'main' script for server-related activity
* It will rely on module scripts with different purposes to function when called upon.
]]

local serverInitialized = Instance.new("BoolValue") -- allows other scripts to know if the server is all setup.
serverInitialized.Name = "serverInitialized"
serverInitialized.Value = false
serverInitialized.Parent = game.ReplicatedStorage

local Players = game:GetService("Players")

-- Modules
local ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)
ModuleLoader.init()

-- New modules:

ModuleLoader.ServerInit.init()
ModuleLoader.AnimationInstances.init()
ModuleLoader.character.init()
ModuleLoader.input_check.init() -- input_check will run on it's own, but we don't need to store it as it will be unused.
ModuleLoader.serverEvents.init()
-- local ServerEvents = require(game.ReplicatedStorage.Shared.ServerEvents)
-- local RagdollSystem = require(game.ReplicatedStorage.Shared.RagdollSystem)

-- local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")
-- local GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

-- GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
--     if Protocol == "Hook" or Protocol == "Haymaker" then -- Used to check which set of remote events should play. When doing basic striking, no animPair nor sentValue is sent in the parameters, unlike doing other misc. events, which is how we distinguish, splitting the events into two to make the code easier to understand.
--         ServerEvents.bAttackEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, nil, nil, plrIsBlocking, isAI) -- Will damage the hitCharacter on the server, as well as sending the other player a remote event to make their character react to the hit.
--     else
--         ServerEvents.miscEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI) -- Will execute misc things such as parrying and sync block damage.
--     end
-- end)

-- GlobalRemoteFunction.OnServerInvoke = function(sendingPlayer, Protocol, object1)
--     return ServerEvents.RFInvokes(sendingPlayer, Protocol, object1)
-- end

-- local function tempCharFunc(player)
--     local character = player.Character
--     -- Wait for HumanoidRootPart to ensure it's fully loaded
-- 		local hrp = character:WaitForChild("HumanoidRootPart", 5)
-- 		if not hrp then return end

--     -- Clone your custom model
    
--     local customModel
--     if player.Name == "Player1" then
--         customModel = game.ReplicatedStorage:WaitForChild("PlayerChar"):Clone()
--     elseif player.Name == "Player2" then
--         customModel = game.ReplicatedStorage:WaitForChild("EnemyChar"):Clone()
--     end
--     customModel.Name = player.Name
--     customModel.Parent = workspace

--     -- Optional: Position the new model where the original spawned
--     customModel:PivotTo(character:GetPivot())

--     -- Replace the character
--     player.Character = customModel
--     character:Destroy()

-- end

local function setupPlayer(player)
    task.spawn(function()
        while not serverInitialized.Value do task.wait() end
        ModuleLoader.ServerInit.InitializePlayer(player) -- initializes player's public objects
        
        -- local playerVelocities = RagdollSystem.InitializePlayer() -- from the .InitializePlayer()
    
        local characterInstance
        if player.Character then -- There is a known issue in roblox where characters won't trigger the .CharacterAdded event the first time they spawn in because they are loaded before the script can process it.
            
            -- tempCharFunc(player)
            characterInstance = ModuleLoader.character.new(player.Character, {statMultipliers = player[player.Name .. "_GameObjects"].statMultipliers})
        
            -- ServerInit.InitializeCharacter(player.Character)
            -- RagdollSystem.InitializeCharacter(playerVelocities[1], playerVelocities[2], player.Character) -- because playerVelocities equals the returned value of .InitializePlayer() (linear and angular were returned in a table), we will referance those variables via table index. Then we add the current char to the function for referancing them.
    
        end
    
        player.CharacterAdded:Connect(function(char)
            -- Initialize character-related stuff on spawn.
    
            -- tempCharFunc(player)
            characterInstance = ModuleLoader.character.new(char, {statMultipliers = player[player.Name .. "_GameObjects"].statMultipliers})
            
            -- ServerInit.InitializeCharacter(char)
            -- RagdollSystem.InitializeCharacter(playerVelocities[1], playerVelocities[2], char) -- because playerVelocities equals the returned value of .InitializePlayer() (linear and angular were returned in a table), we will referance those variables via table index. Then we add the current char to the function for referancing them.
        end)
    
        player.CharacterRemoving:Connect(function()
            -- We want to delete the instance of the character class from the old character
            if characterInstance then
                characterInstance:erase()
            end
        end)


    end)
end

for _, player in pairs(game.Players:GetChildren()) do
    setupPlayer(player)
end
Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    ModuleLoader.ServerInit.RemovePlayer(player)
end)

game:BindToClose(function()
    ModuleLoader.ServerInit.ShutdownServer()
end)


serverInitialized.Value = true