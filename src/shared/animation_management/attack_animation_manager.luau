--[[ 

* Server module that simulates attacking animation tracks and manages accordingly

]]

local Attack_Animation_Management = {}

local function runOnAttackFrames(characterInstance, trackData) --[[ Manages character data when the attack frames of an animation start. NOT the animation itself. Only the data associated with it.]]
    if trackData.Paired_Attribute and trackData.Counter_Attribute then
        characterInstance.canCounter = false
        -- self.GlobalRemoteEvent:FireServer(self.enemyChar, "CounterAttack", self.currentAttack, nil, nil, self.isEnemyHoldingBlock, false)
        
        if trackData.Counter_Attribute then -- NOTE: Move this to the receiving counter instead so the damage aligns with itself
            characterInstance.hitCharacter.Humanoid:TakeDamage(characterInstance.attackDamage)
            characterInstance.playHitSFX()
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
    characterInstance.isAttacking = false
    characterInstance.hitDebounce = false
    characterInstance.canFollowUp = false

    if not trackData.Paired_Attribute then
        characterInstance.SetSpeed(true)
    end

    -- EndOfAttackExists = true

    if trackData.attackLvl == 2 then
        characterInstance.comboCounter = 0
    end
end

local attack1_amountOfTimeBeforeAttackFrames = 0.23 -- the animation marker for StartOfAttack was at 0.14 / 0.60 (1 second).
local attack1_amountOfTimeBeforeEndOfAttack = 0.45 -- level 1 attacks end 0.45 seconds after the animation begins.
local attack1_amountOfTimeBeforeEndOFAnimation = 0.75

-- local attack2_amountOfTimeBeforeAttackFrames = 0.52
-- local attack2_amountOfTimeBeforeEndOfAttack = 1.17
-- local attack2_amountOfTimeBeforeEndOFAnimation = 1.18

function Attack_Animation_Management:runOnIsPlaying(trackData) --[[ Manages character data based on when an attack is playing. NOT the animation track itself. That runs on the client. Unless I decided to move it to the server. ]]

    if trackData.IsPlaying then
        print(trackData.Animation:GetAttribute("TimeUntilStartOfAttack"), trackData.Animation:GetAttribute("TimeUntilEndOfAttack"), trackData.Animation:GetAttribute("Length"))

        -- Schedule a simulation of the AttackFrames marker and handle data accordingly:
        task.delay(trackData.Animation:GetAttribute("TimeUntilStartOfAttack"), function() -- These attributes equal the number (in seconds) until the marker would reach for said animation
            if trackData.IsPlaying then
                warn("Attack frames reached")
                runOnAttackFrames(self.characterInstance, trackData)
            end
        end)

        -- Schedule a simulation of the EndOfAttack marker:
        task.delay(trackData.Animation:GetAttribute("TimeUntilEndOfAttack"), function()
            warn("EndOfAttack reached")
            if trackData.IsPlaying then
                runOnEndOfAttack(self.characterInstance, trackData)
            end
        end)

        -- Schedule a simulation of the end of the attacking animation:
        task.delay(trackData.Animation:GetAttribute("Length"), function()
            warn("Animation fully finished.")
            if trackData.IsPlaying then
                trackData.IsPlaying = false
                trackData.Completed = true
                self.characterInstance.attack_animation_manager:runOnIsPlaying(trackData)
            end
        end)

        self.characterInstance.isAttacking = true
        self.characterInstance.SetSpeed(false)

        if trackData.Counter_Attribute == true then 
            -- A level 1 attack played at the time an enemy's attack landed. We transition this into a counter attack.
            self.characterInstance.setupAttackDamage(self.characterInstance)
            self.characterInstance.setPublicPlayerVariable("canCounter", true)
            self.characterInstance.isCountering = true
            self.characterInstance.isAttacking = true
            self.characterInstance.Protocol = "Counter"
            self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, self.characterInstance.Protocol, self.characterInstance.currentAttack)
            self.characterInstance.Protocol = nil
        end
    elseif not trackData.IsPlaying then
        
        if not trackData.Completed then
            self.characterInstance.didFollowUp = false
            self.characterInstance.Protocol = nil

        elseif trackData.Completed  then
            warn("Resetting...")
            self.characterInstance.reset()
        end

        if trackData.Paired_Attribute == true and trackData.Completed then
            task.delay(0.5, function()
                self.characterInstance.hitDebounce = false
            end)
            self.characterInstance.isAttacking = false
        end

        self.characterInstance.attackFrames = false
        self.characterInstance.pairedPlaying = false
        self.characterInstance.SetSpeed(true)
    end
end

return Attack_Animation_Management