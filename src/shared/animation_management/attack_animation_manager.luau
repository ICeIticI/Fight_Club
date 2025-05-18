local Attack_Animation_Management = {}

-- function Attack_Animation_Management.manage(moduleTbl, track, animation, endOfAttackExists)
--      -- Flag to indicate if the attack has ended
--     local attackEnded = false

--     -- Set animation priority based on attributes
--     if animation:GetAttribute("EventCategory") == "bAttack" then
--         track.Priority = Enum.AnimationPriority.Action
--     elseif animation:GetAttribute("Paired") then
--         track.Priority = Enum.AnimationPriority.Action2
--     end

--     -- Function to handle animation playing state changes
--     local function onAnimationPlaying()
--         if track.IsPlaying then
--             moduleTbl.isAttacking = true
--             moduleTbl.SetSpeed(false)

--             if track.Animation:GetAttribute("Counter") == true then
--                 moduleTbl.setPublicPlayerVariable("canCounter", true)
--                 moduleTbl.isCountering = true
--                 moduleTbl.isAttacking = true
--                 moduleTbl.currentAttack = track.Animation
--                 moduleTbl.Protocol = "Counter"
--                 moduleTbl.GlobalRemoteEvent:FireServer(moduleTbl.enemyChar, moduleTbl.Protocol, moduleTbl.currentAttack)
--                 moduleTbl.Protocol = nil
--             end
--         elseif not track.IsPlaying then
--             if track.TimePosition ~= track.Length then
--                 attackEnded = true
--                 moduleTbl.Protocol = nil
--             elseif track.TimePosition == track.Length and not attackEnded then
--                 moduleTbl.reset()
--             end

--             if track.Animation:GetAttribute("Paired") == true and track.TimePosition == track.Length then
--                 task.delay(0.5, function()
--                     moduleTbl.hitDebounce = false
--                 end)
--                 moduleTbl.isAttacking = false
--             end

--             attackEnded = false
--             moduleTbl.attackFrames = false
--             moduleTbl.pairedPlaying = false
--             moduleTbl.SetSpeed(true)
--         end
--     end

--     -- Function to handle the start of the attack animation
--     local function onStartOfAttack()
--         moduleTbl.attackFrames = true
--         if track.Animation:GetAttribute("Paired") and track.Animation:GetAttribute("Counter") then
--             moduleTbl.setPublicPlayerVariable("canCounter", false)
--             moduleTbl.GlobalRemoteEvent:FireServer(moduleTbl.enemyChar, "CounterAttack", moduleTbl.currentAttack, nil, nil, moduleTbl.isEnemyHoldingBlock, false)
--         else
--             moduleTbl.canFollowUp = true
--             moduleTbl.GlobalRemoteEvent:FireServer(nil, "AttackFrames", nil, nil, nil, nil, false)
--         end
--     end

--     -- Function to handle the anti-followup animation marker
--     local function onAntiFollowup()
--         moduleTbl.canFollowUp = false
--     end

--     -- Function to handle the end of the attack animation
--     local function onEndOfAttack()
--         moduleTbl.isAttacking = false
--         moduleTbl.hitDebounce = false
--         moduleTbl.canFollowUp = false
--         moduleTbl.GlobalRemoteEvent:FireServer(nil, "AttackEnded", nil, nil, nil, nil, false)

--         if not track.Animation:GetAttribute("Paired") then
--             moduleTbl.SetSpeed(true)
--         end

--         endOfAttackExists = true

--         if animation:GetAttribute("AttackLevel") == 2 then
--             moduleTbl.comboCounter = 0
--         end
--     end

--     -- Function to handle the animation stopping
--     local function onAnimationStopped()
--         -- Add any logic to handle animation stopping if needed
--     end

--     -- Connect signals to appropriate functions
--     local A1IsPlayingCONNECT = track:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying) -- Runs as soon as the animation begins
--     local StartOfAttackCONNECT = track:GetMarkerReachedSignal("StartOfAttack"):Connect(onStartOfAttack) -- Runs when the beginning of an attack starts via animation marker
--     local Anti_FollowupCONNECT = track:GetMarkerReachedSignal("Anti_Followup"):Connect(onAntiFollowup) -- A point where you can no longer follow up in an attack
--     local EndOfAttackCONNECT = track:GetMarkerReachedSignal("EndOfAttack"):Connect(onEndOfAttack) -- The end of damaging window
--     local A1StoppedCONNECT = track.Stopped:Connect(onAnimationStopped) -- Runs when attack anims stop for any reason

--     -- Store connections in a table for easy management
--     local A1Connects = {StartOfAttackCONNECT, Anti_FollowupCONNECT, EndOfAttackCONNECT, A1StoppedCONNECT, A1IsPlayingCONNECT}

--     -- Disconnect signals when the humanoid dies
--     moduleTbl.humanoid.Died:Connect(function()
--         for _, connection in pairs(A1Connects) do
--             connection:Disconnect()
--             warn("Connections A1 has been disabled.")
--         end
--     end)
-- end

function Attack_Animation_Management:runOnIsPlaying(trackData) --[[ Manages character data based on when an attack is playing. NOT the animation track itself. That runs on the client. Unless I decided to move it to the server. ]]
    local attackEnded = false
    if trackData.IsPlaying then
        print(self)
        self.characterInstance.isAttacking = true
        self.characterInstance.SetSpeed(false)

        if trackData.Counter_Attribute == true then
            self.characterInstance.setPublicPlayerVariable("canCounter", true)
            self.characterInstance.isCountering = true
            self.characterInstance.isAttacking = true
            self.characterInstance.Protocol = "Counter"
            self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, self.characterInstance.Protocol, self.characterInstance.currentAttack)
            self.characterInstance.Protocol = nil
        end
    elseif not trackData.IsPlaying then
        if self.characterInstance.didFollowUp then
            attackEnded = true
            self.characterInstance.Protocol = nil
        elseif not self.characterInstance.didFollowUp and not attackEnded then
            self.characterInstance.reset()
        end

        if trackData.Paired_Attribute == true and not self.characterInstance.didFollowUp then
            task.delay(0.5, function()
                self.characterInstance.hitDebounce = false
            end)
            self.characterInstance.isAttacking = false
        end

        attackEnded = false
        self.characterInstance.attackFrames = false
        self.characterInstance.pairedPlaying = false
        self.characterInstance.SetSpeed(true)
    end
end

return Attack_Animation_Management