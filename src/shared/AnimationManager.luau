-- local Players = game:GetService("Players")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
local AnimationManager = {}

local function AttackAnimManager(v, currentAnim, EndOfAttackExists)
	-- every time the player presses attack.
	local attackEnded = false

	if currentAnim:GetAttribute("EventCategory") == "bAttack" then -- checking if the current animation (not the track) has the 'EventCategory' attribute, with a value of bAttack, which is given to all basic attacks.
		v.Priority = Enum.AnimationPriority.Action -- then we give the current animation track a priority of 2 so it will have higher priority than default.
	elseif currentAnim:GetAttribute("Paired") then	
		v.Priority = Enum.AnimationPriority.Action2
	end

	local A1IsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(function() -- Runs when any attack animation begins/stops playing
		if v.IsPlaying then
			GameVariables.isAttacking = true
			GameVariables.SetSpeed(false) -- As soon as an attack animation starts, the player will not be able to move.

			if v.Animation:GetAttribute("Counter") == true then
				GameVariables.isCountering = true
				GameVariables.isAttacking = true
				GameVariables.currentAttack = GameVariables.currentReceiveAnimTRACK.Animation -- we also want to classify the counter as a currentattack so the basicStriking module will see it as an attack and be able to send to the server for damage.
				
				GameVariables.Protocol = "Counter"
				warn("sending Counter")
				GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, GameVariables.currentAttack)
				GameVariables.Protocol = nil
			
			end

		elseif not v.IsPlaying then -- Runs when the animation stops for any reason
			
			if v.TimePosition ~= v.Length then -- Runs when the player has canceled an attack
				attackEnded = true
				GameVariables.Protocol = nil -- resets the protocol. This is because the protocol needs to be checked in countering before being allowed to counter. If the plr is throwing a hook already, then we don't want to counter.
		
			elseif v.TimePosition == v.Length and not attackEnded then -- Runs when full animation is done playing
				GameVariables.comboCounter = 0
				GameVariables.followUpCount = 0 -- If this value is more than 1, the player cannot attack	
			
				if EndOfAttackExists == false then -- runs for animations that don't have the EndOfAttack attribute, such as the sync blocks.
					GameVariables.isAttacking = false
					GameVariables.hitDebounce = false
					print("EndOfAttackExists if statement set the hitDebounce to false")
					GameVariables.canFollowUp = false
				end

				if v.Animation:GetAttribute("Counter") == true then
					GameVariables.isCountering = false
					GameVariables.isAttacking = false
				end
			end
			-- GameVariables.hitDebounce = false
			
			if v.Animation:GetAttribute("Paired") == true and v.TimePosition == v.Length then
				delay(0.5, function()
					
					
					-- GameVariables.isAttacking = false
					GameVariables.hitDebounce = false
				end)
				GameVariables.isAttacking = false
				GameVariables.pairedChain = 0 -- If this value is more than 2, the player cannot attack
				GameVariables.comboCounter = 0
				-- GameVariables.canFollowUp = true
			end
			
			attackEnded = false
			GameVariables.attackFrames = false
			GameVariables.pairedPlaying = false
			GameVariables.SetSpeed(true)
		end
	end)
			
	local StartOfAttackCONNECT = v:GetMarkerReachedSignal("StartOfAttack"):Connect(function() -- runs when the animation reaches a point where it can do damage.
		GameVariables.attackFrames = true
		if v.Animation:GetAttribute("Paired") and v.Animation:GetAttribute("Counter") then
			GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, "CounterAttack", GameVariables.currentAttack, nil, nil, GameVariables.isEnemyHoldingBlock, false) -- Deal damage to other client.
		else
			GameVariables.canFollowUp = true

			-- GameVariables.Protocol = "AttackEnded"
			GameVariables.GlobalRemoteEvent:FireServer(nil, "AttackFrames", nil, nil, nil, nil, false) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
		end
	end)
	
	local Anti_FollowupCONNECT = v:GetMarkerReachedSignal("Anti_Followup"):Connect(function()
		GameVariables.canFollowUp = false
	end)
	
	local EndOfAttackCONNECT = v:GetMarkerReachedSignal("EndOfAttack"):Connect(function() -- Runs when player can attack cancel
		
		GameVariables.isAttacking = false
		GameVariables.hitDebounce = false
		GameVariables.canFollowUp = false
		GameVariables.GlobalRemoteEvent:FireServer(nil, "AttackEnded", nil, nil, nil, nil, false) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
		
		if not v.Animation:GetAttribute("Paired") then -- We set the speed of paired attacks in a different :Connect below, so we don't want to manage the paired attack speed here.
			GameVariables.SetSpeed(true)
		end
		
		
		EndOfAttackExists = true

		if currentAnim:GetAttribute("AttackLevel") == 2 then
			GameVariables.comboCounter = 0
		end
	end)
	
	local A1StoppedCONNECT = v.Stopped:Connect(function()
	end)
	
	local A1Connects = {StartOfAttackCONNECT, Anti_FollowupCONNECT, EndOfAttackCONNECT, A1StoppedCONNECT, A1IsPlayingCONNECT}

	GameVariables.humanoid.Died:Connect(function()
		for _, connection in pairs(A1Connects) do
			connection:Disconnect()
			warn("Connections A1 has been disabled.")
		end
	end)
