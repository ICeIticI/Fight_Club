local UserInputService = game:GetService("UserInputService")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local function receive(currentAttackID)
	
	if GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying then
		GameVariables.currentReceiveAnimTRACK:Stop()
	end
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
	GameVariables.currentReceiveAnimTRACK:Play()
	
end

GameVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(currentAttackID, Protocol, sentAnimPair, sentValue) --[[Used to find out what reaction the player
    should do based on what attack the enemy
    did. ]]
	print(sentValue)
    if Protocol == "Receive" then
        receive(currentAttackID)
    elseif Protocol == "AttackStarted" then -- if the enemy is starting an attack, and the player is blocking, perform a synched block.
        if GameVariables.isBlocking then
            GameVariables.synchedBlock(sentAnimPair, sentValue)
        end
    elseif Protocol == "HoldingBlock" then
        GameVariables.isEnemyHoldingBlock = sentValue
	elseif Protocol == "CameraChange" then
		-- The sent value here is charClone, a clone of the player's character. The reason for this is so we can parent the player's local camera to the new cloned body.
		game.Workspace.Camera.CameraSubject = sentValue.Humanoid
		print("REACHEDDDD")
	end
end)


UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and GameVariables.lockOnDebounce.Value and GameVariables.boolCheck(GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isDodging) then -- blocking/dodging  
		GameVariables.isBlocking = true
		GameVariables.FC_BlockStartTRACK:Play()
		GameVariables.humanoid.WalkSpeed /= 1.5
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and (GameVariables.FC_BlockStartTRACK.IsPlaying or GameVariables.FC_BlockTRACK.IsPlaying) then
		GameVariables.isBlocking = false
		GameVariables.FC_BlockStartTRACK:Stop()
		GameVariables.FC_BlockTRACK:Stop()
		GameVariables.humanoid.WalkSpeed *= 1.5
	end
end)