local Character_Init = {}
Character_Init.__index = Character_Init

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

function Character_Init.init()
    local self = {}

    -- define public variables here that the Character will have:
    
    self.id = nil -- the ID is how the server will identify which character this is when we need to retrieve it from the characters table.
    self.player = nil -- If the character is a player, their player object will be stored here.
    self.character = self.player.Character

    self.character.Humanoid.WalkSpeed = 12
	self.character.Humanoid.JumpPower = 0

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
	hbFolder.Name = self.player.Name.."_hitboxesFolder"
	hbFolder.Parent = self.character

	disableDefaultTouchDetections(self.character)
	
	local hitboxHead = createHitbox(self.player, self.character:WaitForChild("Head"))
	hitboxHead.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxLeftArm = createHitbox(self.player, self.character:WaitForChild("Left Arm"))
	hitboxLeftArm.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxRightArm = createHitbox(self.player, self.character:WaitForChild("Right Arm"))
	hitboxRightArm.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxLeftLeg = createHitbox(self.player, self.character:WaitForChild("Left Leg"))
	hitboxLeftLeg.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxRightLeg = createHitbox(self.player, self.character:WaitForChild("Right Leg"))
	hitboxRightLeg.Parent = self.character:WaitForChild(hbFolder.Name)
	local hitboxTorso = createHitbox(self.player, self.character:WaitForChild("Torso"))
	hitboxTorso.Parent = self.character:WaitForChild(hbFolder.Name)

    return self
end

return Character_Init