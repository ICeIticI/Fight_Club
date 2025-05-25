local Character_Init = {}
Character_Init.__index = Character_Init

local Animation_Centric = require(game.ReplicatedStorage.Shared.animation_management.animation_centric)


local function createHitbox(bodyPart) --[[ Function that will create a hitbox of a given part for a given player ]]

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

function Character_Init.init(charModel)
    local self = {}

    -- define public variables here that the Character will have:
    
    self.id = nil -- the ID is how the server will identify which character this is when we need to retrieve it from the characters table.
    self.character = charModel
	self.humanoid = self.character:WaitForChild("Humanoid")
	self.humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
    self.player = game.Players:GetPlayerFromCharacter(charModel) -- If the character is a player, their player object will be stored here.

	self.plrObjectsFolder = self.player:WaitForChild(self.player.Name .. "_GameObjects")
	
	self.previousHealth = self.humanoid.Health -- This var is used to determine how much damage the character takes.
	self.lockOnDebounce = self.plrObjectsFolder:FindFirstChild("lockOnDebounce") -- attemps to find lockOnDebounce. If it doesn't exist, then this var will be nil.

	if not self.lockOnDebounce then
		self.lockOnDebounce = Instance.new("BoolValue") -- shouldn't this be initialized by the server for more security?
		self.lockOnDebounce.Name = "lockOnDebounce"
		self.lockOnDebounce.Parent = self.plrObjectsFolder
	end

	self.hitDebounce = false -- if false, then the player has the ability to deal damage. This is so the player won't hit the enemy multiple times in one attack.
	self.isBlocking = false -- set to true when the client blocks
	self.isAttacking = false
	self.isCountering = false
	self.isGettingHit = false
	self.waitingToAttack = false
	self.pairedPlaying = false -- used to make sure the paired animations don't play while already playing.
	self.canSyncBlock = true
	self.previousWalkSpeed = nil
	self.didFollowUp = false -- when true, the character did a followup attack

	self.attackFrames = false -- when the StartOfAttack marker fires in attack anims, this allows damage to pass

	self.isDodging = false
	self.canFollowUp = false -- The status of whether a player is able to do a followup attack. If its true, then that means they are able to do one. 
	self.isEnemyHoldingBlock = false -- for attacks to be synched attacks when blocked in a synched block.
	self.followUpCount = 0 -- followUpCount is used so a followup wont be done twice back to back when a follow up is done
	self.lastAttack = nil
	self.comboCounter = 0
	
	self.currentAttack = nil										
	self.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim
	self.attackSeries = nil
	-- self.randAttack = nil
	self.distanceBetween = nil
	self.enemyHumanoid = nil -- pre-defined enemy Humanoid because the script hates global variables. Used for the enemy.
	self.enemyChar = nil

	self.attackerCFrame = nil -- When the character gets struck, this variable will equal the CFrame of the attacker's HumanoidRootPart so we can move the character a direction if the hit is significant
	-- ClientVariables.enemyCurrentAttack = nil -- used when the enemy would start an attack via the AttackStarted protocol that gets sent when one starts
	self.randLvl1Type = nil --[[ Used to determine what lvl 1 attacks
						the player will use for said combo ]]
	self.animPair = nil
	self.dodgeAttackTrack = nil

	-- -- New Variables that are replacing old:
	-- self.canAttack = false
	-- self.canGetHit = false
	-- self.areLockedOn = false
	-- -- Above are new variables that will be replacing old ^

	self.pairedAttack = nil -- the variable for which paired attack the attacker is doing
	self.pairedBlock = nil -- the variable for which paired block the attacker is doing
	self.pairedChain = 0 -- The tracker of the character's sync block attack chain. They can only do as many as the max allows
	self.PairedChainMAX = 3 -- The max value for pairedChain.
	
	self.character.Humanoid.WalkSpeed = 12
	self.character.Humanoid.JumpPower = 0

	self.previousWalkSpeed = nil -- will be set when we need to know the last known WalkSpeed of the player
	self.originalWalkSpeed = self.humanoid.WalkSpeed
	self.lockOnSpeed = self.originalWalkSpeed / 1.85

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
	linearVelocity.Parent = self.character.HumanoidRootPart
	
	local lvAttachment = Instance.new("Attachment")
	lvAttachment.Name = "lvAttachment"
	-- lvAttachment.CFrame = CFrame.Angles(0, math.rad(90), 0)
	lvAttachment.Parent = self.character.HumanoidRootPart

	linearVelocity.Attachment0 = lvAttachment
		

	local charAnimator = Instance.new("Animator")
	charAnimator.Name = "charAnimator"
	charAnimator.Parent = self.character:WaitForChild("Humanoid")

    -- Defining the hitboxes when character spawns
	local hbFolder = Instance.new("Folder") --[[ folder to store hitboxes to prevent false 
	   referances of player objects. ]]
	hbFolder.Name = self.character.Name.."_hitboxesFolder"
	hbFolder.Parent = self.character

	disableDefaultTouchDetections(self.character)
	
	local hitboxHead = createHitbox(self.character:WaitForChild("Head"))
	hitboxHead.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxLeftArm = createHitbox(self.character:WaitForChild("Left Arm"))
	hitboxLeftArm.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxRightArm = createHitbox(self.character:WaitForChild("Right Arm"))
	hitboxRightArm.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxLeftLeg = createHitbox(self.character:WaitForChild("Left Leg"))
	hitboxLeftLeg.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxRightLeg = createHitbox(self.character:WaitForChild("Right Leg"))
	hitboxRightLeg.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxTorso = createHitbox(self.character:WaitForChild("Torso"))
	hitboxTorso.Parent = self.character:WaitForChild(hbFolder.Name)

	-- Global Remote Event - Because each player having their own remote event is redundant.
	self.GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")
	-- Global Remote Function - Like the Global Remote Event, but used when we specifically want something returned
	self.GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

	self.LocalBindableEvent = Instance.new("BindableEvent")
	self.LocalBindableEvent.Name = "LocalBindableEvent"
	self.LocalBindableEvent.Parent = game.ReplicatedStorage

	function self.setSpeed(bool) -- Function that manages the character speed based on the character circumstances. Adding 'true' into the parameter will allow the character to move while adding 'false' will not allow movement.
		if bool == true then
		-- we allow the player the ability to move
		
			if self.pairedPlaying == false and self.lockOnDebounce.Value then -- if the player isn't in a paired animation, then
			
				if not self.isBlocking then
					self.previousWalkSpeed = self.lockOnSpeed
				elseif self.isBlocking then
					self.previousWalkSpeed = self.lockOnSpeed / 1.5
				end
					
				self.humanoid.WalkSpeed = self.previousWalkSpeed
			else
				self.humanoid.WalkSpeed = self.originalWalkSpeed
			end

		elseif bool == false then
			-- we take the player's ability to move away
			self.humanoid.WalkSpeed = 0
		end
	end
	
	function self.boolCheck(boolTable) --[[ Function that will check the given boolean values. If any of them are true, then this will return false. If none of them are true, then this will return true. ]]
		local trueBoolTbl = {} -- Table that will store bools that are true, which will mean the boolCheck failed

		for i, v in pairs(boolTable) do
			if v == true then
				table.insert(trueBoolTbl, v)
				warn("boolCheck failed: ".. tostring(i) .. " is true.")
			end
		end

		if next(trueBoolTbl) == nil then -- if we don't find anything in the trueBoolTbl, then all the bools given are false. Therefore, return true
			-- if none of the bools are currently active (true) then the desired action can be completed as it won't interrupt any other action, so we return function as true.
			return true
		else
			return false
		end

	end

	function self.SetSpeed(bool) -- Function that manages the character speed based on the character circumstances. Adding 'true' into the parameter will allow the character to move while adding 'false' will not allow movement.
		if bool == true then
			print("giving back speed")
			-- we allow the player the ability to move

			if self.pairedPlaying == false and self.lockOnDebounce.Value then -- if the player isn't in a paired animation, then

				if not self.isBlocking then
					self.previousWalkSpeed = self.lockOnSpeed
				elseif self.isBlocking then
					self.previousWalkSpeed = self.lockOnSpeed / 1.5
				end

				self.humanoid.WalkSpeed = self.previousWalkSpeed
			else
				self.humanoid.WalkSpeed = self.originalWalkSpeed
			end

		elseif bool == false then
			print("taking away speed")
			-- we take the player's ability to move away
			self.humanoid.WalkSpeed = 0
		end
	end

	function self.reset() --[[ Will set variables of the player back to what they were origianlly, giving the player their default controls back. ]]--
		self.isDodging = false
		self.isCountering = false
		self.isGettingHit = false
		
		self.canFollowUp = false
		self.hitDebounce = false
		self.attackFrames = false
		self.waitingToAttack = false
		
		
		-- if (self.attackTrack and not self.attackTrack.IsPlaying) or (self.pairedAttack and not self.pairedAttack.IsPlaying) then
			-- self.attackTrack = nil
			-- self.currentAttack = nil
		self.followUpCount = 0
		self.comboCounter = 0
		self.isAttacking = false
		self.canSyncBlock = true
		self.pairedPlaying = false
		self.pairedChain = 0
		-- end
		-- if self.currentReceiveAnimTRACK and not self.currentReceiveAnimTRACK.IsPlaying then
		-- 	self.currentReceiveAnimTRACK = nil
		-- 	self.pairedChain = 0
		-- end
		-- ClientVariables.animPair = nil

		self.SetSpeed(true)

	end


	function self.setLinearVelocity(sentVelocity, sentDuration)

		self.character.HumanoidRootPart:WaitForChild("FC_LinearVelocity").VectorVelocity = sentVelocity
		self.character.HumanoidRootPart.FC_LinearVelocity.Enabled = true
		task.wait(sentDuration) -- Character will be under said force till duration ends.

		self.character.HumanoidRootPart.FC_LinearVelocity.VectorVelocity = Vector3.zero
		self.character.HumanoidRootPart.FC_LinearVelocity.Enabled = false

	end

	function self.playReceivingTrack() --[[ After we define an animation track to play in response to an enemy action, this will play said track. ]]
		if self.currentReceiveAnimTRACK then -- play receive animation
			self.currentReceiveAnimTRACK:Play()

			-- reposition the player to face the enemy if they counter them (not a parry)
			if self.currentReceiveAnimTRACK.Animation:GetAttribute("Counter") and not (self.currentReceiveAnimTRACK == self.FC_RightParryTRACK or self.currentReceiveAnimTRACK == self.FC_LeftParryTRACK) then
				self.repositionInFrontOfEnemy()
			end
    	end
	end

	-- Damage types:
	local A1Damage = 5 -- default damage for lvl 1 attacks
	local A2Damage = 11 -- default damage for lvl 2 attacks
	local syncBlockDamage = 2.5 -- damage for sync blocks
	-- local counterAttackDamage = 8
	self.attackDamage = nil -- How much damage the player's current attack will do. If the enemy isn't blocking, it will just equal the attack damage of whatever category the player's attack is in. If they are blocking, this will divide it.

	local sound1, sound2, sound3 = 
	"rbxassetid://9118617342",
	"rbxassetid://82209688846366",
	"rbxassetid://5507815764"

	local tempHitSFXTable = {
		sound1, sound2, sound3
	}
	function self.setupHitSFX()
		self.hitSFX = self.characterInstance.character.Torso:FindFirstChild("hitSFX")
		if not self.hitSFX or not self.hitSFX.SoundId then
			self.hitSFX = Instance.new("Sound")
			self.hitSFX.Name = "hitSFX"

			if self.currentAttack and self.currentAttack:GetAttribute("AttackLevel") == 1 then
				self.attackDamage = A1Damage
				self.hitSFX.SoundId = tempHitSFXTable[math.random(1, #tempHitSFXTable)]
			elseif self.currentAttack and self.currentAttack:GetAttribute("AttackLevel") == 2 then
				self.attackDamage = A2Damage
				self.hitSFX.SoundId = "rbxassetid://112444846023457"
			else
				self.hitSFX.SoundId = math.random(1, #tempHitSFXTable)
				task.wait()
			end
		end
	end

	function self.setupAttackDamage(attacker_characterInstance)
		if attacker_characterInstance.currentAttack:GetAttribute("AttackLevel") == 1 then
			self.attackDamage = A1Damage
		elseif attacker_characterInstance.currentAttack:GetAttribute("AttackLevel") == 2 then
			self.attackDamage = A2Damage
		end
	end



	if self.player ~= nil then
		self.GlobalRemoteFunction:InvokeClient(self.player, "createAnimationTracks")
	else -- not a player. We wanna create animations on server
		Animation_Centric.initialize_animations(Character_Init)
	end

    return self
end

return Character_Init