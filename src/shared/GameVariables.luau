local TweenService = game:GetService("TweenService")
local GameVariables = {}

GameVariables.player = game:GetService("Players").LocalPlayer

GameVariables.character = GameVariables.player.Character or GameVariables.player.CharacterAdded:Wait()
GameVariables.humanoid = GameVariables.character:WaitForChild("Humanoid")
GameVariables.previousHealth = GameVariables.humanoid.Health -- This var is used to determine how much damage the character takes.
GameVariables.charAnimator = GameVariables.character:WaitForChild("Humanoid"):WaitForChild("charAnimator")
GameVariables.humanoidRootPart = GameVariables.character:WaitForChild("HumanoidRootPart")

GameVariables.player.CharacterAdded:Connect(function(character)
	GameVariables.character = character
	GameVariables.humanoid = character:WaitForChild("Humanoid")
	GameVariables.previousHealth = GameVariables.humanoid.Health -- This var is used to determine how much damage the character takes.
	GameVariables.charAnimator = character:WaitForChild("Humanoid"):WaitForChild("charAnimator")
	GameVariables.humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	-- character hitboxes
	GameVariables.hitboxesFolder = GameVariables.character:WaitForChild(GameVariables.player.Name.."_hitboxesFolder")

	GameVariables.hitboxHead = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxHead")
	GameVariables.hitboxLeftArm = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxLeftArm")
	GameVariables.hitboxLeftLeg = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxLeftLeg")
	GameVariables.hitboxRightArm = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxRightArm")
	GameVariables.hitboxRightLeg = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxRightLeg")
	GameVariables.hitboxTorso = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxTorso")

	-- *Hitbox tables*
	GameVariables.hitboxesFolderATTACK = {GameVariables.hitboxLeftArm, GameVariables.hitboxLeftLeg, GameVariables.hitboxRightArm, GameVariables.hitboxRightLeg}
	GameVariables.hitboxesFolderRECEIVE = {GameVariables.hitboxHead, GameVariables.hitboxTorso}
	

	GameVariables.Protocol = nil
	GameVariables.walkingSpeed = 12
	GameVariables.humanoid.WalkSpeed = GameVariables.walkingSpeed
	GameVariables.humanoid.JumpPower = 0

	GameVariables.lockOnDebounce.Value = false
	GameVariables.hitDebounce = false
	GameVariables.isBlocking = false
	GameVariables.isAttacking = false
	GameVariables.isCountering = false
	GameVariables.isGettingHit = false
	GameVariables.waitingToAttack = false
	GameVariables.pairedPlaying = false
	GameVariables.canSyncBlock = true
	GameVariables.previousWalkSpeed = nil

	GameVariables.attackFrames = false
	--GameVariables.attackEnded = false

	GameVariables.isDodging = false
	GameVariables.canFollowUp = false
	GameVariables.isEnemyHoldingBlock = false
	GameVariables.followUpCount = 0
	GameVariables.lastAttack = nil
	GameVariables.comboCounter = 0
	GameVariables.parryWindow = 0.5
	GameVariables.currentAttack = nil
	GameVariables.currentReceiveAnimTRACK = nil
	GameVariables.attackSeries = nil
	GameVariables.randAttack = nil
	GameVariables.distanceBetween = nil
	GameVariables.enemyHumanoid = nil
	GameVariables.enemyChar = nil
	GameVariables.randLvl1Type = nil
	GameVariables.animPair = nil

	-- *animations (attacker)*	
	print(GameVariables.FC_Idle)
	GameVariables.FC_IdleTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_Idle)
	GameVariables.FC_BlockTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_Block)
	GameVariables.FC_BlockStartTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_BlockStart)
	GameVariables.FC_LeftHook1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHook1)
	GameVariables.FC_RightHook1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHook1)
	GameVariables.FC_LeftJabTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftJab)
	GameVariables.FC_RightJabTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightJab)
	GameVariables.FC_LeftUppercutTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftUppercut)
	GameVariables.FC_RightUppercutTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightUppercut)
	GameVariables.FC_LeftHaymakerTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHaymaker)
	GameVariables.FC_RightHaymakerTrack = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHaymaker)
	-- *animations (receiver)*
	GameVariables.FC_LeftHook1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHook1RECEIVER)
	GameVariables.FC_RightHook1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHook1RECEIVER)
	GameVariables.FC_LeftUppercutRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftUppercutRECEIVER)
	GameVariables.FC_RightUppercutRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightUppercutRECEIVER)
	GameVariables.FC_LeftHaymakerRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHaymakerRECEIVER)
	GameVariables.FC_RightHaymakerReceiverTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHaymakerRECEIVER)
	-- *animations (paired)*
	GameVariables.FC_SyncBlock1LTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1L)
	GameVariables.FC_SyncBlock1LRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1LRECEIVER)
	GameVariables.FC_SyncBlock1RTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1R)
	GameVariables.FC_SyncBlock1RRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1RRECEIVER)
	GameVariables.FC_SyncBlock2LTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2L)
	GameVariables.FC_SyncBlock2LRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2LRECEIVER)
	GameVariables.FC_SyncBlock2RTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2R)
	GameVariables.FC_SyncBlock2RRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2RRECEIVER)
	GameVariables.FC_SyncBlock3L1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L1)
	GameVariables.FC_SyncBlock3L1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L1RECEIVER)
	GameVariables.FC_SyncBlock3R1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R1)
	GameVariables.FC_SyncBlock3R1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R1RECEIVER)
	GameVariables.FC_SyncBlock3L2TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L2)
	GameVariables.FC_SyncBlock3L2RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L2RECEIVER)
	GameVariables.FC_SyncBlock3R2TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R2)
	GameVariables.FC_SyncBlock3R2RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R2RECEIVER)

	-- *Animation tables*
	GameVariables.AllAnimations = {
		GameVariables.FC_IdleTRACK, GameVariables.FC_BlockStartTRACK, GameVariables.FC_BlockTRACK,
		GameVariables.FC_LeftHook1TRACK, GameVariables.FC_RightHook1TRACK, 
		GameVariables.FC_LeftJabTRACK, GameVariables.FC_RightJabTRACK,
		GameVariables.FC_LeftUppercutTRACK, GameVariables.FC_RightUppercutTRACK, 
		GameVariables.FC_LeftHaymakerTRACK, GameVariables.FC_RightHaymakerTrack, 
		GameVariables.FC_LeftHook1RECEIVERTRACK, GameVariables.FC_RightHook1RECEIVERTRACK, 
		GameVariables.FC_LeftUppercutRECEIVERTRACK, GameVariables.FC_RightUppercutRECEIVERTRACK, 
		GameVariables.FC_LeftHaymakerRECEIVERTRACK, GameVariables.FC_RightHaymakerReceiverTRACK,
		GameVariables.FC_SyncBlock1LTRACK, GameVariables.FC_SyncBlock1LRECEIVERTRACK,
		GameVariables.FC_SyncBlock1RTRACK, GameVariables.FC_SyncBlock1RRECEIVERTRACK,
		GameVariables.FC_SyncBlock2LTRACK, GameVariables.FC_SyncBlock2LRECEIVERTRACK,
		GameVariables.FC_SyncBlock2RTRACK, GameVariables.FC_SyncBlock2RRECEIVERTRACK,
		GameVariables.FC_SyncBlock3L1TRACK, GameVariables.FC_SyncBlock3L1RECEIVERTRACK,
		GameVariables.FC_SyncBlock3R1TRACK, GameVariables.FC_SyncBlock3R1RECEIVERTRACK,
		GameVariables.FC_SyncBlock3L2TRACK, GameVariables.FC_SyncBlock3L2RECEIVERTRACK,
		GameVariables.FC_SyncBlock3R2TRACK, GameVariables.FC_SyncBlock3R2RECEIVERTRACK
	}

	GameVariables.attack1Table = {}
	GameVariables.attack2Table = {}

	for _, v in pairs(GameVariables.AllAnimations) do -- this for loop fills in the attack1 and attack2Table based off attributes
		if v.Animation:GetAttribute("AttackSeries") then -- standard attacks have the "AttackSeries" attribute so its how we define it as a stnadard attack
			if v.Animation:GetAttribute("AttackLevel") == 1 then -- level 1's will be added to the attack1Table
				table.insert(GameVariables.attack1Table, v)
			elseif v.Animation:GetAttribute("AttackLevel") == 2 then -- level 2's will be added to the attack2Table
				table.insert(GameVariables.attack2Table, v)
			end
		end
	end

	print(GameVariables.attack1Table)
	print(GameVariables.attack2Table)

	GameVariables.pairedAttacksTable = {} -- the for loop below will fill this with all of the attacking paired animations
	GameVariables.pairedBlocksTable = {} -- same above except for receiving animations.

	for _, v in pairs(GameVariables.AllAnimations) do
		if v.Animation:GetAttribute("Paired") then
			print(true)
			if v.Animation:GetAttribute("AnimType") == 1 then
				table.insert(GameVariables.pairedAttacksTable, v)
			elseif v.Animation:GetAttribute("AnimType") == 2 then
				table.insert(GameVariables.pairedBlocksTable, v)
			end
		end

	end
	print(GameVariables.pairedAttacksTable)
	print(GameVariables.pairedBlocksTable)

	GameVariables.pairedAttack = nil
	GameVariables.pairedBlock = nil
	GameVariables.pairedChain = 0
	
	print("plrs spawned")
