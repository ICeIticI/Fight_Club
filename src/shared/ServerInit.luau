--[[  ]]


local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local GlobalRemoteEvent = Instance.new("RemoteEvent") -- used by each client in a server for communication with server-client or client to server
GlobalRemoteEvent.Name = "GlobalRemoteEvent"
GlobalRemoteEvent.Parent = game.ReplicatedStorage

local GlobalRemoteFunction = Instance.new("RemoteFunction") -- used for similar reasons as the GlobalRemoteEvent, but used when we want something returned
GlobalRemoteFunction.Name = "GlobalRemoteFunction"
GlobalRemoteFunction.Parent = game.ReplicatedStorage


-- Creating specific remote events/functions for client-server communication:

local input_check_EVENT = Instance.new("RemoteEvent")
input_check_EVENT.Name = "input_check_EVENT"
input_check_EVENT.Parent = game.ReplicatedStorage

local ServerInit = {}


ServerInit.playerInstances = {} -- Making this a module variable so ServerEvents can access this when it needs to get playerInstances

local function newPlayer(plr)
	--[[Function that holds public variables for the player, that the server
	    will be able to see and check when it needs.]]
		
	local self = {}

	self.Name = plr.Name .. "_Instance"
	self.currentAttack = "" -- the current attack is the animation (not the track) of what the player's currently doing in the attack
	self.iFrames = false -- Bool that determines whether or not the player can be damaged
	self.isGettingHit = false -- Bool that gets set to true when the player is currently under an attack
	self.isDodging = false -- Bool that is set to true when the player is dodging. So when an enemy attacks, and tries to attack again at the player, and if they're dodging, they won't be able to.
	-- self.canAttack = true -- Bool that is true when the player is allowed to attack. Useful to disable when the player is not allowed to attack on their next attack
	self.enemyCFrame = 0 -- The CFrame of the enemy when the enemy attacks the player
	self.canCounter = false -- bool that determines if a player will counter the next attack done by an enemy.

	print("Instance for " .. tostring(plr.Name) .. " has been created.")
	return self
end

local function createHitbox(player, bodyPart) --[[ Function that will create a hitbox of a given part for a given player ]]

	local character = player.Character

	local hitbox = Instance.new("Part")
	hitbox.Name = player.Name.."_hitbox" .. bodyPart.Name:gsub(" ", "") -- Find any spaces in the part name and get rid of them. Say a part like 'Right Leg', it will turn into 'RightLeg'
	hitbox.Position = bodyPart.Position
	hitbox.CanCollide = false
	hitbox.Transparency = 1
	hitbox:SetAttribute("AttackDirection", "Right")
	hitbox:SetAttribute("ReceiveBox", true)
	-- hitbox.Parent = character:WaitForChild(hbFolder.Name)
	local hitbox_Weld = Instance.new("Weld")
	hitbox_Weld.Part0  = hitbox
	hitbox_Weld.Part1 = bodyPart
	hitbox_Weld.Parent = character
	
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

function ServerInit.InitializePlayer(player)
	--[[ Initializes a player when one joins the game ]]

	local playerInstance = newPlayer(player) -- newPlayer() is returned a table of public variables of the player
	table.insert(ServerInit.playerInstances, playerInstance) -- add the specific playerInstance table to the rest of the public playerInstance tables

	local plrObjectsFolder = Instance.new("Folder") -- folder containing the public objects of the player
	plrObjectsFolder.Name = player.Name .. "_GameObjects"
	plrObjectsFolder.Parent = player

    -- local LocalBindableEvent = Instance.new("BindableEvent")
    -- LocalBindableEvent.Name = "LocalBindableEvent"
    -- LocalBindableEvent.Parent = game.ReplicatedStorage
	
	-- Animation defining:
	for _, v in pairs(AnimationInstances) do
		local clonedAnim = v:Clone()
		clonedAnim.Parent = plrObjectsFolder
	end
end

function ServerInit.InitializeCharacter(character)
	--[[ Sets up various things for the specific player character such as hitboxes, 
	     the player animator ]]

	local player = game.Players:GetPlayerFromCharacter(character)

	character.Humanoid.WalkSpeed = 12
	character.Humanoid.JumpPower = 0

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
	linearVelocity.Parent = character.HumanoidRootPart
	
	local lvAttachment = Instance.new("Attachment")
	lvAttachment.Name = "lvAttachment"
	-- lvAttachment.CFrame = CFrame.Angles(0, math.rad(90), 0)
	lvAttachment.Parent = character.HumanoidRootPart

	linearVelocity.Attachment0 = lvAttachment
		

	local charAnimator = Instance.new("Animator")
	charAnimator.Name = "charAnimator"
	charAnimator.Parent = character:WaitForChild("Humanoid")
	
	-- Defining the hitboxes when character spawns
	local hbFolder = Instance.new("Folder") --[[ folder to store hitboxes to prevent false 
	   referances of player objects. ]]
	hbFolder.Name = player.Name.."_hitboxesFolder"
	hbFolder.Parent = character

	disableDefaultTouchDetections(character)
	
	local hitboxHead = createHitbox(player, character:WaitForChild("Head"))
	hitboxHead.Parent = character:WaitForChild(hbFolder.Name)
	
	local hitboxLeftArm = createHitbox(player, character:WaitForChild("Left Arm"))
	hitboxLeftArm.Parent = character:WaitForChild(hbFolder.Name)
	
	local hitboxRightArm = createHitbox(player, character:WaitForChild("Right Arm"))
	hitboxRightArm.Parent = character:WaitForChild(hbFolder.Name)
	
	local hitboxLeftLeg = createHitbox(player, character:WaitForChild("Left Leg"))
	hitboxLeftLeg.Parent = character:WaitForChild(hbFolder.Name)
	
	local hitboxRightLeg = createHitbox(player, character:WaitForChild("Right Leg"))
	hitboxRightLeg.Parent = character:WaitForChild(hbFolder.Name)
	
	local hitboxTorso = createHitbox(player, character:WaitForChild("Torso"))
	hitboxTorso.Parent = character:WaitForChild(hbFolder.Name)
end

return ServerInit