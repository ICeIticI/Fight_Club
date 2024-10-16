-- local Players = game:GetService("Players")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
local AnimationManager = {}

local function AttackAnimManager(v, currentAnim, EndOfAttackExists)
	-- every time the player presses attack.
	local attackEnded = false

	if currentAnim:GetAttribute("EventCategory") == "bAttack" then -- checking if the current animation (not the track) has the 'EventCategory' attribute, with a value of bAttack, which is given to all basic attacks.
		v.Priority = Enum.AnimationPriority.Action2 -- then we give the current animation track a priority of 2 so it will have higher priority than default.
		print(tostring(v) .. " has animation priority 2 now.")
	end
			
	local StartOfAttackCONNECT = v:GetMarkerReachedSignal("StartOfAttack"):Connect(function()
		if not v.Animation:GetAttribute("Paired") then
			GameVariables.canFollowUp = true
		end
		GameVariables.attackFrames = true
	end)

	local Anti_FollowupCONNECT = v:GetMarkerReachedSignal("Anti_Followup"):Connect(function()
		GameVariables.canFollowUp = false
		warn("anti frame reached")
	end)
	
	local EndOfAttackCONNECT = v:GetMarkerReachedSignal("EndOfAttack"):Connect(function() -- Runs when player can attack cancel
		GameVariables.isAttacking = false
		GameVariables.hitDebounce = false
		GameVariables.canFollowUp = false
		
		EndOfAttackExists = true

		if currentAnim:GetAttribute("AttackLevel") == 2 then
			GameVariables.comboCounter = 0
		end

	end)
	
	local A1StoppedCONNECT = v.Stopped:Connect(function() -- Runs when the animation stops for any reason
		if v.TimePosition ~= v.Length then -- Runs when the player has canceled an attack
			attackEnded = true
		
		elseif v.TimePosition == v.Length and not attackEnded then -- Runs when full animation is done playing
		GameVariables.comboCounter = 0
		GameVariables.followUpCount = 0 -- If this value is more than 1, the player cannot attack	
		if EndOfAttackExists == false then -- runs for animations that don't have the EndOfAttack attribute, such as the sync blocks.
				GameVariables.isAttacking = false
				GameVariables.hitDebounce = false
				GameVariables.canFollowUp = false
			end
		end
		
		if v.Animation:GetAttribute("Paired") == true and v.TimePosition == v.Length then
			delay(0.5, function()
				GameVariables.pairedChain = 0 -- If this value is more than 2, the player cannot attack
				GameVariables.isAttacking = false
				GameVariables.hitDebounce = false
				GameVariables.pairedPlaying = false
			end)
			GameVariables.isAttacking = false
			GameVariables.humanoid.WalkSpeed = GameVariables.previousWalkSpeed
			-- GameVariables.canFollowUp = true
		end
		
		attackEnded = false
		GameVariables.attackFrames = false
	end)
	
	local A1Connects = {StartOfAttackCONNECT, Anti_FollowupCONNECT, EndOfAttackCONNECT, A1StoppedCONNECT}

	GameVariables.humanoid.Died:Connect(function()
		for _, connection in pairs(A1Connects) do
			connection:Disconnect()
			warn("Connections A1 has been disabled.")
			
		end
		-- warn(#GameVariables.AllAnimations)
	end)
end

local function ReceiveAnimManager(v, currentAnim)
	local A2IsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(function()

		GameVariables.isGettingHit = true
		GameVariables.randAttack:Stop()
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
				-- Wait a duration of time (like a second or two) before allowing sync blocks again
				wait(1)
				if not GameVariables.FC_BracingBlockLTRACK.IsPlaying or not GameVariables.FC_BracingBlockRTRACK.IsPlaying then -- the last sync block played should set the canSyncBlock variable to true once it finishes.
					GameVariables.canSyncBlock = true
					print("Sync blocks are now possible again")
				end
			elseif v.IsPlaying then
				GameVariables.canSyncBlock = false
				print("Sync blocks are now not allowed.")
			end
		end
	end)
	
	local A2StoppedCONNECT = v.Stopped:Connect(function()
		GameVariables.isGettingHit = false
		if v.Animation:GetAttribute("Paired") then
			GameVariables.pairedPlaying = false
			GameVariables.humanoid.WalkSpeed = GameVariables.previousWalkSpeed
		end
	end)

	local A2Connects = {A2IsPlayingCONNECT, A2StoppedCONNECT}

	GameVariables.humanoid.Died:Connect(function()
		for _, connection in pairs(A2Connects) do
			connection:Disconnect()
		end
	end)
	
end

local function MiscAnimManager(v)
	
	local MiscIsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(function()

		if v.Animation.AnimationId == GameVariables.FC_Block.AnimationId then
				wait(0.15)
				while not GameVariables.canSyncBlock do
					wait()
					print("Waiting for sync block avaliability " .. tostring(GameVariables.canSyncBlock))
				end
			
			warn("Broke out of the for loop...")
			GameVariables.Protocol = "HoldingBlock"
			GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, nil, nil, GameVariables.isBlocking, nil, false) -- letting the enemy know the player is blocking

		elseif v.Animation.AnimationId == GameVariables.FC_LeftParry.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParry.AnimationId then -- manages the parry animations when they start playing
		-- Parry started playing
		if v.IsPlaying == true then
			-- Parry anim started playing
			GameVariables.isCountering = true -- even though we are parrying, we use the isBlocking attribute for simplicity. isAttacking wasnt working properly when we did it with that attribute.
			warn("isBlocking: " .. tostring(GameVariables.isBlocking))
			GameVariables.comboCounter = 3 -- when the player parries someone, they will be able to do a haymaker attack following
			print("we are *blocking* cuz we are parrying. isAttacking: " .. tostring(GameVariables.isAttacking))
		end
		
		end
		
	end)
	
	local MiscStopppedCONNECT = v.Stopped:Connect(function()

		if v.Animation.AnimationId == GameVariables.FC_BlockStart.AnimationId and v.TimePosition == v.Length then -- When the block starting animation ends, we want to play the looping version of the blocking animation.
		GameVariables.FC_BlockTRACK:Play()
		print("is playing block")

		elseif v.Animation.AnimationId == GameVariables.FC_LeftParry.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParry.AnimationId then -- manages the parry animations when they stop playing
		-- Parry stopped playing
		warn("Parry stopped playing")
		GameVariables.hitDebounce = false
		GameVariables.isCountering = false
		-- GameVariables.comboCounter = 3 -- when the player parries someone, they will be able to do a haymaker attack following
		warn("You can attack now after parrying")
		
		delay(0.51, function() -- the parry receiver animations are 0.51 seconds longer than the parries. If the player parries and hangs around doing nothing, they will lose the ability to do a haymaker riposte.
			GameVariables.comboCounter = 0 
		end)

		elseif v.Animation.AnimationId == GameVariables.FC_LeftParryRECEIVER.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParryRECEIVER.AnimationId then -- manages the parry-receiving animations when they stop playing
			-- Parry receiver stopped playing
			wait(0.4)
			warn("Can attack now after getting parried")
			GameVariables.comboCounter = 0 -- reset the combo counter because we dont want to continue the attack chain.
			GameVariables.isAttacking = false
			GameVariables.hitDebounce = false
			warn("Plr got parried and the parry receiver anim finished. isAttacking is now false.")
		end

	end)

	local MiscIsBlockingConnect = v:GetMarkerReachedSignal("isBlocking"):Connect(function()
		GameVariables.isBlocking = true
		print("player is now blocking...!")
	end)

	local MiscConnects = {MiscIsPlayingCONNECT, MiscStopppedCONNECT, MiscIsBlockingConnect}

	GameVariables.humanoid.Died:Connect(function()
		for _, connection in pairs(MiscConnects) do
			connection:Disconnect()
		end
	end)
end





function AnimationManager.manageAnimations()
	wait()
	for _, v in pairs(GameVariables.AllAnimations) do -- When the player presses an input and attacks (down below in UserInputService), this body of code will manage the player's current combo and their ability to do a followup attack after their first. It's up here so this isn't re-created
		print(v.Name .. " .. " .. tostring(v.Priority))

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