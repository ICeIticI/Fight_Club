local Character_Init = {}
Character_Init.__index = Character_Init

local Animation_Init = require(game.ReplicatedStorage.Shared.animation_management.animation_init)

local GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

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
    self.player = game.Players:GetPlayerFromCharacter(charModel) -- If the character is a player, their player object will be stored here.

    self.character.Humanoid.WalkSpeed = 12
	self.character.Humanoid.JumpPower = 0

	self.plrObjectsFolder = self.player:WaitForChild(self.player.Name .. "_GameObjects")
	
	self.humanoid = self.character:WaitForChild("Humanoid")
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
	self.randAttack = nil
	self.distanceBetween = nil
	self.enemyHumanoid = nil -- pre-defined enemy Humanoid because the script hates global variables. Used for the enemy.
	self.enemyChar = nil

	self.attackerCFrame = nil -- When the character gets struck, this variable will equal the CFrame of the attacker's HumanoidRootPart so we can move the character a direction if the hit is significant
	-- ClientVariables.enemyCurrentAttack = nil -- used when the enemy would start an attack via the AttackStarted protocol that gets sent when one starts
	self.randLvl1Type = nil --[[ Used to determine what lvl 1 attacks
						the player will use for said combo ]]
	self.animPair = nil
	self.dodgeAttackTrack = nil

	-- New Variables that are replacing old:
	self.canAttack = false
	self.canGetHit = false
	self.areLockedOn = false
	-- Above are new variables that will be replacing old ^

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

	
	if self.player ~= nil then
		GlobalRemoteFunction:InvokeClient(self.player, "createAnimationTracks")
	else -- not a player. We wanna create animations on server
		Animation_Init.initialize_animations(Character_Init)
	end

    return self
end

return Character_Init