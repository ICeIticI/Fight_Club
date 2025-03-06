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
            GameVariables.currentReceiveAnimTRACK = GameVariables.randomAnimationTrack(GameVariables.counterAttacksTable, "AnimDirection", "Left", "Counter", true)
        elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.randomAnimationTrack(GameVariables.counterAttacksTable, "AnimDirection", "Right", "Counter", true)
        end
    end
end

local function handleDodges()
	local frontVector = GameVariables.character.HumanoidRootPart.CFrame.LookVector
    local frontDotProduct = GameVariables.humanoid.MoveDirection:Dot(frontVector)
    local rightVector = GameVariables.character.HumanoidRootPart.CFrame.RightVector -- the right side of where the character's facing
	local rightDotProduct = GameVariables.humanoid.MoveDirection:Dot(rightVector) -- rightDotProduct, like forwardDotProduct, will return a value it compares from the right side of where the character's facing. > 0 is right, < 0 is left.

    GameVariables.dodgeTrack = nil -- Will be what animation the player dodges with after some checks
    local distanceToTravel = 0 -- The distance the player will travel when dodging. This will be used to calculate vectorVelocity.
    local animTime = 0 -- The time the dodge animation will play for. Used for calculating vectorVelocity.
    local vectorVelocity = Vector3.zero -- When dodging, we obviously want the player to move, so this will be the moving part of the dodge. Depending on the dodge, this will equal a vector3 value.

    if rightDotProduct > 0 and frontDotProduct > -0.5 then -- character is moving right
    print("right dodge")
    distanceToTravel = 2
    animTime = 0.53
    vectorVelocity = Vector3.new(distanceToTravel / animTime, 0, 0)
    GameVariables.dodgeTrack = GameVariables.FC_RightDodgeTRACK

    -- we will also get dodge attack here to perform less calculations so we dont have to do it in BasicStriking
    -- GameVariables.dodgeAttackTrack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Right", "DodgeAttack", true)
    
    elseif rightDotProduct < 0 and frontDotProduct > -0.5 then -- character is moving left
        print("left dodge")
        distanceToTravel = -2
        animTime = 0.53 
        vectorVelocity = Vector3.new(distanceToTravel / animTime, 0, 0)
        GameVariables.dodgeTrack = GameVariables.FC_LeftDodgeTRACK

        -- we will also get dodge attack here to perform less calculations so we dont have to do it in BasicStriking
        -- GameVariables.dodgeAttackTrack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Left", "DodgeAttack", true)
    else
        if frontDotProduct < 0 then -- character is moving backwards
            print("back dodge")
            distanceToTravel = 2
            animTime = 0.23
            vectorVelocity = Vector3.new(0, 0, distanceToTravel / animTime)
            GameVariables.dodgeTrack = GameVariables.FC_BackDodgeTRACK
        end
    end

 
    

    if GameVariables.dodgeTrack then
        GameVariables.setPublicPlayerVariable("iFrames", true)
        GameVariables.block(false) -- stop blocking on dodge
        GameVariables.dodgeTrack:Play()
        GameVariables.setLinearVelocity(vectorVelocity, animTime)
        GameVariables.SetSpeed(false)
        GameVariables.setPublicPlayerVariable("isDodging", true)
        
        task.wait(0.4) -- The amount of time the player has iFrames for dodging
        GameVariables.setPublicPlayerVariable("iFrames", false)
        
        GameVariables.dodgeTrack.Stopped:Wait()

        if GameVariables.dodgeTrack.TimePosition >= GameVariables.dodgeTrack.Length then
            task.wait(0.2) -- give the dodger a bit of time to do an attack before the dodge ends after doing a successful dodge without getting hit when the dodge animation finishes.
        end
        GameVariables.setPublicPlayerVariable("isDodging", false) -- any reaon at all the animation stops, they are no longer dodging.
        if not GameVariables.isAttacking or not GameVariables.waitingToAttack then
            GameVariables.SetSpeed(true)
        end
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
        elseif GameVariables.Protocol ~= "Counter" 
        and GameVariables.randAttack 
        and GameVariables.randAttack.IsPlaying 
        and not GameVariables.currentAttack:GetAttribute("Counter") 
        and not GameVariables.isCountering 
        and not GameVariables.canFollowUp 
        and not GameVariables.attackFrames 
        and not GameVariables.isGettingHit 
        then
            -- If the player is just starting an attack and gets hit, they will counter
            handleCounter(currentAttack)
        elseif not GameVariables.isCountering then
            getHit(currentAttackID)
        end
    elseif GameVariables.isBlocking then
        warn("We is blocking")
        GameVariables.canSyncBlock = false
        if currentAttack:GetAttribute("AnimDirection") == "Left" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockRTRACK
        elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
            GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockLTRACK
        end
    end
    print(GameVariables.isBlocking)

    if GameVariables.currentReceiveAnimTRACK then -- play receive animation
        GameVariables.currentReceiveAnimTRACK:Play()

        -- reposition the player to face the enemy if they counter them (not a parry)
        if GameVariables.currentReceiveAnimTRACK.Animation:GetAttribute("Counter") and not (GameVariables.currentReceiveAnimTRACK == GameVariables.FC_RightParryTRACK or GameVariables.currentReceiveAnimTRACK == GameVariables.FC_LeftParryTRACK) then
            GameVariables.repositionInFrontOfEnemy()
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
            if GameVariables.isBlocking and GameVariables.humanoid.MoveDirection.Magnitude > 0 then
                -- The player is moving

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
            -- GameVariables.repositionInFrontOfEnemy()
            if GameVariables.randAttack and GameVariables.randAttack.IsPlaying then
                GameVariables.randAttack:Stop() -- stop an attack if its playing
            end

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
        elseif Protocol == "dodgeAttack" then -- Will need to change this later as we add more dodge attacks
            
            if GameVariables.randAttack then -- stop any attack that's playing
                GameVariables.randAttack:Stop() 
            end
            
            if currentAttack:GetAttribute("AnimDirection") == "Left" then
                GameVariables.FC_LDodgeAttack1RECEIVERTRACK:Play()
            elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
                GameVariables.FC_RDodgeAttack1RECEIVERTRACK:Play()
            elseif currentAttack:GetAttribute("AnimDirection") == "Back" then
                GameVariables.FC_BDodgeAttack1RECEIVERTRACK:Play()
            end
        end
    end