end





local function ReceiveAnimManager(v, currentAnim)
	local A2IsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(function()

		if v.IsPlaying then
			GameVariables.isGettingHit = true
			GameVariables.canFollowUp = false
			GameVariables.SetSpeed(false) -- don't want the player to be able to move while being hit
			GameVariables.hitDebounce = false

		elseif not v.IsPlaying then
			GameVariables.isGettingHit = false
			GameVariables.isAttacking = false
			
			if v.Animation:GetAttribute("Paired") then
				GameVariables.pairedPlaying = false
				GameVariables.hitDebounce = false
				GameVariables.SetSpeed(true)
			else
				GameVariables.SetSpeed(true)
			end
		end
		-- Down below are changes that happen regardless if the receiving animation plays or stops:
		GameVariables.comboCounter = 0
		
		if GameVariables.randAttack and GameVariables.randAttack.IsPlaying then
			GameVariables.randAttack:Stop()
		end
		
		if currentAnim.AnimationId == GameVariables.FC_RightHaymakerRECEIVER.AnimationId or currentAnim.AnimationId == GameVariables.FC_LeftHaymakerRECEIVER.AnimationId then -- we need to specifically tween specific animations like the rightHaymaker
			if v.IsPlaying == true then
				-- tween now that we know that the haymaker anim has started
				
				local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")
				
				local Info = TweenInfo.new(
					
					v.Length,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					0
					
				)
				
				local tweenGoals = {
					
					CFrame = tweenPart.CFrame * CFrame.new(0,0,2)
				}
				
				local reactTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
				reactTween:Play()
			end
		elseif currentAnim.AnimationId == GameVariables.FC_BracingBlockL.AnimationId or currentAnim.AnimationId == GameVariables.FC_BracingBlockR.AnimationId then -- These animationIds are the bracing blocks.
			if v.IsPlaying == false then
				GameVariables.isBlocking = false
				-- Wait a duration of time (like a second or two) before allowing sync blocks again
				wait(1)
				if not GameVariables.FC_BracingBlockLTRACK.IsPlaying or not GameVariables.FC_BracingBlockRTRACK.IsPlaying then -- the last sync block played should set the canSyncBlock variable to true once it finishes.
					GameVariables.canSyncBlock = true
				end
			elseif v.IsPlaying then
				GameVariables.isBlocking = true
				GameVariables.canSyncBlock = false
			end
		end
	end)


	local A2Connects = {A2IsPlayingCONNECT}

	GameVariables.humanoid.Died:Connect(function()
		for _, connection in pairs(A2Connects) do
			connection:Disconnect()
		end
	end)
end