end)

GameVariables.humanoid.Died:Connect(function()

	print("plr died")
end)
--GameVariables.attackAttri = character:GetAttribute("attackAttri")

-- character hitboxes
GameVariables.hitboxesFolder = GameVariables.character:WaitForChild(GameVariables.player.Name.."_hitboxesFolder")

GameVariables.hitboxHead = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxHead")
GameVariables.hitboxLeftArm = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxLeftArm")
GameVariables.hitboxLeftLeg = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxLeftLeg")
GameVariables.hitboxRightArm = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxRightArm")
GameVariables.hitboxRightLeg = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxRightLeg")
GameVariables.hitboxTorso = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxTorso")

-- *Hitbox tables*
GameVariables.hitboxesFolderATTACK = {GameVariables.hitboxLeftArm, GameVariables.hitboxLeftLeg, GameVariables.hitboxRightArm, GameVariables.hitboxRightLeg}
GameVariables.hitboxesFolderRECEIVE = {GameVariables.hitboxHead, GameVariables.hitboxTorso}

-- create a table for hitboxes, then run :Connect function(s) via for loop for .Touched event and more.

GameVariables.Camera = game.Workspace.CurrentCamera
GameVariables.plrObjectsFolder = GameVariables.player:WaitForChild(GameVariables.player.Name .. "_GameObjects") -- perhaps change it from player.Name to player.playerId for saving and stuff in the future

