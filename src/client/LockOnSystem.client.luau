local UserInputService = game:GetService("UserInputService")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
-- local LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")
-- GameVariables.Sync()

GameVariables.lockOnDebounce.Changed:Connect(function()
	
	if GameVariables.lockOnDebounce.Value == true then -- Runs when the player locks onto somebody
    GameVariables.FC_IdleTRACK:Play()
	print(GameVariables.FC_IdleTRACK)
		-- character changes below:
		GameVariables.humanoid.AutoRotate = false -- doesnt allow the player to rotate themself while locked on.
		GameVariables.humanoid.WalkSpeed = GameVariables.lockOnSpeed
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		
		-- camera subject part
		local subject = GameVariables.character:FindFirstChild("subject") or Instance.new("Part") --[[ Subject is the point
		That the player revoles around when they lock on. It is perfectly between the player and enemy.]]
		
		if GameVariables.character:FindFirstChild("subject") == nil then --[[ Creates a subject if it's not created yet on
		it's first lock on.]]
			subject.Name = "subject"
			subject.Size = Vector3.new(0.1, 0.1, 0.1)
			subject.Transparency = 0.75
			subject.CanCollide = false
			subject.Anchored = true
			subject.CFrame = CFrame.new(
				GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.X,
				GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.Y / 2,
				(GameVariables.humanoidRootPart.Position.Z + GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.Z) / 2 
			)
			subject.Parent = GameVariables.character
		end
		
		-- camera changes:
		GameVariables.Camera.CameraType = Enum.CameraType.Orbital
		GameVariables.Camera.CameraSubject = subject
		--Camera.CameraSubject = raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart")
		GameVariables.Camera.Focus = GameVariables.raycastResult.Instance.Parent.HumanoidRootPart.CFrame
		
		while GameVariables.lockOnDebounce.Value == true and GameVariables.raycastResult ~= nil do
				wait()
				GameVariables.humanoidRootPart.CFrame = CFrame.lookAt(GameVariables.humanoidRootPart.Position, GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position) -- makes sure the player character is always facing the enemy character.
			subject.CFrame = CFrame.new(
				(GameVariables.humanoidRootPart.Position.X + GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.X) / 2,
				subject.CFrame.Y,
				(GameVariables.humanoidRootPart.Position.Z + GameVariables.raycastResult.Instance.Parent:FindFirstChild("HumanoidRootPart").Position.Z) / 2 
				)
		end
	end
	
	if GameVariables.lockOnDebounce.Value == false then
		GameVariables.stopAnimations()
		-- character changes below:
		GameVariables.humanoid.AutoRotate = true
		GameVariables.humanoid.WalkSpeed = GameVariables.originalWalkSpeed
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		
		-- camera changes
		GameVariables.Camera.Focus = GameVariables.originalCamFocus
		GameVariables.Camera.CameraSubject = GameVariables.originalCamSubject
		GameVariables.Camera.CameraType = Enum.CameraType.Custom
	end
end)

UserInputService.InputBegan:Connect(function(input)
	
	if input.KeyCode == Enum.KeyCode.Q then -- lock on with Q
		
		
		-- lock on code below:
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = GameVariables.character:GetChildren()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		
		GameVariables.raycastResult = workspace:Raycast(GameVariables.humanoidRootPart.Position, GameVariables.humanoidRootPart.CFrame.LookVector * 8, rayParams)
		if GameVariables.raycastResult --[[and game.Players:GetPlayerFromCharacter(raycastResult.Instance.Parent) - checks if locked on target is a player character. We turn off for now since it dont matter if its player yet.]]
		and GameVariables.raycastResult.Instance.Parent:FindFirstChild("Humanoid") then -- We found an alive enemy to lock onto.
        GameVariables.enemyHumanoid = GameVariables.raycastResult.Instance.Parent:FindFirstChild("Humanoid")
        GameVariables.enemyChar = GameVariables.enemyHumanoid.Parent
        GameVariables.lockOnDebounce.Value = not GameVariables.lockOnDebounce.Value -- always assures lockOnDebouce is opposite of itself to change. Saves me lines of code
			
		elseif GameVariables.raycastResult == nil and GameVariables.lockOnDebounce.Value == true then
			GameVariables.lockOnDebounce.Value = false
			
		end
		
    end
end)