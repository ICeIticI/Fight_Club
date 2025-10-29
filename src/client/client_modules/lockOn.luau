local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ModuleLoader

local LockOn = {}

local function getCenteredSubjectCFrame() --[[ When the character locks onto the enemy, a 'subject' will be created, which will act as the point where the camera focuses on. So wherever the subject goes, the Camera goes as well. So the subject will start at the camera's current CFrame, and will smoothly go in-between the character and their enemy. This function will return the center position between the character and enemy. ]]
	return CFrame.new(
		(ModuleLoader.ClientVariables.humanoidRootPart.Position.X 
		+ ModuleLoader.ClientVariables.enemyHumanoidRootPart.Position.X) / 2,
		ModuleLoader.ClientVariables.subject.CFrame.Y,
		(ModuleLoader.ClientVariables.humanoidRootPart.Position.Z + ModuleLoader.ClientVariables.enemyHumanoidRootPart.Position.Z) / 2)
end
	
local function faceEnemy(subject, enemyHRP)
	if not enemyHRP then return end

	if not ModuleLoader.ClientVariables.isGrappling then
		ModuleLoader.ClientVariables.humanoidRootPart.CFrame = CFrame.lookAt(
			ModuleLoader.ClientVariables.humanoidRootPart.Position, 
			Vector3.new(enemyHRP.Position.X, 
			ModuleLoader.ClientVariables.humanoidRootPart.Position.Y, 
			enemyHRP.Position.Z)
		) -- makes sure the player character is always facing the enemy character.
	end
	
	if ModuleLoader.ClientVariables.subjectTween.PlaybackState ~= Enum.PlaybackState.Playing then
		subject.CFrame = getCenteredSubjectCFrame()
	end

end

local function createSubject(subject) --[[Creates a invisible part (subject) between the player and the enemy that the camera will be focused on]]
	subject.Name = "subject"
	subject.Size = Vector3.new(0.1, 0.1, 0.1)
	subject.Transparency = 1
	subject.CanCollide = false
	subject.Anchored = true
	subject.Parent = ModuleLoader.ClientVariables.character
end

local function lockOnMovement()
	if not ModuleLoader.ClientVariables.lockOnDebounce.Value then return end

	local currentVelocityMagnitude = ModuleLoader.ClientVariables.humanoidRootPart.AssemblyLinearVelocity.Magnitude
	ModuleLoader.ClientVariables.stopMovementAnimations()

	if currentVelocityMagnitude > 0 or (ModuleLoader.ClientVariables.isInSecureGrapple) then
		
		-- Wait until we move before playing a momentum animation:
		while ModuleLoader.ClientVariables.velocityMagnitude and ModuleLoader.ClientVariables.velocityMagnitude < 0.1 do task.wait() end
		-- If the velocity has changed since we waited then disregard this connection, as a newer one is active:
		if not ModuleLoader.ClientVariables.humanoidRootPart.AssemblyLinearVelocity.Magnitude == currentVelocityMagnitude then return end
		if not LockOn.movementConnection then
			ModuleLoader.ClientVariables.stopMovementAnimations()
			return
		end

		if ModuleLoader.ClientVariables.movingDirection.Value == "right" then
			ModuleLoader.ClientVariables.FC_SideMomentumTRACK:Play()
		elseif ModuleLoader.ClientVariables.movingDirection.Value == "left" then	
			ModuleLoader.ClientVariables.FC_SideMomentumTRACK:AdjustSpeed(-1)
			ModuleLoader.ClientVariables.FC_SideMomentumTRACK:Play()
		elseif ModuleLoader.ClientVariables.movingDirection.Value == "forwards" then
			ModuleLoader.ClientVariables.FC_StraightMomentumTRACK:Play()
		elseif ModuleLoader.ClientVariables.movingDirection.Value == "backwards" then
			ModuleLoader.ClientVariables.FC_StraightMomentumTRACK:AdjustSpeed(-1)
			ModuleLoader.ClientVariables.FC_StraightMomentumTRACK:Play()
		end
	end
end


function LockOn.init()
	ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)
	LockOn.movementConnection = nil
end

function LockOn.Lock(publicVariables)
	-- sync public variables to client:
	for varName, value in pairs(publicVariables) do
		ModuleLoader.ClientVariables[varName] = value
	end
	
	ModuleLoader.ClientVariables.FC_IdleTRACK:Play()
	LockOn.movementConnection = ModuleLoader.ClientVariables.movingDirection:GetPropertyChangedSignal("Value"):Connect(lockOnMovement)
	
	-- character changes below:
	-- ClientVariables.humanoid.AutoRotate = false -- doesnt allow the player to rotate themself while locked on.
	if not RunService:IsStudio() then -- only locks on when not in studio, to make developing easier.
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter -- Because roblox player scripts are currently broke and we are also testing still, we disable this for now until we're done.
	end
	
	-- camera subject part
	ModuleLoader.ClientVariables.subject = ModuleLoader.ClientVariables.character:FindFirstChild("subject") or Instance.new("Part") --[[ Subject is the point
	That the player's camera revoles around when they lock on. It is perfectly between the player and enemy.]]
	
	if ModuleLoader.ClientVariables.character:FindFirstChild("subject") == nil then --[[ Creates a subject if it's not created yet on
	it's first lock on.]]
		createSubject(ModuleLoader.ClientVariables.subject)
	end
	if ModuleLoader.ClientVariables.subject.CFrame ~= ModuleLoader.ClientVariables.humanoidRootPart.CFrame then
		ModuleLoader.ClientVariables.subject.CFrame = ModuleLoader.ClientVariables.humanoidRootPart.CFrame -- the subject will begin at the humanoid's CFrame and smoothly transition to the center between character and enemy
	end

	
	-- camera changes:
	-- ClientVariables.Camera.CameraType = Enum.CameraType.Orbital
	ModuleLoader.ClientVariables.Camera.CameraSubject = ModuleLoader.ClientVariables.subject
	
	local subjectTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out)
		
	local subjectTweenGoal = {CFrame = getCenteredSubjectCFrame()}

	ModuleLoader.ClientVariables.subjectTween = TweenService:Create(ModuleLoader.ClientVariables.subject, subjectTweenInfo, subjectTweenGoal)
	ModuleLoader.ClientVariables.subjectTween:Play()
	-- ClientVariables.subjectTween.Completed:Wait()
	-- print({ClientVariables.lockOnDebounce.Value, 
	-- ClientVariables.humanoidRootPart, 
	-- (ClientVariables.humanoidRootPart.Position - ClientVariables.enemyHumanoidRootPart.Position).Magnitude < 8,
	-- not ClientVariables.enemyHumanoid.deadState.Value,
	-- not ClientVariables.humanoid.deadState.Value})

	faceEnemy(ModuleLoader.ClientVariables.subject)
	while ModuleLoader.ClientVariables.lockOnDebounce.Value == true
	and (ModuleLoader.ClientVariables.humanoidRootPart.Position - ModuleLoader.ClientVariables.enemyHumanoidRootPart.Position).Magnitude < 8
	and not ModuleLoader.ClientVariables.enemyHumanoid.deadState.Value
	and not ModuleLoader.ClientVariables.humanoid.deadState.Value
	do -- constantly keeps the player facing the enemy
		-- Constantly having the player face the enemy when locked on

		task.wait()
		faceEnemy(ModuleLoader.ClientVariables.subject, ModuleLoader.ClientVariables.enemyHumanoidRootPart)
	end

	if LockOn.movementConnection then
		LockOn.movementConnection:Disconnect()
		LockOn.movementConnection = nil
		ModuleLoader.ClientVariables.stopMovementAnimations()
	end

	-- No-longer locked-on. Ensure old, irrelevant data doesn't get used
	for varName, _ in pairs(publicVariables) do -- public variables aint useful after lock-off
		ModuleLoader.ClientVariables[varName] = nil
	end

	return
end

function LockOn.Unlock(publicVariables)

	-- No-longer locked-on. Ensure old, irrelevant data doesn't get used
	for varName, _ in pairs(publicVariables) do -- public variables aint useful after lock-off
		if varName == "lockOnDebounce" then continue end -- Dont wanna make lockOnDebounce nil. We handle that already.
		ModuleLoader.ClientVariables[varName] = nil
	end

	ModuleLoader.ClientVariables.isGrappling = false

	if LockOn.movementConnection then
		LockOn.movementConnection:Disconnect()
		LockOn.movementConnection = nil
		ModuleLoader.ClientVariables.stopMovementAnimations()
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
		
		ModuleLoader.ClientVariables.stopAnimations()
		
		-- character changes below:
		-- ClientVariables.humanoid.AutoRotate = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		
		-- camera changes
		-- ClientVariables.Camera.Focus = ClientVariables.originalCamFocus
		ModuleLoader.ClientVariables.Camera.CameraSubject = ModuleLoader.ClientVariables.humanoid
		ModuleLoader.ClientVariables.Camera.CameraType = Enum.CameraType.Custom
	-- end
end
-- warn("Make sure to make camera lock mouse center before publishing")
return LockOn