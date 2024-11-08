--local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

local ServerEvents = {}

local ServerInit = require(game.ReplicatedStorage.Shared.ServerInit) -- we need to access playerInstances, which is defined in ServerInit, so we can use it here for specific playerInstances.

-- Damage types:
local A1Damage = 5 -- default damage for lvl 1 attacks
local A2Damage = 11 -- default damage for lvl 2 attacks
local syncBlockDamage = 2.5 -- damage for sync blocks
local counterAttackDamage = 8
local sentAttackTrack = nil
local attackDamage = nil -- How much damage the player's current attack will do. If the enemy isn't blocking, it will just equal the attack damage of whatever category the player's attack is in. If they are blocking, this will divide it.

local function isCounterTrackPlaying(animator)
	--[[Function used to check if a counter animation track is playing. If it is, then we don't want the player taking damage after they counter someone.]]
	warn(true)
	local playingTracks = animator:GetPlayingAnimationTracks()
	warn("Checking for counter tracks...")
	for _, v in pairs(playingTracks) do
		print(v.Animation)
		print(v.Animation:GetAttribute("AttackLevel"))
		if v.Animation:GetAttribute("Counter") and v.Animation:GetAttribute("AttackLevel") == 3 then
			print("Enemy is countering. NO damage allowed guys.")
			return true
		end
	end
	print("No counter attack anim is playing. The enemy may be damaged.")
	return false
end

local function getPlayerInstance(plr)
	for _, v in pairs(ServerInit.playerInstances) do
		if v.Name == plr.Name .. "_Instance" then
			warn(tostring(v.Name) .. " has been found. Adding them to playerInstance")
			return v
		end
	end
	print("No such player found ::((")
end

function ServerEvents.bAttackEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, _, _, plrIsBlocking, isAI) -- bAttack stands for basic attack. This function is for the events of a player damaging another with a basic strike.
	-- GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)

	if currentAttack and currentAttack:GetAttribute("AttackLevel") == 1 then
		attackDamage = A1Damage
		elseif currentAttack and currentAttack:GetAttribute("AttackLevel") == 2 then
			attackDamage = A2Damage
		end
		print("uhhhh" .. tostring(Protocol))

	if Protocol == "Hook" or Protocol == "Haymaker" then -- We're basically making sure the enemy is not countering the player here. enemyInstance is a table that includes the enemy's current attacking animation track. We don't want them taking damage if they are countering.
	
		local enemyInstance = getPlayerInstance(hitPlayer) -- table that holds public variables for the server to see and use
		-- if not enemyInstance.currentAttack then
		warn(true)
		if not isCounterTrackPlaying(hitCharacter.Humanoid.charAnimator) or not enemyInstance.currentAttack then
		warn(false)
		local otherProtocol = "Receive"
			if hitPlayer then
				GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, otherProtocol)
			elseif hitCharacter then
				isAI = true
				GlobalRemoteEvent:FireClient(sendingPlayer, currentAttack, otherProtocol, nil, nil, isAI)
			end

			wait(0.1) -- give the server enough time to retrieve the enemy's current attack.. if any.
			enemyInstance = getPlayerInstance(hitPlayer) -- table that holds public variables for the server to see and use
			print(ServerInit.playerInstances)
			print(enemyInstance)
			print(enemyInstance.currentAttack)

			if plrIsBlocking then
				attackDamage = attackDamage/2
			end
			if not enemyInstance.currentAttack and not isCounterTrackPlaying(hitCharacter.Humanoid.charAnimator) then
			hitPlayer.Character.Humanoid.Health -= attackDamage
			end
		end
	end
end


function ServerEvents.miscEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI) -- For misc. events that are sent for server-sided things such as synced blocks, parrying, countering etc.
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
	local playerInstance = getPlayerInstance(sendingPlayer) -- table that holds public variables for the server to see and use
	
	if Protocol == "SyncedBlock" then
		attackDamage = syncBlockDamage
		if plrIsBlocking then
			attackDamage = attackDamage/2
		end
		hitCharacter.Humanoid.Health -= attackDamage
	elseif Protocol == "AttackStarted" or Protocol == "HoldingBlock" then

		if currentAttack then
			playerInstance.currentAttack = currentAttack -- We send the current animation track the player is doing to check if its a counter so the player wont be damaged
			warn(playerInstance.currentAttack)
		end

		if hitPlayer then -- then we are attacking a player, not an AI.
			GlobalRemoteEvent:FireClient(hitPlayer, nil, Protocol, animPair, sentValue, isAI)
			elseif hitCharacter then -- Then its not a player we're attacking, but an AI
			GlobalRemoteEvent:FireClient(sendingPlayer, nil, Protocol, animPair, sentValue, isAI)
		end
	elseif Protocol == "AttackEnded" then
		playerInstance.currentAttack = nil -- When the attack ends, we want the currentAttack to be nothing so the player can be damaged again after being able to counter, as the counter window finished and they cant no more.
		print(playerInstance.currentAttack)
	elseif Protocol == "Parry" then
		attackDamage = attackDamage/2
		hitCharacter.Humanoid.Health -= attackDamage
		warn(tostring(hitPlayer) .. " has been parried!")
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
	
	elseif Protocol == "Counter" then
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
	elseif Protocol == "CounterAttack" then
		hitCharacter.Humanoid.Health -= counterAttackDamage
		print("Counter attack dmg!")
	end
	attackDamage = nil
end
		
return ServerEvents