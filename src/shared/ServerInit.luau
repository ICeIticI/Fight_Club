-- local Players = game.Players
local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local GlobalRemoteEvent = Instance.new("RemoteEvent")
GlobalRemoteEvent.Name = "GlobalRemoteEvent"
GlobalRemoteEvent.Parent = game.ReplicatedStorage
local ServerInit = {}

ServerInit.playerInstances = {} -- Making this a module variable so ServerEvents can access this when it needs to get playerInstances

local function newPlayer(plr)
	--[[Function that holds public variables for the player, that the server will be able to see and check when it
		needs.]]
	local self = {}

	self.Name = plr.Name .. "_Instance"
	self.currentAttack = nil
	self.isGettingHit = false

	print("Instance for " .. tostring(plr.Name) .. " has been created.")
	return self
end

function ServerInit.InitializePlayer(player)
	local playerInstance = newPlayer(player)
	table.insert(ServerInit.playerInstances, playerInstance)
	print(playerInstance)
	print(playerInstance.Name)

	local plrObjectsFolder = Instance.new("Folder")
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
	local player = game.Players:GetPlayerFromCharacter(character)
		
	local charAnimator = Instance.new("Animator")
	charAnimator.Name = "charAnimator"
	charAnimator.Parent = character:WaitForChild("Humanoid")
	
	-- Defining the hitboxes when character spawns
	local hbFolder = Instance.new("Folder") --[[ folder to store hitboxes to prevent false referances of player
	   objects.
	]]
	hbFolder.Name = player.Name.."_hitboxesFolder"
	hbFolder.Parent = character
	
	-- ADD ATTRIBUTES to hitboxes to let client know it's a hitbox for when the player hits an enemy.
	local hitboxHead = Instance.new("Part")
	hitboxHead.Name = player.Name.."_hitboxHead"
	hitboxHead.Position = character:WaitForChild("Head").Position
	
	hitboxHead.Size = Vector3.new(1.2,1.22,1.2)
	hitboxHead.CanCollide = false
	hitboxHead.Transparency = 0.5 -- Set to fully transparent when ready to launch
	hitboxHead:SetAttribute("ReceiveBox", true)
	hitboxHead.Parent = character:WaitForChild(hbFolder.Name)
	local headWeld = Instance.new("Weld")
	headWeld.Part0 = hitboxHead
	headWeld.Part1 = character.Head
	headWeld.Parent = hitboxHead
	
	
	local hitboxLeftArm = Instance.new("Part")
	hitboxLeftArm.Name = player.Name.."_hitboxLeftArm"
	hitboxLeftArm.Position = character:WaitForChild("Left Arm").Position
	
	hitboxLeftArm.Size = Vector3.new(1,2,1)
	hitboxLeftArm.CanCollide = false
	hitboxLeftArm.Transparency = 0.5 -- Set to fully transparent when ready to launch
	hitboxLeftArm:SetAttribute("AttackDirection", "Left")
	hitboxLeftArm:SetAttribute("ReceiveBox", true) -- while the left and right arm hitboxes are attackboxes, they are used in sync blocking where the enemy attacks it, so its in some cases a receivebox.
	hitboxLeftArm.Parent = character:WaitForChild(hbFolder.Name)
	local lftArmHB_Weld = Instance.new("Weld")
	lftArmHB_Weld.Part0 = hitboxLeftArm
	lftArmHB_Weld.Part1 = character:WaitForChild("Left Arm")
	lftArmHB_Weld.Parent = hitboxLeftArm
	
	
	local hitboxRightArm = Instance.new("Part")
	hitboxRightArm.Name = player.Name.."_hitboxRightArm"
	hitboxRightArm.Position = character:WaitForChild("Right Arm").Position
	hitboxRightArm.Size = Vector3.new(1,2,1)
	hitboxRightArm.CanCollide = false
	hitboxRightArm.Transparency = 0.5
	hitboxRightArm:SetAttribute("AttackDirection", "Right")
	hitboxRightArm:SetAttribute("ReceiveBox", true)
	hitboxRightArm.Parent = character:WaitForChild(hbFolder.Name)
	local rghtArm_Weld = Instance.new("Weld")
	rghtArm_Weld.Part0  = hitboxRightArm
	rghtArm_Weld.Part1 = character:WaitForChild("Right Arm")
	rghtArm_Weld.Parent = character
	
	local hitboxLeftLeg = Instance.new("Part")
	hitboxLeftLeg.Name = player.Name.."_hitboxLeftLeg"
	hitboxLeftLeg.Position = character:WaitForChild("Left Leg").Position
	hitboxLeftLeg.Size = Vector3.new(1,2,1)
	hitboxLeftLeg.CanCollide = false
	hitboxLeftLeg.Transparency = 0.5 -- This will soon have to be set to 1 for launch
	hitboxLeftLeg:SetAttribute("AttackDirection", "forward")
	hitboxLeftLeg.Parent = character:WaitForChild(hbFolder.Name)
	local lftLeg_Weld = Instance.new("Weld")
	lftLeg_Weld.Part0 = hitboxLeftLeg
	lftLeg_Weld.Part1 = character:WaitForChild("Left Leg")
	lftLeg_Weld.Parent = character
	
	
	local hitboxRightLeg = Instance.new("Part")
	hitboxRightLeg.Name = player.Name.."_hitboxRightLeg"
	hitboxRightLeg.Position = character:WaitForChild("Right Leg").Position
	hitboxRightLeg.Size = Vector3.new(1,2,1)
	hitboxRightLeg.CanCollide = false
	hitboxRightLeg.Transparency = 0.5 -- Set to 1 when ready for project to launch
	hitboxRightLeg:SetAttribute("AttackDirection", "forward")
	hitboxRightLeg.Parent = character:WaitForChild(hbFolder.Name)
	local rghtLeg_Weld = Instance.new("Weld")
	rghtLeg_Weld.Part0 = hitboxRightLeg
	rghtLeg_Weld.Part1 = character:WaitForChild("Right Leg")
	rghtLeg_Weld.Parent = character
	
	local hitboxTorso = Instance.new("Part")
	hitboxTorso.Name = player.Name.."_hitboxTorso"
	hitboxTorso.Position = character:WaitForChild("Torso").Position
	hitboxTorso.Size = Vector3.new(2,2,1)
	hitboxTorso.CanCollide = false
	hitboxTorso.Transparency = 0.5
	hitboxTorso:SetAttribute("ReceiveBox", true)
	hitboxTorso.Parent = character:WaitForChild(hbFolder.Name)
	local trso_Weld = Instance.new("Weld")
	trso_Weld.Part0 = hitboxTorso
	trso_Weld.Part1 = character:WaitForChild("Torso")
	trso_Weld.Parent = character		
end

return ServerInit