-- player remote & bindable event"
--GameVariables.remoteEvent = plrObjectsFolder:WaitForChild(player.Name.."_RemoteEvent")
--GameVariables.bindableEvent = plrObjectsFolder:WaitForChild(player.Name.."_BindableEvent")

-- Global Remote Event - Because each player having their own remote event is redundant.
GameVariables.GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

GameVariables.LocalBindableEvent = Instance.new("BindableEvent")
GameVariables.LocalBindableEvent.Name = "LocalBindableEvent"
GameVariables.LocalBindableEvent.Parent = game.ReplicatedStorage

GameVariables.Protocol = nil

GameVariables.walkingSpeed = 12
GameVariables.humanoid.WalkSpeed = GameVariables.walkingSpeed

GameVariables.humanoid.JumpPower = 0
-- origins
GameVariables.originalWalkSpeed = GameVariables.humanoid.WalkSpeed
GameVariables.originalCamFocus = GameVariables.Camera.Focus
GameVariables.originalCamSubject = GameVariables.Camera.CameraSubject

--bools and values
GameVariables.lockOnDebounce = Instance.new("BoolValue") -- shouldn't this be initialized by the server for more security?
GameVariables.lockOnDebounce.Name = "lockOnDebounce"
GameVariables.lockOnDebounce.Parent = GameVariables.plrObjectsFolder
GameVariables.hitDebounce = false -- if false, then the player has the ability to deal damage. This is so the player won't hit the enemy multiple times in one attack.
GameVariables.isBlocking = false -- set to true when the client blocks
GameVariables.isAttacking = false
GameVariables.isCountering = false
GameVariables.isGettingHit = false
GameVariables.waitingToAttack = false
GameVariables.pairedPlaying = false -- used to make sure the paired animations don't play while already playing.
GameVariables.canSyncBlock = true
GameVariables.previousWalkSpeed = nil

