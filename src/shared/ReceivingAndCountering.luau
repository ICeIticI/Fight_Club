local UserInputService = game:GetService("UserInputService")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local ReceivingAndCountering = {}

local function receive(currentAttack) -- Local function that manages what "reaction" the player would do based on the attack/circumstances.
	local currentAttackID = currentAttack.AnimationId -- currentAttack is what the enemy is throwing
	
	if GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying then
		GameVariables.currentReceiveAnimTRACK:Stop()
	end
	
	if not GameVariables.isBlocking then -- Receiving attack (not blocking)

		if GameVariables.FC_BlockStartTRACK.IsPlaying then -- if the player gets hit while the blockstart track is playing, then they will perform a parry
			if currentAttack:GetAttribute("AnimDirection") == "Left" then -- perform a left parry animation that will send to the server to damage the enemy slightly, and also make them do an animation in reaction.
				warn("ParryL")
				GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftParryTRACK -- If the enemy threw an attack to the left, then we brace right since their left is our right
			elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
				warn("ParryR")
				GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightParryTRACK
			end
			local Protocol = "Parry"
			
			GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, Protocol, currentAttack)
		else -- the blockStart track is not playing, therefore its not a parry:

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

function ReceivingAndCountering.Receive(currentAttack, Protocol, sentAnimPair, sentValue, isAI)
-- GameVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(currentAttack, Protocol, sentAnimPair, sentValue, isAI) --[[Used to find out what reaction the player
    -- should do based on what attack the enemy
    -- did. ]]
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

		elseif Protocol == "Parry" then
			warn("Should be playing receiving parry track")
			-- if the enemy parried the player, then they will do a reaction to what direction the enemy 
			GameVariables.randAttack:Stop()
			if currentAttack:GetAttribute("AnimDirection") == "Left" then
				-- if the enemy parried to the left, the player's right hand will repelled, and vice versa.
				GameVariables.FC_LeftParryRECEIVERTRACK:Play()
			elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
				GameVariables.FC_RightParryRECEIVERTRACK:Play()
			end
			
		end
	--elseif isAI == true then
		
	end
    
-- end)
end

function ReceivingAndCountering.Block(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and GameVariables.lockOnDebounce.Value and GameVariables.boolCheck(GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isDodging) and not GameVariables.pairedPlaying then -- blocking/dodging  
		-- GameVariables.isBlocking = true
		GameVariables.FC_BlockStartTRACK:Play()
		GameVariables.humanoid.WalkSpeed /= 1.5
	end
end

function ReceivingAndCountering.EndBlock(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and (GameVariables.FC_BlockStartTRACK.IsPlaying or GameVariables.FC_BlockTRACK.IsPlaying) and not GameVariables.pairedPlaying then
		print("Ending block")
		GameVariables.isBlocking = false
		GameVariables.FC_BlockStartTRACK:Stop()
		GameVariables.FC_BlockTRACK:Stop()
		GameVariables.humanoid.WalkSpeed *= 1.5
	end
end

return ReceivingAndCountering