--[[ We obviously know what ragdolling is. Y'know, where a
	 character's joints swing freely and often, is out of
	 control.]]

-- This is possible in roblox, with thanks to two particular assets:

--[[ The Motor6D: This object joins two baseparts together and allow them to be
     animatable. Rigs typically have these.]]

--[[ The BallSocketConstraint: Similar to the Motor6D, but the difference is this
 	 object allows the connected baseparts to swing freely on all axies. it also has a
 	 property called .LimitsEnabled. If set to true, the baseparts can rotate to a
 	 limited degree.]]


-- Services
local Players = game:GetService("Players") -- to be able to ragdoll players who join the game

-- Variables
local jointsCache = {} -- assigns values to keys, like a dictionary. We can define keys such as jointsCache[character] = defined value. 
local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

-- Functions
local function GetMotor6Ds(givenChar)
	local Motor6DsTable = {}
	
	for _, v in pairs(givenChar:GetDescendants()) do
		if v:IsA("Motor6D") then -- the second parameter is recursive. Its by default set to false. But what it does is when set to true, it will search the child, but it will also search it's decendants as well and won't be limited to the child.
			table.insert(Motor6DsTable, v)
		end
	end
	return Motor6DsTable
end

local function Ragdoll(givenChar) -- this will be the function that.. well.. ragdolls the character
	-- givenChar:WaitForChild("HumanoidRootPart").CFrame = givenChar.HumanoidRootPart.CFrame
	-- 		givenChar.Parent = game.Workspace
	-- 		local Protocol = "CameraChange"
	-- 		GlobalRemoteEvent:FireClient(plr, nil, Protocol, nil, charClone) -- sending a remote event so we can parent the player's camera to the new clone
	-- 		char:Destroy()
	
	local givenCharsHumanoid = givenChar.Humanoid
	
	givenCharsHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true) -- Will help the script run better. In other words, it will not be able to apply it's own physical force on other objects so long as the .Physics state is enabled.
	
	for _, v in pairs(jointsCache[givenChar]) do -- going through all of the given player's motor6d's and replacing them with BallSocketConstraints
		v.Enabled = false -- v is each Motor6D in the table. Because we are replacing the motor6ds, we wont need them active.
		
		local attachment0, attachment1 = Instance.new("Attachment"), Instance.new("Attachment") -- creating two attachments that will tell the ballsocketconstraints where to joint things together
		attachment0.CFrame = v.C0 -- C0 is a CFrame of the first basepart that is attached to the given Motor6D.
		attachment0.Parent = v.Part0 -- part0 is the first basepart
		
		attachment1.CFrame = v.C1
		attachment1.Parent = v.Part1
		
		local socket = Instance.new("BallSocketConstraint")
		socket.Attachment0 = attachment0 -- Attachment0 is like Part0 of a Motor6D
		socket.Attachment1 = attachment1
		
		
		-- now with this, we have enabled ragodolling. However, with this alone, the player's head will bobble around like crazy which will shake the camera like an earthquake.
		-- So to prevent this, we will limit the amount of "twistiness" the socket can do for the head, or particularly, the neck motor6d.
		
		if v.Name == "Neck" then
			socket.LimitsEnabled = true -- limits the amount of roation for the socket
			socket.TwistLimitsEnabled = true -- Limits the twist of the socket based on an upper angle and a lower angle
			socket.UpperAngle = 10 -- the range of twist the socket is limited to, or how big of an angle the socket can rotate.
			
		end
		
		socket.Parent = v.Parent -- setting the parent last is best practice, because if we set the parent earlier, it will have to load everything about the socket, THEN re-assign values.
		
	end


	jointsCache[givenChar] = nil -- to clean up the given character's portion of the cache since they died.
end

-- Connects
Players.PlayerAdded:Connect(function(plr) -- for joining players
	
	-- local charClone = nil

		local linearVelocity = Instance.new("LinearVelocity")
		local angularVelocity = Instance.new("AngularVelocity")

	
	plr.CharacterAdded:Connect(function(char) -- and for their spawning characters
		-- if charClone ~= nil then
		-- 	charClone:Destroy()
		-- end
		
		-- local charCFrame = nil
		
		-- delay(0, function()
		-- 	while char.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead do
		-- 		wait()
		-- 		charCFrame = char.HumanoidRootPart.CFrame
		-- 		print(charCFrame)
		-- 	end
		-- end)

		linearVelocity.Attachment0 = char:WaitForChild("HumanoidRootPart").RootAttachment
		linearVelocity.Enabled = false
		linearVelocity.Parent = char.HumanoidRootPart

		angularVelocity.Attachment0 = char.HumanoidRootPart.RootAttachment
		angularVelocity.Enabled = false
		angularVelocity.Parent = char.HumanoidRootPart

		
		local humanoid = char.Humanoid -- we dont need to use :WaitForChild because humanoid is one of the first things that spawn in
		humanoid.BreakJointsOnDeath = false -- so the player's body parts don't fall apart.
		-- char.Archivable = true
        --charClone = char:Clone() -- We do the ragdoll physics on a clone since we can't add velocity to a dead player's character
		humanoid.Died:Connect(function() -- to ragdoll the character on death
			
			--charClone:WaitForChild("HumanoidRootPart").CFrame = charCFrame
			-- local Protocol = "CameraChange"
			-- print(char.HumanoidRootPart.Position)
			--char:Destroy()
			--charClone.Parent = game.Workspace
			--print(charClone.HumanoidRootPart.Position)
			--GlobalRemoteEvent:FireClient(plr, nil, Protocol, nil, charClone) -- sending a remote event so we can parent the player's camera to the new clone
            Ragdoll(char)
			linearVelocity.Enabled = true
			linearVelocity.VectorVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
			
			angularVelocity.Enabled = true
			angularVelocity.AngularVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))


			-- charClone.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
			-- charClone.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
			
		end)
		
		jointsCache[char] = GetMotor6Ds(char) -- getting the Motor6Ds of the given player and storing it in as it's own key in this table.
	end)
end)