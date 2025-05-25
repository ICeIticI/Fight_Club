local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Character_Hitboxes = {}
Character_Hitboxes.__index = Character_Hitboxes


local function isCounterTrackPlaying(animator) --[[Function used to check if a counter animation track is playing. If it is, then we don't want the player taking damage after they counter someone.]]

	local playingTracks = animator:GetPlayingAnimationTracks()
	for _, v in pairs(playingTracks) do
		if v.Animation:GetAttribute("Counter") and v.Animation:GetAttribute("AttackLevel") == 3 then
			return true
		end
	end
	return false
end

-- Function to handle receiving an attack
local function receive(receiver_characterInstance, attacker_currentAttack)
    -- local currentAttackID = currentAttack.AnimationId

    if receiver_characterInstance.currentReceiveAnimTRACK and receiver_characterInstance.currentReceiveAnimTRACK.IsPlaying then
        receiver_characterInstance.currentReceiveAnimTRACK:Stop()
    end

    if not receiver_characterInstance.isBlocking then
        if receiver_characterInstance.FC_BlockStartTRACK.IsPlaying then
            -- If the player gets hit while the blockstart track is playing, then they will perform a parry
            -- handleBlocking(currentAttack)
            receiver_characterInstance:receive("parry", attacker_currentAttack)
        elseif receiver_characterInstance.Protocol ~= "Counter" 
        and receiver_characterInstance.randAttack 
        and receiver_characterInstance.randAttack.IsPlaying 
        and not receiver_characterInstance.currentAttack:GetAttribute("Counter") 
        and not receiver_characterInstance.isCountering 
        and not receiver_characterInstance.canFollowUp 
        and not receiver_characterInstance.attackFrames 
        and not receiver_characterInstance.isGettingHit 
        then
            -- If the player is just starting an attack and gets hit, they will counter
            -- handleCounter(currentAttack)
            receiver_characterInstance:receive("counterAttack", attacker_currentAttack)
        elseif not receiver_characterInstance.isCountering then
            -- getHit(currentAttack)
            if attacker_currentAttack:GetAttribute("AttackLevel") == 1 then
                receiver_characterInstance:receive("receiveLevel1", attacker_currentAttack)
            elseif attacker_currentAttack:GetAttribute("AttackLevel") == 2 then
                receiver_characterInstance:receive("receiveLevel2", attacker_currentAttack)
            end
        end
    elseif receiver_characterInstance.isBlocking then
        warn("We is blocking")
        receiver_characterInstance.canSyncBlock = false
        receiver_characterInstance:receive("bracingBlock", attacker_currentAttack)
    end

    -- characterInstance.playReceivingTrack()
end

local function attackHandler(characterInstance, enemyInstance) --[[ handles when a character lands an attack ]]
    local enemyCurrentAttack = enemyInstance.currentAttack
	local hitSFX = characterInstance.player.Character.Torso:FindFirstChild("hitSFX")
	
	if not enemyInstance.iFrames and (not isCounterTrackPlaying(enemyInstance.charAnimator)) then
		-- local otherProtocol = "Receive"
		
		-- if hitPlayer then
		-- 	GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, otherProtocol)
		-- elseif hitCharacter then
		-- 	-- isAI = true
		-- 	GlobalRemoteEvent:FireClient(characterInstance.player, currentAttack, otherProtocol, nil, nil, isAI)
		-- end
        receive(characterInstance, enemyCurrentAttack)
			
		task.wait(0.1) -- give the server enough time to retrieve the enemy's current attack.. if any.
		enemyInstance.enemyCFrame = characterInstance.humanoidRootPart.CFrame -- We want to know where the enemy is when they hit us so we can repel the opposite direction
			
		if enemyInstance.isBlocking then
			attackDamage = attackDamage/2
		end

		-- if attackDamage and not enemyInstance.canCounter then
		-- 	enemyInstance.humanoid:TakeDamage(attackDamage)
		-- 	hitSFX:Play()
		-- end

	end
end


function Character_Hitboxes:manageHitboxes()
    for _, v in pairs(self.characterInstance.hitboxesFolderATTACK) do
        local touchedConnection = v.Touched:Connect(function(touchedObject)
            if self.characterInstance.isAttacking and not self.characterInstance.hitDebounce and touchedObject:GetAttribute("ReceiveBox") and touchedObject.Parent.Parent:FindFirstChild("Humanoid") and self.characterInstance.currentAttack and not touchedObject:IsAncestorOf(self.characterInstance.character) then
                self.characterInstance.hitDebounce = true
                local enemyCharacter = touchedObject.Parent.Parent
                local enemyInstance = Characters:GetCharacterObjectByCharacter(enemyCharacter)
                local enemyPlayer = enemyInstance.player

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
                    
                    -- self.setupHitSFX()
                    -- setupAttackDamage(self.characterInstance)

                    attackHandler(self.characterInstance, enemyInstance)
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