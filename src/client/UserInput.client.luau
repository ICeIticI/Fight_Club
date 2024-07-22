local UserInputService = game:GetService("UserInputService")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local player = GameVariables.player
local character = GameVariables.character
local humanoidRootPart
local TestObject = GameVariables.TestObject
print(player)
wait(3)
GameVariables.Set(TestObject, 9)
warn("changed on first client")

-- UserInputService.InputBegan:Connect(function(input)
	
-- 	if input.KeyCode == Enum.KeyCode.Q then -- lock on with Q
		
		
-- 		-- lock on code below:
-- 		local rayParams = RaycastParams.new()
-- 		rayParams.FilterDescendantsInstances = character:GetChildren()
-- 		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		
-- 		raycastResult = workspace:Raycast(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 8, rayParams)
-- 		if raycastResult --[[and game.Players:GetPlayerFromCharacter(raycastResult.Instance.Parent) - checks if locked on target is a player character. We turn off for now since it dont matter if its player yet.]]
-- 		and raycastResult.Instance.Parent:FindFirstChild("Humanoid") then -- We found an alive enemy to lock onto.
-- 			enemyHumanoid = raycastResult.Instance.Parent:FindFirstChild("Humanoid")
-- 			enemyChar = enemyHumanoid.Parent
-- 			lockOnDebounce.Value = not lockOnDebounce.Value -- always assures lockOnDebouce is opposite of itself to change. Saves me lines of code
			
-- 		elseif raycastResult == nil and lockOnDebounce.Value == true then
-- 			lockOnDebounce.Value = false
			
-- 		end
		
		
-- 	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and lockOnDebounce.Value and not waitingToAttack and pairedChain <= 2 and (raycastResult.Instance.Position - humanoidRootPart.Position).Magnitude <= 4.25 then -- atacking
-- 																																				-- This part in simple terms makes sure the player is less or equal to 4 studs from enemy bfore attacking
-- 		--[[ When the player presses attack, we want to randomly choose between a series of hooks or jabs
-- 			 for attack level 1. Once combo counter finishes it's 3rd attack, we will transition to level
-- 			 2 attacks (haymakers).]]
-- 		distanceBetween = (raycastResult.Instance.Position - humanoidRootPart.Position).Magnitude
-- 		followUpCount += 1
-- 		if isEnemyHoldingBlock then
-- 			pairedChain += 1
-- 			print("paired chain added. Num of times: ".. tostring(pairedChain))
-- 		end
		
		
-- 		if boolCheck(isAttacking, isBlocking, isDodging) and not waitingToAttack then
-- 			if pairedChain <= 2 then
-- 				animPair = {math.random(1,2), math.random(1,2)} -- first index will determine if its left or right. Second index will tell which specific animation will play, given the direction. Both are randomly selected.
-- 				Protocol = "AttackStarted"
-- 				GlobalRemoteEvent:FireServer(Players:GetPlayerFromCharacter(enemyChar), Protocol, nil, animPair, pairedChain) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
-- 			end
-- 			print(isAttacking)
-- 			attack()
-- 		elseif canFollowUp == true then -- the player followed up with their attack.
-- 			waitingToAttack = true
-- 			print("waiting on next attack")
-- 			while isAttacking do
-- 				wait()
-- 			end
-- 			if followUpCount == 1 then
-- 				--[[ *NOTE: Uppercuts will ONLY be doable on a follow-up, so I will
-- 				            need to create a unique attack() function to make it
-- 				            a choice.]]
-- 				if pairedChain <= 2 then
-- 					animPair = {math.random(1,2), math.random(1,2)}
-- 					Protocol = "AttackStarted"
-- 					GlobalRemoteEvent:FireServer(Players:GetPlayerFromCharacter(enemyChar), Protocol, nil, animPair, pairedChain) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
-- 				end
-- 				print(isAttacking)
-- 				attack(true) -- true is used for a followup combo, which enables uppercuts.
-- 				waitingToAttack = false
-- 			end
-- 		end
		
		
-- 		-- the :GetMarkerReachedSignal function has to be moved outside the function, otherwise it will keep doubling the detection, which can alter performance
		
		
-- 	elseif input.UserInputType == Enum.UserInputType.MouseButton2 and lockOnDebounce.Value and boolCheck(isAttacking, isBlocking, isDodging) then -- blocking/dodging
-- 		isBlocking = true
-- 		FC_BlockStartTRACK:Play()
-- 		humanoid.WalkSpeed /= 1.5
-- 	end
-- end)


-- UserInputService.InputEnded:Connect(function(input)
-- 	if input.UserInputType == Enum.UserInputType.MouseButton2 and (FC_BlockStartTRACK.IsPlaying or FC_BlockTRACK.IsPlaying) then
-- 		isBlocking = false
-- 		FC_BlockStartTRACK:Stop()
-- 		FC_BlockTRACK:Stop()
-- 		humanoid.WalkSpeed *= 1.5
-- 	end
-- end)