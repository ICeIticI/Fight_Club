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
    -- if receiver_characterInstance.currentReceiveAnimTRACK and receiver_characterInstance.currentReceiveAnimTRACK.IsPlaying then
    --     receiver_characterInstance.currentReceiveAnimTRACK:Stop()
    -- end

    if not receiver_characterInstance.isBlocking then
        if receiver_characterInstance.BlockStartAnimPlaying then
            -- If the player gets hit while the blockstart track is playing, then they will perform a parry
            -- handleBlocking(currentAttack)
            receiver_characterInstance:receive("parry", attacker_characterInstance)
            attacker_characterInstance:receive("receiveParry", receiver_characterInstance)
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
            -- handleCounter(currentAttack)
            receiver_characterInstance:repulseAttack("counter", attacker_characterInstance) 
            attacker_characterInstance:receive("counterAttack", receiver_characterInstance)
        
        elseif not receiver_characterInstance.isCountering
        and attacker_characterInstance.currentAttack_trackData 
        then
                -- getHit(currentAttack)
            if attacker_characterInstance.currentAttack_trackData.Animation:GetAttribute("AttackLevel") == 1 then
                receiver_characterInstance:receive("receiveLevel1", attacker_characterInstance)
            elseif attacker_characterInstance.currentAttack_trackData.Animation:GetAttribute("AttackLevel") == 2 then
                receiver_characterInstance:receive("receiveLevel2", attacker_characterInstance)
            end
        
        end
    
    elseif receiver_characterInstance.isBlocking and not receiver_characterInstance.pairedPlaying then
        receiver_characterInstance.canSyncBlock = false
        receiver_characterInstance:receive("bracingBlock", attacker_characterInstance)
    end

    -- characterInstance.playReceivingTrack()
end

local function attackHandler(attacker_characterInstance, receiver_characterInstance) --[[ handles when a character lands an attack ]]
    -- local enemyCurrentAttack = enemyInstance.currentAttack_trackData
	-- local hitSFX = characterInstance.player.Character.Torso:FindFirstChild("hitSFX")
	
    if not receiver_characterInstance.iFrames and not (
        receiver_characterInstance.currentAttack_trackData 
        and receiver_characterInstance.currentAttack_trackData.Animation:GetAttribute("Counter")
        and receiver_characterInstance.currentAttack_trackData.IsPlaying
    )
    and not receiver_characterInstance.isGrappling
    then
        attacker_characterInstance.GlobalRemoteEvent:FireClient(attacker_characterInstance.player, "shakeCamera", {type = "Strike"})
        receive(receiver_characterInstance, attacker_characterInstance)
    end
end


local potentialEnemyChar -- when attacking and hit something, this will store what could potentially be a character, if any.
local potentialEnemyInstance -- if the potentialEnemyChar is in fact a character and has a characterInstance

function Character_Hitboxes:manageHitboxes()
    for _, v in pairs(self.characterInstance.attackHitboxes) do
        
        local touchedConnection = v.Touched:Connect(function(touchedObject)
            if not self.characterInstance.isAttacking then return end
            
            
            if self.characterInstance.isAttacking.Value then -- Begin checling for potentialEnemy stuff only if we're attacking, otherwise it'll check for every single .Touched no matter the circumstance, which is very processing.
                potentialEnemyChar = touchedObject:FindFirstAncestorWhichIsA("Model")
                potentialEnemyInstance = Characters:GetCharacterObjectByCharacter(potentialEnemyChar)
                
                -- print(
                --     self.characterInstance.isAttacking.Value ,
                --     touchedObject:GetAttribute("ReceiveBox"),
                --     potentialEnemyInstance ~= nil,
                --     self.characterInstance.currentAttack_trackData,
                --     not touchedObject:IsAncestorOf(self.characterInstance.character),
                --     not potentialEnemyInstance.hitDebounce[self.characterInstance.id]
                -- )
            end
        
            if self.characterInstance.isAttacking.Value 
            and touchedObject:GetAttribute("ReceiveBox")
            and potentialEnemyInstance ~= nil
            and self.characterInstance.currentAttack_trackData
            and not touchedObject:IsAncestorOf(self.characterInstance.character)
            and not potentialEnemyInstance.hitDebounce[self.characterInstance.id]
            then

                
                potentialEnemyInstance.hitDebounce[self.characterInstance.id] = true
                
                local enemyInstance = potentialEnemyInstance
                local enemyPlayer = enemyInstance.player


                -- cleanup the potentialEnemy stuff so irrelevant data doesn't get used for future attacks:
                potentialEnemyChar = nil
                potentialEnemyInstance = nil

                if not self.characterInstance.isCountering then
                    local attackLevel = self.characterInstance.currentAttack_trackData.Animation:GetAttribute("AttackLevel")
                    if attackLevel == 1 then
                        self.characterInstance.Protocol = "Hook"
                    elseif attackLevel == 2 then
                        self.characterInstance.Protocol = "Haymaker"
                    elseif self.characterInstance.currentAttack_trackData.Animation:GetAttribute("Paired") and not (self.characterInstance.currentReceiveAnimTRACK and self.characterInstance.currentReceiveAnimTRACK.Animation:GetAttribute("Finisher")) and not (self.characterInstance.currentReceiveAnimTRACK and self.characterInstance.currentReceiveAnimTRACK.Animation:GetAttribute("Counter")) then
                        self.characterInstance.Protocol = "SyncedBlock"
                    end
                end

                if not self.characterInstance.attackFrames then -- Will wait for an attack to end before attacking again
                    repeat task.wait()
                    until self.characterInstance.attackFrames or not self.characterInstance.isAttacking.Value
                end

                if enemyPlayer and self.characterInstance.isAttacking.Value and self.characterInstance.attackFrames then
                    -- self.characterInstance.GlobalRemoteEvent:FireServer(enemyCharacter, self.characterInstance.Protocol, self.characterInstance.currentAttack, self.characterInstance.character.HumanoidRootPart.CFrame, nil, self.characterInstance.isEnemyHoldingBlock, false)
                    -- self.setupHitSFX()
                    -- setupAttackDamage(self.characterInstance)
                    attackHandler(self.characterInstance, enemyInstance)
                -- else
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