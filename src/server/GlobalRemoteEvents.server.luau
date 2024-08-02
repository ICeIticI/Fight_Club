--local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

GlobalRemoteEvent.OnServerEvent:Connect(function(_, hitPlayer, Protocol, currentAttackID, animPair, sentValue)
	if Protocol == "Hook" or Protocol == "Haymaker" then
		local otherProtocol = "Receive"
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttackID, otherProtocol)
	end
	if Protocol == "Hook" then -- do Hook-worthy damage
	hitPlayer.Character.Humanoid.Health -= 5
	elseif Protocol == "Haymaker" then
	hitPlayer.Character.Humanoid.Health -= 11
	elseif Protocol == "SyncedBlock" then
		hitPlayer.Character.Humanoid.Health -= 2.5
	elseif Protocol == "AttackStarted" or Protocol == "HoldingBlock" then
		print(sentValue)
		GlobalRemoteEvent:FireClient(hitPlayer, nil, Protocol, animPair, sentValue)
	end
end)