local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")
-- local GlobalBindableEvent = game.ReplicatedStorage:WaitForChild("GlobalBindableEvent")

GlobalRemoteEvent.OnServerEvent:Connect(function(_, hitPlayer, Protocol, currentAttackID, animPair, pairedChain)
	
	if Protocol == "Hook" or Protocol == "Haymaker" then
		local otherProtocol = "Receive"
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttackID, otherProtocol)
	end
	if Protocol == "Hook" then -- do Hook-worthy damage
	hitPlayer.Character.Humanoid.Health -= 5
	elseif Protocol == "Haymaker" then
	hitPlayer.Character.Humanoid.Health -= 11
	elseif Protocol == "AttackStarted" or Protocol == "HoldingBlock" then
		GlobalRemoteEvent:FireClient(hitPlayer, nil, Protocol, animPair, pairedChain)
	end
end)