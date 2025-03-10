--local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

local ServerEvents = {}

local ServerInit = require(game.ReplicatedStorage.Shared.ServerInit) -- we need to access playerInstances, which is defined in ServerInit, so we can use it here for specific playerInstances.

-- Damage types:
local A1Damage = 5 -- default damage for lvl 1 attacks
local A2Damage = 11 -- default damage for lvl 2 attacks
local syncBlockDamage = 2.5 -- damage for sync blocks
local counterAttackDamage = 8
local attackDamage = nil -- How much damage the player's current attack will do. If the enemy isn't blocking, it will just equal the attack damage of whatever category the player's attack is in. If they are blocking, this will divide it.

local sound1, sound2, sound3 = 
	"rbxassetid://9118617342",
	"rbxassetid://82209688846366",
	"rbxassetid://5507815764"

local tempHitSFXTable = {
	sound1, sound2, sound3
}

local function isCounterTrackPlaying(animator) --[[Function used to check if a counter animation track is playing. If it is, then we don't want the player taking damage after they counter someone.]]

	local playingTracks = animator:GetPlayingAnimationTracks()
	for _, v in pairs(playingTracks) do
		if v.Animation:GetAttribute("Counter") and v.Animation:GetAttribute("AttackLevel") == 3 then
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
	local hitSFX = sendingPlayer.Character.Torso:FindFirstChild("hitSFX")
	
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
		enemyInstance.enemyCFrame = sendingPlayer.Character.HumanoidRootPart.CFrame -- We want to know where the enemy is when they hit us so we can repel the opposite direction
			
		if plrIsBlocking then
			attackDamage = attackDamage/2
		end

		if attackDamage and not isCounterTrackPlaying(hitCharacter.Humanoid.charAnimator) then
			hitPlayer.Character.Humanoid:TakeDamage(attackDamage)
			hitSFX:Play()
		end

	end
end



-- miscEvent function handlers:

local function syncBlockHandler(hitCharacter, plrIsBlocking, sentSFX)
	attackDamage = syncBlockDamage
	if plrIsBlocking then
		attackDamage = attackDamage/2
	end
	hitCharacter.Humanoid.Health -= attackDamage
	if sentSFX then
		sentSFX:Play()
		print("Playing SFX")
		sentSFX.SoundId = ""
	end
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

local function changeVariableHandler(hitCharacter, currentAttack, playerInstance) --[[ This protocol means we want to change a variable in the player's playerInstance table because its lives in the server and is not accessible to the client ]]

		local desiredVariableName = hitCharacter --[[ We pass the variable name in the 
		hitCharacter spot so we dont have a million parameters and save space. But in 
		this case hitCharacter is NOT actually a character.]]
		local newValue = currentAttack -- Same thing above but for the value itself we want the new variable to be

		playerInstance[desiredVariableName] = newValue
end


function ServerEvents.bAttackEvents(object1, object2, object3, object4, _, _, object5, object6) -- bAttack stands for basic attack.
	--[[This function is for the events of a player damaging another with a basic strike.]]
	local sendingPlayer = object1
	local hitCharacter = object2
	local Protocol = object3
	local currentAttack = object4
	local plrIsBlocking = object5
	local enemyCFrame = object6

	local hitSFX = sendingPlayer.Character.Torso:FindFirstChild("hitSFX")
	if not hitSFX then
		hitSFX = Instance.new("Sound")
		hitSFX.Name = "hitSFX"
	end
	hitSFX.Parent = sendingPlayer.Character.Torso

	-- GlobalRemoteEvent.OnServerEvent:Connect(function(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, plrIsBlocking, isAI)
	local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
	local enemyInstance = getPlayerInstance(hitPlayer.Name) -- table that holds public variables for the server to see and use

	if currentAttack and currentAttack:GetAttribute("AttackLevel") == 1 then
		attackDamage = A1Damage
		hitSFX.SoundId = tempHitSFXTable[math.random(1, #tempHitSFXTable)]
		elseif currentAttack and currentAttack:GetAttribute("AttackLevel") == 2 then
			attackDamage = A2Damage
			hitSFX.SoundId = "rbxassetid://112444846023457"
		end

	if Protocol == "Hook" or Protocol == "Haymaker" then -- We're basically making sure the enemy is not countering the player here. enemyInstance is a table that includes the enemy's current attacking animation track. We don't want them taking damage if they are countering.
		print(Protocol)
		attackHandler(sendingPlayer, hitCharacter, currentAttack, plrIsBlocking, enemyInstance, enemyCFrame)
	end
end


function ServerEvents.miscEvents(object1, object2, object3, object4, object5, object6, object7, object8)
	 --[[ For misc. events that are sent for server-sided things such as
	      synced blocks, parrying, countering etc. ]]
	local sendingPlayer = object1
	local hitCharacter = object2
	local Protocol = object3
	local currentAttack = object4
	local animPair = object5
	local sentValue = object6
	local plrIsBlocking = object7
	local isAI = object8

	local hitSFX = sendingPlayer.Character.Torso:FindFirstChild("hitSFX")
	if Protocol == "Parry" or Protocol == "CounterAttack" or Protocol == "SyncedBlock" then
		
		if not hitSFX or not hitSFX.SoundId then
			hitSFX = Instance.new("Sound")
			hitSFX.Name = "hitSFX"
			hitSFX.SoundId = math.random(1, #tempHitSFXTable)
			task.wait()
		end
	end

	local hitPlayer -- the player which was struck. If it was sent then the 'if' statement below will identify them

	local playerInstance = getPlayerInstance(sendingPlayer.Name) -- table that holds public variables for the server to see and use
	local enemyInstance

	if typeof(hitCharacter) == "Instance" then -- making sure hitCharacter is an object before passing it on to find a player match
		hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
		enemyInstance = getPlayerInstance(hitPlayer.Name)
	end	  
	

	if Protocol == "SyncedBlock" then
		syncBlockHandler(hitCharacter, plrIsBlocking, hitSFX)
	
	elseif Protocol == "AttackStarted" or Protocol == "HoldingBlock" then
		attackStartHoldBlockHandler(sendingPlayer, hitCharacter, Protocol, currentAttack, animPair, sentValue, isAI, playerInstance)

	elseif Protocol == "AttackFrames" then
		playerInstance.isGettingHit = true
	elseif Protocol == "AttackEnded" then
		playerInstance.currentAttack = nil -- When the attack ends, we want the currentAttack to be nothing so the player can be damaged again after being able to counter, as the counter window finished and they cant no more.
		playerInstance.isGettingHit = false
	elseif Protocol == "Parry" then
		attackDamage = attackDamage/2
		-- hitCharacter.Humanoid.Health -= attackDamage
		hitCharacter.Humanoid:TakeDamage(attackDamage)
		hitSFX:Play()
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
					
	elseif Protocol == "Counter" or Protocol == "dodgeAttack" then
		GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, Protocol)
	
	elseif Protocol == "CounterAttack" then
		-- hitCharacter.Humanoid.Health -= counterAttackDamage
		hitCharacter.Humanoid:TakeDamage(counterAttackDamage)
		hitSFX:Play()
	elseif Protocol == "setPlayerVariable" then
		changeVariableHandler(hitCharacter, currentAttack, playerInstance)

	elseif Protocol == "dodge" then
		--[[ When a character dodges another, make sure they cant do anything for a 
			 short period so a dodge attack can happen, if desired. ]]
		if enemyInstance then
			enemyInstance.canAttack = false
			task.wait(3)
			enemyInstance.canAttack = true
		end
	elseif Protocol == "SetLinearVelocity" then
		-- sentForce is a number
		local sentVelocity = hitCharacter -- takes the place of hitCharacter to save argument space
		local sentDuration = currentAttack
		
		sendingPlayer.Character.HumanoidRootPart:WaitForChild("FC_LinearVelocity").VectorVelocity = sentVelocity
		sendingPlayer.Character.HumanoidRootPart.FC_LinearVelocity.Enabled = true
		task.wait(sentDuration) -- Character will be under said force till duration ends.

		sendingPlayer.Character.HumanoidRootPart.FC_LinearVelocity.VectorVelocity = Vector3.zero
		sendingPlayer.Character.HumanoidRootPart.FC_LinearVelocity.Enabled = false

	elseif Protocol == "setCharacterCFrame" then
		local sentHRP = hitCharacter:WaitForChild("HumanoidRootPart")
		local sentCFrame = currentAttack

		sentHRP.CFrame = sentCFrame
	end
	-- attackDamage = nil
end



function ServerEvents.RFInvokes(object1, object2, object3)
	local sendingPlayer = object1
	local Protocol = object2

	if Protocol == "getPlayerInstance" then
		local plrName = object3
        -- print(sendingPlayer, Protocol, object1)
		return getPlayerInstance(plrName)
    end
end

return ServerEvents