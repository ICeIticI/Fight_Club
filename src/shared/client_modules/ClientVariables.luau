-- local TweenService = game:GetService("TweenService")
local ClientVariables = {}
ClientVariables.__index = ClientVariables

ClientVariables.player = game:GetService("Players").LocalPlayer
ClientVariables.initialized = false

local function Init() -- The .CharacterAdded event doesn't always track when a player character is added. Sometimes the character spawns and beats the event. So just in case, this function was created to initialize (or reinitialize) variables that are crutial for the game to work.
	ClientVariables.initialized = false

	ClientVariables.character = ClientVariables.player.Character or ClientVariables.player.CharacterAdded:Wait()
	ClientVariables.humanoid = ClientVariables.character:WaitForChild("Humanoid")
	-- ClientVariables.previousHealth = ClientVariables.humanoid.Health -- This var is used to determine how much damage the character takes.

	ClientVariables.charAnimator = ClientVariables.character:WaitForChild("Humanoid"):WaitForChild("charAnimator")
	ClientVariables.humanoidRootPart = ClientVariables.character:WaitForChild("HumanoidRootPart")

	-- Hitbox stuff:
	--[[
	!
	ClientVariables.hitboxesFolder = ClientVariables.character:WaitForChild(ClientVariables.player.Name.."_hitboxesFolder")

	ClientVariables.hitboxHead = ClientVariables.hitboxesFolder:WaitForChild(ClientVariables.player.Name.."_hitboxHead")
	ClientVariables.hitboxLeftArm = ClientVariables.hitboxesFolder:WaitForChild(ClientVariables.player.Name.."_hitboxLeftArm")
	ClientVariables.hitboxLeftLeg = ClientVariables.hitboxesFolder:WaitForChild(ClientVariables.player.Name.."_hitboxLeftLeg")
	ClientVariables.hitboxRightArm = ClientVariables.hitboxesFolder:WaitForChild(ClientVariables.player.Name.."_hitboxRightArm")
	ClientVariables.hitboxRightLeg = ClientVariables.hitboxesFolder:WaitForChild(ClientVariables.player.Name.."_hitboxRightLeg")
	ClientVariables.hitboxTorso = ClientVariables.hitboxesFolder:WaitForChild(ClientVariables.player.Name.."_hitboxTorso")

	-- *Hitbox tables*
	ClientVariables.hitboxesFolderATTACK = {ClientVariables.hitboxLeftArm, ClientVariables.hitboxLeftLeg, ClientVariables.hitboxRightArm, ClientVariables.hitboxRightLeg}
	ClientVariables.hitboxesFolderRECEIVE = {ClientVariables.hitboxHead, ClientVariables.hitboxTorso}
]]
	-- ClientVariables.Protocol = nil
	-- ClientVariables.humanoid.JumpPower = 0

	-- Bools and Values:
	
	ClientVariables.lockOnDebounce = ClientVariables.plrObjectsFolder:FindFirstChild("lockOnDebounce") -- attemps to find lockOnDebounce. If it doesn't exist, then this var will be nil.

	if not ClientVariables.lockOnDebounce then
		ClientVariables.lockOnDebounce = Instance.new("BoolValue") -- shouldn't this be initialized by the server for more security?
		ClientVariables.lockOnDebounce.Name = "lockOnDebounce"
		ClientVariables.lockOnDebounce.Parent = ClientVariables.plrObjectsFolder
	end

	--[[
	ClientVariables.hitDebounce = false -- if false, then the player has the ability to deal damage. This is so the player won't hit the enemy multiple times in one attack.
	ClientVariables.isBlocking = false -- set to true when the client blocks
	ClientVariables.isAttacking = false
	ClientVariables.isCountering = false
	ClientVariables.isGettingHit = false
	ClientVariables.pairedPlaying = false -- used to make sure the paired animations don't play while already playing.
	ClientVariables.waitingToAttack = false
	ClientVariables.canSyncBlock = true
	ClientVariables.previousWalkSpeed = nil

	ClientVariables.attackFrames = false -- when the StartOfAttack marker fires in attack anims, this allows damage to pass

	ClientVariables.isDodging = false
	ClientVariables.canFollowUp = false -- The status of whether a player is able to do a followup attack. If its true, then that means they are able to do one. 
	ClientVariables.isEnemyHoldingBlock = false -- for attacks to be synched attacks when blocked in a synched block.
	ClientVariables.followUpCount = 0 -- followUpCount is used so a followup wont be done twice back to back when a follow up is done
	ClientVariables.lastAttackTrack = nil
	ClientVariables.comboCounter = 0
	
	ClientVariables.currentAttack = nil		

		ClientVariables.attackSeries = nil
	-- ClientVariables.randAttack = nil
	ClientVariables.distanceBetween = nil
	ClientVariables.enemyHumanoid = nil -- pre-defined enemy Humanoid because the script hates global variables. Used for the enemy.
	ClientVariables.enemyChar = nil

		ClientVariables.attackerCFrame = nil -- When the character gets struck, this variable will equal the CFrame of the attacker's HumanoidRootPart so we can move the character a direction if the hit is significant
	ClientVariables.enemyCurrentAttack = nil -- used when the enemy would start an attack via the AttackStarted protocol that gets sent when one starts
	ClientVariables.randLvl1Type = nil -- Used to determine what lvl 1 attacks the player will use for said combo
	ClientVariables.animPair = nil
	
	-- New Variables that are replacing old:
	ClientVariables.canAttack = false
	ClientVariables.canGetHit = false
	ClientVariables.areLockedOn = false
	-- Above are new variables that will be replacing old ^
	
	ClientVariables.dodgeAttackTrack = nil
	]]								
	ClientVariables.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim

	-- Loading animation tracks:
	--[[
	!
	ClientVariables.FC_IdleTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_Idle)
	ClientVariables.FC_BlockTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_Block)
	ClientVariables.FC_BlockStartTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_BlockStart)
	ClientVariables.FC_LeftHook1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftHook1)
	ClientVariables.FC_RightHook1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightHook1)
	ClientVariables.FC_LeftJabTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftJab)
	ClientVariables.FC_RightJabTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightJab)
	ClientVariables.FC_LeftUppercutTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftUppercut)
	ClientVariables.FC_RightUppercutTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightUppercut)
	ClientVariables.FC_LeftHaymakerTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftHaymaker)
	ClientVariables.FC_RightHaymakerTrack = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightHaymaker)

	-- *animation tracks (receiver)*
	ClientVariables.FC_LeftHook1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftHook1RECEIVER)
	ClientVariables.FC_RightHook1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightHook1RECEIVER)
	ClientVariables.FC_LeftUppercutRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftUppercutRECEIVER)
	ClientVariables.FC_RightUppercutRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightUppercutRECEIVER)
	ClientVariables.FC_LeftHaymakerRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftHaymakerRECEIVER)
	ClientVariables.FC_RightHaymakerReceiverTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightHaymakerRECEIVER)

	-- *animation tracks (paired)*
	ClientVariables.FC_SyncBlock1LTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock1L)
	ClientVariables.FC_SyncBlock1LRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock1LRECEIVER)
	ClientVariables.FC_SyncBlock1RTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock1R)
	ClientVariables.FC_SyncBlock1RRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock1RRECEIVER)
	ClientVariables.FC_SyncBlock2LTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock2L)
	ClientVariables.FC_SyncBlock2LRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock2LRECEIVER)
	ClientVariables.FC_SyncBlock2RTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock2R)
	ClientVariables.FC_SyncBlock2RRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock2RRECEIVER)
	ClientVariables.FC_SyncBlock3L1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3L1)
	ClientVariables.FC_SyncBlock3L1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3L1RECEIVER)
	ClientVariables.FC_SyncBlock3R1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3R1)
	ClientVariables.FC_SyncBlock3R1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3R1RECEIVER)
	ClientVariables.FC_SyncBlock3L2TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3L2)
	ClientVariables.FC_SyncBlock3L2RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3L2RECEIVER)
	ClientVariables.FC_SyncBlock3R2TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3R2)
	ClientVariables.FC_SyncBlock3R2RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_SyncBlock3R2RECEIVER)
	ClientVariables.FC_BracingBlockLTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_BracingBlockL)
	ClientVariables.FC_BracingBlockRTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_BracingBlockR)
	ClientVariables.FC_LeftParryTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftParry)
	ClientVariables.FC_LeftParryRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftParryRECEIVER)
	ClientVariables.FC_RightParryTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightParry)
	ClientVariables.FC_RightParryRECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightParryRECEIVER)
	ClientVariables.FC_RightCounter1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightCounter1)
	ClientVariables.FC_RightCounter1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightCounter1RECEIVER)
	ClientVariables.FC_LeftCounter1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftCounter1)
	ClientVariables.FC_LeftCounter1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftCounter1RECEIVER)
	
	ClientVariables.FC_RightCounter2TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightCounter2)
	ClientVariables.FC_RightCounter2RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightCounter2RECEIVER)
	ClientVariables.FC_LeftCounter2TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftCounter2)
	ClientVariables.FC_LeftCounter2RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftCounter2RECEIVER)


	-- *animation tracks (dodges)*
	ClientVariables.FC_LeftDodgeTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LeftDodge)
	ClientVariables.FC_RightDodgeTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RightDodge)
	ClientVariables.FC_BackDodgeTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_BackDodge)

	-- *animation tracks (dodge attacks)*
	ClientVariables.FC_LDodgeAttack1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LDodgeAttack1)
	ClientVariables.FC_LDodgeAttack1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_LDodgeAttack1RECEIVER)
	ClientVariables.FC_RDodgeAttack1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RDodgeAttack1)
	ClientVariables.FC_RDodgeAttack1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_RDodgeAttack1RECEIVER)
	ClientVariables.FC_BDodgeAttack1TRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_BDodgeAttack1)
	ClientVariables.FC_BDodgeAttack1RECEIVERTRACK = ClientVariables.charAnimator:LoadAnimation(ClientVariables.FC_BDodgeAttack1RECEIVER)

	-- *Animation track tables*
	ClientVariables.AllAnimations = { -- Table for managing all animation TRACKS.
	ClientVariables.FC_IdleTRACK, ClientVariables.FC_BlockStartTRACK, ClientVariables.FC_BlockTRACK,
	ClientVariables.FC_LeftHook1TRACK, ClientVariables.FC_RightHook1TRACK, 
	ClientVariables.FC_LeftJabTRACK, ClientVariables.FC_RightJabTRACK,
	ClientVariables.FC_LeftUppercutTRACK, ClientVariables.FC_RightUppercutTRACK, 
	ClientVariables.FC_LeftHaymakerTRACK, ClientVariables.FC_RightHaymakerTrack, 
	ClientVariables.FC_LeftHook1RECEIVERTRACK, ClientVariables.FC_RightHook1RECEIVERTRACK, 
	ClientVariables.FC_LeftUppercutRECEIVERTRACK, ClientVariables.FC_RightUppercutRECEIVERTRACK, 
	ClientVariables.FC_LeftHaymakerRECEIVERTRACK, ClientVariables.FC_RightHaymakerReceiverTRACK,
	ClientVariables.FC_SyncBlock1LTRACK, ClientVariables.FC_SyncBlock1LRECEIVERTRACK,
	ClientVariables.FC_SyncBlock1RTRACK, ClientVariables.FC_SyncBlock1RRECEIVERTRACK,
	ClientVariables.FC_SyncBlock2LTRACK, ClientVariables.FC_SyncBlock2LRECEIVERTRACK,
	ClientVariables.FC_SyncBlock2RTRACK, ClientVariables.FC_SyncBlock2RRECEIVERTRACK,
	ClientVariables.FC_SyncBlock3L1TRACK, ClientVariables.FC_SyncBlock3L1RECEIVERTRACK,
	ClientVariables.FC_SyncBlock3R1TRACK, ClientVariables.FC_SyncBlock3R1RECEIVERTRACK,
	ClientVariables.FC_SyncBlock3L2TRACK, ClientVariables.FC_SyncBlock3L2RECEIVERTRACK,
	ClientVariables.FC_SyncBlock3R2TRACK, ClientVariables.FC_SyncBlock3R2RECEIVERTRACK,
	ClientVariables.FC_BracingBlockLTRACK, ClientVariables.FC_BracingBlockRTRACK,
	ClientVariables.FC_LeftParryTRACK, ClientVariables.FC_LeftParryRECEIVERTRACK,
	ClientVariables.FC_RightParryTRACK, ClientVariables.FC_RightParryRECEIVERTRACK,
	ClientVariables.FC_RightCounter1TRACK, ClientVariables.FC_RightCounter1RECEIVERTRACK,
	ClientVariables.FC_LeftCounter1TRACK, ClientVariables.FC_LeftCounter1RECEIVERTRACK,
	ClientVariables.FC_RightCounter2TRACK, ClientVariables.FC_RightCounter2RECEIVERTRACK,
	ClientVariables.FC_LeftCounter2TRACK, ClientVariables.FC_LeftCounter2RECEIVERTRACK,
	ClientVariables.FC_LeftDodgeTRACK, ClientVariables.FC_RightDodgeTRACK,
	ClientVariables.FC_LDodgeAttack1TRACK, ClientVariables.FC_LDodgeAttack1RECEIVERTRACK,
	ClientVariables.FC_RDodgeAttack1TRACK, ClientVariables.FC_RDodgeAttack1RECEIVERTRACK,
	ClientVariables.FC_BDodgeAttack1TRACK, ClientVariables.FC_BDodgeAttack1RECEIVERTRACK
	
	}

	ClientVariables.attack1Table = {}
	ClientVariables.attack2Table = {}

	ClientVariables.pairedAttacksTable = {} -- the for loop below will fill this with all of the attacking paired animations
	ClientVariables.pairedBlocksTable = {} -- same above except for receiving animations.
	
	ClientVariables.counterAttacksTable = {}
	ClientVariables.dodgeAttacksTable = {}

	for _, v in pairs(ClientVariables.AllAnimations) do -- this for loop fills in the attack1 and attack2Table based off attributes
		if v.Animation:GetAttribute("AttackSeries") then -- standard attacks have the "AttackSeries" attribute so its how we define it as a stnadard attack
			if v.Animation:GetAttribute("AttackLevel") == 1 then -- level 1's will be added to the attack1Table
				table.insert(ClientVariables.attack1Table, v)
			elseif v.Animation:GetAttribute("AttackLevel") == 2 then -- level 2's will be added to the attack2Table
				table.insert(ClientVariables.attack2Table, v)
			end
		elseif v.Animation:GetAttribute("Paired") then -- adds paired animations into either pairedAttacks or pairedBlocks
			if v.Animation:GetAttribute("AnimType") == 1 then

				if v.Animation:GetAttribute("Counter") and not v.Animation:GetAttribute("DodgeAttack") then
					-- is a counter attack
					table.insert(ClientVariables.counterAttacksTable, v)
				elseif v.Animation:GetAttribute("DodgeAttack") then
					-- is a dodge attack
					table.insert(ClientVariables.dodgeAttacksTable, v)
				end
				table.insert(ClientVariables.pairedAttacksTable, v)

			elseif v.Animation:GetAttribute("AnimType") == 2 then
				table.insert(ClientVariables.pairedBlocksTable, v)
			end
		end
	end

	-- for _, v in pairs(ClientVariables.AllAnimations) do
	-- 	if v.Animation:GetAttribute("Paired") then
	-- 		if v.Animation:GetAttribute("AnimType") == 1 then
	-- 			table.insert(ClientVariables.pairedAttacksTable, v)
	-- 		elseif v.Animation:GetAttribute("AnimType") == 2 then
	-- 			table.insert(ClientVariables.pairedBlocksTable, v)
	-- 		end
	-- 	end
	-- end
]]

