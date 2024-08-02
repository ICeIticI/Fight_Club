local Players = game.Players

local GlobalRemoteEvent = Instance.new("RemoteEvent")
GlobalRemoteEvent.Name = "GlobalRemoteEvent"
GlobalRemoteEvent.Parent = game.ReplicatedStorage
print("thanks, server script")

Players.PlayerAdded:Connect(function(player)
	local plrObjectsFolder = Instance.new("Folder")
	plrObjectsFolder.Name = player.Name .. "_GameObjects"
	plrObjectsFolder.Parent = player

    -- local LocalBindableEvent = Instance.new("BindableEvent")
    -- LocalBindableEvent.Name = "LocalBindableEvent"
    -- LocalBindableEvent.Parent = game.ReplicatedStorage
	
	-- Animation defining:
	local FC_Idle = Instance.new("Animation")
	FC_Idle.Name = "FC_Idle"
	FC_Idle.AnimationId = "rbxassetid://16976891984"
	FC_Idle.Parent = plrObjectsFolder

	local FC_BlockStart = Instance.new("Animation")
	FC_BlockStart.Name = "FC_BlockStart"
	FC_BlockStart.AnimationId = "rbxassetid://18266066281"
	FC_BlockStart.Parent = plrObjectsFolder
	
	local FC_Block = Instance.new("Animation")
	FC_Block.Name = "FC_Block"
	FC_Block.AnimationId = "rbxassetid://16976697757"
	FC_Block.Parent = plrObjectsFolder
	
	local FC_LeftHook1 = Instance.new("Animation")
	FC_LeftHook1.Name = "FC_LeftHook1"
	FC_LeftHook1.AnimationId = "rbxassetid://16998937874"
	FC_LeftHook1:SetAttribute("AttackLevel", 1) -- *There will be three types of attack levels: 1 is for jabs and hooks etc, 2 is for haymakers and other powerful attacks, 3 is for finishers, executions and other paired animations.
	FC_LeftHook1:SetAttribute("AnimType", 1) -- AnimType will distinguish what kind of animation we're dealing with. 1 is attacks, 2 is receives,
	FC_LeftHook1:SetAttribute("AttackSeries", "Hooks")
	FC_LeftHook1.Parent = plrObjectsFolder
	
	local FC_RightHook1 = Instance.new("Animation")
	FC_RightHook1.Name = "FC_RightHook1"
	FC_RightHook1.AnimationId = "rbxassetid://17021541192"
	FC_RightHook1:SetAttribute("AttackLevel", 1)
	FC_RightHook1:SetAttribute("AnimType", 1)
	FC_RightHook1:SetAttribute("AttackSeries", "Hooks")
	FC_RightHook1.Parent = plrObjectsFolder
	
	local FC_LeftJab = Instance.new("Animation")
	FC_LeftJab.Name = "FC_LeftJab"
	FC_LeftJab.AnimationId = "rbxassetid://18207098315"
	FC_LeftJab:SetAttribute("AttackLevel", 1)
	FC_LeftJab:SetAttribute("AnimType", 1)
	FC_LeftJab:SetAttribute("AttackSeries", "Jabs")
	FC_LeftJab.Parent = plrObjectsFolder
	
	local FC_RightJab = Instance.new("Animation")
	FC_RightJab.Name = "FC_RightJab"
	FC_RightJab.AnimationId = "rbxassetid://18210186455"
	FC_RightJab:SetAttribute("AttackLevel", 1)
	FC_RightJab:SetAttribute("AnimType", 1)
	FC_RightJab:SetAttribute("AttackSeries", "Jabs")
	FC_RightJab.Parent = plrObjectsFolder
	
	local FC_LeftUppercut = Instance.new("Animation")
	FC_LeftUppercut.Name = "FC_LeftUppercut"
	FC_LeftUppercut.AnimationId = "rbxassetid://18224256126"
	FC_LeftUppercut:SetAttribute("AttackLevel", 1)
	FC_LeftUppercut:SetAttribute("AnimType", 1)
	FC_LeftUppercut:SetAttribute("AttackSeries", "Uppercuts")
	FC_LeftUppercut.Parent = plrObjectsFolder
	
	local FC_RightUppercut = Instance.new("Animation")
	FC_RightUppercut.Name = "FC_RightUppercut"
	FC_RightUppercut.AnimationId = "rbxassetid://18223875093"
	FC_RightUppercut:SetAttribute("AttackLevel", 1)
	FC_RightUppercut:SetAttribute("AnimType", 1)
	FC_RightUppercut:SetAttribute("AttackSeries", "Uppercuts")
	FC_RightUppercut.Parent = plrObjectsFolder
	
	local FC_LeftHaymaker = Instance.new("Animation")
	FC_LeftHaymaker.Name = "FC_LeftHaymaker"
	FC_LeftHaymaker.AnimationId = "rbxassetid://18195506368"
	FC_LeftHaymaker:SetAttribute("AttackLevel", 2)
	FC_LeftHaymaker:SetAttribute("AnimType", 1)
	FC_LeftHaymaker:SetAttribute("AttackSeries", "Haymakers")
	FC_LeftHaymaker.Parent = plrObjectsFolder
	
	local FC_RightHaymaker = Instance.new("Animation")
	FC_RightHaymaker.Name = "FC_RightHaymaker"
	FC_RightHaymaker.AnimationId = "rbxassetid://17216832518"
	FC_RightHaymaker:SetAttribute("AttackLevel", 2)
	FC_RightHaymaker:SetAttribute("AnimType", 1)
	FC_RightHaymaker:SetAttribute("AttackSeries", "Haymakers")
	FC_RightHaymaker.Parent = plrObjectsFolder
	
	
	local FC_LeftHook1RECEIVER = Instance.new("Animation")
	FC_LeftHook1RECEIVER.Name = "FC_LeftHook1RECEIVER"
	FC_LeftHook1RECEIVER.AnimationId = "rbxassetid://17012688911"
	FC_LeftHook1RECEIVER:SetAttribute("AnimType", 2)
	FC_LeftHook1RECEIVER.Parent = plrObjectsFolder
	
	local FC_RightHook1RECEIVER = Instance.new("Animation")
	FC_RightHook1RECEIVER.Name = "FC_RightHook1RECEIVER"
	FC_RightHook1RECEIVER.AnimationId = "rbxassetid://17149671845"
	FC_RightHook1RECEIVER:SetAttribute("AnimType", 2)
	FC_RightHook1RECEIVER.Parent = plrObjectsFolder
	
	local FC_LeftUppercutRECEIVER = Instance.new("Animation")
	FC_LeftUppercutRECEIVER.Name = "FC_LeftUppercutRECEIVER"
	FC_LeftUppercutRECEIVER.AnimationId = "rbxassetid://18224267835"
	FC_LeftUppercutRECEIVER:SetAttribute("AnimType", 2)
	FC_LeftUppercutRECEIVER.Parent = plrObjectsFolder
	
	local FC_RightUppercutRECEIVER = Instance.new("Animation")
	FC_RightUppercutRECEIVER.Name = "FC_RightUppercutRECEIVER"
	FC_RightUppercutRECEIVER.AnimationId = "rbxassetid://18224216460"
	FC_RightUppercutRECEIVER:SetAttribute("AnimType", 2)
	FC_RightUppercutRECEIVER.Parent = plrObjectsFolder
	
	local FC_LeftHaymakerRECEIVER = Instance.new("Animation")
	FC_LeftHaymakerRECEIVER.Name = "FC_LeftHaymakerRECEIVER"
	FC_LeftHaymakerRECEIVER.AnimationId = "rbxassetid://18195570469"
	FC_LeftHaymakerRECEIVER:SetAttribute("AnimType", 2)
	FC_LeftHaymakerRECEIVER.Parent = plrObjectsFolder
	
	local FC_RightHaymakerRECEIVER = Instance.new("Animation")
	FC_RightHaymakerRECEIVER.Name = "FC_RightHaymakerRECEIVER"
	FC_RightHaymakerRECEIVER.AnimationId = "rbxassetid://17231536892"
	FC_RightHaymakerRECEIVER:SetAttribute("AnimType", 2)
	FC_RightHaymakerRECEIVER.Parent = plrObjectsFolder
	
	
	local FC_SyncBlock1L = Instance.new("Animation")
	FC_SyncBlock1L.Name = "FC_SyncBlock1L"
	FC_SyncBlock1L.AnimationId = "rbxassetid://18313294082"
	FC_SyncBlock1L:SetAttribute("AttackLevel", 3)
	FC_SyncBlock1L:SetAttribute("AnimType", 1)
	FC_SyncBlock1L:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock1L:SetAttribute("Paired", true)
	FC_SyncBlock1L.Parent = plrObjectsFolder
	
	local FC_SyncBlock1LRECEIVER = Instance.new("Animation")
	FC_SyncBlock1LRECEIVER.Name = "FC_SyncBlock1LRECEIVER"
	FC_SyncBlock1LRECEIVER.AnimationId = "rbxassetid://18313350253"
	FC_SyncBlock1LRECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock1LRECEIVER:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock1LRECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock1LRECEIVER.Parent = plrObjectsFolder
	
	local FC_SyncBlock1R = Instance.new("Animation")
	FC_SyncBlock1R.Name = "FC_SyncBlock1R"
	FC_SyncBlock1R.AnimationId = "rbxassetid://18411572433"
	FC_SyncBlock1R:SetAttribute("AttackLevel", 3)
	FC_SyncBlock1R:SetAttribute("AnimType", 1)
	FC_SyncBlock1R:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock1R:SetAttribute("Paired", true)
	FC_SyncBlock1R.Parent = plrObjectsFolder
	
	local FC_SyncBlock1RRECEIVER = Instance.new("Animation")
	FC_SyncBlock1RRECEIVER.Name = "FC_SyncBlock1RRECEIVER"
	FC_SyncBlock1RRECEIVER.AnimationId = "rbxassetid://18411663259"
	FC_SyncBlock1RRECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock1RRECEIVER:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock1RRECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock1RRECEIVER.Parent = plrObjectsFolder
	
	local FC_SyncBlock2L = Instance.new("Animation")
	FC_SyncBlock2L.Name = "FC_SyncBlock2L"
	FC_SyncBlock2L.AnimationId = "rbxassetid://18513963314"
	FC_SyncBlock2L:SetAttribute("AttackLevel", 3)
	FC_SyncBlock2L:SetAttribute("AnimType", 1)
	FC_SyncBlock2L:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock2L:SetAttribute("Paired", true)
	FC_SyncBlock2L.Parent = plrObjectsFolder
	
	local FC_SyncBlock2LRECEIVER = Instance.new("Animation")
	FC_SyncBlock2LRECEIVER.Name = "FC_SyncBlock2LRECEIVER"
	FC_SyncBlock2LRECEIVER.AnimationId = "rbxassetid://18513976177"
	FC_SyncBlock2LRECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock2LRECEIVER:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock2LRECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock2LRECEIVER.Parent = plrObjectsFolder
	
	local FC_SyncBlock2R = Instance.new("Animation")
	FC_SyncBlock2R.Name = "FC_SyncBlock2R"
	FC_SyncBlock2R.AnimationId = "rbxassetid://18513983953"
	FC_SyncBlock2R:SetAttribute("AttackLevel", 3)
	FC_SyncBlock2R:SetAttribute("AnimType", 1)
	FC_SyncBlock2R:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock2R:SetAttribute("Paired", true)
	FC_SyncBlock2R.Parent = plrObjectsFolder
	
	local FC_SyncBlock2RRECEIVER = Instance.new("Animation")
	FC_SyncBlock2RRECEIVER.Name = "FC_SyncBlock2RRECEIVER"
	FC_SyncBlock2RRECEIVER.AnimationId = "rbxassetid://18513989602"
	FC_SyncBlock2RRECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock2RRECEIVER:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock2RRECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock2RRECEIVER.Parent = plrObjectsFolder

	local FC_SyncBlock3L1 = Instance.new("Animation")
	FC_SyncBlock3L1.Name = "FC_SyncBlock3L1"
	FC_SyncBlock3L1.AnimationId = "rbxassetid://18740951548"
	FC_SyncBlock3L1:SetAttribute("AttackLevel", 3)
	FC_SyncBlock3L1:SetAttribute("AnimType", 1)
	FC_SyncBlock3L1:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock3L1:SetAttribute("Paired", true)
	FC_SyncBlock3L1.Parent = plrObjectsFolder
	
	local FC_SyncBlock3L1RECEIVER = Instance.new("Animation")
	FC_SyncBlock3L1RECEIVER.Name = "FC_SyncBlock3L1RECEIVER"
	FC_SyncBlock3L1RECEIVER.AnimationId = "rbxassetid://18740954203"
	FC_SyncBlock3L1RECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock3L1RECEIVER:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock3L1RECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock3L1RECEIVER.Parent = plrObjectsFolder

	local FC_SyncBlock3R1 = Instance.new("Animation")
	FC_SyncBlock3R1.Name = "FC_SyncBlock3R1"
	FC_SyncBlock3R1.AnimationId = "rbxassetid://18743711875"
	FC_SyncBlock3R1:SetAttribute("AttackLevel", 3)
	FC_SyncBlock3R1:SetAttribute("AnimType", 1)
	FC_SyncBlock3R1:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock3R1:SetAttribute("Paired", true)
	FC_SyncBlock3R1.Parent = plrObjectsFolder
	
	local FC_SyncBlock3R1RECEIVER = Instance.new("Animation")
	FC_SyncBlock3R1RECEIVER.Name = "FC_SyncBlock3R1RECEIVER"
	FC_SyncBlock3R1RECEIVER.AnimationId = "rbxassetid://18743714470"
	FC_SyncBlock3R1RECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock3R1RECEIVER:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock3R1RECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock3R1RECEIVER.Parent = plrObjectsFolder

	local FC_SyncBlock3L2 = Instance.new("Animation")
	FC_SyncBlock3L2.Name = "FC_SyncBlock3L2"
	FC_SyncBlock3L2.AnimationId = "rbxassetid://18747173117"
	FC_SyncBlock3L2:SetAttribute("AttackLevel", 3)
	FC_SyncBlock3L2:SetAttribute("AnimType", 1)
	FC_SyncBlock3L2:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock3L2:SetAttribute("Paired", true)
	FC_SyncBlock3L2.Parent = plrObjectsFolder
	
	local FC_SyncBlock3L2RECEIVER = Instance.new("Animation")
	FC_SyncBlock3L2RECEIVER.Name = "FC_SyncBlock3L2RECEIVER"
	FC_SyncBlock3L2RECEIVER.AnimationId = "rbxassetid://18747180819"
	FC_SyncBlock3L2RECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock3L2RECEIVER:SetAttribute("AnimDirection", "Left")
	FC_SyncBlock3L2RECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock3L2RECEIVER.Parent = plrObjectsFolder

	local FC_SyncBlock3R2 = Instance.new("Animation")
	FC_SyncBlock3R2.Name = "FC_SyncBlock3R2"
	FC_SyncBlock3R2.AnimationId = "rbxassetid://18757168674"
	FC_SyncBlock3R2:SetAttribute("AttackLevel", 3)
	FC_SyncBlock3R2:SetAttribute("AnimType", 1)
	FC_SyncBlock3R2:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock3R2:SetAttribute("Paired", true)
	FC_SyncBlock3R2.Parent = plrObjectsFolder
	
	local FC_SyncBlock3R2RECEIVER = Instance.new("Animation")
	FC_SyncBlock3R2RECEIVER.Name = "FC_SyncBlock3R2RECEIVER"
	FC_SyncBlock3R2RECEIVER.AnimationId = "rbxassetid://18757172855"
	FC_SyncBlock3R2RECEIVER:SetAttribute("AnimType", 2)
	FC_SyncBlock3R2RECEIVER:SetAttribute("AnimDirection", "Right")
	FC_SyncBlock3R2RECEIVER:SetAttribute("Paired", true)
	FC_SyncBlock3R2RECEIVER.Parent = plrObjectsFolder
	

	player.CharacterAdded:Connect(function(character)
		
		local charAnimator = Instance.new("Animator")
		charAnimator.Name = "charAnimator"
		charAnimator.Parent = character:WaitForChild("Humanoid")
		
		--local FC_IdleTRACK = charAnimator:LoadAnimation(FC_Idle)
		--local FC_BlockTRACK = charAnimator:LoadAnimation(FC_Block)
		--local FC_LeftHook1TRACK = charAnimator:LoadAnimation(FC_LeftHook1)
		--local FC_RightHook1TRACK = charAnimator:LoadAnimation(FC_RightHook1)
		--local FC_RightHaymakerTrack = charAnimator:LoadAnimation(FC_RightHaymaker)

		-- *animations (receiver)*
		
		--local FC_LeftHook1RECEIVERTRACK = charAnimator:LoadAnimation(FC_LeftHook1RECEIVER)
		--local FC_RightHook1RECEIVERTRACK = charAnimator:LoadAnimation(FC_RightHook1RECEIVER)
		--local FC_RightHaymakerReceiverTRACK = charAnimator:LoadAnimation(FC_RightHaymakerRECEIVER)
		
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
	end)
end)