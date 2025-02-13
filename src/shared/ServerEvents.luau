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

local function isCounterTrackPlaying(animator) --[[Function used to check if a counter animation track is playing. If it is, then we don't want the player taking damage after they counter someone.]]

	local playingTracks = animator:GetPlayingAnimationTracks()
	for _, v in pairs(playingTracks) do
		if v.Animation:GetAttribute("Counter") and v.Animation:GetAttribute("AttackLevel") == 3 then
			print("Enemy is countering. NO damage allowed guys.")
			return true
		end
	end
	return false
end

local function getPlayerInstance(plrName)
	--[[ Returns the playerInstance of a given player ]]

	for _, v in pairs(ServerInit.playerInstances) do
		if v.Name == plrName .. "_Instance" then
			return v
		end
	end
	print("No such player found ::((")
	return nil
end

-- bAttack function handlers:

local function attackHandler(sendingPlayer, hitCharacter, currentAttack, plrIsBlocking, enemyInstance, isAI) --[[ handles when a character lands an attack ]]
	
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)

	if not enemyInstance.iFrames and (not isCounterTrackPlaying(hitCharacter.Humanoid.charAnimator) or not enemyInstance.currentAttack) then
		local otherProtocol = "Receive"
		if hitPlayer then
			GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, otherProtocol)
		elseif hitCharacter then
			isAI = true
			GlobalRemoteEvent:FireClient(sendingPlayer, currentAttack, otherProtocol, nil, nil, isAI)
		end

		task.wait(0.1) -- give the server enough time to retrieve the enemy's current attack.. if any.
		enemyInstance = getPlayerInstance(hitPlayer.Name) -- table that holds public variables for the server to see and use

		if plrIsBlocking then
			attackDamage = attackDamage/2
		end
		if attackDamage and not isCounterTrackPlaying(hitCharacter.Humanoid.charAnimator) then
			hitPlayer.Character.Humanoid.Health -= attackDamage
		end
	end
end



-- miscEvent function handlers:

local function syncBlockHandler(hitCharacter, plrIsBlocking)
	attackDamage = syncBlockDamage
	if plrIsBlocking then
		attackDamage = attackDamage/2
	end
	hitCharacter.Humanoid.Health -= attackDamage
end

local function attackStartHoldBlockHandler(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, isAI, playerInstance)
	if currentAttack then
		playerInstance.currentAttack = currentAttack -- We send the current animation track the player is doing to check if its a counter so the player wont be damaged
	end

	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)

	if hitPlayer then -- then we are attacking a player, not an AI.
		GlobalRemoteEvent:FireClient(hitPlayer, nil, Protocol, animPair, sentValue, isAI)

	elseif hitCharacter then -- Then its not a player we're attacking, but an AI
		GlobalRemoteEvent:FireClient(sendingPlayer, nil, Protocol, animPair, sentValue, isAI)
	end
end

local function changeVariableHandler(hitCharacter, currentAttack, playerInstance)
	warn("changing a var")
		--[[ This protocol means we want to change a variable in the player's 
		playerInstance table because its lives in the server and is not accessible to 
		the client ]]

		local desiredVariableName = hitCharacter --[[ We pass the variable name in the 
		hitCharacter spot so we dont have a million parameters and save space. But in 
		this case hitCharacter is NOT actually a character.]]
		local newValue = currentAttack -- Same thing above but for the value itself we want the new variable to be

		playerInstance[desiredVariableName] = newValue
end


function ServerEvents.bAttackEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, _, _, plrIsBlocking, isAI) -- bAttack stands for basic attack.
	--[[This function is for the events of a player damaging another with a basic strike.]]

	-- GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
	local enemyInstance = getPlayerInstance(hitPlayer.Name) -- table that holds public variables for the server to see and use

	if currentAttack and currentAttack:GetAttribute("AttackLevel") == 1 then
		attackDamage = A1Damage
		elseif currentAttack and currentAttack:GetAttribute("AttackLevel") == 2 then
			attackDamage = A2Damage
		end

	if Protocol == "Hook" or Protocol == "Haymaker" then -- We're basically making sure the enemy is not countering the player here. enemyInstance is a table that includes the enemy's current attacking animation track. We don't want them taking damage if they are countering.
		attackHandler(sendingPlayer, hitCharacter, currentAttack, plrIsBlocking, enemyInstance, isAI)
	end
end


function ServerEvents.miscEvents(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
	 --[[ For misc. events that are sent for server-sided things such as
	      synced blocks, parrying, countering etc. ]]
	local hitPlayer -- the player which was struck. If it was sent then the 'if' statement below will identify them

	local playerInstance = getPlayerInstance(sendingPlayer.Name) -- table that holds public variables for the server to see and use
	local enemyInstance

	if typeof(hitCharacter) == "Instance" then -- making sure hitCharacter is an object before passing it on to find a player match
		hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
		enemyInstance = getPlayerInstance(hitPlayer.Name)
	end	  
	

	if Protocol == "SyncedBlock" then
		syncBlockHandler(hitCharacter, plrIsBlocking)
	
	elseif Protocol == "AttackStarted" or Protocol == "HoldingBlock" then
		attackStartHoldBlockHandler(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, isAI, playerInstance)

	elseif Protocol == "AttackFrames" then
		playerInstance.isGettingHit = true
		print(playerInstance.isGettingHit)
	elseif Protocol == "AttackEnded" then
		playerInstance.currentAttack = nil -- When the attack ends, we want the currentAttack to be nothing so the player can be damaged again after being able to counter, as the counter window finished and they cant no more.
		playerInstance.isGettingHit = false
		print(playerInstance.isGettingHit)
	elseif Protocol == "Parry" then
		attackDamage = attackDamage/2
		hitCharacter.Humanoid.Health -= attackDamage
		warn(tostring(hitPlayer) .. " has been parried!")
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
					
	elseif Protocol == "Counter" then
		warn(tostring(Protocol) .. " by " .. tostring(sendingPlayer))
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
	
	elseif Protocol == "CounterAttack" then
		warn(Protocol)
		hitCharacter.Humanoid.Health -= counterAttackDamage

	elseif Protocol == "setPlayerVariable" then
		changeVariableHandler(hitCharacter, currentAttack, playerInstance)

	elseif Protocol == "dodge" then
		print("dodging")
		--[[ When a character dodges another, make sure they cant do anything for a 
			 short period so a dodge attack can happen, if desired. ]]
		if enemyInstance then
			warn("Enemy Instance!")
			enemyInstance.canAttack = false
			task.wait(3)
			enemyInstance.canAttack = true
		end

	end
	attackDamage = nil
end



function ServerEvents.RFInvokes(sendingPlayer, Protocol, object1)
	if Protocol == "getPlayerInstance" then
		local plrName = object1
        print(sendingPlayer, Protocol, object1)
		return getPlayerInstance(plrName)
    end
end

return ServerEvents