--[[
	ClientVariables.pairedAttack = nil -- the variable for which paired attack the attacker is doing
	ClientVariables.pairedBlock = nil -- the variable for which paired block the attacker is doing
	ClientVariables.pairedChain = 0 -- The tracker of the character's sync block attack chain. They can only do as many as the max allows
]]

	ClientVariables.stamina = ClientVariables.plrObjectsFolder:WaitForChild("stamina")

	ClientVariables.initialized = true
	return print("Initialized the client variables")
end

ClientVariables.Camera = game.Workspace.CurrentCamera
ClientVariables.plrObjectsFolder = ClientVariables.player:WaitForChild(ClientVariables.player.Name .. "_GameObjects") -- perhaps change it from player.Name to player.playerId for saving and stuff in the future

-- Global Remote Event - Because each player having their own remote event is redundant.
ClientVariables.GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")
-- Global Remote Function - Like the Global Remote Event, but used when we specifically want something returned
ClientVariables.GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

--[[
ClientVariables.LocalBindableEvent = Instance.new("BindableEvent")
ClientVariables.LocalBindableEvent.Name = "LocalBindableEvent"
ClientVariables.LocalBindableEvent.Parent = game.ReplicatedStorage
]]

-- NOTE*: Perhaps instead of creating a bunch of animations, we make a single animation then when the player needs to animate, load the animId into the animation. Id's would prob be in a table.