GameVariables.lockOnSpeed = GameVariables.originalWalkSpeed / 1.85
GameVariables.attackFrames = false -- when the StartOfAttack marker fires in attack anims, this allows damage to pass
--GameVariables.attackEnded = false

GameVariables.isDodging = false
GameVariables.canFollowUp = false -- The status of whether a player is able to do a followup attack. If its true, then that means they are able to do one. 
GameVariables.isEnemyHoldingBlock = false -- for attacks to be synched attacks when blocked in a synched block.
GameVariables.followUpCount = 0 -- followUpCount is used so a followup wont be done twice back to back when a follow up is done
GameVariables.lastAttack = nil
GameVariables.comboCounter = 0
GameVariables.parryWindow = 0.5
GameVariables.currentAttack = nil										
--GameVariables.enemyCurrentAttackID = nil -- the anim id the enemy attacked the player with
GameVariables.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim
GameVariables.attackSeries = nil
GameVariables.randAttack = nil
GameVariables.distanceBetween = nil
GameVariables.enemyHumanoid = nil -- pre-defined enemy Humanoid because the script hates global variables. Used for the enemy.
GameVariables.enemyChar = nil
GameVariables.randLvl1Type = nil --[[ Used to determine what lvl 1 attacks
					   the player will use for said combo ]]


-- New Variables that are replacing old:
GameVariables.canAttack = false
GameVariables.canGetHit = false
GameVariables.areLockedOn = false
-- Above are new variables that will be replacing old ^


GameVariables.animPair = nil

-- GameVariables.actionTable = {GameVariables.isBlocking, GameVariables.isAttacking, GameVariables.isCountering}

-- GameVariables.rayParams = RaycastParams.new()
-- GameVariables.rayParams.FilterDescendantsInstances = GameVariables.character:GetChildren()
-- GameVariables.rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- GameVariables.raycastResult = workspace:Raycast(GameVariables.humanoidRootPart.Position, GameVariables.humanoidRootPart.CFrame.LookVector * 8, GameVariables.rayParams)

-- NOTE*: Perhaps instead of creating a bunch of animations, we make a single animation then when the player needs to animate, load the animId into the animation. Id's would prob be in a table.
-- *animations (attacker)*
GameVariables.FC_Idle = GameVariables.plrObjectsFolder:WaitForChild("FC_Idle")
GameVariables.FC_IdleTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_Idle)

GameVariables.FC_Block = GameVariables.plrObjectsFolder:WaitForChild("FC_Block")
GameVariables.FC_BlockTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_Block)

GameVariables.FC_BlockStart = GameVariables.plrObjectsFolder:WaitForChild("FC_BlockStart")
GameVariables.FC_BlockStartTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_BlockStart)

GameVariables.FC_LeftHook1 = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHook1")
GameVariables.FC_LeftHook1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHook1)

GameVariables.FC_RightHook1 = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHook1")
GameVariables.FC_RightHook1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHook1)

GameVariables.FC_LeftJab = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftJab")
GameVariables.FC_LeftJabTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftJab)

GameVariables.FC_RightJab = GameVariables.plrObjectsFolder:WaitForChild("FC_RightJab")
GameVariables.FC_RightJabTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightJab)

GameVariables.FC_LeftUppercut = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftUppercut")
GameVariables.FC_LeftUppercutTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftUppercut)

GameVariables.FC_RightUppercut = GameVariables.plrObjectsFolder:WaitForChild("FC_RightUppercut")
GameVariables.FC_RightUppercutTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightUppercut)

GameVariables.FC_LeftHaymaker = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHaymaker")
GameVariables.FC_LeftHaymakerTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHaymaker)

GameVariables.FC_RightHaymaker = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHaymaker")
GameVariables.FC_RightHaymakerTrack = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHaymaker)

-- *animations (receiver)*
GameVariables.FC_LeftHook1RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHook1RECEIVER")
GameVariables.FC_LeftHook1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHook1RECEIVER)

GameVariables.FC_RightHook1RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHook1RECEIVER")
GameVariables.FC_RightHook1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHook1RECEIVER)

