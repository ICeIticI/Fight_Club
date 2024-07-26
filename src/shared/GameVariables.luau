local GameVariables = {}

GameVariables.player = game:GetService("Players").LocalPlayer

while not GameVariables.player do
	wait(0.1)
	print("waiting for player...")
	if GameVariables.player ~= nil then
		warn("WEEE'REE FREEEE")
		break
	end
end

print(GameVariables.player)
GameVariables.character = GameVariables.player.Character or GameVariables.player.CharacterAdded:Wait()
GameVariables.humanoid = GameVariables.character:WaitForChild("Humanoid")
GameVariables.previousHealth = GameVariables.humanoid.Health -- This var is used to determine how much damage the character takes.
GameVariables.charAnimator = GameVariables.character:WaitForChild("Humanoid"):WaitForChild("charAnimator")
GameVariables.humanoidRootPart = GameVariables.character:WaitForChild("HumanoidRootPart")
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
GameVariables.plrObjectsFolder = GameVariables.player:WaitForChild(GameVariables.player.Name .. "_GameObjects")

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

-- origins
GameVariables.originalWalkSpeed = GameVariables.humanoid.WalkSpeed
GameVariables.originalCamFocus = GameVariables.Camera.Focus
GameVariables.originalCamSubject = GameVariables.Camera.CameraSubject

--bools and values
GameVariables.lockOnDebounce = Instance.new("BoolValue") -- shouldn't this be initialized by the server for more security?
GameVariables.lockOnDebounce.Name = "lockOnDebounce"
GameVariables.lockOnDebounce.Parent = GameVariables.plrObjectsFolder
GameVariables.hitDebounce = false
GameVariables.isBlocking = false
GameVariables.isAttacking = false
GameVariables.waitingToAttack = false
GameVariables.pairedPlaying = false -- used to make sure the paired animations don't play while already playing.
GameVariables.previousWalkSpeed = nil

GameVariables.lockOnSpeed = GameVariables.originalWalkSpeed / 1.85
GameVariables.attackFrames = false -- when the StartOfAttack marker fires in attack anims, this allows damage to pass
--GameVariables.attackEnded = false

GameVariables.isDodging = false
GameVariables.canFollowUp = false
GameVariables.isEnemyHoldingBlock = false -- for attacks to be synched attacks when blocked in a synched block.
GameVariables.followUpCount = 0 -- followUpCount is used so a followup wont be done twice back to back when a follow up is done
GameVariables.lastAttack = nil
GameVariables.comboCounter = 0
GameVariables.parryWindow = 0.5
GameVariables.currentAttack = nil										
--GameVariables.enemyCurrentAttackID = nil -- the anim id the enemy attacked the player with
GameVariables.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim
GameVariables.currentDirection = nil
GameVariables.attackSeries = nil
GameVariables.randAttack = nil
GameVariables.distanceBetween = nil
GameVariables.enemyHumanoid = nil -- pre-defined enemyHumanoid because the script hates global variables. Used for the enemy.
GameVariables.enemyChar = nil
GameVariables.randLvl1Type = nil --[[ Used to determine what lvl 1 attacks
					   the player will use for said combo ]]

GameVariables.animPair = nil

GameVariables.actionTable = {GameVariables.isBlocking, GameVariables.isAttacking, GameVariables.isDodging}

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
	GameVariables.FC_SyncBlock2RTRACK, GameVariables.FC_SyncBlock2RRECEIVERTRACK
}

GameVariables.attack1Table = {GameVariables.FC_LeftHook1TRACK, GameVariables.FC_RightHook1TRACK, GameVariables.FC_LeftJabTRACK, GameVariables.FC_RightJabTRACK, GameVariables.FC_LeftUppercutTRACK, GameVariables.FC_RightUppercutTRACK}
GameVariables.attack2Table = {GameVariables.FC_LeftHaymakerTRACK, GameVariables.FC_RightHaymakerTrack}

GameVariables.pairedAttacksTable = {GameVariables.FC_SyncBlock1LTRACK, GameVariables.FC_SyncBlock1RTRACK, GameVariables.FC_SyncBlock2LTRACK, GameVariables.FC_SyncBlock2RTRACK}
GameVariables.pairedBlocksTable = {GameVariables.FC_SyncBlock1LRECEIVERTRACK, GameVariables.FC_SyncBlock1RRECEIVERTRACK, GameVariables.FC_SyncBlock2LRECEIVERTRACK, GameVariables.FC_SyncBlock2RRECEIVERTRACK}
GameVariables.pairedAttack = nil
GameVariables.pairedBlock = nil
GameVariables.pairedChain = 0 -- players can only do 2 sync block attacks in a row.

