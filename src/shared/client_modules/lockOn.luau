local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)

local LockOn = {}

local function getCenteredSubjectCFrame() --[[ When the character locks onto the enemy, a 'subject' will be created, which will act as the point where the camera focuses on. So wherever the subject goes, the Camera goes as well. So the subject will start at the camera's current CFrame, and will smoothly go in-between the character and their enemy. This function will return the center position between the character and enemy. ]]

	return CFrame.new(
		(ClientVariables.humanoidRootPart.Position.X 
		+ ClientVariables.enemyHumanoidRootPart.Position.X) / 2,
		ClientVariables.subject.CFrame.Y,
		(ClientVariables.humanoidRootPart.Position.Z + ClientVariables.enemyHumanoidRootPart.Position.Z) / 2)
	end
	
local function faceEnemy(subject, enemyHRP)
	if not enemyHRP then return end

	if not ClientVariables.isGrappling then
		ClientVariables.humanoidRootPart.CFrame = CFrame.lookAt(
			ClientVariables.humanoidRootPart.Position, 
			Vector3.new(enemyHRP.Position.X, 
			ClientVariables.humanoidRootPart.Position.Y, 
			enemyHRP.Position.Z)
		) -- makes sure the player character is always facing the enemy character.
	end
	
	if ClientVariables.subjectTween.PlaybackState ~= Enum.PlaybackState.Playing then
		subject.CFrame = getCenteredSubjectCFrame()
	end

end


local function createSubject(subject) --[[Creates a invisible part (subject) between the player and the enemy that the camera will be focused on]]
	subject.Name = "subject"
	subject.Size = Vector3.new(0.1, 0.1, 0.1)
	subject.Transparency = 0.75
	subject.CanCollide = false
	subject.Anchored = true
	subject.Parent = ClientVariables.character
end

local movementConnection

function LockOn.Lock(publicVariables)
	-- sync public variables to client:
	for varName, value in pairs(publicVariables) do
		ClientVariables[varName] = value
	end
		
	ClientVariables.FC_IdleTRACK:Play()

	movementConnection = ClientVariables.movingDirection:GetPropertyChangedSignal("Value"):Connect(function()

		local currentVelocityMagnitude = ClientVariables.humanoidRootPart.AssemblyLinearVelocity.Magnitude
		ClientVariables.stopMovementAnimations()

		if currentVelocityMagnitude > 0 or (ClientVariables.isInSecureGrapple) then
			
			-- Wait until we move before playing a momentum animation:
			while ClientVariables.velocityMagnitude and ClientVariables.velocityMagnitude < 0.1 do task.wait() end
			-- If the velocity has changed since we waited then disregard this connection, as a newer one is active:
			if not ClientVariables.humanoidRootPart.AssemblyLinearVelocity.Magnitude == currentVelocityMagnitude then return end

			if ClientVariables.movingDirection.Value == "right" then
				ClientVariables.FC_SideMomentumTRACK:Play()
			elseif ClientVariables.movingDirection.Value == "left" then	
				ClientVariables.FC_SideMomentumTRACK:AdjustSpeed(-1)
				ClientVariables.FC_SideMomentumTRACK:Play()
			elseif ClientVariables.movingDirection.Value == "forwards" then
				ClientVariables.FC_StraightMomentumTRACK:Play()
			elseif ClientVariables.movingDirection.Value == "backwards" then
				ClientVariables.FC_StraightMomentumTRACK:AdjustSpeed(-1)
				ClientVariables.FC_StraightMomentumTRACK:Play()
			end
		end
	end)
	
	-- character changes below:
	-- ClientVariables.humanoid.AutoRotate = false -- doesnt allow the player to rotate themself while locked on.
	if not RunService:IsStudio() then -- only locks on when not in studio, to make developing easier.
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter -- Because roblox player scripts are currently broke and we are also testing still, we disable this for now until we're done.
	end
	
	-- camera subject part
	ClientVariables.subject = ClientVariables.character:FindFirstChild("subject") or Instance.new("Part") --[[ Subject is the point
	That the player's camera revoles around when they lock on. It is perfectly between the player and enemy.]]
	
	if ClientVariables.character:FindFirstChild("subject") == nil then --[[ Creates a subject if it's not created yet on
	it's first lock on.]]
		createSubject(ClientVariables.subject)
	end
	if ClientVariables.subject.CFrame ~= ClientVariables.humanoidRootPart.CFrame then
		ClientVariables.subject.CFrame = ClientVariables.humanoidRootPart.CFrame -- the subject will begin at the humanoid's CFrame and smoothly transition to the center between character and enemy
	end

	
	-- camera changes:
	-- ClientVariables.Camera.CameraType = Enum.CameraType.Orbital
	ClientVariables.Camera.CameraSubject = ClientVariables.subject
	
	local subjectTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out)
		
	local subjectTweenGoal = {CFrame = getCenteredSubjectCFrame()}

	ClientVariables.subjectTween = TweenService:Create(ClientVariables.subject, subjectTweenInfo, subjectTweenGoal)
	ClientVariables.subjectTween:Play()
	-- ClientVariables.subjectTween.Completed:Wait()
	faceEnemy(ClientVariables.subject)
	while ClientVariables.lockOnDebounce.Value == true
	and (ClientVariables.humanoidRootPart.Position - ClientVariables.enemyHumanoidRootPart.Position).Magnitude < 8
	and not ClientVariables.enemyHumanoid.deadState.Value
	do -- constantly keeps the player facing the enemy
		-- Constantly having the player face the enemy when locked on

		task.wait()
		faceEnemy(ClientVariables.subject, ClientVariables.enemyHumanoidRootPart)
	end

	if movementConnection then
		movementConnection:Disconnect()
		movementConnection = nil
		ClientVariables.stopMovementAnimations()
	end

	return
end

function LockOn.Unlock(publicVariables)

	-- No-longer locked-on. Ensure old, irrelevant data doesn't get used
	for varName, _ in pairs(publicVariables) do -- public variables aint useful after lock-off
		if varName == "lockOnDebounce" then continue end -- Dont wanna make lockOnDebounce nil. We handle that already.
		ClientVariables[varName] = nil
	end

	ClientVariables.isGrappling = false

	if movementConnection then
		movementConnection:Disconnect()
		movementConnection = nil
		ClientVariables.stopMovementAnimations()
	end


    -- if ClientVariables.humanoid.Health <= 0 or ClientVariables.enemyHumanoid and ClientVariables.enemyHumanoid.Health <= 0 then -- if the player or enemy dies, then we want to stop locking on.
	-- 	task.wait(0.5)
	-- 	ClientVariables.lockOnDebounce.Value = false
	-- end

	-- if not workspace:Raycast(ClientVariables.humanoidRootPart.Position, ClientVariables.humanoidRootPart.CFrame.LookVector * 7, ClientVariables.lockOnRayParams) then -- When the while loop above ends, we want to check if its because the player got too far. If so, then we want to set the lockOnDebounce to false
	-- 	ClientVariables.lockOnDebounce.Value = false
	-- end
	-- end
	
	-- if ClientVariables.lockOnDebounce.Value == false then
		-- Stop locking onto enemy
		
		ClientVariables.stopAnimations()
		
		-- character changes below:
		-- ClientVariables.humanoid.AutoRotate = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		
		-- camera changes
		-- ClientVariables.Camera.Focus = ClientVariables.originalCamFocus
		ClientVariables.Camera.CameraSubject = ClientVariables.humanoid
		ClientVariables.Camera.CameraType = Enum.CameraType.Custom
	-- end
end
-- warn("Make sure to make camera lock mouse center before publishing")
return LockOn