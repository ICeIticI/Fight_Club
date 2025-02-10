local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local ReceivingAndCountering = {}

-- Function to determine which receive animation to play based on the current attack ID
local function getHit(currentAttackID)
    if currentAttackID == GameVariables.FC_LeftHook1.AnimationId or currentAttackID == GameVariables.FC_LeftJab.AnimationId then
        -- Left reaction for level 1 attacks
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHook1RECEIVERTRACK
    elseif currentAttackID == GameVariables.FC_RightHook1.AnimationId or currentAttackID == GameVariables.FC_RightJab.AnimationId then
        -- Right reaction for level 1 attacks
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHook1RECEIVERTRACK
    elseif currentAttackID == GameVariables.FC_LeftUppercut.AnimationId then
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftUppercutRECEIVERTRACK
    elseif currentAttackID == GameVariables.FC_RightUppercut.AnimationId then
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightUppercutRECEIVERTRACK
    elseif currentAttackID == GameVariables.FC_RightHaymaker.AnimationId then
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHaymakerReceiverTRACK
    elseif currentAttackID == GameVariables.FC_LeftHaymaker.AnimationId then
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHaymakerRECEIVERTRACK
    end
end

-- Function to handle blocking and parrying
local function handleBlocking(currentAttack)
    if currentAttack:GetAttribute("AnimDirection") == "Left" then
        -- Perform a left parry
        warn("ParryL")
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightParryTRACK
    elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
        -- Perform a right parry
        warn("ParryR")
        GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftParryTRACK
    end
    local Protocol = "Parry"
    GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, Protocol, currentAttack)
end

-- Function to handle counter attacks
local function handleCounter(currentAttack)
    wait()
    if not (GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying) then
        GameVariables.isCountering = true
        GameVariables.randAttack:Stop()
        if currentAttack:GetAttribute("AnimDirection") == "Left" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Left", "Counter", true)
        elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Right", "Counter", true)
        end
    end
end

local function handleDodges()
	local rightVector = GameVariables.character.HumanoidRootPart.CFrame.RightVector -- the right side of where the character's facing
	local rightDotProduct = GameVariables.humanoid.MoveDirection:Dot(rightVector) -- rightDotProduct, like forwardDotProduct, will return a value it compares from the right side of where the character's facing. > 0 is right, < 0 is left.

    local dodgeTrack -- Will be what animation the player dodges with after some checks

	if rightDotProduct > 0 then -- character is moving right
		print("right dodge")
        dodgeTrack = GameVariables.FC_RightDodgeTRACK
	elseif rightDotProduct < 0 then -- character is moving left
		print("left dodge")
        dodgeTrack = GameVariables.FC_LeftDodgeTRACK
	end

    if dodgeTrack then
        local protocol = "changePlayerVariable"
        GameVariables.GlobalRemoteEvent:FireServer("iFrames", protocol, true)
        dodgeTrack:Play()
        GameVariables.SetSpeed(false)

        task.wait(0.2)
        protocol = "changePlayerVariable"
        GameVariables.GlobalRemoteEvent:FireServer("iFrames", protocol, false)

        dodgeTrack.Stopped:Wait()

        if dodgeTrack.TimePosition == dodgeTrack.Length then -- character did a dodge through the entire animation. Send to server so we can not allow the enemy to attack for a short bit for a dodge attack to play out.
            local Protocol = "dodge"
            GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, Protocol)
        end
        
        GameVariables.SetSpeed(true)
    end

end

