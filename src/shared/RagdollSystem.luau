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

local RagdollSystem = {}
-- Services
-- local Players = game:GetService("Players") -- to be able to ragdoll players who join the game

-- Variables
local jointsCache = {} -- assigns values to keys, like a dictionary. We can define keys such as jointsCache[character] = defined value. 
-- local GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")

-- Functions
local function GetMotor6Ds(givenChar)
	--[[ Finds & returns all Motor6Ds in a character in a table format ]]

	local Motor6DsTable = {}
	
	for _, v in pairs(givenChar:GetDescendants()) do
		if v:IsA("Motor6D") then -- the second parameter is recursive. Its by default set to false. But what it does is when set to true, it will search the child, but it will also search it's decendants as well and won't be limited to the child.
			table.insert(Motor6DsTable, v)
		end
	end
	return Motor6DsTable
end

local function solidifyBodyParts(char, sentBool) -- Function that will make sure each body part of a given char is solid so it doesn't go through the ground and stuff when ragdolling
	if sentBool == true then -- for ragdolls
		for _, child in pairs(char:GetChildren()) do
			if child:IsA("BasePart") then -- we found a body part
				task.wait()
				print(char.Name, child)
				child.CanCollide = sentBool
			end
		end
	elseif sentBool == false then -- for un-ragdolling..
		for _, child in pairs(char:GetChildren()) do
			if child:IsA("BasePart") then -- we found a body part
				if child.Name == "Torso" or child.Name == "Head" then
					child.CanCollide = true
					warn(child)
				else
					child.CanCollide = false
				end
				task.wait()
				print(char.Name, child)
				child.CanCollide = sentBool
			end
		end
	end
end

local function Ragdoll(givenChar, sentBool) --[[this will be the function that.. well.. ragdolls the character ]]
	local givenCharsHumanoid = givenChar.Humanoid

	if sentBool == true then
		givenCharsHumanoid.PlatformStand = true
		givenCharsHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
		for _, v in pairs(jointsCache[givenChar]) do
			v.Enabled = false

			local attachment0, attachment1 = Instance.new("Attachment"), Instance.new("Attachment")
			attachment0.Name = "ragdoll_attachment0"
			attachment0.CFrame = v.C0
			attachment0.Parent = v.Part0
			
			attachment1.Name = "ragdoll_attachment1"
			attachment1.CFrame = v.C1
			attachment1.Parent = v.Part1
			
			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "ragdoll_socket"
			socket.Attachment0 = attachment0
			socket.Attachment1 = attachment1
			
			if v.Name == "Neck" then
				socket.LimitsEnabled = true
				socket.TwistLimitsEnabled = true
				socket.UpperAngle = 10
			end
			
			socket.Parent = v.Parent
		end
	else
		givenCharsHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		for _, v in pairs(jointsCache[givenChar]) do
			v.Enabled = true

			for _, child in pairs(v.Parent:GetChildren()) do
				if child:IsA("BallSocketConstraint") or (child:IsA("Attachment") and string.find(child.Name, "ragdoll_attachment")) then
					child:Destroy()
				end
			end
		end
		givenCharsHumanoid.PlatformStand = false
	end

	-- givenCharsHumanoid.PlatformStand = not sentBool
	solidifyBodyParts(givenChar, sentBool)
end

-- Connects:

function RagdollSystem.InitializePlayer() --[[ When a player joins the game, we want to set up two instances: Linear and Angular velocities that will be given a parent of the current character of the player. The function will return these, so it can be used when initializing the plr char. ]]

-- Players.PlayerAdded:Connect(function(plr) -- for joining players
	
	-- local charClone = nil

	local linearVelocity = Instance.new("LinearVelocity")
	local angularVelocity = Instance.new("AngularVelocity")

	return {linearVelocity, angularVelocity}

end

function RagdollSystem.InitializeCharacter(linearVelocity, angularVelocity, char)
	
	-- plr.CharacterAdded:Connect(fun`ction(char) -- and for their spawning characters
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
			--[[ The player will ragdoll on death, as well as making the player corpse move
			     via angular and linear velocities. ]]

			--charClone:WaitForChild("HumanoidRootPart").CFrame = charCFrame
			-- local Protocol = "CameraChange"
			-- print(char.HumanoidRootPart.Position)
			--char:Destroy()
			--charClone.Parent = game.Workspace
			--print(charClone.HumanoidRootPart.Position)
			--GlobalRemoteEvent:FireClient(plr, nil, Protocol, nil, charClone) -- sending a remote event so we can parent the player's camera to the new clone
            Ragdoll(char, true)

			-- giving the character random velocity when on ragdoll:
			linearVelocity.Enabled = true
			linearVelocity.VectorVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
			
			angularVelocity.Enabled = true
			angularVelocity.AngularVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))


			-- charClone.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
			-- charClone.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
			jointsCache[char] = nil -- to clean up the given character's portion of the cache since they died.
		end)
		
		jointsCache[char] = GetMotor6Ds(char) -- getting the Motor6Ds of the given player and storing it in as it's own key in this table.

		-- Not ready yet..:
		--[[
			local FC_LinearVelocity = char.HumanoidRootPart:WaitForChild("FC_LinearVelocity")
		local LeftLegHitbox = char[char.Name .. "_hitboxesFolder"]:WaitForChild(char.Name .. "_hitboxLeftLeg")
		local RightLegHitbox = char[char.Name .. "_hitboxesFolder"]:WaitForChild(char.Name .. "_hitboxRightLeg")
		
		local legHitboxesTable = {
			LeftLegHitbox,
			RightLegHitbox
		}
		
		for _, hitbox in pairs(legHitboxesTable) do
			hitbox.Touched:Connect(function()
				if FC_LinearVelocity.VectorVelocity.Magnitude > 0.1 then
					Ragdoll(char, true)
					wait(2)
					Ragdoll(char, false)
				end
				print(FC_LinearVelocity.VectorVelocity.Magnitude)
			end)
		end
		]]
		

		--testing:
		-- task.wait(3)
		-- Ragdoll(char, true)
		-- print("ragdolled the char")
		-- task.wait(3)
		-- Ragdoll(char, false)
-- end)
end

return RagdollSystem