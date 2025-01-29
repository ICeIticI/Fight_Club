local UserInputService = game:GetService("UserInputService")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
-- local LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")
-- GameVariables.Sync()
local LockOnSystem = {}

local function faceEnemy(subject)
	GameVariables.humanoidRootPart.CFrame = CFrame.lookAt(GameVariables.humanoidRootPart.Position, Vector3.new(GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.X, GameVariables.humanoidRootPart.Position.Y, GameVariables.raycastResult.Instance.Parent.HumanoidRootPart.Position.Z)) -- makes sure the player character is always facing the enemy character.
	subject.CFrame = CFrame.new(
		(GameVariables.humanoidRootPart.Position.X + GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.X) / 2,
		subject.CFrame.Y,
		(GameVariables.humanoidRootPart.Position.Z + GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.Z) / 2)

end

local function createSubject(subject) --[[Creates a invisible part (subject) between the player and the enemy that the camera will be focused on]]
	subject.Name = "subject"
			subject.Size = Vector3.new(0.1, 0.1, 0.1)
			subject.Transparency = 0.75
			subject.CanCollide = false
			subject.Anchored = true
			subject.CFrame = CFrame.new(
				GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.X,
				GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.Y / 2,
				(GameVariables.humanoidRootPart.Position.Z + GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.Z) / 2)
			subject.Parent = GameVariables.character
end


function LockOnSystem.LockOn()

	local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = GameVariables.character:GetChildren()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		
		GameVariables.raycastResult =
		workspace:Raycast(GameVariables.humanoidRootPart.Position,
						  GameVariables.humanoidRootPart.CFrame.LookVector * 8,
						  rayParams) -- Raycast in front of player to find an enemy
						  

		if GameVariables.raycastResult and GameVariables.raycastResult.Instance.Parent:FindFirstChild("Humanoid") then -- We found an alive enemy to lock onto.
			GameVariables.enemyHumanoid = GameVariables.raycastResult.Instance.Parent:FindFirstChild("Humanoid")
			GameVariables.enemyChar = GameVariables.enemyHumanoid.Parent
			
			GameVariables.lockOnDebounce.Value = not GameVariables.lockOnDebounce.Value -- always assures lockOnDebouce is opposite of itself to change. Saves me lines of code
			
			
		if not game.Players:GetPlayerFromCharacter(GameVariables.enemyChar) then -- then our target isn't a player. We'll send a bindable event to the character
				if GameVariables.enemyChar.Name == "TestDummy" then
					GameVariables.LocalBindableEvent:Fire(GameVariables.lockOnDebounce)
				end
			end
			
		elseif GameVariables.raycastResult == nil and GameVariables.lockOnDebounce.Value == true then -- no enemy detected by raycast
			GameVariables.lockOnDebounce.Value = false
			
		end

	-- GameVariables.lockOnDebounce.Value = not GameVariables.lockOnDebounce.Value
	

	if GameVariables.lockOnDebounce.Value == true then -- Runs when the player locks onto somebody
    GameVariables.FC_IdleTRACK:Play()
		-- character changes below:
		GameVariables.humanoid.AutoRotate = false -- doesnt allow the player to rotate themself while locked on.
		GameVariables.SetSpeed(true)
		--[[
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter -- Because roblox player scripts are currently broke and we are also testing still, we disable this for now until we're done.
		--]]
		
		-- camera subject part
		local subject = GameVariables.character:FindFirstChild("subject") or Instance.new("Part") --[[ Subject is the point
		That the player's camera revoles around when they lock on. It is perfectly between the player and enemy.]]
		
		if GameVariables.character:FindFirstChild("subject") == nil then --[[ Creates a subject if it's not created yet on
		it's first lock on.]]
			createSubject(subject)
		end
		
		-- camera changes:
		--[[ -- Roblox is having some camera-related issues as of now. Once they fix it I intend to re-enable this.
		GameVariables.Camera.CameraType = Enum.CameraType.Orbital
		GameVariables.Camera.CameraSubject = subject
		--Camera.CameraSubject = raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart")
		GameVariables.Camera.Focus = GameVariables.raycastResult.Instance.Parent.HumanoidRootPart.CFrame
		]]
		
		while GameVariables.lockOnDebounce.Value == true and workspace:Raycast(GameVariables.humanoidRootPart.Position, GameVariables.humanoidRootPart.CFrame.LookVector * 8, rayParams) ~= nil do -- constantly keeps the player facing the enemy
			-- Constantly having the player face the enemy when locked on

			wait()
			faceEnemy(subject)
		end

		if not workspace:Raycast(GameVariables.humanoidRootPart.Position, GameVariables.humanoidRootPart.CFrame.LookVector * 7, rayParams) then -- When the while loop above ends, we want to check if its because the player got too far. If so, then we want to set the lockOnDebounce to false
			GameVariables.lockOnDebounce.Value = false
			print("Too far from enemy.")
		end

	end
	
	if GameVariables.lockOnDebounce.Value == false then
		-- Stop locking onto enemy
		
		GameVariables.stopAnimations()
		-- character changes below:
		GameVariables.humanoid.AutoRotate = true
		GameVariables.SetSpeed(true)
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		
		-- camera changes
		--[[ -- Roblox is having some camera-related issues as of now. Once they fix it I intend to re-enable this.
		GameVariables.Camera.Focus = GameVariables.originalCamFocus
		GameVariables.Camera.CameraSubject = GameVariables.originalCamSubject
		GameVariables.Camera.CameraType = Enum.CameraType.Custom
		]]
	end



	
	-- if input.KeyCode == Enum.KeyCode.Q then -- lock on with Q
		
		
		-- lock on code below:
		
		
    -- end

end

return LockOnSystem