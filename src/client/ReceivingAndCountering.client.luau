local UserInputService = game:GetService("UserInputService")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local function receive(currentAttack)
	local currentAttackID = currentAttack.AnimationId
	
	if GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying then
		GameVariables.currentReceiveAnimTRACK:Stop()
	end
	
	if not GameVariables.isBlocking then -- Receiving attack (not blocking)
		if currentAttackID == GameVariables.FC_LeftHook1.AnimationId or currentAttackID == GameVariables.FC_LeftJab.AnimationId then -- left reaction, should check for other lvl 1 lefts
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHook1RECEIVERTRACK
		elseif currentAttackID == GameVariables.FC_RightHook1.AnimationId or currentAttackID == GameVariables.FC_RightJab.AnimationId then -- right reaction, same above for rights here
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHook1RECEIVERTRACK
		elseif currentAttackID == GameVariables.FC_LeftUppercut.AnimationId then
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftUppercutRECEIVERTRACK
		elseif currentAttackID == GameVariables.FC_RightUppercut.AnimationId then
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightUppercutRECEIVERTRACK
		elseif currentAttackID == GameVariables.FC_RightHaymaker.AnimationId then
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHaymakerReceiverTRACK
		elseif currentAttackID == GameVariables.FC_LeftHaymaker.AnimationId then
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHaymakerRECEIVERTRACK
		end
	elseif GameVariables.isBlocking then -- Bracing block
		GameVariables.canSyncBlock = false -- Trying to get this to dictate if receiving plr can sync block
		if currentAttack:GetAttribute("AnimDirection") == "Left" then
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockRTRACK -- If the enemy threw an attack to the left, then we brace right since their left is our right
		elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
			GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockLTRACK
		end
	end
	
	
	GameVariables.currentReceiveAnimTRACK:Play()
	
end

GameVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(currentAttack, Protocol, sentAnimPair, sentValue, isAI) --[[Used to find out what reaction the player
    should do based on what attack the enemy
    did. ]]
	if not isAI then
		if Protocol == "Receive" then
			receive(currentAttack)
		elseif Protocol == "AttackStarted" then -- if the enemy is starting an attack, and the player is blocking, perform a synched block.
			print(sentValue)
			if GameVariables.isBlocking and GameVariables.canSyncBlock then
				GameVariables.synchedBlock(sentAnimPair, sentValue)
				warn("Sync block being performed")
			end
		elseif Protocol == "HoldingBlock" then
			GameVariables.isEnemyHoldingBlock = sentValue
		-- elseif Protocol == "CameraChange" then
		-- 	-- The sent value here is charClone, a clone of the player's character. The reason for this is so we can parent the player's local camera to the new cloned body.
		-- 	game.Workspace.Camera.CameraSubject = sentValue.Humanoid
		-- 	game.Workspace.Camera.CFrame = sentValue.Head.CFrame
		-- 	print("REACHEDDDD")
		end
	elseif isAI == true then
		
	end
    
end)


UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and GameVariables.lockOnDebounce.Value and GameVariables.boolCheck(GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isDodging) and not GameVariables.pairedPlaying then -- blocking/dodging  
		GameVariables.isBlocking = true
		GameVariables.FC_BlockStartTRACK:Play()
		GameVariables.humanoid.WalkSpeed /= 1.5
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and (GameVariables.FC_BlockStartTRACK.IsPlaying or GameVariables.FC_BlockTRACK.IsPlaying) and not GameVariables.pairedPlaying then
		GameVariables.isBlocking = false
		GameVariables.FC_BlockStartTRACK:Stop()
		GameVariables.FC_BlockTRACK:Stop()
		GameVariables.humanoid.WalkSpeed *= 1.5
	end
end)