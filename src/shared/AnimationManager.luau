-- local Players = game:GetService("Players")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local AnimationManager = {}

-- Function to manage attack animations
local function AttackAnimManager(v, currentAnim, EndOfAttackExists)
    -- Flag to indicate if the attack has ended
    local attackEnded = false

    -- Set animation priority based on attributes
    if currentAnim:GetAttribute("EventCategory") == "bAttack" then
        v.Priority = Enum.AnimationPriority.Action
    elseif currentAnim:GetAttribute("Paired") then
        v.Priority = Enum.AnimationPriority.Action2
    end

    -- Function to handle animation playing state changes
    local function onAnimationPlaying()
        if v.IsPlaying then
            GameVariables.isAttacking = true
            GameVariables.SetSpeed(false)
            warn("taking away speed")

            if v.Animation:GetAttribute("Counter") == true then
                GameVariables.setPublicPlayerVariable("canCounter", true)
                GameVariables.isCountering = true
                GameVariables.isAttacking = true
                GameVariables.currentAttack = v.Animation
                GameVariables.Protocol = "Counter"
                GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, GameVariables.currentAttack)
                GameVariables.Protocol = nil
            end
        elseif not v.IsPlaying then
            if v.TimePosition ~= v.Length then
                attackEnded = true
                GameVariables.Protocol = nil
            elseif v.TimePosition == v.Length and not attackEnded then
                GameVariables.reset()
            end

            if v.Animation:GetAttribute("Paired") == true and v.TimePosition == v.Length then
                task.delay(0.5, function()
                    GameVariables.hitDebounce = false
                end)
                GameVariables.isAttacking = false
            end

            attackEnded = false
            GameVariables.attackFrames = false
            GameVariables.pairedPlaying = false
            GameVariables.SetSpeed(true)
        end
    end

    -- Function to handle the start of the attack animation
    local function onStartOfAttack()
        GameVariables.attackFrames = true
        if v.Animation:GetAttribute("Paired") and v.Animation:GetAttribute("Counter") then
            GameVariables.setPublicPlayerVariable("canCounter", false)
            GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, "CounterAttack", GameVariables.currentAttack, nil, nil, GameVariables.isEnemyHoldingBlock, false)
        else
            GameVariables.canFollowUp = true
            GameVariables.GlobalRemoteEvent:FireServer(nil, "AttackFrames", nil, nil, nil, nil, false)
        end
    end

    -- Function to handle the anti-followup animation marker
    local function onAntiFollowup()
        GameVariables.canFollowUp = false
    end

    -- Function to handle the end of the attack animation
    local function onEndOfAttack()
        GameVariables.isAttacking = false
        GameVariables.hitDebounce = false
        GameVariables.canFollowUp = false
        GameVariables.GlobalRemoteEvent:FireServer(nil, "AttackEnded", nil, nil, nil, nil, false)

        if not v.Animation:GetAttribute("Paired") then
            GameVariables.SetSpeed(true)
        end

        EndOfAttackExists = true

        if currentAnim:GetAttribute("AttackLevel") == 2 then
            GameVariables.comboCounter = 0
        end
    end

    -- Function to handle the animation stopping
    local function onAnimationStopped()
        -- Add any logic to handle animation stopping if needed
    end

    -- Connect signals to appropriate functions
    local A1IsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying) -- Runs as soon as the animation begins
    local StartOfAttackCONNECT = v:GetMarkerReachedSignal("StartOfAttack"):Connect(onStartOfAttack) -- Runs when the beginning of an attack starts via animation marker
    local Anti_FollowupCONNECT = v:GetMarkerReachedSignal("Anti_Followup"):Connect(onAntiFollowup) -- A point where you can no longer follow up in an attack
    local EndOfAttackCONNECT = v:GetMarkerReachedSignal("EndOfAttack"):Connect(onEndOfAttack) -- The end of damaging window
    local A1StoppedCONNECT = v.Stopped:Connect(onAnimationStopped) -- Runs when attack anims stop for any reason

    -- Store connections in a table for easy management
    local A1Connects = {StartOfAttackCONNECT, Anti_FollowupCONNECT, EndOfAttackCONNECT, A1StoppedCONNECT, A1IsPlayingCONNECT}

    -- Disconnect signals when the humanoid dies
    GameVariables.humanoid.Died:Connect(function()
        for _, connection in pairs(A1Connects) do
            connection:Disconnect()
            warn("Connections A1 has been disabled.")
        end
    end)
end