GameVariables.TestObject = 12

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
	if GameVariables.pairedChain <= 2 then
		
		if followupCombo or (GameVariables.pairedBlock and GameVariables.pairedBlock.IsPlaying) then -- For followup attacks
			if GameVariables.pairedAttack and GameVariables.pairedAttack.IsPlaying then -- runs for the attacker
			GameVariables.pairedAttack:Stop()
				if GameVariables.pairedAttack == GameVariables.FC_SyncBlock1LTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock1RTRACK
				elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock1RTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock1LTRACK
				elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock2LTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock2RTRACK
				elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock2RTRACK then
					GameVariables.pairedAttack = GameVariables.FC_SyncBlock2LTRACK
				end
				
			elseif GameVariables.pairedBlock and GameVariables.pairedBlock.IsPlaying then -- runs for the receiver
			GameVariables.pairedBlock:Stop()
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
	
		GameVariables.previousWalkSpeed = GameVariables.lockOnSpeed
		GameVariables.humanoid.WalkSpeed = 0
		
		if GameVariables.isBlocking then
		
			GameVariables.pairedBlock:Play()
		
		elseif GameVariables.isAttacking then
		
			GameVariables.currentAttack = GameVariables.pairedAttack
			
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
				local repositionTween = GameVariables.TweenService:Create(tweenPart, Info, tweenGoals)
				repositionTween:Play()
			end
				
			GameVariables.pairedAttack:Play()
			
		--end
		-- player will play their part of the synched block while the enemy does theirs.
		end
	end
end

--[[
function GameVariables.attack(followupCombo)
	if GameVariables.isEnemyHoldingBlock then
		GameVariables.isAttacking = true
		GameVariables.synchedBlock(nil, followupCombo)
	else
		local randAttackTABLE = {}
		if GameVariables.comboCounter == 0 then
			local randNumber
			GameVariables.randAttack = nil
			if followupCombo == true then -- players will be possibly able to do uppercuts if they are doing a followup combo from a past combo
				randNumber = math.random(2, 3)
			elseif not followupCombo then
				randNumber = math.random(1, 2) -- on a new combo without a followup, they can do only jabs or hooks on lvl 1's
			end
			-- a random number will be generated from above
			if randNumber == 1 then -- Hooks
			GameVariables.randLvl1Type = "Jabs" -- Will choose randomly between a set of attack types.
			elseif randNumber == 2 then
				GameVariables.randLvl1Type = "Hooks"
			elseif randNumber == 3 then
				GameVariables.randLvl1Type = "Uppercuts"
			end
		end
		
		if GameVariables.comboCounter <=2 and GameVariables.enemyHumanoid.Health > 10 then
			
			if not GameVariables.randAttack then -- This will run if the player hasn't started a combo yet
				for _, v in pairs(GameVariables.attack1Table) do -- This will get all attacks that are in the given attackSeries and puts them in a table, then randomly selects one of them by index number.
					if v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
						table.insert(randAttackTABLE, v)
					end
				end
				GameVariables.randAttack = randAttackTABLE[math.random(1,#randAttackTABLE)]
				
			else -- The player has thrown an attack before.
				
				local sameAttackChance = math.random(1,100)
				if sameAttackChance > 10 or GameVariables.lastAttack.Animation:GetAttribute("AttackSeries") == "Uppercuts" then
					for _, v in pairs(GameVariables.attack1Table) do
						if v ~= GameVariables.randAttack and v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
							GameVariables.randAttack = v
							break
						end
					end
				end
			end
			
			if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
				GameVariables.lastAttack:Stop()
			end
			
			GameVariables.currentAttack = GameVariables.randAttack.Animation
			
			GameVariables.isAttacking = true
			GameVariables.randAttack:Play()
			GameVariables.lastAttack = GameVariables.randAttack
			GameVariables.comboCounter += 1
			
		elseif GameVariables.comboCounter >= 3 or GameVariables.enemyHumanoid.Health <= 10 then
			GameVariables.randAttack = GameVariables.attack2Table[math.random(1, #GameVariables.attack2Table)]

			if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
				GameVariables.lastAttack:Stop()
			end
			
			GameVariables.currentAttack = GameVariables.randAttack.Animation
			GameVariables.isAttacking = true
			GameVariables.randAttack:Play()
			GameVariables.lastAttack = GameVariables.randAttack
			GameVariables.comboCounter+=1

		end
	end
end
--]]

-- function GameVariables.receive(currentAttackID, Protocol)
	
-- 	if GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying then
-- 		GameVariables.currentReceiveAnimTRACK:Stop()
-- 	end
-- 	if currentAttackID == GameVariables.FC_LeftHook1.AnimationId or currentAttackID == GameVariables.FC_LeftJab.AnimationId then -- left reaction, should check for other lvl 1 lefts
-- 	GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHook1RECEIVERTRACK
-- 	elseif currentAttackID == GameVariables.FC_RightHook1.AnimationId or currentAttackID == GameVariables.FC_RightJab.AnimationId then -- right reaction, same above for rights here
-- 	GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHook1RECEIVERTRACK
-- 	elseif currentAttackID == GameVariables.FC_LeftUppercut.AnimationId then
-- 		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftUppercutRECEIVERTRACK
-- 	elseif currentAttackID == GameVariables.FC_RightUppercut.AnimationId then
-- 		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightUppercutRECEIVERTRACK
-- 	elseif currentAttackID == GameVariables.FC_RightHaymaker.AnimationId then
-- 		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHaymakerReceiverTRACK
-- 	elseif currentAttackID == GameVariables.FC_LeftHaymaker.AnimationId then
-- 		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHaymakerRECEIVERTRACK
-- 	end
-- 	GameVariables.currentReceiveAnimTRACK:Play()
	
-- end


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