--[[ 

* Server module that simulates attacking animation tracks and manages accordingly

]]

local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Attack_Animation_Management = {}

local function runOnAttackFrames(characterInstance, trackData) --[[ Manages character data when the attack frames of an animation start. NOT the animation itself. Only the data associated with it.]]
    characterInstance.attackFrames = true
    if trackData.Paired_Attribute then 
        characterInstance.canCounter = false
        if trackData.Animation:GetAttribute("Grapple") == true then
            characterInstance.canFollowUp = true
        end
        -- self.GlobalRemoteEvent:FireServer(self.enemyChar, "CounterAttack", self.currentAttack, nil, nil, self.isEnemyHoldingBlock, false)
        
        -- if trackData.Counter_Attribute or trackData.DodgeAttack_Attribute then -- counterattack animation
        -- -- elseif trackData.DodgeAttack_Attribute then
        if (trackData.Animation:GetAttribute("SyncBlockFinisher") == true) or (trackData.Animation:GetAttribute("Grapple") == false) then -- can be true or false, all we know is its a sync block of some sort
            characterInstance.humanoid:TakeDamage(characterInstance.attackDamage / characterInstance.finalStatValues.BlockAbsorption.Value)
            characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "shakeCamera", {type = "SyncBlock", AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
            characterInstance.playHitSFX(trackData)
        elseif trackData.Animation:GetAttribute("SyncBlockFinisher") == false then -- can be true or false, all we know is its a sync block of some sort
            characterInstance.enemyChar.Humanoid:TakeDamage(characterInstance.attackDamage / characters:GetCharacterObjectByCharacter(characterInstance.enemyChar).finalStatValues.BlockAbsorption.Value)
            characterInstance.GlobalRemoteEvent:FireClient(game.Players:GetPlayerFromCharacter(characterInstance.enemyChar), "shakeCamera", {type = "SyncBlock", AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
            characterInstance.playHitSFX(trackData)
            characterInstance.canFollowUp = true
        -- elseif trackData.Animation:GetAttribute("Grapple") == false then
            
        else

            if characterInstance.isGrappling then -- grapple attacks dont inherently make the camera shake so we gotta do it here
                characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "shakeCamera", {type = "Strike"})
            end
            characterInstance.enemyChar.Humanoid:TakeDamage(characterInstance.attackDamage)
            characterInstance.GlobalRemoteEvent:FireClient(game.Players:GetPlayerFromCharacter(characterInstance.enemyChar), "shakeCamera", {type = trackData.type, AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
            characterInstance.playHitSFX(trackData)
        end

        -- So I may have lied about below lol:

        -- All this crap below will be handled in the hitboxes module. Damage and what not do not be dealt via animation manager.

        -- -- Deal coubter damage:
        -- characterInstance.hitCharacter.Humanoid:TakeDamage(counterAttackDamage)
        -- Play a sound effect for hitting the enemy on counter:
        -- hitSFX:Play()
    else
        characterInstance.canFollowUp = true
        -- self.GlobalRemoteEvent:FireServer(nil, "AttackFrames", nil, nil, nil, nil, false)
        -- characterInstance.isGettingHit = true
    end
end

local function runOnEndOfAttack(characterInstance, trackData) --[[ When we simulate the end of an attack, this will run to correctly manage the data ]]
    characterInstance.attackFrames = false
    characterInstance.isAttacking.Value = false
    -- characterInstance.hitDebounce = false
    characterInstance.canFollowUp = false

    if not trackData.Paired_Attribute then
        characterInstance.SetSpeed(true)
    end

    -- EndOfAttackExists = true

    if trackData.attackLvl == 2 then
        characterInstance.comboCounter = 0
    end
end

-- local attack1_amountOfTimeBeforeAttackFrames = 0.23 -- the animation marker for StartOfAttack was at 0.14 / 0.60 (1 second).
-- local attack1_amountOfTimeBeforeEndOfAttack = 0.45 -- level 1 attacks end 0.45 seconds after the animation begins.
-- local attack1_amountOfTimeBeforeEndOFAnimation = 0.75

-- local attack2_amountOfTimeBeforeAttackFrames = 0.52
-- local attack2_amountOfTimeBeforeEndOfAttack = 1.17
-- local attack2_amountOfTimeBeforeEndOFAnimation = 1.18

function Attack_Animation_Management:runOnIsPlaying(trackData) --[[ Manages character data based on when an attack is playing. NOT the animation track itself. That runs on the client. Unless I decided to move it to the server. ]]

    if trackData.IsPlaying then

        -- Schedule a simulation of the AttackFrames marker and handle data accordingly:
        if trackData.Animation:FindFirstChild("attackTimePositions") then -- Some level 3 sync blocks have no damage-dealing, so no StartOfAttack
            
            for _, attackTimePosition in pairs(trackData.Animation.attackTimePositions:GetChildren()) do
                task.delay(attackTimePosition.Value / self.characterInstance.finalStatValues.attackSpeed.Value, function() -- These attributes equal the number (in seconds) until the marker would reach for said animation
                if trackData.IsPlaying then
                        runOnAttackFrames(self.characterInstance, trackData)
                    end
                end)
            end
        end

        -- Schedule a simulation of the EndOfAttack marker:
        if trackData.Animation:GetAttribute("TimeUntilEndOfAttack") then
            task.delay(trackData.Animation:GetAttribute("TimeUntilEndOfAttack") / self.characterInstance.finalStatValues.attackSpeed.Value, function()
                if trackData.IsPlaying then
                    runOnEndOfAttack(self.characterInstance, trackData)
                end
            end)
        end

        -- Schedule a simulation of the end of the attacking animation:
        task.delay(trackData.Animation:GetAttribute("Length") / self.characterInstance.finalStatValues.attackSpeed.Value, function()
            if trackData.IsPlaying then
                trackData.IsPlaying = false
                trackData.Completed = true
                self.characterInstance.attack_animation_manager:runOnIsPlaying(trackData)
            end
        end)

        self.characterInstance.attackFrames = false -- attackFrames will only be enabled once the "StartOfAttack" marker gets reached.
        self.characterInstance.isAttacking.Value = true
        self.characterInstance.didFollowUp = false
        self.characterInstance.isGettingHit = false
        self.characterInstance.SetSpeed(false)

        if trackData.Counter_Attribute == true then
            self.characterInstance.humanoidRootPart.FC_LinearVelocity.Enabled = false
            -- A level 1 attack played at the time an enemy's attack landed. We transition this into a counter attack.
            self.characterInstance.canCounter = true
            -- self.characterInstance.isCountering = true
            -- self.characterInstance.isAttacking.Value = true
            -- self.characterInstance.Protocol = "Counter"
            -- self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, self.characterInstance.Protocol, self.characterInstance.currentAttack)
            -- self.characterInstance.Protocol = nil
            -- self.characterInstance:repulseAttack("counter", Characters:GetCharacterObjectByCharacter(self.characterInstance.attackingChar))
        end
    elseif not trackData.IsPlaying then


        
        if not trackData.Completed then
            self.characterInstance.Protocol = nil
            
        elseif trackData.Completed  then
            -- if not trackData.attackLvl == 2 then
            --     self.characterInstance.didFollowUp = false
            -- end
            
            if not self.characterInstance.isGrappling then
                self.characterInstance.reset()
            else
                if trackData.attackLvl == 3 then
                    self.characterInstance.isGrappling = false
                    self.characterInstance.grappleDelay = false
                    self.characterInstance.enemyChar.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    self.characterInstance.GlobalRemoteEvent:FireClient(game.Players:GetPlayerFromCharacter(self.characterInstance.enemyChar), "shakeCamera", {type = trackData.type, AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
                    self.characterInstance.enemyChar.Humanoid.Health = 0

                    self.characterInstance.lockOnDebounce.Value = false
                end

                self.characterInstance.waitingToAttack = false
                self.characterInstance.canFollowUp = false
                self.characterInstance.SetSpeed(true)
            end
        end

        if trackData.Animation:GetAttribute("Grapple") == false then -- a false grapple, which means it ends the grappling session
            self.characterInstance.isGrappling = false

            self.characterInstance.setCharacterMassless(self.characterInstance.enemyChar, false)
            self.characterInstance.enemyChar.Humanoid.PlatformStand = false
        end

        if trackData.Paired_Attribute == true and trackData.Completed then
            -- task.delay(0.5, function()
            --     self.characterInstance.hitDebounce = false
            -- end)
            self.characterInstance.isAttacking.Value = false
        end

        -- self.characterInstance.currentAttack_trackData = nil
        self.characterInstance.attackFrames = false
        self.characterInstance.pairedPlaying = false
        
        -- if self.currentAttack_trackData == trackData then
        --     self.currentAttack_trackData = nil
        -- end
    end
end

return Attack_Animation_Management