GameVariables.FC_LeftUppercutRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftUppercutRECEIVER")
GameVariables.FC_LeftUppercutRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftUppercutRECEIVER)

GameVariables.FC_RightUppercutRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightUppercutRECEIVER")
GameVariables.FC_RightUppercutRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightUppercutRECEIVER)

GameVariables.FC_LeftHaymakerRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHaymakerRECEIVER")
GameVariables.FC_LeftHaymakerRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHaymakerRECEIVER)

GameVariables.FC_RightHaymakerRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHaymakerRECEIVER")
GameVariables.FC_RightHaymakerReceiverTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHaymakerRECEIVER)

-- *animations (paired)*
GameVariables.FC_SyncBlock1L = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1L")
GameVariables.FC_SyncBlock1LTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1L)

GameVariables.FC_SyncBlock1LRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1LRECEIVER")
GameVariables.FC_SyncBlock1LRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1LRECEIVER)

GameVariables.FC_SyncBlock1R = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1R")
GameVariables.FC_SyncBlock1RTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1R)

GameVariables.FC_SyncBlock1RRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1RRECEIVER")
GameVariables.FC_SyncBlock1RRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1RRECEIVER)

GameVariables.FC_SyncBlock2L = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2L")
GameVariables.FC_SyncBlock2LTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2L)

GameVariables.FC_SyncBlock2LRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2LRECEIVER")
GameVariables.FC_SyncBlock2LRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2LRECEIVER)

GameVariables.FC_SyncBlock2R = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2R")
GameVariables.FC_SyncBlock2RTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2R)

GameVariables.FC_SyncBlock2RRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2RRECEIVER")
GameVariables.FC_SyncBlock2RRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2RRECEIVER)

GameVariables.FC_SyncBlock3L1 = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L1")
GameVariables.FC_SyncBlock3L1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L1)

GameVariables.FC_SyncBlock3L1RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L1RECEIVER")
GameVariables.FC_SyncBlock3L1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L1RECEIVER)

GameVariables.FC_SyncBlock3R1 = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R1")
GameVariables.FC_SyncBlock3R1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R1)

GameVariables.FC_SyncBlock3R1RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R1RECEIVER")
GameVariables.FC_SyncBlock3R1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R1RECEIVER)

GameVariables.FC_SyncBlock3L2 = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L2")
GameVariables.FC_SyncBlock3L2TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L2)

GameVariables.FC_SyncBlock3L2RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L2RECEIVER")
GameVariables.FC_SyncBlock3L2RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3L2RECEIVER)

GameVariables.FC_SyncBlock3R2 = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R2")
GameVariables.FC_SyncBlock3R2TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R2)

GameVariables.FC_SyncBlock3R2RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R2RECEIVER")
GameVariables.FC_SyncBlock3R2RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock3R2RECEIVER)

GameVariables.FC_BracingBlockL = GameVariables.plrObjectsFolder:WaitForChild("FC_BracingBlockL")
GameVariables.FC_BracingBlockLTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_BracingBlockL)

GameVariables.FC_BracingBlockR = GameVariables.plrObjectsFolder:WaitForChild("FC_BracingBlockR")
GameVariables.FC_BracingBlockRTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_BracingBlockR)

GameVariables.FC_LeftParry = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftParry")
GameVariables.FC_LeftParryTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftParry)
-- GameVariables.FC_LeftParryTRACK.Priority = Enum.AnimationPriority.Action4

GameVariables.FC_LeftParryRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftParryRECEIVER")
GameVariables.FC_LeftParryRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftParryRECEIVER)

GameVariables.FC_RightParry = GameVariables.plrObjectsFolder:WaitForChild("FC_RightParry")
GameVariables.FC_RightParryTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightParry)
-- GameVariables.FC_RightParryTRACK.Priority = Enum.AnimationPriority.Action4

GameVariables.FC_RightParryRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightParryRECEIVER")
GameVariables.FC_RightParryRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightParryRECEIVER)


