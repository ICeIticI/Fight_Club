local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local Misc_Animation_Management = {}


local function runOnIsBlocking(characterInstance) --[[ Simulates when the isBlocking animation marker gets reached. ]]
    characterInstance.isBlocking = true
end

-- Stamina management:

local drainRate = 1 -- how much stamina gets drained per wait()
local regenRate = 1 -- how much stamina gets regenerated per wait()

local blockCost = 10
local isRegening = false -- Gets set to true when the character's stamina is regenerating, so it doesn't stack

local function regenStamina(characterInstance) --[[ Will regenerate stamina, if not doing so already. ]]
    if not isRegening then
        isRegening = true
        while (not characterInstance.BlockStartAnimPlaying and not characterInstance.holdingBlock) and characterInstance.stamina.Value < 100 do
            characterInstance.stamina.Value += regenRate
            -- staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, self.characterInstance.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            task.wait()
        end
        isRegening = false
    end
end

local function drainStamina(characterInstance, trackData) --[[ Function that will drain stamina, depending on whether or not they're blocking in some way. ]]
    if trackData.AnimationId == AnimationInstances.FC_BlockStart.AnimationId then
        -- On block start, we just take a one-time chunk of stamina
        if characterInstance.stamina.Value - blockCost >= 0 then -- If a block occurs when they have less then 10 stamina, then the size of the green bar will not disappear but keep going
            characterInstance.stamina.Value -= blockCost
        else
            characterInstance.stamina.Value = 0
        end

    elseif trackData.AnimationId == AnimationInstances.FC_Block.AnimationId then
        -- On holding block, we continuously drain their stamina until they stop blocking
        while characterInstance.holdingBlock and characterInstance.stamina.Value > 0 do
            characterInstance.stamina.Value -= drainRate
            task.wait()
        end
        characterInstance:block(false)
    end
end



function Misc_Animation_Management:runOnIsPlaying(trackData)

    if trackData.IsPlaying then

        
        if trackData.Animation:GetAttribute("TimeUntilIsBlocking") then
            task.delay(trackData.Animation:GetAttribute("TimeUntilIsBlocking"), function()
                if trackData.IsPlaying then -- we simulate the track playing, so we need to manually check if the track is even playing
                    runOnIsBlocking(self.characterInstance)
                end
            end)
        end

        if not trackData.Animation:GetAttribute("Looped") then
            task.delay(trackData.Animation:GetAttribute("Length"), function()
                if trackData.IsPlaying then
                    trackData.IsPlaying = false
                    trackData.Completed = true -- Represents whether or not an animation track has completely played through and finished.
                    self.characterInstance.misc_animation_manager:runOnIsPlaying(trackData)
                end
            end)
        end

        
        if trackData.Animation.AnimationId == AnimationInstances.FC_LeftParry.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParry.AnimationId then
            -- Parry animation started playing
            task.spawn(function() -- likely will cause delay if not in place
                self.characterInstance:block(false)
            end)
            self.characterInstance.isGettingHit = false

            self.characterInstance.canFollowUp = true
            print(self.characterInstance.canFollowUp)
            -- self.characterInstance.isAttacking.Value = true
            self.characterInstance.isCountering = true
            self.characterInstance.comboCounter = 3 -- Player can do a haymaker attack following a parry
            self.characterInstance.followUpCount = 1 -- for followup attacks, followUpCount must be > 1, so attacking will increase it (to 2), making it pass the > 1 check.

        elseif trackData.Animation.AnimationId == AnimationInstances.FC_BlockStart.AnimationId then
            drainStamina(self.characterInstance, trackData)

        elseif trackData.Animation.AnimationId == AnimationInstances.FC_Block.AnimationId then
            
            self.characterInstance.holdingBlock = true
            
            drainStamina(self.characterInstance, trackData)
            
            task.wait(0.5) -- only add a wait for sync blocks if they start blocking. If they let go, then no sync block should happen as soon as the guard drops
            if trackData.IsPlaying then
                self.characterInstance.canSyncBlock = true
            end
            -- while trackData.IsPlaying do
            --     self.characterInstance.stamina.Value -= drainRate
            --     -- staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, self.characterInstance.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            --     if self.characterInstance.stamina <= 0 then
            --         self.characterInstance.block(false)
            --     end
            --     task.wait()
            -- end
        end
        
    elseif not trackData.IsPlaying then

        if trackData.Animation.AnimationId == AnimationInstances.FC_BlockStart.AnimationId then

            -- Play the looping version of the blocking animation when block start animation ends
            -- warn("play loop")
            -- AnimationInstances.FC_BlockTRACK:Play()
            self.characterInstance.BlockStartAnimPlaying = false
            if trackData.Completed and self.characterInstance.isBlocking then

                -- block_trackData.IsPlaying = true
                -- self.characterInstance.manageAnimation(block_trackData)

                -- self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockAnimation")
                self.characterInstance:block(true)
            end

            -- What if we want a delay for stam regen after a parry attempt?:
            task.wait(0.2)
            regenStamina(self.characterInstance)
            
        elseif trackData.Animation.AnimationId == AnimationInstances.FC_Block.AnimationId then
            self.characterInstance.holdingBlock = false
            regenStamina(self.characterInstance)
        
            -- self.characterInstance.Protocol = "HoldingBlock"
            -- self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, self.characterInstance.Protocol, nil, nil, self.characterInstance.isBlocking, nil, false)


        elseif trackData.Animation.AnimationId == AnimationInstances.FC_LeftParry.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParry.AnimationId then
            -- Parry animation stopped playing
            -- self.characterInstance.isAttacking.Value = false
            
            self.characterInstance.isCountering = false
            self.characterInstance.isGettingHit = false
            task.delay(0.51, function()
                if not self.characterInstance.isAttacking.Value then -- the character went through the whole parry animation and didnt riposte.
                    self.characterInstance.canFollowUp = false -- if they attacked during the parry anim, it will followup, so
                    self.characterInstance.comboCounter = 0
                    print("Combo counter is now 0")
                end
            end)
        elseif trackData.Animation:GetAttribute("Dodge") then
            
            if trackData.Completed then
                task.wait(0.2) -- give the dodger a bit of time to do an attack before the dodge ends after doing a successful dodge without getting hit when the dodge animation finishes.
            end
            self.characterInstance.isDodging = false

            if not self.characterInstance.isAttacking.Value and not self.characterInstance.waitingToAttack then
                self.characterInstance.SetSpeed(true)
            end

        elseif trackData.Animation.AnimationId == AnimationInstances.FC_LeftParryRECEIVER.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParryRECEIVER.AnimationId then
            -- Parry receiver animation stopped playing
            self.characterInstance.canFollowUp = false
            task.wait(0.4)
            self.characterInstance.comboCounter = 0 -- Reset combo counter to prevent continuing the attack chain
            -- self.characterInstance.isAttacking.Value = false
            -- self.characterInstance.hitDebounce = false
        
        end

        -- runs regardless of the receive type when they stop playing:

        -- This will run for the end for every misc animation thats not a parry:
        if not trackData.Animation.AnimationId == AnimationInstances.FC_LeftParry.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParry.AnimationId then
            
            self.characterInstance.isAttacking.Value = false
            -- self.characterInstance.hitDebounce = false
        end
    end

    -- if trackData.Animation.AnimationId == AnimationInstances.FC_Block.AnimationId then
    --     if trackData.IsPlaying then
    --         task.wait(0.5) -- only add a wait for sync blocks if they start blocking. If they let go, then no sync block should happen as soon as the guard drops
    --     end
        
    --     self.characterInstance.holdingBlock = trackData.IsPlaying -- Either true or false depending on if they're animation is playing or not
        
    --     self.characterInstance.Protocol = "HoldingBlock"
    --     self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, self.characterInstance.Protocol, nil, nil, self.characterInstance.isBlocking, nil, false)
    
    --     regenStamina(self.characterInstance)
    
    -- end
end

return Misc_Animation_Management