-- *animations (attacker)*
--[[
ClientVariables.FC_Idle = ClientVariables.plrObjectsFolder:WaitForChild("FC_Idle")
ClientVariables.FC_Block = ClientVariables.plrObjectsFolder:WaitForChild("FC_Block")
ClientVariables.FC_BlockStart = ClientVariables.plrObjectsFolder:WaitForChild("FC_BlockStart")
ClientVariables.FC_LeftHook1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftHook1")
ClientVariables.FC_RightHook1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightHook1")
ClientVariables.FC_LeftJab = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftJab")
ClientVariables.FC_RightJab = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightJab")
ClientVariables.FC_LeftUppercut = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftUppercut")
ClientVariables.FC_RightUppercut = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightUppercut")
ClientVariables.FC_LeftHaymaker = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftHaymaker")
ClientVariables.FC_RightHaymaker = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightHaymaker")

-- *animations (receiver)*
ClientVariables.FC_LeftHook1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftHook1RECEIVER")
ClientVariables.FC_RightHook1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightHook1RECEIVER")
ClientVariables.FC_LeftUppercutRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftUppercutRECEIVER")
ClientVariables.FC_RightUppercutRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightUppercutRECEIVER")
ClientVariables.FC_LeftHaymakerRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftHaymakerRECEIVER")
ClientVariables.FC_RightHaymakerRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightHaymakerRECEIVER")

-- *animations (paired)*
ClientVariables.FC_SyncBlock1L = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1L")
ClientVariables.FC_SyncBlock1LRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1LRECEIVER")
ClientVariables.FC_SyncBlock1R = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1R")
ClientVariables.FC_SyncBlock1RRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1RRECEIVER")
ClientVariables.FC_SyncBlock2L = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2L")
ClientVariables.FC_SyncBlock2LRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2LRECEIVER")
ClientVariables.FC_SyncBlock2R = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2R")
ClientVariables.FC_SyncBlock2RRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2RRECEIVER")
ClientVariables.FC_SyncBlock3L1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L1")
ClientVariables.FC_SyncBlock3L1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L1RECEIVER")
ClientVariables.FC_SyncBlock3R1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R1")
ClientVariables.FC_SyncBlock3R1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R1RECEIVER")
ClientVariables.FC_SyncBlock3L2 = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L2")
ClientVariables.FC_SyncBlock3L2RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3L2RECEIVER")
ClientVariables.FC_SyncBlock3R2 = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R2")
ClientVariables.FC_SyncBlock3R2RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock3R2RECEIVER")
ClientVariables.FC_BracingBlockL = ClientVariables.plrObjectsFolder:WaitForChild("FC_BracingBlockL")
ClientVariables.FC_BracingBlockR = ClientVariables.plrObjectsFolder:WaitForChild("FC_BracingBlockR")
ClientVariables.FC_LeftParry = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftParry")
ClientVariables.FC_LeftParryRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftParryRECEIVER")
ClientVariables.FC_RightParry = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightParry")
ClientVariables.FC_RightParryRECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightParryRECEIVER")
ClientVariables.FC_RightCounter1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightCounter1")
ClientVariables.FC_RightCounter1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightCounter1RECEIVER")
ClientVariables.FC_LeftCounter1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftCounter1")
ClientVariables.FC_LeftCounter1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftCounter1RECEIVER")
ClientVariables.FC_RightCounter2 = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightCounter2")
ClientVariables.FC_RightCounter2RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightCounter2RECEIVER")
ClientVariables.FC_LeftCounter2 = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftCounter2")
ClientVariables.FC_LeftCounter2RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftCounter2RECEIVER")


-- *animations (dodges)*
ClientVariables.FC_LeftDodge = ClientVariables.plrObjectsFolder:WaitForChild("FC_LeftDodge")
ClientVariables.FC_RightDodge = ClientVariables.plrObjectsFolder:WaitForChild("FC_RightDodge")
ClientVariables.FC_BackDodge = ClientVariables.plrObjectsFolder:WaitForChild("FC_BackDodge")

-- *animations (dodge attacks)*
ClientVariables.FC_LDodgeAttack1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_LDodgeAttack1")
ClientVariables.FC_LDodgeAttack1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_LDodgeAttack1RECEIVER")
ClientVariables.FC_RDodgeAttack1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_RDodgeAttack1")
ClientVariables.FC_RDodgeAttack1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_RDodgeAttack1RECEIVER")
ClientVariables.FC_BDodgeAttack1 = ClientVariables.plrObjectsFolder:WaitForChild("FC_BDodgeAttack1")
ClientVariables.FC_BDodgeAttack1RECEIVER = ClientVariables.plrObjectsFolder:WaitForChild("FC_BDodgeAttack1RECEIVER")
]]
-- ClientVariables.walkingSpeed = 12
-- ClientVariables.PairedChainMAX = 3 -- The max value for pairedChain.