-- *Animation tables*
GameVariables.AllAnimations = {
	GameVariables.FC_IdleTRACK, GameVariables.FC_BlockStartTRACK, GameVariables.FC_BlockTRACK,
	GameVariables.FC_LeftHook1TRACK, GameVariables.FC_RightHook1TRACK, 
	GameVariables.FC_LeftJabTRACK, GameVariables.FC_RightJabTRACK,
	GameVariables.FC_LeftUppercutTRACK, GameVariables.FC_RightUppercutTRACK, 
	GameVariables.FC_LeftHaymakerTRACK, GameVariables.FC_RightHaymakerTrack, 
	GameVariables.FC_LeftHook1RECEIVERTRACK, GameVariables.FC_RightHook1RECEIVERTRACK, 
	GameVariables.FC_LeftUppercutRECEIVERTRACK, GameVariables.FC_RightUppercutRECEIVERTRACK, 
	GameVariables.FC_LeftHaymakerRECEIVERTRACK, GameVariables.FC_RightHaymakerReceiverTRACK,
	GameVariables.FC_SyncBlock1LTRACK, GameVariables.FC_SyncBlock1LRECEIVERTRACK,
	GameVariables.FC_SyncBlock1RTRACK, GameVariables.FC_SyncBlock1RRECEIVERTRACK,
	GameVariables.FC_SyncBlock2LTRACK, GameVariables.FC_SyncBlock2LRECEIVERTRACK,
	GameVariables.FC_SyncBlock2RTRACK, GameVariables.FC_SyncBlock2RRECEIVERTRACK,
	GameVariables.FC_SyncBlock3L1TRACK, GameVariables.FC_SyncBlock3L1RECEIVERTRACK,
	GameVariables.FC_SyncBlock3R1TRACK, GameVariables.FC_SyncBlock3R1RECEIVERTRACK,
	GameVariables.FC_SyncBlock3L2TRACK, GameVariables.FC_SyncBlock3L2RECEIVERTRACK,
	GameVariables.FC_SyncBlock3R2TRACK, GameVariables.FC_SyncBlock3R2RECEIVERTRACK,
	GameVariables.FC_BracingBlockLTRACK, GameVariables.FC_BracingBlockRTRACK,
	GameVariables.FC_LeftParryTRACK, GameVariables.FC_LeftParryRECEIVERTRACK,
	GameVariables.FC_RightParryTRACK, GameVariables.FC_RightParryRECEIVERTRACK
}

GameVariables.attack1Table = {}
GameVariables.attack2Table = {}

for _, v in pairs(GameVariables.AllAnimations) do -- this for loop fills in the attack1 and attack2Table based off attributes
	if v.Animation:GetAttribute("AttackSeries") then -- standard attacks have the "AttackSeries" attribute so its how we define it as a stnadard attack
		if v.Animation:GetAttribute("AttackLevel") == 1 then -- level 1's will be added to the attack1Table
			table.insert(GameVariables.attack1Table, v)
		elseif v.Animation:GetAttribute("AttackLevel") == 2 then -- level 2's will be added to the attack2Table
			table.insert(GameVariables.attack2Table, v)
		end
	end
end

-- USE FOR LOOP ON ANIMATIONS TABLE FOR BOTH THESE TABLES TO FIND THE CORRECT ANIMATION TYPE DEPENDING ON WHAT AnimType THEY ARE!!!:
GameVariables.pairedAttacksTable = {} -- the for loop below will fill this with all of the attacking paired animations
GameVariables.pairedBlocksTable = {} -- same above except for receiving animations.

for _, v in pairs(GameVariables.AllAnimations) do
	if v.Animation:GetAttribute("Paired") then
		if v.Animation:GetAttribute("AnimType") == 1 then
			table.insert(GameVariables.pairedAttacksTable, v)
		elseif v.Animation:GetAttribute("AnimType") == 2 then
			table.insert(GameVariables.pairedBlocksTable, v)
		end
	end

end

GameVariables.pairedAttack = nil -- the variable for which paired attack the attacker is doing
GameVariables.pairedBlock = nil -- the variable for which paired block the attacker is doing
GameVariables.pairedChain = 0 -- The tracker of the character's sync block attack chain. They can only do as many as the max allows
GameVariables.PairedChainMAX = 3 -- The max value for pairedChain.

