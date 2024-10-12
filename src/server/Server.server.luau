--[[
* This server script will act as a 'main' script for server-related activity
* It will rely on module scripts with different purposes to function when called upon.
]]

local Players = game.Players

-- Modules
local ServerInit = require(game.ReplicatedStorage.Shared.ServerInit)
local ServerEvents = require(game.ReplicatedStorage.Shared.ServerEvents)
local RagdollSystem = require(game.ReplicatedStorage.Shared.RagdollSystem)

local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")


GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
    print("Received event from " .. tostring(sendingPlayer) .. " by their protocol: " .. tostring(Protocol))
    print("currentAttack:" .. tostring(currentAttack))
    if Protocol == "Hook" or Protocol == "Haymaker" then -- Used to check which set of remote events should play. When doing basic striking, no animPair nor sentValue is sent in the parameters, unlike doing other misc. events, which is how we distinguish, splitting the events into two to make the code easier to understand.
       print("The attack is basic")
        -- print("Basic attack reached server.")
        ServerEvents.bAttackEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, nil, nil, plrIsBlocking, isAI) -- Will damage the hitCharacter on the server, as well as sending the other player a remote event to make their character react to the hit.
    else
        print("Misc. action reached server. The protocol: " .. tostring(Protocol))
        ServerEvents.miscEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI) -- Will execute misc things such as parrying and sync block damage.
    end

    print(Protocol)
end)

Players.PlayerAdded:Connect(function(player)
    print("player added")
    ServerInit.InitializePlayer(player)
    local playerVelocities = RagdollSystem.InitializePlayer() -- from the .InitializePlayer()

    if player.Character then -- There is a known issue in roblox where characters won't trigger the .CharacterAdded event the first time they spawn in because they are loaded before the script can process it.
        
        print("Char added!")
        ServerInit.InitializeCharacter(player.Character)
        RagdollSystem.InitializeCharacter(playerVelocities[1], playerVelocities[2], player.Character) -- because playerVelocities equals the returned value of .InitializePlayer() (linear and angular were returned in a table), we will referance those variables via table index. Then we add the current char to the function for referancing them.
    end

    player.CharacterAdded:Connect(function(char)
        print("Character has been added")
        -- Initialize character-related stuff on spawn.
        ServerInit.InitializeCharacter(char)
        RagdollSystem.InitializeCharacter(playerVelocities[1], playerVelocities[2], char) -- because playerVelocities equals the returned value of .InitializePlayer() (linear and angular were returned in a table), we will referance those variables via table index. Then we add the current char to the function for referancing them.
    end)

end)