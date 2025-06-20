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

local ragdollFunction = require(game.ReplicatedStorage.Shared.ragdollFunction)

local RagdollSystem = {}

local function setCharacterNetworkOwnershipTo(character : Model, newOwner)
	for _, child in pairs(character:GetChildren()) do
		if child:IsA("BasePart") then
			child:SetNetworkOwner(newOwner)
		end
	end
end

function RagdollSystem:InitializeCharacter()
		
	local humanoid = self.characterInstance.character.Humanoid -- we dont need to use :WaitForChild because humanoid is one of the first things that spawn in
	humanoid.BreakJointsOnDeath = false -- so the player's body parts don't fall apart.
	-- char.Archivable = true
	--charClone = char:Clone() -- We do the ragdoll physics on a clone since we can't add velocity to a dead player's character
	print("heyy")

	-- if self.characterInstance.player then
	-- 	self.characterInstance.GlobalRemoteEvent:FireAllClients("setupRagdoll", {character = self.characterInstance.character, id = self.characterInstance.id})
	-- else
		ragdollFunction.setupRagdoll(self.characterInstance.character, self.characterInstance.id)
	-- end

	humanoid.Died:Connect(function() -- to ragdoll the character on death
		print("ooo death")			
		
		-- if self.characterInstance.player then
		-- 	setCharacterNetworkOwnershipTo(self.characterInstance.character, self.characterInstance.player)
		-- 	self.characterInstance.GlobalRemoteEvent:FireAllClients("ragdoll", {character = self.characterInstance.character, id = self.characterInstance.id, ragdollBool = true})
		-- else -- NPC. Run on server right here
			ragdollFunction.ragdoll(self.characterInstance.character, self.characterInstance.id, true)
		-- end		
	end)
end

return RagdollSystem