end

-- Function to handle blocking input
function ReceivingAndCountering.Block(input)

    -- If the player is holding the block button, we store that as a variable:
    if GameVariables.BlockInputs[input.UserInputType] or GameVariables.BlockInputs[input.KeyCode] then
        GameVariables.isBlockBeingPressed = true -- bool that lets us know if the block button is being held down. This does NOT mean they are blocking though, as this is used to check if the button itself is being held down.
    end

    if GameVariables.lockOnDebounce.Value 
    and GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering}) 
    and not GameVariables.pairedPlaying then
        GameVariables.block(true)
    end
end

-- Function to handle end of blocking input
function ReceivingAndCountering.EndBlock(input)
    -- If the player is holding the block button, we store that as a variable:
    if GameVariables.BlockInputs[input.UserInputType] or GameVariables.BlockInputs[input.KeyCode] then
        GameVariables.isBlockBeingPressed = false
    end

    if 
    (GameVariables.FC_BlockStartTRACK.IsPlaying 
    or 
    GameVariables.FC_BlockTRACK.IsPlaying) 
    and not GameVariables.pairedPlaying
    and not GameVariables.waitingToAttack 
	and not GameVariables.isAttacking 
	and not GameVariables.getPublicPlayerInstance(GameVariables.player.Name)["isDodging"]
    then
        GameVariables.block(false)
    end
end

return ReceivingAndCountering