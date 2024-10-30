--local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

local ServerEvents = {}

-- Damage types:
local A1Damage = 5 -- default damage for lvl 1 attacks
local A2Damage = 11 -- default damage for lvl 2 attacks
local syncBlockDamage = 2.5 -- damage for sync blocks
local counterAttackDamage = 8
local attackDamage = nil -- How much damage the player's current attack will do. If the enemy isn't blocking, it will just equal the attack damage of whatever category the player's attack is in. If they are blocking, this will divide it.

function ServerEvents.bAttackEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, _, _, plrIsBlocking, isAI) -- bAttack stands for basic attack. This function is for the events of a player damaging another with a basic strike.
	-- GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
	
	if currentAttack and currentAttack:GetAttribute("AttackLevel") == 1 then
		attackDamage = A1Damage
		elseif currentAttack and currentAttack:GetAttribute("AttackLevel") == 2 then
			attackDamage = A2Damage
		end
		
	if Protocol == "Hook" or Protocol == "Haymaker" then
		local otherProtocol = "Receive"
		if hitPlayer then
			GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, otherProtocol)
			elseif hitCharacter then
				isAI = true
				GlobalRemoteEvent:FireClient(sendingPlayer, currentAttack, otherProtocol, nil, nil, isAI)
			end
	end
	if Protocol == "Hook" then -- do Hook-worthy damage
	-- attackDamage = A1Damage
	if plrIsBlocking then
		attackDamage = attackDamage/2
		print("bracing block absorbed some damage")
	end
	hitPlayer.Character.Humanoid.Health -= attackDamage
	elseif Protocol == "Haymaker" then
		-- attackDamage = A2Damage
		if plrIsBlocking then
			attackDamage = attackDamage/2
		end
		hitPlayer.Character.Humanoid.Health -= attackDamage
	end
end


function ServerEvents.miscEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI) -- For misc. events that are sent for server-sided things such as synced blocks, parrying, countering etc.
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
	
	if Protocol == "SyncedBlock" then
		attackDamage = syncBlockDamage
		if plrIsBlocking then
			attackDamage = attackDamage/2
		end
		hitCharacter.Humanoid.Health -= attackDamage
	elseif Protocol == "AttackStarted" or Protocol == "HoldingBlock" then
		if hitPlayer then
			GlobalRemoteEvent:FireClient(hitPlayer, nil, Protocol, animPair, sentValue, isAI)
			elseif hitCharacter then -- Then its not a player we're attacking, but an AI
			GlobalRemoteEvent:FireClient(sendingPlayer, nil, Protocol, animPair, sentValue, isAI)
		end
	elseif Protocol == "Parry" then
		print("Protocol is indeed parry, by server!")
		attackDamage = attackDamage/2
		hitCharacter.Humanoid.Health -= attackDamage
		warn(tostring(hitPlayer) .. " has been parried!")
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
	
	elseif Protocol == "Counter" then
		print("Somebody got countered ooooohhhh")
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
	elseif Protocol == "CounterAttack" then
		hitCharacter.Humanoid.Health -= counterAttackDamage
		print("Counter attack dmg!")
	end
	attackDamage = nil
		-- end)
end
		
return ServerEvents