-- Function to handle receiving an attack
local function receive(currentAttack)
    local currentAttackID = currentAttack.AnimationId

    if GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying then
        GameVariables.currentReceiveAnimTRACK:Stop()
    end

    if not GameVariables.isBlocking then
        if GameVariables.FC_BlockStartTRACK.IsPlaying then
            -- If the player gets hit while the blockstart track is playing, then they will perform a parry
            handleBlocking(currentAttack)
        elseif GameVariables.Protocol ~= "Counter" and GameVariables.randAttack and GameVariables.randAttack.IsPlaying and not GameVariables.currentAttack:GetAttribute("Counter") and not GameVariables.isCountering and not GameVariables.canFollowUp and not GameVariables.attackFrames and not GameVariables.isGettingHit then
            -- If the player is just starting an attack and gets hit, they will counter
            handleCounter(currentAttack)
        elseif not GameVariables.isCountering then
            getHit(currentAttackID)
        end
    elseif GameVariables.isBlocking then
        GameVariables.canSyncBlock = false
        if currentAttack:GetAttribute("AnimDirection") == "Left" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockRTRACK
        elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockLTRACK
        end
    end

    if GameVariables.currentReceiveAnimTRACK then
        GameVariables.currentReceiveAnimTRACK:Play()
        if GameVariables.currentReceiveAnimTRACK.Animation:GetAttribute("Counter") and not (GameVariables.currentReceiveAnimTRACK == GameVariables.FC_RightParryTRACK or GameVariables.currentReceiveAnimTRACK == GameVariables.FC_LeftParryTRACK) then
            GameVariables.character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(GameVariables.enemyChar:WaitForChild("HumanoidRootPart").Position + GameVariables.enemyChar.HumanoidRootPart.CFrame.LookVector * 3 , GameVariables.enemyChar.HumanoidRootPart.Position)
        end
    end
end

-- Function to handle receiving different types of protocol messages
function ReceivingAndCountering.Receive(currentAttack, Protocol, sentAnimPair, sentValue, isAI)
    if not isAI then
        if Protocol == "Receive" then
            receive(currentAttack)
        elseif Protocol == "AttackStarted" then
            -- If the enemy is starting an attack, and the player is blocking, perform a synched block
            print(sentValue)
            if GameVariables.isBlocking and GameVariables.canSyncBlock and GameVariables.humanoid.MoveDirection.Magnitude > 0 then
                -- The player is moving
                print("can dodge")

				handleDodges()

            elseif GameVariables.isBlocking and GameVariables.canSyncBlock and GameVariables.humanoid.MoveDirection.Magnitude == 0 then
                -- The player is not moving and will perform a sync block
                GameVariables.synchedBlock(sentAnimPair, sentValue)
            end
        elseif Protocol == "HoldingBlock" then
            GameVariables.isEnemyHoldingBlock = sentValue
        elseif Protocol == "Parry" then
            GameVariables.randAttack:Stop()
            if currentAttack:GetAttribute("AnimDirection") == "Left" then
                GameVariables.FC_RightParryRECEIVERTRACK:Play()
            elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
                GameVariables.FC_LeftParryRECEIVERTRACK:Play()
            end
        elseif Protocol == "Counter" and not (GameVariables.FC_LeftCounter1RECEIVERTRACK.IsPlaying or GameVariables.FC_RightCounter1RECEIVERTRACK.IsPlaying) then
            GameVariables.randAttack:Stop()
            if currentAttack:GetAttribute("AnimDirection") == "Left" then
                if currentAttack.AnimationId == GameVariables.FC_LeftCounter1.AnimationId then
                    GameVariables.FC_LeftCounter1RECEIVERTRACK:Play()
                elseif currentAttack.AnimationId == GameVariables.FC_LeftCounter2.AnimationId then
                    GameVariables.FC_LeftCounter2RECEIVERTRACK:Play()
                end
            elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
                if currentAttack.AnimationId == GameVariables.FC_RightCounter1.AnimationId then
                    GameVariables.FC_RightCounter1RECEIVERTRACK:Play()
                elseif currentAttack.AnimationId == GameVariables.FC_RightCounter2.AnimationId then
                    GameVariables.FC_RightCounter2RECEIVERTRACK:Play()
                end
            end
        end
    end
end

-- Function to handle blocking input
function ReceivingAndCountering.Block(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 
    and GameVariables.lockOnDebounce.Value 
    and GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering}) 
    and not GameVariables.pairedPlaying then
        GameVariables.FC_BlockStartTRACK:Play()
        GameVariables.humanoid.WalkSpeed /= 1.5
    end
end

-- Function to handle end of blocking input
function ReceivingAndCountering.EndBlock(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and (GameVariables.FC_BlockStartTRACK.IsPlaying or GameVariables.FC_BlockTRACK.IsPlaying) and not GameVariables.pairedPlaying then
        GameVariables.isBlocking = false
        GameVariables.FC_BlockStartTRACK:Stop()
        GameVariables.FC_BlockTRACK:Stop()
        GameVariables.SetSpeed(true)
    end
end

return ReceivingAndCountering