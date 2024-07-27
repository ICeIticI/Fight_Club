local Players = game:GetService("Players")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

for _, v in pairs(GameVariables.AllAnimations) do -- When the player presses an input and attacks (down below in UserInputService), this body of code will manage the player's current combo and their ability to do a followup attack after their first. It's up here so this isn't re-created
	local currentAnim = v.Animation
	
	if currentAnim:GetAttribute("AnimType") == 1 then -- anim type 1 is attacks
		-- every time the player presses attack.
		local attackEnded = false
		
		v:GetMarkerReachedSignal("StartOfAttack"):Connect(function()
			GameVariables.attackFrames = true
			-- GameVariables.followUpCount = 1
			print(GameVariables.followUpCount)
		end)

		v:GetMarkerReachedSignal("Anti_Followup"):Connect(function()
			GameVariables.canFollowUp = false
			print("anti frame reached")
		end)
		
		v:GetMarkerReachedSignal("EndOfAttack"):Connect(function() -- Runs when player can attack cancel
			GameVariables.isAttacking = false
			GameVariables.hitDebounce = false

			if currentAnim:GetAttribute("AttackLevel") == 2 then
				GameVariables.comboCounter = 0
			end

		end)
		
		v.Stopped:Connect(function() -- Runs when the animation stops for any reason
			
			if v.TimePosition ~= v.Length then -- Runs when the player has canceled an attack
				attackEnded = true
			
			elseif v.TimePosition == v.Length and not attackEnded then -- Runs when full animation is done playing
            GameVariables.comboCounter = 0
				
				-- print("paired chain 000")
				
			end
			
			if v.Animation:GetAttribute("Paired") == true and v.TimePosition == v.Length then
				delay(0.5, function()
					GameVariables.pairedChain = 0 -- If this value is more than 2, the player cannot attack
					GameVariables.followUpCount = 0 -- If this value is more than 1, the player cannot attack
					GameVariables.isAttacking = false
					GameVariables.hitDebounce = false
					print("reached")
				end)
				GameVariables.pairedPlaying = false
				GameVariables.isAttacking = false
				GameVariables.humanoid.WalkSpeed = GameVariables.previousWalkSpeed
				GameVariables.canFollowUp = true
			end
			
			attackEnded = false
			GameVariables.attackFrames = false
		end)
		
		
	elseif currentAnim:GetAttribute("AnimType") == 2 then -- anim type 2 is receive
		
		v:GetPropertyChangedSignal("IsPlaying"):Connect(function()
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
			end
		end)
		
		v.Stopped:Connect(function()
			if v.Animation:GetAttribute("Paired") then
				GameVariables.pairedPlaying = false
				GameVariables.humanoid.WalkSpeed = GameVariables.previousWalkSpeed
			end
		end)
		
	else -- Misc. Animations such as blocking
		
		v:GetPropertyChangedSignal("IsPlaying"):Connect(function()
			if v.Animation.AnimationId == GameVariables.FC_Block.AnimationId and v.IsPlaying == true then
				GameVariables.Protocol = "HoldingBlock"
				GameVariables.GlobalRemoteEvent:FireServer(Players:GetPlayerFromCharacter(GameVariables.enemyChar), GameVariables.Protocol) -- letting the enemy know the player is blocking
			end
		end)
		
		v.Stopped:Connect(function()
			if v.Animation.AnimationId == GameVariables.FC_BlockStart.AnimationId and v.TimePosition == v.Length then -- When the block starting animation ends, we want to play the looping version of the blocking animation.
            GameVariables.FC_BlockTRACK:Play()
			end
		end)
	end
	
	
	
end