-- User Input Types
ClientVariables.AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.Touch] = true, [Enum.KeyCode.ButtonB] = true} -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
ClientVariables.BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true}
ClientVariables.GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true}
ClientVariables.LockOnInputs = {[Enum.KeyCode.Q] = true, [Enum.KeyCode.ButtonL2] = true} -- May have LockOnInputs for each system

--ClientVariables.humanoid = nil -- we need this here because the script doesn't know what is connected to the .Died event until the .Init() function runs, but this :Connect will begin checking as soon as the script reaches it, so we need it to at least exist as a variable before using it in a built-in event.
local canInit = true -- local variable that dictates when the script is able to initialize the Init() function. We don't want it running twice, as that will just be creating unnecessairy load times.
local humanoidDiedConnect -- the :Connect() event for when the player's current humanoid dies.

ClientVariables.player.CharacterAdded:Connect(function()
	if canInit then
		Init()
		canInit = false
	end

	humanoidDiedConnect = ClientVariables.humanoid.Died:Connect(function()
		canInit = true
		ClientVariables.initialized = false
		
		-- Disconnect the .Died event so we don't have .Died connects of the player's past dead humanoids running, which will be re-initialized on next player character spawn:
		humanoidDiedConnect:Disconnect()
	 end)

end)

 -- find a way to make sure these two Init() functions don't both run. Only one Init() should run when the player character spawns in.

 if ClientVariables.player.Character then
	if canInit then
		Init()
		canInit = false
	end

	ClientVariables.humanoid.Died:Connect(function()
		canInit = true
		ClientVariables.initialized = false
	 end)