-- User Input Types
GameVariables.AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.Touch] = true, [Enum.KeyCode.ButtonB] = true} -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
GameVariables.BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true}
GameVariables.GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true}
-- GameVariables.LockOnInputs = {Enum.KeyCode} -- May have LockOnInputs for each system

-- functions
function GameVariables.stopAnimations() -- add params? Perhaps we could change function to "changeAnimations" with the first parameter being whether we should stop or play, and add animations in following parameters
	GameVariables.FC_IdleTRACK:Stop()
end

function GameVariables.boolCheck(a, b, c)
	for _, v in pairs({a,b,c}) do
		if v == true then
			return false
		end
	end
-- if none of the bools are currently active (true) then the desired action can be completed as it won't interrupt any other action, so we return function as true.
	return true
end

function GameVariables.synchedBlock(sentAnimPair, followupCombo) -- Handles the sync block mechanic for both attacker and receiver
	warn(followupCombo)
	if GameVariables.pairedChain <= GameVariables.PairedChainMAX and GameVariables.canSyncBlock then
		
		if followupCombo and followupCombo > 1 or (GameVariables.pairedBlock and GameVariables.pairedBlock.IsPlaying) then -- For followup attacks
			warn("Are you somehow in here?")
			if GameVariables.pairedAttack and GameVariables.pairedAttack.IsPlaying then -- runs for the attacker
			GameVariables.pairedAttack:Stop()
			print("Are we good pleaseeeE?")
			if followupCombo == 3 then
				if GameVariables.animPair and GameVariables.animPair[1] == 1 then
					if GameVariables.animPair and GameVariables.animPair[2] == 1 then
						GameVariables.pairedAttack = GameVariables.FC_SyncBlock3L1TRACK
					elseif GameVariables.animPair and GameVariables.animPair[2] == 2 then
						GameVariables.pairedAttack = GameVariables.FC_SyncBlock3L2TRACK
					end
				elseif GameVariables.animPair and GameVariables.animPair[1] == 2 then
					if GameVariables.animPair and GameVariables.animPair[2] == 1 then
						GameVariables.pairedAttack = GameVariables.FC_SyncBlock3R1TRACK
					elseif GameVariables.animPair and GameVariables.animPair[2] == 2 then
						GameVariables.pairedAttack = GameVariables.FC_SyncBlock3R2TRACK
					end
				end
				warn(GameVariables.pairedAttack)
			else
				if GameVariables.pairedAttack == GameVariables.FC_SyncBlock1LTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock1RTRACK
				elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock1RTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock1LTRACK
				elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock2LTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock2RTRACK
				elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock2RTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock2LTRACK
				end
			end
				
			elseif GameVariables.pairedBlock and GameVariables.pairedBlock.IsPlaying then -- runs for the receiver
				GameVariables.pairedBlock:Stop()
				if followupCombo == 3 then
					if sentAnimPair and sentAnimPair[1] == 1 then
						if sentAnimPair and sentAnimPair[2] == 1 then
							GameVariables.pairedBlock = GameVariables.FC_SyncBlock3L1RECEIVERTRACK
						elseif sentAnimPair and sentAnimPair[2] == 2 then
							GameVariables.pairedBlock = GameVariables.FC_SyncBlock3L2RECEIVERTRACK
						end
					elseif sentAnimPair and sentAnimPair[1] == 2 then
						if sentAnimPair and sentAnimPair[2] == 1 then
							GameVariables.pairedBlock = GameVariables.FC_SyncBlock3R1RECEIVERTRACK
						elseif sentAnimPair and sentAnimPair[2] == 2 then
							GameVariables.pairedBlock = GameVariables.FC_SyncBlock3R2RECEIVERTRACK
						end
					end
				else
					if GameVariables.pairedBlock == GameVariables.FC_SyncBlock1LRECEIVERTRACK then
						GameVariables.pairedBlock = GameVariables.FC_SyncBlock1RRECEIVERTRACK
					elseif GameVariables.pairedBlock == GameVariables.FC_SyncBlock1RRECEIVERTRACK then
						GameVariables.pairedBlock = GameVariables.FC_SyncBlock1LRECEIVERTRACK
					elseif GameVariables.pairedBlock == GameVariables.FC_SyncBlock2LRECEIVERTRACK then
						GameVariables.pairedBlock = GameVariables.FC_SyncBlock2RRECEIVERTRACK
					elseif GameVariables.pairedBlock == GameVariables.FC_SyncBlock2RRECEIVERTRACK then
						GameVariables.pairedBlock = GameVariables.FC_SyncBlock2LRECEIVERTRACK
					end
				end
			end
				
		
		else -- for non-followup attacks
			if (sentAnimPair and sentAnimPair[1] == 1) or (GameVariables.animPair and GameVariables.animPair[1] == 1) then
				if (sentAnimPair and sentAnimPair[2] == 1) or (GameVariables.animPair and GameVariables.animPair[2] == 1) then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock1LTRACK
					GameVariables.pairedBlock = GameVariables.FC_SyncBlock1LRECEIVERTRACK
				elseif (sentAnimPair and sentAnimPair[2] == 2) or (GameVariables.animPair and GameVariables.animPair[2] == 2) then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock2LTRACK
					GameVariables.pairedBlock = GameVariables.FC_SyncBlock2LRECEIVERTRACK
				end
			
			elseif (sentAnimPair and sentAnimPair[1] == 2) or (GameVariables.animPair and GameVariables.animPair[1] == 2) then
				if (sentAnimPair and sentAnimPair[2] == 1) or (GameVariables.animPair and GameVariables.animPair[2] == 1) then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock1RTRACK
					GameVariables.pairedBlock = GameVariables.FC_SyncBlock1RRECEIVERTRACK
				elseif (sentAnimPair and sentAnimPair[2] == 2) or (GameVariables.animPair and GameVariables.animPair[2] == 2) then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock2RTRACK
					GameVariables.pairedBlock = GameVariables.FC_SyncBlock2RRECEIVERTRACK
				end
			end
		end
		
		GameVariables.pairedPlaying = true
	
		if not GameVariables.isBlocking then
			GameVariables.previousWalkSpeed = GameVariables.lockOnSpeed
		elseif GameVariables.isBlocking then
			GameVariables.previousWalkSpeed = GameVariables.lockOnSpeed / 1.5
		end
		
		GameVariables.humanoid.WalkSpeed = 0
		
		if GameVariables.isBlocking then
		print(sentAnimPair)
			GameVariables.pairedBlock:Play()
		
		elseif GameVariables.isAttacking and GameVariables.pairedAttack then -- Script breaks if pairedAttack doesn't exist, so we need to add it in as a check.
		
			GameVariables.currentAttack = GameVariables.pairedAttack.Animation
			
			if GameVariables.distanceBetween ~= 3 then -- we want the sync to happen at three studs ideally
				local enemyRoot = GameVariables.raycastResult.Instance.Parent.HumanoidRootPart
				
				local direction = enemyRoot.Position - GameVariables.humanoidRootPart.Position -- the direction toward the enemy from the player
				local normalizedDirection = direction.Unit -- makes the unit measuring toward the player equal to 1. It is the |absolute value|
				
				local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")

				local Info = TweenInfo.new(

					0.2,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					0

				)

				local tweenGoals = {}
				
				tweenGoals.CFrame = CFrame.new(enemyRoot.Position - normalizedDirection * 3) * CFrame.Angles(GameVariables.humanoidRootPart.CFrame:ToOrientation())
																							    -- This above basically makes the player maintain the same orientation.
				local repositionTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
				repositionTween:Play()
			end
				
			GameVariables.pairedAttack:Play()
			GameVariables.canFollowUp = true -- once the paired attack starts, the player can immediately follow up (when the animation ends that is)
			
		--end
		-- player will play their part of the synched block while the enemy does theirs.
		end
	end
end

function GameVariables.Set(givenObject, newValue)
    givenObject = newValue
	GameVariables.LocalBindableEvent:Fire(givenObject, newValue)
end

function GameVariables.Sync()
	GameVariables.LocalBindableEvent.Event:Connect(function(givenObject, newValue)
		givenObject = newValue
		print(givenObject)
		warn("neext")
	end)
end

function GameVariables.SetPlayer(givenPlayer)
	GameVariables.player = givenPlayer
	warn(tostring(givenPlayer) .. " is the player that has been set for " .. tostring(GameVariables.player))
end

return GameVariables