-- Function to manage receive animations
local function ReceiveAnimManager(v, currentAnim)
    -- Function to handle animation playing state changes
    local function onAnimationPlaying()
        if not v.IsPlaying and v.Animation:GetAttribute("Counter") then
            -- Delay the receiver after getting countered to ensure a punish
            task.wait(0.4)
            print("can now do stuff")
            GameVariables.isGettingHit = false
        end
        
        if v.IsPlaying then
            GameVariables.isGettingHit = true
            GameVariables.canFollowUp = false
            GameVariables.SetSpeed(false) -- Prevent the player from moving while being hit
            GameVariables.hitDebounce = false
        elseif not v.IsPlaying then
            GameVariables.reset()
            if not GameVariables.isBlockBeingPressed and GameVariables.isBlocking then
                GameVariables.block(false)
            end
        end

        -- Changes that happen regardless if the receiving animation plays or stops
        GameVariables.comboCounter = 0

        if GameVariables.randAttack and GameVariables.randAttack.IsPlaying then
            GameVariables.randAttack:Stop()
        end

        if currentAnim.AnimationId == GameVariables.FC_RightHaymakerRECEIVER.AnimationId or currentAnim.AnimationId == GameVariables.FC_LeftHaymakerRECEIVER.AnimationId then
            -- Tween specific animations like the rightHaymaker
            if v.IsPlaying then
                --[[
                local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")
                local Info = TweenInfo.new(v.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
                local tweenGoals = { CFrame = tweenPart.CFrame * CFrame.new(0, 0, 2) }
                local reactTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
                reactTween:Play()
                ]]
                local enemyCFrame = GameVariables.getPublicPlayerInstance(GameVariables.player.Name).enemyCFrame
                local linearForce = GameVariables.humanoidRootPart.CFrame:VectorToObjectSpace(enemyCFrame.LookVector.Unit * 3)

                GameVariables.setLinearVelocity(linearForce, 0.63)

            end
        elseif currentAnim.AnimationId == GameVariables.FC_BracingBlockL.AnimationId or currentAnim.AnimationId == GameVariables.FC_BracingBlockR.AnimationId then
            -- Handle bracing blocks
            if not v.IsPlaying then
                -- Wait before allowing sync blocks again
                task.wait(1)
                if not GameVariables.FC_BracingBlockLTRACK.IsPlaying or not GameVariables.FC_BracingBlockRTRACK.IsPlaying then
                    GameVariables.canSyncBlock = true
                end
            elseif v.IsPlaying then
                GameVariables.isBlocking = true
                GameVariables.canSyncBlock = false
            end
        end
    end

    -- Connect signal to appropriate function
    local A2IsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying)

    -- Store connections in a table for easy management
    local A2Connects = {A2IsPlayingCONNECT}

    -- Disconnect signals when the humanoid dies
    GameVariables.humanoid.Died:Connect(function()
        for _, connection in pairs(A2Connects) do
            connection:Disconnect()
        end
    end)
end


-- Function to manage miscellaneous animations
local function MiscAnimManager(v)
    -- Function to handle animation playing state changes
    local function onAnimationPlaying()
        if v.IsPlaying then
            if v.Animation.AnimationId == GameVariables.FC_LeftParry.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParry.AnimationId then
                -- Parry animation started playing
                GameVariables.isCountering = true
                GameVariables.comboCounter = 3 -- Player can do a haymaker attack following a parry
            end
        elseif not v.IsPlaying then
            if v.Animation.AnimationId == GameVariables.FC_BlockStart.AnimationId and v.TimePosition == v.Length then
                -- Play the looping version of the blocking animation when block start animation ends
                -- warn("play loop")
				GameVariables.FC_BlockTRACK:Play()
            elseif v.Animation.AnimationId == GameVariables.FC_LeftParry.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParry.AnimationId then
                -- Parry animation stopped playing
                GameVariables.isCountering = false
                task.delay(0.51, function()
                    GameVariables.comboCounter = 0
                    print("Combo counter is now 0")
                end)
            elseif v.Animation.AnimationId == GameVariables.FC_LeftParryRECEIVER.AnimationId or v.Animation.AnimationId == GameVariables.FC_RightParryRECEIVER.AnimationId then
                -- Parry receiver animation stopped playing
                GameVariables.canFollowUp = false
                task.wait(0.4)
                GameVariables.comboCounter = 0 -- Reset combo counter to prevent continuing the attack chain
                GameVariables.isAttacking = false
                GameVariables.hitDebounce = false
            end

            GameVariables.isAttacking = false
            GameVariables.hitDebounce = false
        end

        if v.Animation.AnimationId == GameVariables.FC_Block.AnimationId then
            if v.IsPlaying then
                task.wait(0.5) -- only add a wait for sync blocks if they start blocking. If they let go, then no sync block should happen as soon as the guard drops
            end

            GameVariables.Protocol = "HoldingBlock"
            GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, nil, nil, GameVariables.isBlocking, nil, false)
        end
    end

    -- Function to handle blocking animation marker
    local function onIsBlocking()
        GameVariables.isBlocking = true
    end

    -- Connect signals to appropriate functions
    local MiscIsPlayingCONNECT = v:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationPlaying)
    local MiscIsBlockingConnect = v:GetMarkerReachedSignal("isBlocking"):Connect(onIsBlocking)

    -- Store connections in a table for easy management
    local MiscConnects = {MiscIsPlayingCONNECT, MiscIsBlockingConnect}

    -- Disconnect signals when the humanoid dies
    GameVariables.humanoid.Died:Connect(function()
        for _, connection in pairs(MiscConnects) do
            connection:Disconnect()
        end
    end)
end



function AnimationManager.manageAnimations()
	task.wait()
    warn("Now gonna manage aniamtions:")
   
    while not GameVariables.AllAnimations do task.wait() end
	
    for _, v in pairs(GameVariables.AllAnimations) do -- When the player presses an input and attacks (down below in UserInputService), this body of code will manage the player's current combo and their ability to do a followup attack after their first. It's up here so this isn't re-created

		local currentAnim = v.Animation
		local EndOfAttackExists = false -- for the functions that don't have this event, I want them to run code when the animation has stopped. However, animations that have this marker won't be able to run it.

		if currentAnim:GetAttribute("AnimType") == 1 then -- anim type 1 is attacks
			AttackAnimManager(v, currentAnim, EndOfAttackExists)
			
		elseif currentAnim:GetAttribute("AnimType") == 2 then -- anim type 2 is receive
			ReceiveAnimManager(v, currentAnim)

		else -- Misc. Animations such as blocking
			MiscAnimManager(v)
			
		end
	end
end

return AnimationManager