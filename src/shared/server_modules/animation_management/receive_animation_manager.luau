local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)
local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Receive_Animation_Management = {}

function Receive_Animation_Management:runOnIsPlaying(trackData)
    
    local attacker_characterInstance = characters:GetCharacterObjectByCharacter(self.characterInstance.attackingChar)
    local enemyAttackSpeed
    if attacker_characterInstance then
        enemyAttackSpeed = attacker_characterInstance.finalStatValues.attackSpeed.Value
    else
        enemyAttackSpeed = 1
    end
    
    if trackData.IsPlaying then

        -- Schedule a simulation of the end of the receiving animation:
        task.delay(trackData.Animation:GetAttribute("Length") * enemyAttackSpeed, function()
            if trackData.IsPlaying then
                trackData.IsPlaying = false
                trackData.Completed = true
                self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
            end
        end)

        self.characterInstance.isGettingHit = true
        self.characterInstance.isAttacking.Value = false
        self.characterInstance.canFollowUp = false
        self.characterInstance.SetSpeed(false) -- Prevent the player from moving while being hit

        if trackData.Counter_Attribute then
            task.wait(0.4 * enemyAttackSpeed)
            self.characterInstance.isGettingHit = false
        end

        if trackData.AnimationId == AnimationInstances.FC_RightHaymakerRECEIVER.AnimationId or trackData.AnimationId == AnimationInstances.FC_LeftHaymakerRECEIVER.AnimationId then
        -- Tween specific animations like the rightHaymaker
            --[[
            local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")
            local Info = TweenInfo.new(v.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
            local tweenGoals = { CFrame = tweenPart.CFrame * CFrame.new(0, 0, 2) }
            local reactTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
            reactTween:Play()
            ]]
            local enemyCFrame = characters:GetCharacterObjectByCharacter(self.characterInstance.attackingChar).humanoidRootPart.CFrame
            local linearForce = self.characterInstance.humanoidRootPart.CFrame:VectorToObjectSpace(enemyCFrame.LookVector.Unit * 3)
            self.characterInstance:setLinearVelocity(linearForce, 0.63)
        end

        if trackData.AnimationId == AnimationInstances.FC_BracingBlockL.AnimationId or trackData.AnimationId == AnimationInstances.FC_BracingBlockR.AnimationId then
            self.characterInstance.isBlocking = true
            self.characterInstance.canSyncBlock = false
        end

        
    elseif not trackData.IsPlaying then
        -- self.characterInstance.hitDebounce = false

        if trackData.Animation:GetAttribute("Grapple") == false then -- a false grapple, which means it ends the grappling session
            self.characterInstance.isGrappling = false
        end
        if trackData.Animation:GetAttribute("AttackLevel") == 3 then -- level 3 grapple attacks are for executions. When the animation ends, kill the character.
            self.characterInstance.isGrappling = false
            self.characterInstance.lockOnDebounce.Value = false
            self.characterInstance.humanoid.Health = 0
        end

        if not self.characterInstance.isGrappling then
            self.characterInstance.reset()
        end
        if not self.characterInstance.isBlockBeingPressed and self.characterInstance.isBlocking then
            self.characterInstance:block(false)
        end

        if trackData.AnimationId == AnimationInstances.FC_BracingBlockL.AnimationId or trackData.AnimationId == AnimationInstances.FC_BracingBlockR.AnimationId then
            -- Wait before allowing sync blocks again
            task.wait(1 * enemyAttackSpeed)
            if not trackData.IsPlaying then
                self.characterInstance.canSyncBlock = true
            end
        end

    end

    -- Changes that happen regardless if the receiving animation plays or stops
    self.characterInstance.comboCounter = 0

    if self.characterInstance.attackTrack and self.characterInstance.attackTrack.IsPlaying then
        self.characterInstance.attackTrack:Stop()
    end

    -- stop linear velocity if its playing thats not in response to a haymaker:
    if not (trackData.AnimationId == AnimationInstances.FC_RightHaymakerRECEIVER.AnimationId or trackData.AnimationId == AnimationInstances.FC_LeftHaymakerRECEIVER.AnimationId) then
        self.characterInstance.humanoidRootPart.FC_LinearVelocity.Enabled = false
    end

    -- if trackData.AnimationId == AnimationInstances.FC_BracingBlockL.AnimationId or trackData.AnimationId == AnimationInstances.FC_BracingBlockR.AnimationId then
    --     -- Handle bracing blocks
    --     if not trackData.IsPlaying then
    --         -- Wait before allowing sync blocks again
    --         task.wait(1)
    --         if not AnimationInstances.FC_BracingBlockL.IsPlaying or not AnimationInstances.FC_BracingBlockR.IsPlaying then
    --             self.characterInstance.canSyncBlock = true
    --         end
    --     elseif trackData.IsPlaying then
    --         self.characterInstance.isBlocking = true
    --         self.characterInstance.canSyncBlock = false
    --     end
    -- end
end

return Receive_Animation_Management