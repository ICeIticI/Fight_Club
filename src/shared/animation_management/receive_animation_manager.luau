local Receive_Animation_Management = {}

function Receive_Animation_Management.manage(moduleTbl, track, animation)
    -- Function to handle animation playing state changes
    local function onAnimationPlaying()
        if not track.IsPlaying and track.Animation:GetAttribute("Counter") then
            -- Delay the receiver after getting countered to ensure a punish
            task.wait(0.4)
            print("can now do stuff")
            moduleTbl.isGettingHit = false
        end
        
        if track.IsPlaying then
            moduleTbl.isGettingHit = true
            moduleTbl.canFollowUp = false
            moduleTbl.SetSpeed(false) -- Prevent the player from moving while being hit
            moduleTbl.hitDebounce = false
        elseif not track.IsPlaying then
            moduleTbl.reset()
            if not moduleTbl.isBlockBeingPressed and moduleTbl.isBlocking then
                moduleTbl.block(false)
            end
        end

        -- Changes that happen regardless if the receiving animation plays or stops
        moduleTbl.comboCounter = 0

        if moduleTbl.randAttack and moduleTbl.randAttack.IsPlaying then
            moduleTbl.randAttack:Stop()
        end

        if animation.AnimationId == moduleTbl.FC_RightHaymakerRECEIVER.AnimationId or animation.AnimationId == moduleTbl.FC_LeftHaymakerRECEIVER.AnimationId then
            -- Tween specific animations like the rightHaymaker
            if track.IsPlaying then
                --[[
                local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")
                local Info = TweenInfo.new(v.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
                local tweenGoals = { CFrame = tweenPart.CFrame * CFrame.new(0, 0, 2) }
                local reactTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
                reactTween:Play()
                ]]
                local enemyCFrame = moduleTbl.getPublicPlayerInstance(moduleTbl.player.Name).enemyCFrame
                local linearForce = moduleTbl.humanoidRootPart.CFrame:VectorToObjectSpace(enemyCFrame.LookVector.Unit * 3)

                moduleTbl.setLinearVelocity(linearForce, 0.63)

            end
        elseif animation.AnimationId == moduleTbl.FC_BracingBlockL.AnimationId or animation.AnimationId == moduleTbl.FC_BracingBlockR.AnimationId then
            -- Handle bracing blocks
            if not track.IsPlaying then
                -- Wait before allowing sync blocks again
                task.wait(1)
                if not moduleTbl.FC_BracingBlockLTRACK.IsPlaying or not moduleTbl.FC_BracingBlockRTRACK.IsPlaying then
                    moduleTbl.canSyncBlock = true
                end
            elseif track.IsPlaying then
                moduleTbl.isBlocking = true
                moduleTbl.canSyncBlock = false
            end
        end
    end

    -- Connect signal to appropriate function
    local A2IsPlayingCONNECT = track:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying)

    -- Store connections in a table for easy management
    local A2Connects = {A2IsPlayingCONNECT}

    -- Disconnect signals when the humanoid dies
    moduleTbl.humanoid.Died:Connect(function()
        for _, connection in pairs(A2Connects) do
            connection:Disconnect()
        end
    end)
end

return Receive_Animation_Management