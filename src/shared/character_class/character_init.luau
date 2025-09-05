local Character_Init = {}
Character_Init.__index = Character_Init

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)
local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)
local Animation_Centric = require(game.ReplicatedStorage.Shared.animation_centric)
local ragdollFunction = require(game.ReplicatedStorage.Shared.ragdollFunction)
local utilities = require(game.ReplicatedStorage.Shared.utilities)

local function createHitbox(bodyPart, characterInstance) --[[ Function that will create a hitbox of a given part for a given player ]]

	local char = bodyPart.Parent

	local hitbox = Instance.new("Part")
	hitbox.Name = char.Name.."_hitbox" .. bodyPart.Name:gsub(" ", "") -- Find any spaces in the part name and get rid of them. Say a part like 'Right Leg', it will turn into 'RightLeg'
	hitbox.Position = bodyPart.Position
	hitbox.CanCollide = false
	hitbox.Transparency = 1
	hitbox:SetAttribute("AttackDirection", "Right")
	hitbox:SetAttribute("ReceiveBox", true)
	-- hitbox.Parent = character:WaitForChild(hbFolder.Name)
	local hitbox_Weld = Instance.new("Weld")
	hitbox_Weld.Part0  = hitbox
	hitbox_Weld.Part1 = bodyPart
	hitbox_Weld.Parent = char
	
	if bodyPart.Name == "Head" then
		hitbox.Size = Vector3.new(1.2,1.22,1.2)
		hitbox:SetAttribute("ReceiveBox", true)
	elseif bodyPart.Name == "Torso" then
		hitbox.Size = Vector3.new(2,2,1)
		hitbox:SetAttribute("ReceiveBox", true)
	elseif bodyPart.Name == "Left Arm" then
		hitbox.Size = Vector3.new(1,2,1)
		hitbox:SetAttribute("AttackDirection", "Left")
		hitbox:SetAttribute("ReceiveBox", true) -- while the left and right arm hitboxes are attackboxes, they are used in sync blocking where the enemy attacks it, so its in some cases a receivebox.
	elseif bodyPart.Name == "Right Arm" then
		hitbox.Size = Vector3.new(1,2,1)
		hitbox:SetAttribute("AttackDirection", "Right")
		hitbox:SetAttribute("ReceiveBox", true)
	elseif bodyPart.Name == "Left Leg" or bodyPart.Name == "Right Leg" then
		hitbox.Size = Vector3.new(1,2,1)
		hitbox:SetAttribute("AttackDirection", "forward")
	end

	if hitbox:GetAttribute("AttackDirection") then -- add it to the attack hitboxes folder if its an attack hitbox
		table.insert(characterInstance.attackHitboxes, hitbox)
	end

	task.wait()
	return hitbox
end

local function disableDefaultTouchDetections(givenChar) --[[ This function will go through the given character and disable the .Touched connections for their baseparts such as their head, arms, etc. Without doing this, the hitboxes maually added wont work well.]]
	for _, child in pairs(givenChar:GetChildren()) do
		if child:IsA("BasePart") then
			child.CanTouch = false
		end
	end
end

local function createBaseValue(characterInstance, name, value)
	local newBaseValue = Instance.new("NumberValue")
	newBaseValue.Name = name
	newBaseValue.Value = value
	newBaseValue.Parent = characterInstance.finalStatValuesFolder

	return newBaseValue
end

