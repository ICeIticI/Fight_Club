local ragdollFunction = {}

local function GetMotor6Ds(givenChar) --[[ Finds & returns all Motor6Ds in a character in a table format ]]

	local Motor6DsTable = {}
	
	for _, v in pairs(givenChar:GetDescendants()) do
		if v:IsA("Motor6D") then -- the second parameter is recursive. Its by default set to false. But what it does is when set to true, it will search the child, but it will also search it's decendants as well and won't be limited to the child.
			table.insert(Motor6DsTable, v)
		end
	end
	return Motor6DsTable
end

local function solidifyBodyParts(char : Model, sentBool : boolean) -- Function that will make sure each body part of a given char is solid so it doesn't go through the ground and stuff when ragdolling
	if sentBool == true then -- for ragdolls
		for _, child in pairs(char:GetChildren()) do
			if child:IsA("BasePart") then -- we found a body part
				task.wait()
				child.CanCollide = sentBool
			end
		end
	elseif sentBool == false then -- for un-ragdolling..
		for _, child in pairs(char:GetChildren()) do
			if child:IsA("BasePart") then -- we found a body part
				if child.Name == "Torso" or child.Name == "Head" then
					child.CanCollide = true
				else
					child.CanCollide = false
				end
				task.wait()
				child.CanCollide = sentBool
			end
		end
	end
end


local charactersRagdollData = {} -- table holding data for each character for ragdoll purposes

function ragdollFunction.setupRagdoll(char : Model, id : number)

	-- local charId = char:GetAttribute("id")
	-- if not charId then return warn(tostring(char.Name) .. " does not have an id, which we need to setup ragdoll stuff") end

	charactersRagdollData[id] = {} -- the specific table for this character holding data for ragdoll functionality

	charactersRagdollData[id].linearVelocity = Instance.new("LinearVelocity")
	charactersRagdollData[id].angularVelocity = Instance.new("AngularVelocity")
	charactersRagdollData[id].angularVelocity.Attachment0 = char:WaitForChild("HumanoidRootPart").RootAttachment
	charactersRagdollData[id].angularVelocity.Enabled = false
	charactersRagdollData[id].angularVelocity.Parent = char.HumanoidRootPart

	charactersRagdollData[id].Attachment0 = char.HumanoidRootPart.RootAttachment
	charactersRagdollData[id].Enabled = false
	charactersRagdollData[id].Parent = char.HumanoidRootPart

	charactersRagdollData[id].jointsCache = GetMotor6Ds(char) -- getting the Motor6Ds of the given player and storing it in as it's own key in this table.

end

function ragdollFunction.ragdoll(char : Model, id : number, sentBool : boolean) --[[this will be the function that.. well.. ragdolls the character ]]
	
	-- local charId = char:GetAttribute("id")
	-- if not charId then return warn(tostring(char.Name) .. " does not have an id, which is needed to actually ragdoll") end

	local humanoid = char.Humanoid

	local current_characterRagdollData = charactersRagdollData[id] -- the specific table for this character holding data for ragdoll functionality
	local jointsCache = current_characterRagdollData.jointsCache
		
	if sentBool == true then

		current_characterRagdollData.linearVelocity.Enabled = true
		current_characterRagdollData.linearVelocity.VectorVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
		
		current_characterRagdollData.angularVelocity.Enabled = true
		current_characterRagdollData.angularVelocity.AngularVelocity = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))


		-- Turned off PlatformStand because it prevented death from falls -- just damages them and they would just heal up.
		-- humanoid.PlatformStand = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
		
		for _, v in pairs(jointsCache) do
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
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		for _, v in pairs(jointsCache) do
			v.Enabled = true

			for _, child in pairs(v.Parent:GetChildren()) do
				if child:IsA("BallSocketConstraint") or (child:IsA("Attachment") and string.find(child.Name, "ragdoll_attachment")) then
					child:Destroy()
				end
			end
		end
		humanoid.PlatformStand = false
	end

	-- givenCharsHumanoid.PlatformStand = not sentBool
	solidifyBodyParts(char, sentBool)
end

return ragdollFunction