local function MiscAnimManager(v)
	
	local MiscIsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(function()

		if v.IsPlaying then
			if v.Animation.AnimationId == GameVariables.FC_LeftParry.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParry.AnimationId then -- manages the parry and counter animations when they start playing
				-- Parry anim started playing
				GameVariables.isCountering = true -- even though we are parrying, we use the isBlocking attribute for simplicity. isAttacking wasnt working properly when we did it with that attribute.
				GameVariables.comboCounter = 3 -- when the player parries someone, they will be able to do a haymaker attack following
			end

		elseif not v.IsPlaying then
			if v.Animation.AnimationId == GameVariables.FC_BlockStart.AnimationId and v.TimePosition == v.Length then -- When the block starting animation ends, we want to play the looping version of the blocking animation.
				GameVariables.FC_BlockTRACK:Play()

			elseif v.Animation.AnimationId == GameVariables.FC_LeftParry.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParry.AnimationId then -- manages the parry animations when they stop playing
			-- Parry stopped playing
			GameVariables.isCountering = false
			-- GameVariables.comboCounter = 3 -- when the player parries someone, they will be able to do a haymaker attack following
			
			delay(0.51, function() -- the parry receiver animations are 0.51 seconds longer than the parries. If the player parries and hangs around doing nothing, they will lose the ability to do a haymaker riposte.
				GameVariables.comboCounter = 0 
			end)

			elseif v.Animation.AnimationId == GameVariables.FC_LeftParryRECEIVER.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParryRECEIVER.AnimationId then -- manages the parry-receiving animations when they stop playing
				-- INSTEAD OF LISTING EVERY ANIMATION, ADD ATTRIBUTES TO SIMPLIFY!!!
				-- Parry receiver stopped playing
				GameVariables.canFollowUp = false
				wait(0.4)
				GameVariables.comboCounter = 0 -- reset the combo counter because we dont want to continue the attack chain.
				GameVariables.isAttacking = false
				GameVariables.hitDebounce = false
			end

			GameVariables.isAttacking = false
			GameVariables.hitDebounce = false
		end

		if v.Animation.AnimationId == GameVariables.FC_Block.AnimationId then
				wait(0.15)
			-- 	while not GameVariables.canSyncBlock do
			-- 		wait()
			-- 		print("Waiting for sync block avaliability " .. tostring(GameVariables.canSyncBlock))
			-- 	end
			
			GameVariables.Protocol = "HoldingBlock"
			GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, nil, nil, GameVariables.isBlocking, nil, false) -- letting the enemy know the player is blocking
		end
	end)

	local MiscIsBlockingConnect = v:GetMarkerReachedSignal("isBlocking"):Connect(function()
		GameVariables.isBlocking = true
	end)

	local MiscConnects = {MiscIsPlayingCONNECT, MiscIsBlockingConnect}

	GameVariables.humanoid.Died:Connect(function()
		for _, connection in pairs(MiscConnects) do
			connection:Disconnect()
		end
	end)
end





function AnimationManager.manageAnimations()
	wait()
	for _, v in pairs(GameVariables.AllAnimations) do -- When the player presses an input and attacks (down below in UserInputService), this body of code will manage the player's current combo and their ability to do a followup attack after their first. It's up here so this isn't re-created

		local currentAnim = v.Animation
		local EndOfAttackExists = false -- for the functions that don't have this event, I want them to run code when the animation has stopped. However, animations that have this marker won't be able to run it.

		if currentAnim:GetAttribute("AnimType") == 1 then -- anim type 1 is attacks
			AttackAnimManager(v, currentAnim, EndOfAttackExists)
			
		elseif currentAnim:GetAttribute("AnimType") == 2 then -- anim type 2 is receive
			ReceiveAnimManager(v, currentAnim)

		else -- Misc. Animations such as blocking
			MiscAnimManager(v)
			
		end
	end
end

-- manageAnimations()

-- GameVariables.player.CharacterAdded:Connect(function()
-- 	manageAnimations()
-- 	print("Animation manager activated.")
-- end)

return AnimationManager