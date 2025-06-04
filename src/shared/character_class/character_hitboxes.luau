local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Character_Hitboxes = {}
Character_Hitboxes.__index = Character_Hitboxes


-- local function isCounterTrackPlaying(animator) --[[Function used to check if a counter animation track is playing. If it is, then we don't want the player taking damage after they counter someone.]]

-- 	local playingTracks = animator:GetPlayingAnimationTracks()
-- 	for _, v in pairs(playingTracks) do
-- 		if v.Animation:GetAttribute("Counter") and v.Animation:GetAttribute("AttackLevel") == 3 then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- Function to handle receiving an attack
local function receive(receiver_characterInstance, attacker_characterInstance)
    -- local currentAttackID = currentAttack.AnimationId
    receiver_characterInstance.attackingChar = attacker_characterInstance.character
    print("check 1")
    -- if receiver_characterInstance.currentReceiveAnimTRACK and receiver_characterInstance.currentReceiveAnimTRACK.IsPlaying then
    --     receiver_characterInstance.currentReceiveAnimTRACK:Stop()
    -- end
    print(attacker_characterInstance, attacker_characterInstance.currentAttack_trackData)
    if not receiver_characterInstance.isBlocking then
        print("check 1.5")
        if receiver_characterInstance.BlockStartAnimPlaying then
            -- If the player gets hit while the blockstart track is playing, then they will perform a parry
            -- handleBlocking(currentAttack)
            receiver_characterInstance:receive("parry", attacker_characterInstance)
            attacker_characterInstance:receive("receiveParry", receiver_characterInstance)
        print("check 2")
        elseif receiver_characterInstance.Protocol ~= "Counter" -- Checks before countering:
        and receiver_characterInstance.currentAttack_trackData -- Make sure the attack exists for countering
        and receiver_characterInstance.currentAttack_trackData.IsPlaying -- Make sure we are attacking. This anim should be playing before the 'StartOfAttack' marker reaches in order to counter
        and not receiver_characterInstance.currentAttack_trackData.Counter_Attribute -- Make sure we're not playing a counter animation
        and not receiver_characterInstance.isCountering -- Make sure we're not countering
        and not receiver_characterInstance.canFollowUp -- NOTE: may change but counters (as of now) are only possible when you wait for an attack, meaning not doable mid-combo
        and not receiver_characterInstance.attackFrames -- Attackframes mean we're too late in the animation. May be redundant to have this check.
        and not receiver_characterInstance.isGettingHit -- Should not be possible when getting hit, but I'm sure other checks before would fail if thats the case.. so it may be redundant.
        then
            -- ! If the player is just starting an attack and gets hit, they will counter ! --
            print("check 3")
            -- handleCounter(currentAttack)
            receiver_characterInstance:repulseAttack("counter", attacker_characterInstance) 
            attacker_characterInstance:receive("counterAttack", receiver_characterInstance)
        
        elseif not receiver_characterInstance.isCountering
        and attacker_characterInstance.currentAttack_trackData 
        then
            print("check 4")
                -- getHit(currentAttack)
            if attacker_characterInstance.currentAttack_trackData.Animation:GetAttribute("AttackLevel") == 1 then
                receiver_characterInstance:receive("receiveLevel1", attacker_characterInstance)
            elseif attacker_characterInstance.currentAttack_trackData.Animation:GetAttribute("AttackLevel") == 2 then
                receiver_characterInstance:receive("receiveLevel2", attacker_characterInstance)
            end
        
        end
    
    elseif receiver_characterInstance.isBlocking then
        warn("We is blocking")
        receiver_characterInstance.canSyncBlock = false
        receiver_characterInstance:receive("bracingBlock", attacker_characterInstance)
    end

    -- characterInstance.playReceivingTrack()
end

local function attackHandler(characterInstance, enemyInstance) --[[ handles when a character lands an attack ]]
    -- local enemyCurrentAttack = enemyInstance.currentAttack_trackData
	local hitSFX = characterInstance.player.Character.Torso:FindFirstChild("hitSFX")
	
	if not enemyInstance.iFrames and not (enemyInstance.currentAttack_trackData and enemyInstance.currentAttack_trackData.Animation:GetAttribute("Counter")) then
		-- local otherProtocol = "Receive"
		
		-- if hitPlayer then
		-- 	GlobalRemoteEvent:FireClient(hitPlayer, currentAttack, otherProtocol)
		-- elseif hitCharacter then
		-- 	-- isAI = true
		-- 	GlobalRemoteEvent:FireClient(characterInstance.player, currentAttack, otherProtocol, nil, nil, isAI)
		-- end
        print("receive reached")
        receive(enemyInstance, characterInstance)
			
		task.wait(0.1) -- give the server enough time to retrieve the enemy's current attack.. if any.
		enemyInstance.enemyCFrame = characterInstance.humanoidRootPart.CFrame -- We want to know where the enemy is when they hit us so we can repel the opposite direction
			
		if enemyInstance.isBlocking then
			characterInstance.attackDamage = characterInstance.attackDamage/2
		end

		-- if attackDamage and not enemyInstance.canCounter then
		-- 	enemyInstance.humanoid:TakeDamage(attackDamage)
		-- 	hitSFX:Play()
		-- end

	end
end


function Character_Hitboxes:manageHitboxes()
    for _, v in pairs(self.characterInstance.attackHitboxes) do
        local touchedConnection = v.Touched:Connect(function(touchedObject)
            -- print
            -- (
            -- self.characterInstance.isAttacking, 
            -- not self.characterInstance.hitDebounce,
            -- touchedObject:GetAttribute("ReceiveBox"),
            -- touchedObject.Parent.Parent:FindFirstChild("Humanoid"),
            -- self.characterInstance.currentAttack,
            -- not touchedObject:IsAncestorOf(self.characterInstance.character)
            -- )
            
            if self.characterInstance.isAttacking 
            and not self.characterInstance.hitDebounce 
            and touchedObject:GetAttribute("ReceiveBox")
            and touchedObject.Parent.Parent:FindFirstChild("Humanoid")
            and self.characterInstance.currentAttack_trackData
            and not touchedObject:IsAncestorOf(self.characterInstance.character) 
            then
                self.characterInstance.hitDebounce = true
                local enemyCharacter = touchedObject.Parent.Parent
                local enemyInstance = Characters:GetCharacterObjectByCharacter(enemyCharacter)
                local enemyPlayer = enemyInstance.player

                if not self.characterInstance.isCountering then
                    print("attackLevel stuff reached")
                    local attackLevel = self.characterInstance.currentAttack_trackData.Animation:GetAttribute("AttackLevel")
                    if attackLevel == 1 then
                        self.characterInstance.Protocol = "Hook"
                    elseif attackLevel == 2 then
                        self.characterInstance.Protocol = "Haymaker"
                    elseif self.characterInstance.currentAttack_trackData.Animation:GetAttribute("Paired") and not (self.characterInstance.currentReceiveAnimTRACK and self.characterInstance.currentReceiveAnimTRACK.Animation:GetAttribute("Finisher")) and not (self.characterInstance.currentReceiveAnimTRACK and self.characterInstance.currentReceiveAnimTRACK.Animation:GetAttribute("Counter")) then
                        self.characterInstance.Protocol = "SyncedBlock"
                    end
                end

                -- if not self.characterInstance.attackFrames then -- Will wait for an attack to end before attacking again
                --     print("waiting for attack to end")
                --     repeat task.wait()
                --     until self.characterInstance.attackFrames or not self.characterInstance.isAttacking
                -- end

                print(enemyPlayer, self.characterInstance.isAttacking, self.characterInstance.attackFrames)
                if enemyPlayer and self.characterInstance.isAttacking and self.characterInstance.attackFrames then
                    warn(self.characterInstance.Protocol)
                    -- self.characterInstance.GlobalRemoteEvent:FireServer(enemyCharacter, self.characterInstance.Protocol, self.characterInstance.currentAttack, self.characterInstance.character.HumanoidRootPart.CFrame, nil, self.characterInstance.isEnemyHoldingBlock, false)
                    
                    -- self.setupHitSFX()
                    -- setupAttackDamage(self.characterInstance)
                    print("attackHandler reached")
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