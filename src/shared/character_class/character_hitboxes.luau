local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Character_Hitboxes = {}
Character_Hitboxes.__index = Character_Hitboxes

-- Damage types:
local A1Damage = 5 -- default damage for lvl 1 attacks
local A2Damage = 11 -- default damage for lvl 2 attacks
local syncBlockDamage = 2.5 -- damage for sync blocks
local counterAttackDamage = 8
local attackDamage = nil -- How much damage the player's current attack will do. If the enemy isn't blocking, it will just equal the attack damage of whatever category the player's attack is in. If they are blocking, this will divide it.

local function isCounterTrackPlaying(animator) --[[Function used to check if a counter animation track is playing. If it is, then we don't want the player taking damage after they counter someone.]]

	local playingTracks = animator:GetPlayingAnimationTracks()
	for _, v in pairs(playingTracks) do
		if v.Animation:GetAttribute("Counter") and v.Animation:GetAttribute("AttackLevel") == 3 then
			return true
		end
	end
	return false
end

local function attackHandler(characterInstance) --[[ handles when a character lands an attack ]]
	local enemyInstance = Characters:GetCharacterObjectByCharacter(characterInstance.enemyChar)
    local hitPlayer = enemyInstance.player
	local hitSFX = characterInstance.player.Character.Torso:FindFirstChild("hitSFX")
	
	if not enemyInstance.iFrames and (not isCounterTrackPlaying(hitCharacter.Humanoid.charAnimator)) then
		local otherProtocol = "Receive"
		
		if hitPlayer then
			GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, otherProtocol)
		elseif hitCharacter then
			-- isAI = true
			GlobalRemoteEvent:FireClient(characterInstance.player, currentAttack, otherProtocol, nil, nil, isAI)
		end
			
		task.wait(0.1) -- give the server enough time to retrieve the enemy's current attack.. if any.
		enemyInstance.humanoidRootPart = characterInstance.humanoidRootPart.CFrame -- We want to know where the enemy is when they hit us so we can repel the opposite direction
			
		if enemyInstance.isBlocking then
			attackDamage = attackDamage/2
		end

		if attackDamage and not enemyInstance.canCounter then
			hitPlayer.Character.Humanoid:TakeDamage(attackDamage)
			hitSFX:Play()
		end

	end
end


function Character_Hitboxes:manageHitboxes()
    task.wait()
    for _, v in pairs(self.characterInstance.hitboxesFolderATTACK) do
        local touchedConnection = v.Touched:Connect(function(touchedObject)
            if self.characterInstance.isAttacking and not self.characterInstance.hitDebounce and touchedObject:GetAttribute("ReceiveBox") and touchedObject.Parent.Parent:FindFirstChild("Humanoid") and self.characterInstance.currentAttack and not touchedObject:IsAncestorOf(self.characterInstance.character) then
                self.characterInstance.hitDebounce = true
                local enemyCharacter = touchedObject.Parent.Parent
                local enemyPlayer = game.Players:GetPlayerFromCharacter(enemyCharacter)

                if not self.characterInstance.isCountering then
                    local attackLevel = self.characterInstance.currentAttack:GetAttribute("AttackLevel")
                    if attackLevel == 1 then
                        self.characterInstance.Protocol = "Hook"
                    elseif attackLevel == 2 then
                        self.characterInstance.Protocol = "Haymaker"
                    elseif self.characterInstance.currentAttack:GetAttribute("Paired") and not (self.characterInstance.currentReceiveAnimTRACK and self.characterInstance.currentReceiveAnimTRACK.Animation:GetAttribute("Finisher")) and not (self.characterInstance.currentReceiveAnimTRACK and self.characterInstance.currentReceiveAnimTRACK.Animation:GetAttribute("Counter")) then
                        self.characterInstance.Protocol = "SyncedBlock"
                    end
                end

                if not self.characterInstance.attackFrames then -- Will wait for an attack to end before attacking again
                    repeat task.wait()
                    until self.characterInstance.attackFrames or not self.characterInstance.isAttacking
                end

                if enemyPlayer and self.characterInstance.isAttacking and self.characterInstance.attackFrames then
                    warn(self.characterInstance.Protocol)
                    -- self.characterInstance.GlobalRemoteEvent:FireServer(enemyCharacter, self.characterInstance.Protocol, self.characterInstance.currentAttack, self.characterInstance.character.HumanoidRootPart.CFrame, nil, self.characterInstance.isEnemyHoldingBlock, false)
                    attackHandler(self.characterInstance)
                -- else
                --     warn({enemyPlayer, GameVariables.isAttacking, GameVariables.attackFrames})
                end
            end
        end)

        self.characterInstance.humanoid.Died:Connect(function()
            touchedConnection:Disconnect()
            print("disconnecting connection")
        end)
    end
end

return Character_Hitboxes