end

while not ClientVariables.humanoid do -- will wait until the humanoid exists.
	task.wait()
end

-- origins
-- ClientVariables.originalWalkSpeed = ClientVariables.humanoid.WalkSpeed
ClientVariables.originalCamFocus = ClientVariables.Camera.Focus
ClientVariables.originalCamSubject = ClientVariables.Camera.CameraSubject

-- ClientVariables.lockOnSpeed = ClientVariables.originalWalkSpeed / 1.85

-- functions
function ClientVariables.stopAnimations() -- add params? Perhaps we could change function to "changeAnimations" with the first parameter being whether we should stop or play, and add animations in following parameters
	ClientVariables.FC_IdleTRACK:Stop()
end
--[[
function ClientVariables.boolCheck(boolTable)
	for _, v in pairs(boolTable) do
		if v == true then
			return false
		end
	end
-- if none of the bools are currently active (true) then the desired action can be completed as it won't interrupt any other action, so we return function as true.
	return true
end

function ClientVariables.SetSpeed(bool) -- Function that manages the character speed based on the character circumstances. Adding 'true' into the parameter will allow the character to move while adding 'false' will not allow movement.
	if bool == true then
		print("giving back speed")
		-- we allow the player the ability to move

		if ClientVariables.pairedPlaying == false and ClientVariables.lockOnDebounce.Value then -- if the player isn't in a paired animation, then

			if not ClientVariables.isBlocking then
				ClientVariables.previousWalkSpeed = ClientVariables.lockOnSpeed
			elseif ClientVariables.isBlocking then
				ClientVariables.previousWalkSpeed = ClientVariables.lockOnSpeed / 1.5
			end

			ClientVariables.humanoid.WalkSpeed = ClientVariables.previousWalkSpeed
		else
			ClientVariables.humanoid.WalkSpeed = ClientVariables.originalWalkSpeed
		end

	elseif bool == false then
		print("taking away speed")
		-- we take the player's ability to move away
		ClientVariables.humanoid.WalkSpeed = 0
	end
end

-- Move this function to the server:

function ClientVariables.reset() --[[ Will set variables of the player back to what they were origianlly, giving the player their default controls back.
	ClientVariables.isDodging = false
	ClientVariables.isCountering = false
	ClientVariables.isGettingHit = false
	
	ClientVariables.canFollowUp = false
	ClientVariables.hitDebounce = false
	ClientVariables.attackFrames = false
	ClientVariables.waitingToAttack = false
	
	
	if (ClientVariables.attackTrack and not ClientVariables.attackTrack.IsPlaying) or (ClientVariables.pairedAttack and not ClientVariables.pairedAttack.IsPlaying) then
			ClientVariables.attackTrack = nil
			ClientVariables.currentAttack = nil
			ClientVariables.followUpCount = 0
			ClientVariables.comboCounter = 0
			ClientVariables.isAttacking = false
			ClientVariables.canSyncBlock = true
			ClientVariables.pairedPlaying = false
			ClientVariables.pairedChain = 0
	end
	if ClientVariables.currentReceiveAnimTRACK and not ClientVariables.currentReceiveAnimTRACK.IsPlaying then
		ClientVariables.currentReceiveAnimTRACK = nil
		ClientVariables.pairedChain = 0
	end
	-- ClientVariables.animPair = nil


	ClientVariables.SetSpeed(true)

end

function ClientVariables.repositionInFrontOfEnemy() --[[ repositions the character in front of the enemy. 

	ClientVariables.character:WaitForChild("HumanoidRootPart").CFrame = 
	CFrame.new(ClientVariables.enemyChar:WaitForChild("HumanoidRootPart").Position 
				+ ClientVariables.enemyChar.HumanoidRootPart.CFrame.LookVector * 3 
				, ClientVariables.enemyChar.HumanoidRootPart.Position)

end

function ClientVariables.synchedBlock(sentAnimPair, followupCombo) -- Handles the sync block mechanic for both attacker and receiver
	if ClientVariables.pairedChain <= ClientVariables.PairedChainMAX and ClientVariables.canSyncBlock then
		if followupCombo and followupCombo > 1 or (ClientVariables.pairedBlock and ClientVariables.pairedBlock.IsPlaying) then -- For followup attacks
			
			if ClientVariables.pairedAttack and ClientVariables.pairedAttack.IsPlaying then -- runs for the attacker
				
				ClientVariables.pairedAttack:Stop()
				if followupCombo == 3 then

					if ClientVariables.animPair and ClientVariables.animPair[1] == 1 then
						if ClientVariables.animPair and ClientVariables.animPair[2] == 1 then
							ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock3L1TRACK
						elseif ClientVariables.animPair and ClientVariables.animPair[2] == 2 then
							ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock3L2TRACK
						end
					elseif ClientVariables.animPair and ClientVariables.animPair[1] == 2 then
						if ClientVariables.animPair and ClientVariables.animPair[2] == 1 then
							ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock3R1TRACK
						elseif ClientVariables.animPair and ClientVariables.animPair[2] == 2 then
							ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock3R2TRACK
						end
					end
					
				else

					if ClientVariables.pairedAttack == ClientVariables.FC_SyncBlock1LTRACK then
						ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock1RTRACK
					elseif ClientVariables.pairedAttack == ClientVariables.FC_SyncBlock1RTRACK then
						ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock1LTRACK
					elseif ClientVariables.pairedAttack == ClientVariables.FC_SyncBlock2LTRACK then
						ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock2RTRACK
					elseif ClientVariables.pairedAttack == ClientVariables.FC_SyncBlock2RTRACK then
						ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock2LTRACK
					end
				
				end
				
			elseif ClientVariables.pairedBlock and ClientVariables.pairedBlock.IsPlaying then -- runs for the receiver
				
				ClientVariables.pairedBlock:Stop()
				if followupCombo == 3 then
					
					if sentAnimPair and sentAnimPair[1] == 1 then
						if sentAnimPair and sentAnimPair[2] == 1 then
							ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock3L1RECEIVERTRACK
						elseif sentAnimPair and sentAnimPair[2] == 2 then
							ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock3L2RECEIVERTRACK
						end
					
					elseif sentAnimPair and sentAnimPair[1] == 2 then
						
						if sentAnimPair and sentAnimPair[2] == 1 then
							ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock3R1RECEIVERTRACK
						elseif sentAnimPair and sentAnimPair[2] == 2 then
							ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock3R2RECEIVERTRACK
						end
					
					end

				else

					if ClientVariables.pairedBlock == ClientVariables.FC_SyncBlock1LRECEIVERTRACK then
						ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock1RRECEIVERTRACK
					elseif ClientVariables.pairedBlock == ClientVariables.FC_SyncBlock1RRECEIVERTRACK then
						ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock1LRECEIVERTRACK
					elseif ClientVariables.pairedBlock == ClientVariables.FC_SyncBlock2LRECEIVERTRACK then
						ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock2RRECEIVERTRACK
					elseif ClientVariables.pairedBlock == ClientVariables.FC_SyncBlock2RRECEIVERTRACK then
						ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock2LRECEIVERTRACK
					end

				end
				
			end
				
		
		else -- for non-followup attacks
			
			if (sentAnimPair and sentAnimPair[1] == 1) or (ClientVariables.animPair and ClientVariables.animPair[1] == 1) then
				if (sentAnimPair and sentAnimPair[2] == 1) or (ClientVariables.animPair and ClientVariables.animPair[2] == 1) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock1LTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock1LRECEIVERTRACK
				elseif (sentAnimPair and sentAnimPair[2] == 2) or (ClientVariables.animPair and ClientVariables.animPair[2] == 2) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock2LTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock2LRECEIVERTRACK
				end
			
			elseif (sentAnimPair and sentAnimPair[1] == 2) or (ClientVariables.animPair and ClientVariables.animPair[1] == 2) then
				if (sentAnimPair and sentAnimPair[2] == 1) or (ClientVariables.animPair and ClientVariables.animPair[2] == 1) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock1RTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock1RRECEIVERTRACK
				elseif (sentAnimPair and sentAnimPair[2] == 2) or (ClientVariables.animPair and ClientVariables.animPair[2] == 2) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock2RTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock2RRECEIVERTRACK
				end
			end
		end
		
		ClientVariables.pairedPlaying = true
	
		-- if not ClientVariables.isBlocking then
		-- 	ClientVariables.previousWalkSpeed = ClientVariables.lockOnSpeed
		-- elseif ClientVariables.isBlocking then
		-- 	ClientVariables.previousWalkSpeed = ClientVariables.lockOnSpeed / 1.5
		-- end
		
		-- ClientVariables.humanoid.WalkSpeed = 0
		ClientVariables.SetSpeed(false)
		if ClientVariables.isBlocking then
			ClientVariables.pairedBlock:Play()
		
		elseif ClientVariables.pairedAttack and not ClientVariables.isBlocking then -- Script breaks if pairedAttack doesn't exist, so we need to add it in as a check.
			ClientVariables.currentAttack = ClientVariables.pairedAttack.Animation
			
			if ClientVariables.distanceBetween ~= 3 then -- we want the sync to happen at three studs ideally
				local enemyRoot = ClientVariables.raycastResult.Instance.Parent.HumanoidRootPart
				
				local direction = enemyRoot.Position - ClientVariables.humanoidRootPart.Position -- the direction toward the enemy from the player
				local normalizedDirection = direction.Unit -- makes the unit measuring toward the player equal to 1. It is the |absolute value|
				
				local tweenPart = ClientVariables.character:WaitForChild("HumanoidRootPart")

				local Info = TweenInfo.new(

					0.2,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					0

				)

				local tweenGoals = {}
				
				tweenGoals.CFrame = CFrame.new(enemyRoot.Position - normalizedDirection * 3) * CFrame.Angles(ClientVariables.humanoidRootPart.CFrame:ToOrientation())
																							    -- This above basically makes the player maintain the same orientation.
				local repositionTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
				repositionTween:Play()
			end
				
			ClientVariables.pairedAttack:Play()
			ClientVariables.canFollowUp = true -- once the paired attack starts, the player can immediately follow up (when the animation ends that is)
			
		--end
		-- player will play their part of the synched block while the enemy does theirs.
		end
	end
end

function ClientVariables.block(bool)
	if bool == true then
		ClientVariables.FC_BlockStartTRACK:Play()
		ClientVariables.humanoid.WalkSpeed /= 1.5
	else
		ClientVariables.isBlocking = false
		-- ClientVariables.canSyncBlock = false
		ClientVariables.FC_BlockStartTRACK:Stop()
		ClientVariables.FC_BlockTRACK:Stop()
		if not ClientVariables.isGettingHit then
			ClientVariables.SetSpeed(true)
		end
	end
end

function ClientVariables.getPublicPlayerInstance(plrName) --[[ Function that will fetch from the server the public playerInstance values in a single table, replicating the playerInstance, so the client can use it for checks. Will return nil if there is no such player in the game.
    -- print(plrName)
	local protocol = "getPlayerInstance"
    return ClientVariables.GlobalRemoteFunction:InvokeServer(protocol, plrName)
end

function ClientVariables.setPublicPlayerVariable(var, value) --[[ Function that will change a given public variable to a given value from the local player's playerInstance located on the server. If the variable doesn't exist, then it will create a new public variable. 
	
	local protocol = "setPlayerVariable"
	ClientVariables.GlobalRemoteEvent:FireServer(var, protocol, value)
end

function ClientVariables.setLinearVelocity(velocity, durationOfVelocity) --[[ Function that will set the VectorForce of the player's character to the given Vector3. 
	local protocol = "SetLinearVelocity"
	ClientVariables.GlobalRemoteEvent:FireServer(velocity, protocol, durationOfVelocity)
end

function ClientVariables.setCharacterCFrame(char, newCFrame) --[[ Will set the character position on the server so it's changes will more accurately reflect across the server. 
	local HRP = char:WaitForChild("HumanoidRootPart")
	local protocol = "setCharacterCFrame"
	ClientVariables.GlobalRemoteEvent:FireServer(char, protocol, newCFrame)
end


function ClientVariables.Set(givenObject, newValue)
    givenObject = newValue
	ClientVariables.LocalBindableEvent:Fire(givenObject, newValue)
end

function ClientVariables.Sync()
	ClientVariables.LocalBindableEvent.Event:Connect(function(givenObject, newValue)
		givenObject = newValue
		print(givenObject)
		warn("neext")
	end)
end

function ClientVariables.SetPlayer(givenPlayer)
	ClientVariables.player = givenPlayer
	warn(tostring(givenPlayer) .. " is the player that has been set for " .. tostring(ClientVariables.player))
end
]]

return ClientVariables