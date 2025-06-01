local Receive_Animation_Management = {}


function Receive_Animation_Management:runOnIsPlaying(trackData)
    if trackData.IsPlaying then

        self.characterInstance.isGettingHit = true
        self.characterInstance.canFollowUp = false
        self.characterInstance.SetSpeed(false) -- Prevent the player from moving while being hit
        self.characterInstance.hitDebounce = false

        if trackData.Counter_Attribute then
            task.wait(0.4)
            self.characterInstance.isGettingHit = false
        end

        if trackData.AnimationId == self.characterInstance.FC_RightHaymakerRECEIVER.AnimationId or trackData.AnimationId == self.characterInstance.FC_LeftHaymakerRECEIVER.AnimationId then
        -- Tween specific animations like the rightHaymaker
            --[[
            local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")
            local Info = TweenInfo.new(v.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
            local tweenGoals = { CFrame = tweenPart.CFrame * CFrame.new(0, 0, 2) }
            local reactTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
            reactTween:Play()
            ]]
            local enemyCFrame = self.characterInstance.getPublicPlayerInstance(self.characterInstance.player.Name).enemyCFrame
            local linearForce = self.characterInstance.humanoidRootPart.CFrame:VectorToObjectSpace(enemyCFrame.LookVector.Unit * 3)

            self.characterInstance.setLinearVelocity(linearForce, 0.63)
        end

        if trackData.AnimationId == self.characterInstance.FC_BracingBlockL.AnimationId or trackData.AnimationId == self.characterInstance.FC_BracingBlockR.AnimationId then
            self.characterInstance.isBlocking = true
            self.characterInstance.canSyncBlock = false
        end

        
    elseif not trackData.IsPlaying then
        
        self.characterInstance.reset()
        if not self.characterInstance.isBlockBeingPressed and self.characterInstance.isBlocking then
            self.characterInstance.block(false)
        end

        if trackData.AnimationId == self.characterInstance.FC_BracingBlockL.AnimationId or trackData.AnimationId == self.characterInstance.FC_BracingBlockR.AnimationId then
            -- Wait before allowing sync blocks again
            task.wait(1)
            if not self.characterInstance.FC_BracingBlockLTRACK.IsPlaying or not self.characterInstance.FC_BracingBlockRTRACK.IsPlaying then
                self.characterInstance.canSyncBlock = true
            end
        end

    end

    -- Changes that happen regardless if the receiving animation plays or stops
    self.characterInstance.comboCounter = 0

    if self.characterInstance.attackTrack and self.characterInstance.attackTrack.IsPlaying then
        self.characterInstance.attackTrack:Stop()
    end

    if trackData.AnimationId == self.characterInstance.FC_BracingBlockL.AnimationId or trackData.AnimationId == self.characterInstance.FC_BracingBlockR.AnimationId then
        -- Handle bracing blocks
        if not trackData.IsPlaying then
            -- Wait before allowing sync blocks again
            task.wait(1)
            if not self.characterInstance.FC_BracingBlockLTRACK.IsPlaying or not self.characterInstance.FC_BracingBlockRTRACK.IsPlaying then
                self.characterInstance.canSyncBlock = true
            end
        elseif trackData.IsPlaying then
            self.characterInstance.isBlocking = true
            self.characterInstance.canSyncBlock = false
        end
    end
end

return Receive_Animation_Management