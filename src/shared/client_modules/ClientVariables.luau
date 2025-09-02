local ClientVariables = {}
ClientVariables.__index = ClientVariables

ClientVariables.player = game:GetService("Players").LocalPlayer
ClientVariables.initialized = false
local canInit = true -- local variable that dictates when the script is able to initialize the Init() function. We don't want it running twice, as that will just be creating unnecessairy load times.


local function Init() -- The .CharacterAdded event doesn't always track when a player character is added. Sometimes the character spawns and beats the event. So just in case, this function was created to initialize (or reinitialize) variables that are crutial for the game to work.
	ClientVariables.initialized = false

	ClientVariables.character = ClientVariables.player.Character or ClientVariables.player.CharacterAdded:Wait()
	ClientVariables.humanoid = ClientVariables.character:WaitForChild("Humanoid")
	-- ClientVariables.previousHealth = ClientVariables.humanoid.Health -- This var is used to determine how much damage the character takes.

	ClientVariables.charAnimator = ClientVariables.character:WaitForChild("Humanoid"):WaitForChild("Animator")
	ClientVariables.humanoidRootPart = ClientVariables.character:WaitForChild("HumanoidRootPart")
	print("hrp: ", ClientVariables.humanoidRootPart, ClientVariables.humanoidRootPart.Parent.Humanoid.Health)

	-- Bools and Values:
	
	ClientVariables.lockOnDebounce = ClientVariables.plrObjectsFolder:FindFirstChild("lockOnDebounce") -- attemps to find lockOnDebounce. If it doesn't exist, then this var will be nil.
	ClientVariables.movingDirection = ClientVariables.plrObjectsFolder:FindFirstChild("movingDirection")							

	ClientVariables.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim


	ClientVariables.stamina = ClientVariables.plrObjectsFolder:WaitForChild("stamina")
	ClientVariables.maxStamina = ClientVariables.plrObjectsFolder:WaitForChild("maxStamina")
	
	local humanoidDiedConnect -- the :Connect() event for when the player's current humanoid dies.
	humanoidDiedConnect = ClientVariables.humanoid.Died:Connect(function()
		canInit = true
		ClientVariables.initialized = false
		
		-- Disconnect the .Died event so we don't have .Died connects of the player's past dead humanoids running, which will be re-initialized on next player character spawn:
		humanoidDiedConnect:Disconnect()
	 end)

	 -- Constantly record the velocity of the character and stop leg movement animation when its around 0:
	task.spawn(function()
		while ClientVariables.humanoid.Health > 0 do
			task.wait()
			ClientVariables.velocityMagnitude = ClientVariables.humanoidRootPart.AssemblyLinearVelocity.Magnitude
			if ClientVariables.velocityMagnitude < 0.1 then
				-- while not ClientVariables.velocityMagnitude do task.wait() end
				
				ClientVariables.stopMovementAnimations()
			end
		end
	end)
	-- ClientVariables.initialized = true
	return
end


ClientVariables.Camera = game.Workspace.CurrentCamera
ClientVariables.plrObjectsFolder = ClientVariables.player:WaitForChild(ClientVariables.player.Name .. "_GameObjects") -- perhaps change it from player.Name to player.playerId for saving and stuff in the future

ClientVariables.finalStatValuesFolder = ClientVariables.plrObjectsFolder:WaitForChild("baseValues")
-- for _, intV in pairs(ClientVariables.plrObjectsFolder:WaitForChild("baseValues"):GetChildren()) do
-- 	ClientVariables.finalStatValues[intV.Name] = intV
-- end

-- Global Remote Event - Because each player having their own remote event is redundant.
ClientVariables.GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

-- Global Remote Function - Like the Global Remote Event, but used when we specifically want something returned
ClientVariables.GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

-- Global Bindable Event
ClientVariables.GlobalBindableEvent = game.ReplicatedStorage:WaitForChild("GlobalBindableEvent")

-- Local Remote Event:
ClientVariables.LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")


-- User Input Types
ClientVariables.AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.Touch] = true, [Enum.KeyCode.ButtonB] = true} -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
ClientVariables.BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true}
ClientVariables.GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true}
ClientVariables.LockOnInputs = {[Enum.KeyCode.Q] = true, [Enum.KeyCode.ButtonL2] = true} -- May have LockOnInputs for each system

--ClientVariables.humanoid = nil -- we need this here because the script doesn't know what is connected to the .Died event until the .Init() function runs, but this :Connect will begin checking as soon as the script reaches it, so we need it to at least exist as a variable before using it in a built-in event.

ClientVariables.player.CharacterAdded:Connect(function()
	if canInit then
		Init()
		canInit = false
	end
end)

if ClientVariables.player.Character then
	if canInit then
		Init()
		canInit = false
	end
end

while not ClientVariables.humanoid do -- will wait until the humanoid exists.
	task.wait()
end

-- origins
-- ClientVariables.originalWalkSpeed = ClientVariables.humanoid.WalkSpeed
ClientVariables.originalCamFocus = ClientVariables.Camera.Focus
ClientVariables.originalCamSubject = ClientVariables.Camera.CameraSubject

-- ClientVariables.lockOnSpeed = ClientVariables.originalWalkSpeed / 1.85

-- functions
function ClientVariables.stopAnimations() -- add params? Perhaps we could change function to "changeAnimations" with the first parameter being whether we should stop or play, and add animations in following parameters
	local tracksToStop = {
		ClientVariables.FC_IdleTRACK,
		ClientVariables.currentReceiveAnimTRACK,
		ClientVariables.currentGrabSecureTRACK,
		ClientVariables.currentReceiveGrabSecureTRACK,
		ClientVariables.currentGrabTRACK,
	}

	for _, track in pairs(tracksToStop) do
		if track then
			track:Stop()
		end
	end
	
end

function ClientVariables.stopMovementAnimations()
	if not ClientVariables.FC_SideMomentumTRACK or not ClientVariables.FC_StraightMomentumTRACK then return end

	ClientVariables.FC_StraightMomentumTRACK:Stop()
	ClientVariables.FC_SideMomentumTRACK:Stop()
end

return ClientVariables