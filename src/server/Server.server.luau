--[[
* This server script will act as a 'main' script for server-related activity
* It will rely on module scripts with different purposes to function when called upon.
]]

local Players = game.Players

local ServerEvents = require(game.ReplicatedStorage.Shared.ServerEvents)
local ServerInit = require(game.ReplicatedStorage.Shared.ServerInit)
local RagdollSystem = require(game.ReplicatedStorage.Shared.RagdollSystem)

local GlobalRemoteEvent = Instance.new("RemoteEvent")
GlobalRemoteEvent.Name = "GlobalRemoteEvent"
GlobalRemoteEvent.Parent = game.ReplicatedStorage

GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
    if animPair == nil or sentValue == nil then -- Used to check which set of remote events should play. When doing basic striking, no animPair nor sentValue is sent in the parameters, unlike doing other misc. events, which is how we distinguish, splitting the events into two to make the code easier to understand.
        ServerEvents.bAttackEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, nil, nil, plrIsBlocking, isAI) -- Will damage the hitCharacter on the server, as well as sending the other player a remote event to make their character react to the hit.
    else
        ServerEvents.miscEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI) -- Will execute misc things such as parrying and sync block damage.
    end
end)

Players.PlayerAdded:Connect(function(player)
    ServerInit.InitializePlayer(player)
    local playerVelocities = RagdollSystem.InitializePlayer() -- from the .InitializePlayer()

    player.CharacterAdded:Connect(function(char)
        RagdollSystem.InitializeCharacter(playerVelocities[1], playerVelocities[2], char) -- because playerVelocities equals the returned value of .InitializePlayer() (linear and angular were returned in a table), we will referance those variables via table index. Then we add the current char to the function for referancing them.
        ServerInit.InitializeCharacter(char)
    end)

end)