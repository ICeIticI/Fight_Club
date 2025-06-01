local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local Misc_Animation_Management = {}

-- function Misc_Animation_Management.manage(moduleTbl, track)
--     -- Function to handle animation playing state changes
--     local function onAnimationPlaying()
--         if track.IsPlaying then
--             if track.Animation.AnimationId == moduleTbl.FC_LeftParry.AnimationId or track.Animation.AnimationId == moduleTbl.FC_RightParry.AnimationId then
--                 -- Parry animation started playing
--                 moduleTbl.isCountering = true
--                 moduleTbl.comboCounter = 3 -- Player can do a haymaker attack following a parry
--             end
--         elseif not track.IsPlaying then
--             if track.Animation.AnimationId == moduleTbl.FC_BlockStart.AnimationId and track.TimePosition == track.Length then
--                 -- Play the looping version of the blocking animation when block start animation ends
--                 -- warn("play loop")
-- 				moduleTbl.FC_BlockTRACK:Play()
--             elseif track.Animation.AnimationId == moduleTbl.FC_LeftParry.AnimationId or track.Animation.AnimationId == moduleTbl.FC_RightParry.AnimationId then
--                 -- Parry animation stopped playing
--                 moduleTbl.isCountering = false
--                 task.delay(0.51, function()
--                     moduleTbl.comboCounter = 0
--                     print("Combo counter is now 0")
--                 end)
--             elseif track.Animation.AnimationId == moduleTbl.FC_LeftParryRECEIVER.AnimationId or track.Animation.AnimationId == moduleTbl.FC_RightParryRECEIVER.AnimationId then
--                 -- Parry receiver animation stopped playing
--                 moduleTbl.canFollowUp = false
--                 task.wait(0.4)
--                 moduleTbl.comboCounter = 0 -- Reset combo counter to prevent continuing the attack chain
--                 moduleTbl.isAttacking = false
--                 moduleTbl.hitDebounce = false
--             end

--             moduleTbl.isAttacking = false
--             moduleTbl.hitDebounce = false
--         end

--         if track.Animation.AnimationId == moduleTbl.FC_Block.AnimationId then
--             if track.IsPlaying then
--                 task.wait(0.5) -- only add a wait for sync blocks if they start blocking. If they let go, then no sync block should happen as soon as the guard drops
--             end

--             moduleTbl.Protocol = "HoldingBlock"
--             moduleTbl.GlobalRemoteEvent:FireServer(moduleTbl.enemyChar, moduleTbl.Protocol, nil, nil, moduleTbl.isBlocking, nil, false)
--         end
--     end

--     -- Function to handle blocking animation marker
--     local function onIsBlocking()
--         moduleTbl.isBlocking = true
--     end

--     -- Connect signals to appropriate functions
--     local MiscIsPlayingCONNECT = track:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying)
--     local MiscIsBlockingConnect = track:GetMarkerReachedSignal("isBlocking"):Connect(onIsBlocking)

--     -- Store connections in a table for easy management
--     local MiscConnects = {MiscIsPlayingCONNECT, MiscIsBlockingConnect}

--     -- Disconnect signals when the humanoid dies
--     moduleTbl.humanoid.Died:Connect(function()
--         for _, connection in pairs(MiscConnects) do
--             connection:Disconnect()
--         end
--     end)
-- end

local function runOnIsBlocking(characterInstance) --[[ Simulates when the isBlocking animation marker gets reached. ]]
    characterInstance.isBlocking = true
end

function Misc_Animation_Management:runOnIsPlaying(trackData)

    if trackData.IsPlaying then
        
        if trackData.Animation:GetAttribute("isBlocking") then
            task.delay(trackData.Animation:GetAttribute("TimeUntilIsBlocking"), function()
                if trackData.IsPlaying then -- we simulate the track playing, so we need to manually check if the track is even playing
                    runOnIsBlocking(self.characterInstance)
                end
            end)
        end

        task.delay(trackData:GetAttribute("Length"), function()
            if trackData.IsPlaying then
                trackData.IsPlaying = false
                trackData.Completed = true -- Represents whether or not an animation track has completely played through and finished.
                self.characterInstance.misc_animation_manager:runOnIsPlaying(trackData)
            end
        end)

        
        if trackData.Animation.AnimationId == AnimationInstances.FC_LeftParry.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParry.AnimationId then
            -- Parry animation started playing
            self.characterInstance.isCountering = true
            self.characterInstance.comboCounter = 3 -- Player can do a haymaker attack following a parry
        end
        
    elseif not trackData.IsPlaying then

        if trackData.Animation.AnimationId == AnimationInstances.FC_BlockStart.AnimationId and trackData.Completed then
            -- Play the looping version of the blocking animation when block start animation ends
            -- warn("play loop")
            AnimationInstances.FC_BlockTRACK:Play()
        elseif trackData.Animation.AnimationId == AnimationInstances.FC_LeftParry.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParry.AnimationId then
            -- Parry animation stopped playing
            self.characterInstance.isCountering = false
            task.delay(0.51, function()
                self.characterInstance.comboCounter = 0
                print("Combo counter is now 0")
            end)
        elseif trackData.Animation:GetAttribute("Dodge") then
            
            if trackData.Completed then
                task.wait(0.2) -- give the dodger a bit of time to do an attack before the dodge ends after doing a successful dodge without getting hit when the dodge animation finishes.
            end
            self.characterInstance.isDodging = false

            if not self.characterInstance.isAttacking and not self.characterInstance.waitingToAttack then
                self.characterInstance.setSpeed(true)
            end

        elseif trackData.Animation.AnimationId == AnimationInstances.FC_LeftParryRECEIVER.AnimationId or trackData.Animation.AnimationId == AnimationInstances.FC_RightParryRECEIVER.AnimationId then
            -- Parry receiver animation stopped playing
            self.characterInstance.canFollowUp = false
            task.wait(0.4)
            self.characterInstance.comboCounter = 0 -- Reset combo counter to prevent continuing the attack chain
            self.characterInstance.isAttacking = false
            self.characterInstance.hitDebounce = false
        end

        self.characterInstance.isAttacking = false
        self.characterInstance.hitDebounce = false
    end

    if trackData.Animation.AnimationId == AnimationInstances.FC_Block.AnimationId then
        if trackData.IsPlaying then
            task.wait(0.5) -- only add a wait for sync blocks if they start blocking. If they let go, then no sync block should happen as soon as the guard drops
        end

        self.characterInstance.Protocol = "HoldingBlock"
        self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, self.characterInstance.Protocol, nil, nil, self.characterInstance.isBlocking, nil, false)
    end
end

return Misc_Animation_Management