local Misc_Animation_Management = {}

function Misc_Animation_Management.manage(moduleTbl, track)
    -- Function to handle animation playing state changes
    local function onAnimationPlaying()
        if track.IsPlaying then
            if track.Animation.AnimationId == moduleTbl.FC_LeftParry.AnimationId or track.Animation.AnimationId == moduleTbl.FC_RightParry.AnimationId then
                -- Parry animation started playing
                moduleTbl.isCountering = true
                moduleTbl.comboCounter = 3 -- Player can do a haymaker attack following a parry
            end
        elseif not track.IsPlaying then
            if track.Animation.AnimationId == moduleTbl.FC_BlockStart.AnimationId and track.TimePosition == track.Length then
                -- Play the looping version of the blocking animation when block start animation ends
                -- warn("play loop")
				moduleTbl.FC_BlockTRACK:Play()
            elseif track.Animation.AnimationId == moduleTbl.FC_LeftParry.AnimationId or track.Animation.AnimationId == moduleTbl.FC_RightParry.AnimationId then
                -- Parry animation stopped playing
                moduleTbl.isCountering = false
                task.delay(0.51, function()
                    moduleTbl.comboCounter = 0
                    print("Combo counter is now 0")
                end)
            elseif track.Animation.AnimationId == moduleTbl.FC_LeftParryRECEIVER.AnimationId or track.Animation.AnimationId == moduleTbl.FC_RightParryRECEIVER.AnimationId then
                -- Parry receiver animation stopped playing
                moduleTbl.canFollowUp = false
                task.wait(0.4)
                moduleTbl.comboCounter = 0 -- Reset combo counter to prevent continuing the attack chain
                moduleTbl.isAttacking = false
                moduleTbl.hitDebounce = false
            end

            moduleTbl.isAttacking = false
            moduleTbl.hitDebounce = false
        end

        if track.Animation.AnimationId == moduleTbl.FC_Block.AnimationId then
            if track.IsPlaying then
                task.wait(0.5) -- only add a wait for sync blocks if they start blocking. If they let go, then no sync block should happen as soon as the guard drops
            end

            moduleTbl.Protocol = "HoldingBlock"
            moduleTbl.GlobalRemoteEvent:FireServer(moduleTbl.enemyChar, moduleTbl.Protocol, nil, nil, moduleTbl.isBlocking, nil, false)
        end
    end

    -- Function to handle blocking animation marker
    local function onIsBlocking()
        moduleTbl.isBlocking = true
    end

    -- Connect signals to appropriate functions
    local MiscIsPlayingCONNECT = track:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying)
    local MiscIsBlockingConnect = track:GetMarkerReachedSignal("isBlocking"):Connect(onIsBlocking)

    -- Store connections in a table for easy management
    local MiscConnects = {MiscIsPlayingCONNECT, MiscIsBlockingConnect}

    -- Disconnect signals when the humanoid dies
    moduleTbl.humanoid.Died:Connect(function()
        for _, connection in pairs(MiscConnects) do
            connection:Disconnect()
        end
    end)
end

return Misc_Animation_Management