local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
-- local LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")
-- GameVariables.Sync()
local LockOnSystem = {}

local function getCenteredSubjectCFrame() --[[ When the character locks onto the enemy, a 'subject' will be created, which will act as the point where the camera focuses on. So wherever the subject goes, the Camera goes as well. So the subject will start at the camera's current CFrame, and will smoothly go in-between the character and their enemy. This function will return the center position between the character and enemy. ]]
	return CFrame.new(
		(GameVariables.humanoidRootPart.Position.X + GameVariables.enemyHumanoidRootPart.Position.X) / 2,
		GameVariables.subject.CFrame.Y,
		(GameVariables.humanoidRootPart.Position.Z + GameVariables.enemyHumanoidRootPart.Position.Z) / 2)
	end
	
local function faceEnemy(subject)
	
	GameVariables.humanoidRootPart.CFrame = CFrame.lookAt(
		GameVariables.humanoidRootPart.Position, 
		Vector3.new(GameVariables.enemyHumanoidRootPart.Position.X, 
		GameVariables.humanoidRootPart.Position.Y, 
		GameVariables.enemyHumanoidRootPart.Position.Z)
	) -- makes sure the player character is always facing the enemy character.
	
	if GameVariables.subjectTween.PlaybackState ~= Enum.PlaybackState.Playing then
		
		subject.CFrame = getCenteredSubjectCFrame()
		
	end

end


local function createSubject(subject) --[[Creates a invisible part (subject) between the player and the enemy that the camera will be focused on]]
	subject.Name = "subject"
			subject.Size = Vector3.new(0.1, 0.1, 0.1)
			subject.Transparency = 0.75
			subject.CanCollide = false
			subject.Anchored = true
			subject.Parent = GameVariables.character
end


-- function LockOnSystem.Init() --[[ Function that should be ran as soon as the playe joins the game to control mouse behavior ]]
-- 	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

-- end

function LockOnSystem.LockOn()

	if not GameVariables.isAttacking 
	and not GameVariables.isGettingHit 
	and not GameVariables.pairedPlaying 
	and not GameVariables.getPublicPlayerInstance(GameVariables.player.Name)["isDodging"] 
	and not GameVariables.isBlocking 
	and not GameVariables.waitingToAttack
	then -- the player should not be able to lock off when in action, whether thats attacking, blocking, dodging, countering, etc
		
		local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = GameVariables.character:GetChildren()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			
			GameVariables.raycastResult =
			workspace:Raycast(GameVariables.humanoidRootPart.Position,
							  GameVariables.humanoidRootPart.CFrame.LookVector * 8,
							  rayParams) -- Raycast in front of player to find an enemy
							  
	
			if GameVariables.raycastResult and not GameVariables.raycastResult.Instance.Parent:GetAttribute("TavernKeeper") and GameVariables.raycastResult.Instance.Parent:FindFirstChild("Humanoid") then -- We found an alive enemy to lock onto (thats not the tavern keeper).
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
		
	
		if (GameVariables.lockOnDebounce.Value == true and GameVariables.raycastResult.Instance.Parent:FindFirstChild("Humanoid")) or (GameVariables.isGettingHit and not GameVariables.lockOnDebounce.Value) then -- Runs when the player locks onto somebody
		
			print(GameVariables.originalCamFocus, "Subject:", GameVariables.originalCamSubject)
			
			GameVariables.enemyHumanoidRootPart = GameVariables.raycastResult.Instance.Parent:WaitForChild("HumanoidRootPart")
			GameVariables.FC_IdleTRACK:Play()
			-- character changes below:
			GameVariables.humanoid.AutoRotate = false -- doesnt allow the player to rotate themself while locked on.
			GameVariables.SetSpeed(true)
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter -- Because roblox player scripts are currently broke and we are also testing still, we disable this for now until we're done.
			
			-- camera subject part
			GameVariables.subject = GameVariables.character:FindFirstChild("subject") or Instance.new("Part") --[[ Subject is the point
			That the player's camera revoles around when they lock on. It is perfectly between the player and enemy.]]
			
			if GameVariables.character:FindFirstChild("subject") == nil then --[[ Creates a subject if it's not created yet on
			it's first lock on.]]
				createSubject(GameVariables.subject)
			end
			if GameVariables.subject.CFrame ~= GameVariables.humanoidRootPart.CFrame then
				GameVariables.subject.CFrame = GameVariables.humanoidRootPart.CFrame -- the subject will begin at the humanoid's CFrame and smoothly transition to the center between character and enemy
			end
	
			
			-- camera changes:
			-- GameVariables.Camera.CameraType = Enum.CameraType.Orbital
			GameVariables.Camera.CameraSubject = GameVariables.subject
			
			local subjectTweenInfo = TweenInfo.new(
				1,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			)
			local subjectTweenGoal = {CFrame = getCenteredSubjectCFrame()}
	
			GameVariables.subjectTween = TweenService:Create(GameVariables.subject, subjectTweenInfo, subjectTweenGoal)
			GameVariables.subjectTween:Play()
	
			-- GameVariables.subjectTween.Completed:Wait()
			
			while GameVariables.lockOnDebounce.Value == true and workspace:Raycast(GameVariables.humanoidRootPart.Position, GameVariables.humanoidRootPart.CFrame.LookVector * 8, rayParams) ~= nil and GameVariables.enemyHumanoid.Health > 0 and GameVariables.humanoid.Health > 0 do -- constantly keeps the player facing the enemy
				-- Constantly having the player face the enemy when locked on
	
				task.wait()
				faceEnemy(GameVariables.subject)
			end
	
			if GameVariables.humanoid.Health <= 0 or GameVariables.enemyHumanoid.Health <= 0 then -- if the player or enemy dies, then we want to stop locking on.
				task.wait(0.5)
				GameVariables.lockOnDebounce.Value = false
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
			-- GameVariables.Camera.Focus = GameVariables.originalCamFocus
			GameVariables.Camera.CameraSubject = GameVariables.humanoid
			GameVariables.Camera.CameraType = Enum.CameraType.Custom
		end
	
	
	
		
		-- if input.KeyCode == Enum.KeyCode.Q then -- lock on with Q
			
			
			-- lock on code below:
			
			
		-- end
	end


end

return LockOnSystem