function Character_Init.init(charModel, data)

	while not charModel.Humanoid do task.wait() end -- makes sure the humanoid gets created before going through with the init
    local characterInstance = {}

	characterInstance.initialized = false -- bool that identifies whether or not the characterInstance finished it's init.

    -- define public variables here that the Character will have:
    
    characterInstance.id = nil -- the ID is how the server will identify which character this is when we need to retrieve it from the characters table.
    characterInstance.character = charModel
	characterInstance.humanoid = characterInstance.character:WaitForChild("Humanoid")
	characterInstance.humanoidRootPart = characterInstance.character:WaitForChild("HumanoidRootPart")
    characterInstance.player = game.Players:GetPlayerFromCharacter(charModel) -- If the character is a player, their player object will be stored here.
	characterInstance.plrObjectsFolder = characterInstance.player:WaitForChild(characterInstance.player.Name .. "_GameObjects")
	
	-- if not characterInstance.statMultipliers then
	-- 	characterInstance.statMultipliers = {
	-- 		MaxHealth_Multiplier = {defaultMultiplier = 1},
			
	-- 		A1Damage_Multiplier = {defaultMultiplier = 1},
	-- 		A2Damage_Multiplier = {defaultMultiplier = 1},
	-- 		syncBlockDamage_Multiplier = {defaultMultiplier = 1},
	-- 		counterAttackDamage_Multiplier = {defaultMultiplier = 1},
			
	-- 		pairedChainMAX_Multiplier = {defaultMultiplier = 1},
	-- 		escapeGrappleProgressPower_Multiplier = {defaultMultiplier = 1},
	-- 		staminaDrainRate_Multiplier = {defaultMultiplier = 1},
	-- 		staminaRegenRate_Multiplier = {defaultMultiplier = 1},
	-- 		BlockAbsorption_Multiplier = {defaultMultiplier = 1},
	-- 		attackSpeed_Multiplier = {defaultMultiplier = 1}, -- increase to make attacks faster
	-- 		HealthRegen_Multiplier = {defaultMultiplier = 1},
	-- 	}
	-- end
	
	characterInstance.statMultipliers = data.statMultipliers -- folder of stats that multiply together to get a result for player stats

	-- need to define this in case moduleTbl in animationCentric is run on server for an npc, which requires the use of this variable found in ClientVariables:
	characterInstance.finalStatValuesFolder = characterInstance.player:WaitForChild(characterInstance.player.Name .. "_GameObjects"):WaitForChild("baseValues")

	characterInstance.finalStatValues = {}
	for _, baseValue in pairs(characterInstance.statMultipliers:GetChildren()) do
		print(baseValue, baseValue:GetAttributes())
		characterInstance.finalStatValues[string.gsub(baseValue.Name, "_Multiplier", "")] = createBaseValue(characterInstance, string.gsub(baseValue.Name, "_Multiplier", ""), utilities.multiplyTableValuesTogether(baseValue:GetAttributes()))
	end

	characterInstance.proxyTable_finalStatValues = {} -- Everytime a stat gets changed, we'll apply it to the character via proxy table, since there are no metamethods for updating an existing value
	setmetatable(characterInstance.proxyTable_finalStatValues, {
		__newindex = function(_, i, v)
			-- here we apply the stat change to the character. And we won't use rawset so it can be changed again. We wont actually store data in this table.
			if i == "MaxHealth" then
				characterInstance.humanoid[i] = characterInstance.originalMaxHealth * v
				print(characterInstance.humanoid.MaxHealth)
			-- else
			-- 	characterInstance[i]*= v
			end
		end
	})

	characterInstance.previousHealth = characterInstance.humanoid.Health -- This var is used to determine how much damage the character takes.
	characterInstance.lockOnDebounce = characterInstance.plrObjectsFolder:FindFirstChild("lockOnDebounce") -- attemps to find lockOnDebounce. If it doesn't exist, then this var will be nil.
	characterInstance.movingDirection = characterInstance.plrObjectsFolder:FindFirstChild("movingDirection")
	
	if not characterInstance.lockOnDebounce then
		characterInstance.lockOnDebounce = Instance.new("BoolValue") -- shouldn't this be initialized by the server for more security?
		characterInstance.lockOnDebounce.Name = "lockOnDebounce"
		characterInstance.lockOnDebounce.Parent = characterInstance.plrObjectsFolder
	end

	if not characterInstance.movingDirection then
		characterInstance.movingDirection = Instance.new("StringValue")
		characterInstance.movingDirection.Name = "movingDirection"
		characterInstance.movingDirection.Parent = characterInstance.plrObjectsFolder
	end

	characterInstance.lockOnDebounce.Value = false

	local connects = {}

	connects.isAttackingConnect = nil

	characterInstance.hitDebounce = {} -- Dictates whether or not we can take damage. This will ideally be a table of characters who hit us, and their name gets removed after their attack is finished.
	characterInstance.hitDebounce_metatable = {


		__newindex = function(t, i, v) -- runs when a table value gets changed that does NOT exist
			if v == true then
				
				rawset(t, i, v)

				local isAttacking = characters:GetCharacterObjectById(i).isAttacking
				connects.isAttackingConnect = isAttacking:GetPropertyChangedSignal("Value"):Connect(function()
					rawset(t, i, nil)
				end)
				
			-- elseif v == false then
			-- 	rawset(t, i, nil)
			end
		end
		}

	setmetatable(characterInstance.hitDebounce, characterInstance.hitDebounce_metatable)
	
	characterInstance.isBlocking = false -- set to true when the client blocks
	characterInstance.isAttacking = Instance.new("BoolValue")
	characterInstance.isAttacking.Value = false
	characterInstance.isCountering = false
	characterInstance.isGettingHit = false
	characterInstance.waitingToAttack = false
	characterInstance.pairedPlaying = false -- used to make sure the paired animations don't play while already playing.
	characterInstance.canSyncBlock = true
	characterInstance.previousWalkSpeed = nil
	characterInstance.didFollowUp = false -- when true, the character did a followup attack

	characterInstance.attackFrames = false -- when the StartOfAttack marker fires in attack anims, this allows damage to pass

	characterInstance.isDodging = false
	characterInstance.canFollowUp = false -- The status of whether a player is able to do a followup attack. If its true, then that means they are able to do one. 
	characterInstance.isEnemyHoldingBlock = false -- for attacks to be synched attacks when blocked in a synched block.
	characterInstance.followUpCount = 0 -- followUpCount is used so a followup wont be done twice back to back when a follow up is done
	characterInstance.lastAttackTrack = nil
	characterInstance.comboCounter = 0
	
	characterInstance.currentAttack_trackData = nil										
	characterInstance.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim
	characterInstance.attackSeries = nil
	-- self.randAttack = nil
	characterInstance.distanceBetween = nil
	characterInstance.enemyHumanoid = nil -- pre-defined enemy Humanoid because the script hates global variables. Used for the enemy.
	characterInstance.enemyChar = nil

	characterInstance.attackerCFrame = nil -- When the character gets struck, this variable will equal the CFrame of the attacker's HumanoidRootPart so we can move the character a direction if the hit is significant
	-- ClientVariables.enemyCurrentAttack = nil -- used when the enemy would start an attack via the AttackStarted protocol that gets sent when one starts
	characterInstance.randLvl1Type = nil --[[ Used to determine what lvl 1 attacks
						the player will use for said combo ]]
	characterInstance.animPair = nil
	characterInstance.dodgeAttackTrack = nil

	-- -- New Variables that are replacing old:
	-- self.canAttack = false
	-- self.canGetHit = false
	-- self.areLockedOn = false
	-- -- Above are new variables that will be replacing old ^

	characterInstance.pairedAttack = nil -- the variable for which paired attack the attacker is doing
	characterInstance.pairedBlock = nil -- the variable for which paired block the attacker is doing
	characterInstance.pairedChain = 0 -- The tracker of the character's sync block attack chain. They can only do as many as the max allows
	characterInstance.pairedChainMAX = 3 -- The max value for pairedChain.
	characterInstance.originalMaxHealth = 100

	characterInstance.character.Humanoid.MaxHealth = characterInstance.originalMaxHealth * characterInstance.finalStatValues.MaxHealth.Value
	characterInstance.character.Humanoid.WalkSpeed = 12
	characterInstance.character.Humanoid.JumpPower = 0
	characterInstance.character.Humanoid.MaxSlopeAngle = 40 -- reducing this from 89 so they cant climb well. Will mean they will slip off cliffs if they get too close

	-- "Variable" variables; these values will differ per fighter class the character chooses:
	characterInstance.escapeGrappleProgressPower = 5 -- How much progress the character has to escaping a grapple each time input is pressed. For NPCs, this will be autonomously applied

	characterInstance.previousWalkSpeed = nil -- will be set when we need to know the last known WalkSpeed of the player
	characterInstance.originalWalkSpeed = characterInstance.humanoid.WalkSpeed
	characterInstance.lockOnSpeed = characterInstance.originalWalkSpeed / 1.85 -- change denominator as needed

	-- Stamina management:

	characterInstance.maxStamina = characterInstance.plrObjectsFolder:FindFirstChild("maxStamina") or (function()
		characterInstance.maxStamina = Instance.new("NumberValue") -- the maximum stamina of the character. This value will likely change depending on what abilities the character has that grant them more or less stamina
		characterInstance.maxStamina.Name = "maxStamina"
		characterInstance.maxStamina.Value = 100
		characterInstance.maxStamina.Parent = characterInstance.plrObjectsFolder
		return characterInstance.maxStamina
	end)()

	characterInstance.stamina = characterInstance.plrObjectsFolder:FindFirstChild("stamina") or (function()
		characterInstance.stamina = Instance.new("NumberValue") -- the stamina of the player. If they get 0 they wont be able to block or parry
		characterInstance.stamina.Name = "stamina"
		characterInstance.stamina.Value = characterInstance.maxStamina.Value -- start out with max stamina
		characterInstance.stamina.Parent = characterInstance.plrObjectsFolder
		return characterInstance.stamina
	end)()


	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Enabled = false
	linearVelocity.Name = "FC_LinearVelocity"
	linearVelocity.Visible = false
	linearVelocity.VectorVelocity = Vector3.new(0,0,0)
	linearVelocity.ForceLimitsEnabled = true
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = Vector3.new(math.huge, 0, math.huge)
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.Parent = characterInstance.character.HumanoidRootPart
	
	local lvAttachment = Instance.new("Attachment")
	lvAttachment.Name = "lvAttachment"
	-- lvAttachment.CFrame = CFrame.Angles(0, math.rad(90), 0)
	-- lvAttachment.CFrame = CFrame.new(0,0,-3) * CFrame.Angles(0,math.rad(180),0)
	lvAttachment.Parent = characterInstance.character.HumanoidRootPart

	linearVelocity.Attachment0 = lvAttachment

	characterInstance.grapplePart = Instance.new("Part")
	characterInstance.grapplePart.Name = "grapplePart"
	characterInstance.grapplePart.Size = Vector3.new(1,1,1)
	characterInstance.grapplePart.Transparency = 1
	characterInstance.grapplePart.CFrame = lvAttachment.CFrame 
	characterInstance.grapplePart.CanCollide = false
	characterInstance.grapplePart.CanTouch = false
	characterInstance.grapplePart.CanQuery = false

	local grapplePartConnector = Instance.new("Motor6D") -- keeps the grapplePart from moving from the front of the character
	grapplePartConnector.Name = "grapplePartConnector"
	grapplePartConnector.Part0 = characterInstance.grapplePart
	grapplePartConnector.Part1 = characterInstance.humanoidRootPart
	grapplePartConnector.C1 = lvAttachment.CFrame * CFrame.new(0,0,-3) * CFrame.Angles(0, math.rad(180), 0)
	grapplePartConnector.Parent = characterInstance.grapplePart

	characterInstance.grapplePart.Parent = characterInstance.humanoidRootPart

	-- local charAnimator = Instance.new("Animator")
	-- charAnimator.Name = "charAnimator"
	-- charAnimator.Parent = characterInstance.character:WaitForChild("Humanoid")

    -- Defining the hitboxes when character spawns
	local hbFolder = Instance.new("Folder") --[[ folder to store hitboxes to prevent false 
	   referances of player objects. ]]
	hbFolder.Name = characterInstance.character.Name.."_hitboxesFolder"
	hbFolder.Parent = characterInstance.character

	characterInstance.attackHitboxes = {} -- table that stores the data for the attack hitboxes

	disableDefaultTouchDetections(characterInstance.character)
	
	local hitboxHead = createHitbox(characterInstance.character:WaitForChild("Head"), characterInstance)
	hitboxHead.Parent = characterInstance.character:WaitForChild(hbFolder.Name)
	local hitboxLeftArm = createHitbox(characterInstance.character:WaitForChild("Left Arm"), characterInstance)
	hitboxLeftArm.Parent = characterInstance.character:WaitForChild(hbFolder.Name)
	local hitboxRightArm = createHitbox(characterInstance.character:WaitForChild("Right Arm"), characterInstance)
	hitboxRightArm.Parent = characterInstance.character:WaitForChild(hbFolder.Name)
	local hitboxLeftLeg = createHitbox(characterInstance.character:WaitForChild("Left Leg"), characterInstance)
	hitboxLeftLeg.Parent = characterInstance.character:WaitForChild(hbFolder.Name)
	local hitboxRightLeg = createHitbox(characterInstance.character:WaitForChild("Right Leg"), characterInstance)
	hitboxRightLeg.Parent = characterInstance.character:WaitForChild(hbFolder.Name)
	local hitboxTorso = createHitbox(characterInstance.character:WaitForChild("Torso"), characterInstance)
	hitboxTorso.Parent = characterInstance.character:WaitForChild(hbFolder.Name)

	-- Global Remote Event - Because each player having their own remote event is redundant.
	characterInstance.GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")
	-- Global Remote Function - Like the Global Remote Event, but used when we specifically want something returned
	characterInstance.GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

	characterInstance.LocalBindableEvent = game.ReplicatedStorage:FindFirstChild("LocalBindableEvent") or (function()
		characterInstance.LocalBindableEvent = Instance.new("BindableEvent")
		characterInstance.LocalBindableEvent.Name = "LocalBindableEvent"
		characterInstance.LocalBindableEvent.Parent = game.ReplicatedStorage
	end)()
	function characterInstance.boolCheck(boolTable) --[[ Function that will check the given boolean values. If any of them are true, then this will return false. If none of them are true, then this will return true. ]]
		local trueBoolTbl = {} -- Table that will store bools that are true, which will mean the boolCheck failed

		for i, v in pairs(boolTable) do
			if v == true then
				table.insert(trueBoolTbl, v)
				warn("boolCheck failed for " .. tostring(characterInstance.character.Name) .. ": " .. tostring(i) .. " is true.")
			end
		end

		if next(trueBoolTbl) == nil then -- if we don't find anything in the trueBoolTbl, then all the bools given are false. Therefore, return true
			-- if none of the bools are currently active (true) then the desired action can be completed as it won't interrupt any other action, so we return function as true.
			return true
		else
			return false
		end
	end

	function characterInstance.randomAnimation(animFolder, attribuesAndValuesTable) --[[ Will return a randomly-picked animation from a given table. You can put in attributes to filter what kind of animation you want.]]

		--[[ 
		attributesAndValuesTable will be a dictionary with the index being 
		the attribute name and the value being what it should equal. 
		For example:

		{AnimDirection = "Right", Paired = true,}

		^ These are the attributes we want as well as the values we want them to equal.

		]]

    	local randAttackTbl = {}

		-- Microsoft Copilot AI-altered my old code to make it work:

		for _, animation in pairs(animFolder) do
			local matchesAll = true -- ✅ Track whether all attributes match
			
			if attribuesAndValuesTable then -- if you dont put in a table of attributes and values, then every single animation in the given table will be considered in the randomization
				for attribute, value in pairs(attribuesAndValuesTable) do
					local attrValue = animation:GetAttribute(tostring(attribute))
	
					-- ✅ Ensure all attributes match
					if (value and attrValue ~= value) or (not value and not attrValue) then
						matchesAll = false -- 🚫 Mark as a mismatch
						break -- ✅ Exit the attribute loop early
					end
				end
			end
			
			-- ✅ Add animation only if all attributes matched
			if matchesAll then
				table.insert(randAttackTbl, animation)
			end
		end

		-- Microsoft Copilot AI-altered my old code to make it work ^

		if not next(randAttackTbl) then -- No matches were found with the specified attributes
			return warn("No animation tracks found with the specified parameters, and therefore no animation was randomly picked. Check your given attributes to see if your desired animations have them.")
		end

		return randAttackTbl[math.random(1, #randAttackTbl)] -- returns the randomly-selected animation track
	end

	function characterInstance.SetSpeed(bool) -- Function that manages the character speed based on the character circumstances. Adding 'true' into the parameter will allow the character to move while adding 'false' will not allow movement.
		characterInstance.speedSet = false -- A status variable. When true, it means the character's speed was set. This is useful so when we use .repositionInFrontOfEnemy, they wont be able to move cause we'll wait till this variable is true before proceeding with that strand of code.
		if bool == true then
			-- we allow the player the ability to move

			if characterInstance.pairedPlaying == false and characterInstance.lockOnDebounce.Value then -- if the player isn't in a paired animation, then

				if not characterInstance.isBlocking then
					characterInstance.previousWalkSpeed = characterInstance.lockOnSpeed
				elseif characterInstance.isBlocking then
					characterInstance.previousWalkSpeed = characterInstance.lockOnSpeed / 1.5
				end

				characterInstance.humanoid.WalkSpeed = characterInstance.previousWalkSpeed
			else
				characterInstance.humanoid.WalkSpeed = characterInstance.originalWalkSpeed
			end

		elseif bool == false then
			-- we take the player's ability to move away
			characterInstance.humanoid.WalkSpeed = 0
		end
		characterInstance.speedSet = true
	end

	function characterInstance.reset() --[[ Will set variables of the player back to what they were origianlly, giving the player their default controls back. ]]--
		characterInstance.isDodging = false
		characterInstance.isBlocking = false
		characterInstance.isCountering = false
		characterInstance.isGettingHit = false
		
		characterInstance.canFollowUp = false
		characterInstance.didFollowUp = false
		
		-- characterInstance.hitDebounce = {}
		-- setmetatable(characterInstance.hitDebounce_metatable) --re-applying the metatable after clearing the table so it can be given back its metatable functionality.
		
		characterInstance.attackFrames = false
		characterInstance.waitingToAttack = false
		
		
		-- if (self.attackTrack and not self.attackTrack.IsPlaying) or (self.pairedAttack and not self.pairedAttack.IsPlaying) then
			-- self.attackTrack = nil
			-- self.currentAttack = nil
		characterInstance.followUpCount = 0
		characterInstance.comboCounter = 0
		characterInstance.isAttacking.Value = false
		characterInstance.BlockStartAnimPlaying = false
		characterInstance.canSyncBlock = true
		characterInstance.pairedPlaying = false
		characterInstance.pairedChain = 0

		characterInstance.isInSecureGrapple = false
        characterInstance.isInGrappleSuccess = false
		characterInstance.nextInput = nil

		-- end
		-- if self.currentReceiveAnimTRACK and not self.currentReceiveAnimTRACK.IsPlaying then
		-- 	self.currentReceiveAnimTRACK = nil
		-- 	self.pairedChain = 0
		-- end
		-- ClientVariables.animPair = nil

		characterInstance.SetSpeed(true)

	end


	function characterInstance:setLinearVelocity(sentVelocity, sentDuration)
		task.spawn(function() -- this function should not halt the script
			characterInstance.humanoidRootPart:WaitForChild("FC_LinearVelocity").VectorVelocity = sentVelocity
			characterInstance.humanoidRootPart.FC_LinearVelocity.Enabled = true
			task.wait(sentDuration) -- Character will be under said force till duration ends.
	
			characterInstance.humanoidRootPart.FC_LinearVelocity.VectorVelocity = Vector3.zero
			characterInstance.humanoidRootPart.FC_LinearVelocity.Enabled = false
		end)
	end

	function characterInstance.repositionInFrontOfEnemy(sentCharacter) --[[ repositions the character in front of the enemy. ]]
		if not sentCharacter then 
			sentCharacter = characterInstance.enemyChar -- sentCharacter is a newer feature added to this function. Before adding enemyChar would be used, so to still support that code, we'll just set enemyChar to sentCharacter
		end
		
		characterInstance.character:WaitForChild("HumanoidRootPart").CFrame = 
		CFrame.new(sentCharacter:WaitForChild("HumanoidRootPart").Position 
					+ sentCharacter.HumanoidRootPart.CFrame.LookVector * 3 
					, sentCharacter.HumanoidRootPart.Position)
	end

	-- Damage types:
	local baseA1Damage = 7 -- default damage for lvl 1 attacks
	local baseA2Damage = 14 -- default damage for lvl 2 attacks
	local baseSyncBlockDamage = 3.5 -- damage for sync blocks
	local baseCounterAttackDamage = 10
	characterInstance.attackDamage = nil -- How much damage the player's current attack will do. If the enemy isn't blocking, it will just equal the attack damage of whatever category the player's attack is in. If they are blocking, this will divide it.

	local sound1, sound2, sound3 = 
	"rbxassetid://9118617342",
	"rbxassetid://82209688846366",
	"rbxassetid://5507815764"

	local tempHitSFXTable = {
		sound1, sound2, sound3
	}
	function characterInstance.setupHitSFX()
		characterInstance.hitSFX = characterInstance.characterInstance.character.Torso:FindFirstChild("hitSFX")
		if not characterInstance.hitSFX or not characterInstance.hitSFX.SoundId then
			characterInstance.hitSFX = Instance.new("Sound")
			characterInstance.hitSFX.Name = "hitSFX"

			if characterInstance.currentAttack_trackData and characterInstance.currentAttack_trackData.attackLvl == 1 then
				characterInstance.hitSFX.SoundId = tempHitSFXTable[math.random(1, #tempHitSFXTable)]
			elseif characterInstance.currentAttack_trackData and characterInstance.currentAttack_trackData.attackLvl == 2 then
				characterInstance.hitSFX.SoundId = "rbxassetid://112444846023457"
			else
				characterInstance.hitSFX.SoundId = math.random(1, #tempHitSFXTable)
				task.wait()
			end
		end
	end

	function characterInstance:setupAttackDamage(trackData)
		if not trackData then return warn("No trackData provided to the :setupAttackDamage function: ", trackData) end

		-- for animations that have multiple points of damage (such as repeatedly hitting the enemy in the animation):
		local damageDivider = trackData.Animation:GetAttribute("DamageDivider")
		if not damageDivider then -- if we dont have multiple hits in our animation, then no division is needed. Do full damage on that one hit
			damageDivider = 1
		end
		-- ideally, if there are, say 3 hits in an animation, we'll divide the damage by 3 so after the 3 hits we'll do the same damage as if it were only 1 hit.

		if trackData.attackLvl == 1 then
			return (baseA1Damage * characterInstance.finalStatValues.A1Damage.Value) / damageDivider
		elseif trackData.attackLvl == 2 then
			return (baseA2Damage * characterInstance.finalStatValues.A2Damage.Value) / damageDivider
		elseif trackData.Counter_Attribute or trackData.DodgeAttack_Attribute then
			return (baseCounterAttackDamage * characterInstance.finalStatValues.counterAttackDamage.Value) / damageDivider
		elseif trackData.Animation:GetAttribute("SyncBlockFinisher") == true or trackData.Animation:GetAttribute("SyncBlockFinisher") == false then
			return (baseSyncBlockDamage * characterInstance.finalStatValues.syncBlockDamage.Value) / damageDivider
		elseif trackData.attackLvl == 3 then
			-- want them to have 0.1 health by the last hit of the execution before the game kills them for ragdoll:
			return (self.enemyChar.Humanoid.Health / damageDivider) - (0.1/damageDivider) -- we deal as much damage to the enemy as they have health remaining, since it's an execution. We subtract 0.1 so it doesn't ACTUALLY kill them or set their health to 0 since when their health is 0 they ragdoll and that ruins the execution
		end

		return warn("No attack damage found with the given data:", trackData)
	end

	function characterInstance.manageAnimation(trackData)
		task.spawn(function()
			
			local AnimType = trackData.Animation:GetAttribute("AnimType")
	
			if AnimType and AnimType == 1 then
				characterInstance.attack_animation_manager:runOnIsPlaying(trackData)
			elseif AnimType and AnimType == 2 then
				characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
			else
				characterInstance.misc_animation_manager:runOnIsPlaying(trackData)
			end
		end)
	end
	
	function characterInstance.simulateIsPlayingOfLastData(bool) --[[ Will turn the IsPlaying data of the previous attack & receive datas to a given bool, probably to false since we wanna turn off the last animations ]]
		if characterInstance.lastAttackData then
			characterInstance.lastAttackData.IsPlaying = bool
		end
		if characterInstance.lastReceiveData then
			characterInstance.lastReceiveData.IsPlaying = bool
		end
	end


	local hitCacheTable = {}
	for _ = 1, 3 do -- caching 3 different sounds so in quick progression of gettin hit, the SFX wont just cut, which would be noticeable
		local newSound = Instance.new("Sound")
		newSound.Name = "hitSFX"
		newSound.Parent = characterInstance.character.Torso
		table.insert(hitCacheTable, newSound)
	end

	local SFXTable = {
		"rbxassetid://9118617342",
		"rbxassetid://82209688846366",
		"rbxassetid://5507815764"
	}

	function characterInstance.playHitSFX(trackData)
		local soundId
		if trackData.type == "Level1"
		or trackData.Paired_Attribute
		or (trackData.type and trackData.type == "Parry") -- parrys should have their own special SFX at some point
		then
			soundId = SFXTable[math.random(1, #SFXTable)]
		elseif trackData.type == "Level2" then
			soundId = "rbxassetid://112444846023457"
		end

		if not soundId then 
			warn("Current trackData: ")
			return error("playHitSFX function: The specified attack level of the given trackData isn't specified to get a sound for the hit SFX.") 
		end
		
		local i, sfx = next(hitCacheTable)
		sfx.SoundId = soundId
		sfx:Play()
		-- Removing & re-inserting the sound object into the table pushes it to the end so it doesn't get drawn back-to-back on SFX plays:
		table.remove(hitCacheTable, i)
		table.insert(hitCacheTable, sfx)
	end

	
	function characterInstance.setCharacterMassless(character, bool)
		for _, child in pairs(character:GetChildren()) do
			if child:IsA("BasePart") then
				child.Massless = bool
			end
		end
	end

	-- AI-Altered code by Microsoft Copilot:
	connects.MoveDirectionConnection = nil
	connects.MoveDirectionConnection = characterInstance.humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		local root = characterInstance.character:WaitForChild("HumanoidRootPart")
		local moveDir = characterInstance.humanoid.MoveDirection

		local frontVector = root.CFrame.LookVector
		local rightVector = root.CFrame.RightVector -- the right side of where the character's facing

		local frontDot = moveDir:Dot(frontVector)
		local rightDot = moveDir:Dot(rightVector) -- rightDotProduct, like forwardDotProduct, will return a value it compares from the right side of where the character's facing. > 0 is right, < 0 is left.

		if rightDot > 0.5 and frontDot > -0.5 then -- 0.5 makes our range of momentum we consider right, left, etc more strict than 0, otherwise every little movement in a direction will make the movingDirection that direction. We dont want unintentional direction momentum.
			characterInstance.movingDirection.Value = "right"
		elseif rightDot < -0.5 and frontDot > -0.5 then
			characterInstance.movingDirection.Value = "left"
		elseif frontDot < -0.5 then
			characterInstance.movingDirection.Value = "backwards"
		elseif frontDot > 0.5 then
			characterInstance.movingDirection.Value = "forwards"
		else
			characterInstance.movingDirection.Value = "none"
		end
	end)
	-- AI-Altered code by Microsoft Copilot ^

	local deadState = Instance.new("BoolValue")
	deadState.Name = "deadState"
	deadState.Value = false
	deadState.Parent = characterInstance.humanoid

	connects.deadStateConnect = nil
	connects.deadStateConnect = characterInstance.humanoid.StateEnabledChanged:Connect(function(stateType, stateEnabled)
		if stateType ~= Enum.HumanoidStateType.Dead then return end -- make sure we're working with the Dead state type
		-- characterInstance.GlobalRemoteEvent:FireAllClients("updateMyDeadState", {humanoid = characterInstance.humanoid, stateEnabled = stateEnabled})
		deadState.Value = stateEnabled
	end)

	connects.lockOnConnect = nil
	connects.lockOnConnect = characterInstance.lockOnDebounce:GetPropertyChangedSignal("Value"):Connect(function()

		characterInstance.SetSpeed(true)
		-- Turn off AutoRotate if we're locked on, and vice versa:
		characterInstance.humanoid.AutoRotate = not characterInstance.lockOnDebounce.Value


		if characterInstance.lockOnDebounce.Value == true then
			-- built-in enemyChar-retrieving code if we dont have enemyChar yet:
			if not characterInstance.enemyChar then
				if not characterInstance.raycastInstance then return error("No enemychar nor raycastInstance. Are you even locked-on?") end
				
				if characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model"):FindFirstChildWhichIsA("Humanoid") then
                	characterInstance.enemyChar = characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model")
				else
					error({"No humanoid found with the given raycastInstance: ", characterInstance.raycastInstance, "their parent:", characterInstance.raycastInstance.Parent})
            	end
			end
			
        	characterInstance.enemyHumanoidRootPart = characterInstance.enemyChar:WaitForChild("HumanoidRootPart")
			characterInstance.enemyHumanoid = characterInstance.enemyChar.Humanoid

		else
			characterInstance.reset()
			characterInstance:block(false)
		end
		print("sending lock-on signal")
		utilities.sendLockOnSignal(characterInstance)

	end)

	-- local fallDamageConnection

	connects.DiedConnection = nil
	connects.DiedConnection = characterInstance.humanoid.Died:Connect(function()

		if characterInstance.attackingChar and game.Players:GetPlayerFromCharacter(characterInstance.attackingChar) then
			local killerInstance = characters:GetCharacterObjectByCharacter(characterInstance.attackingChar)
			
			killerInstance.player.leaderstats.Tokens.Value += 2
			killerInstance.player.leaderstats.Takedowns.Value += 1
			
			-- Will regen health if they got perk(s) equipped for it
			killerInstance.humanoid.Health += killerInstance.humanoid.MaxHealth * killerInstance.finalStatValues.HealthRegen.Value
		end
		-- characterInstance.humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true) -- To trigger the StateEnabledChange event, which fires only when the :SetStateEnabled method is used.
		
		-- connects.MoveDirectionConnection:Disconnect()
		-- connects.MoveDirectionConnection = nil
		
		
		-- connects.isAttackingConnect:Disconnect()
		-- connects.isAttackingConnect = nil
		
		-- connects.lockOnConnect:Disconnect()
		-- connects.lockOnConnect = nil
		-- warn(connects.lockOnConnect)

		for _, connection in pairs(connects) do
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
		
		setmetatable(characterInstance.hitDebounce, nil)
		
		task.delay(0.5, function()
			deadState.Value = true
			connects.deadStateConnect:Disconnect()
			connects.deadStateConnect = nil
		end)
		
		-- connects.DiedConnection:Disconnect()
		-- connects.DiedConnection = nil
	end)

	-- Fall damage:
	-- local minYVelocity = 20 -- minimum velocity to start taking damage
	-- local maxYVelocity = 90 -- highest velocity to take damage. If they go faster, they'll just die

	-- local previousYVelocity = 0

	local ragdollYPos = 80 -- if their Y pos go below this point then they ragdoll
	local deathYPos = 30

	local moneyCount = 0 -- variable that goes up 1 every 0.1 second until 2 minutes reaches, then it rewards the player with money, and resets.
	local minutesUntilToken = 2
	task.spawn(function()
		-- Real fall damage:
		while characterInstance.humanoid.Health > 0 do
				task.wait(0.1)

				if characterInstance.player then
					moneyCount += 1
	
					if moneyCount >= (minutesUntilToken * 60) / 0.1 then
						characterInstance.player.leaderstats.Tokens.Value += 1
						moneyCount = 0
					end
				end

			-- 	local newYVelocity = -characterInstance.humanoidRootPart.Velocity.Y
			-- 	if newYVelocity <= 0 and previousYVelocity <= 0 then continue end
				
			-- 	print("we falling!!!!!", newYVelocity, previousYVelocity)
			-- 	if (previousYVelocity - newYVelocity) > minYVelocity then -- we hard-stopped landed and had some velocity prior. We landed.
			-- 		-- We landed
			-- 		if previousYVelocity > maxYVelocity then
			-- 			print("kill shot")
			-- 			-- characterInstance.humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			-- 			-- characterInstance.humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			-- 			-- characterInstance.humanoid.MaxHealth = 0
			-- 			characterInstance.humanoid.Health = 0
			-- 			-- print("Dead Enabled:", characterInstance.humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead))
			-- 		elseif previousYVelocity > minYVelocity then
			-- 			local fallDamage = newYVelocity - minYVelocity * 1.5
			-- 			characterInstance.humanoid.Health -= fallDamage
			-- 		end
			-- 	end
			-- 	previousYVelocity = newYVelocity
			
			-- Simulated fall damage (if their Y coordinate is low then they ragdoll and die):
			if characterInstance.humanoidRootPart.CFrame.Y < ragdollYPos then
				characterInstance.lockOnDebounce.Value = false
				characterInstance.humanoid.PlatformStand = true
				ragdollFunction.ragdoll(characterInstance.character, characterInstance.id, true)
			end
			if characterInstance.humanoidRootPart.CFrame.Y < deathYPos then
				characterInstance.humanoid.PlatformStand = false
				characterInstance.humanoid.Health = 0
				break
			end
		end

	end)

	-- Putting animations into tables to easily pull from them when needed without having a bunch of attributes for each animation for distinction:
	-- AT stands for Animation Table

	characterInstance.AT_GrabAttacks = {AnimationInstances.FC_GrabAttack1, AnimationInstances.FC_GrabAttack2, AnimationInstances.FC_GrabAttack3}
	characterInstance.AT_GrabExecutions = {AnimationInstances.FC_GrabExecute1, AnimationInstances.FC_GrabExecute2}

	
	if characterInstance.player ~= nil then
		characterInstance.GlobalRemoteFunction:InvokeClient(characterInstance.player, "createAnimationTracks")
	else -- not a player. We wanna create animations on server
		Animation_Centric.initialize_animations(Character_Init)
	end


	-- pcall(function()
	-- 	if characterInstance.character:FindFirstChild("Animator") then		
	-- 		characterInstance.character.Humanoid.Animator:Destroy()
	-- 	end
	-- end)


    return characterInstance
end

return Character_Init