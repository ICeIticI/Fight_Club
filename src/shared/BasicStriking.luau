local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
wait()

local BasicStriking = {}

local function setAttackType(followupCombo) --[[ Will set the attack type when a new combo starts ]]
    local randNumber
    GameVariables.randAttack = nil
    if followupCombo then
        randNumber = math.random(2, 3)
    else
        randNumber = math.random(1, 2)
    end

    if randNumber == 1 then
        GameVariables.randLvl1Type = "Jabs"
    elseif randNumber == 2 then
        GameVariables.randLvl1Type = "Hooks"
    elseif randNumber == 3 then
        GameVariables.randLvl1Type = "Uppercuts"
    end
end

local function playAttackAnimation() --[[ Responsible for handling the logic of when an attack ANIMATION starts ]]
    if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
        GameVariables.lastAttack:Stop()
    end
    GameVariables.currentAttack = GameVariables.randAttack.Animation
    GameVariables.randAttack:Play()
    GameVariables.lastAttack = GameVariables.randAttack
end

local function handleLevel1Attack() --[[ Will initiate a lvl 1 attack AND handle other logic like setting variables ]]
    if not GameVariables.randAttack then
        GameVariables.randAttack = GameVariables.randomAnimationTrack(GameVariables.attack1Table, "AttackSeries", GameVariables.randLvl1Type)
    else
        local sameAttackChance = math.random(1, 100)
        if sameAttackChance > 10 or GameVariables.lastAttack.Animation:GetAttribute("AttackSeries") == "Uppercuts" then
            for _, v in pairs(GameVariables.attack1Table) do
                if v ~= GameVariables.randAttack and v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
                    GameVariables.randAttack = v
                    break
                end
            end
            -- GameVariables.randAttack = GameVariables.randomAnimationTrack(GameVariables.attack1Table, "AttackSeries", GameVariables.randLvl1Type)
        end
    end
    playAttackAnimation()
    GameVariables.comboCounter += 1
end

local function handleHaymakerAttack() --[[ Will initiate a level2 attack as well as it's variables that need to be changed ]]
    GameVariables.randAttack = GameVariables.attack2Table[math.random(1, #GameVariables.attack2Table)]
    playAttackAnimation()
    GameVariables.comboCounter += 1
end

local function attack(followupCombo)
    -- if GameVariables.getPublicPlayerInstance(GameVariables.enemyChar.Name)["isDodging"] == true then
    --     GameVariables.randAttack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "DodgeAttack", true, "AnimDirection", GameVariables.dodgeTrack:GetAttribute("AnimDirection"))
    --     GameVariables.randAttack:Play()
    if GameVariables.isEnemyHoldingBlock and not GameVariables.isGettingHit and GameVariables.enemyChar.Humanoid.MoveDirection.Magnitude == 0 then
        GameVariables.synchedBlock(nil, followupCombo)
    elseif GameVariables.isGettingHit then
        return false
    elseif GameVariables.getPublicPlayerInstance(GameVariables.enemyChar.Name)["isDodging"] ~= true then -- gets the public canAttack of the player and makes sure its true before attacking
        if GameVariables.comboCounter == 0 then
            setAttackType(followupCombo)
        end

        if GameVariables.comboCounter <= 2 and GameVariables.enemyHumanoid.Health > 10 then
            handleLevel1Attack()
        elseif GameVariables.comboCounter >= 3 or GameVariables.enemyHumanoid.Health <= 10 then
            handleHaymakerAttack()
        end
    else
        warn("Attack call failed! :(")
    end
end

local function dodgeAttack() --[[ Function that will execute a dodge attack between a character and enemy ]]
    GameVariables.randAttack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "DodgeAttack", true, "AnimDirection", GameVariables.dodgeTrack.Animation:GetAttribute("AnimDirection"))
    GameVariables.repositionInFrontOfEnemy()

    -- GameVariables.dodgeAttackTrack:Play()
    GameVariables.randAttack:Play()
    print(GameVariables.randAttack, GameVariables.dodgeTrack)

    GameVariables.waitingToAttack = false
    local reason = "dodgeAttack"
    GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, reason, GameVariables.FC_LDodgeAttack1TRACK.Animation)
end


function BasicStriking.manageHitboxes()
    task.wait()
    for _, v in pairs(GameVariables.hitboxesFolderATTACK) do
        local touchedConnection = v.Touched:Connect(function(touchedObject)
            if GameVariables.isAttacking and not GameVariables.hitDebounce and touchedObject:GetAttribute("ReceiveBox") and touchedObject.Parent.Parent:FindFirstChild("Humanoid") and GameVariables.currentAttack then
                GameVariables.hitDebounce = true
                local enemyCharacter = touchedObject.Parent.Parent
                local enemyPlayer = game.Players:GetPlayerFromCharacter(enemyCharacter)

                if not GameVariables.isCountering then
                    local attackLevel = GameVariables.currentAttack:GetAttribute("AttackLevel")
                    if attackLevel == 1 then
                        GameVariables.Protocol = "Hook"
                    elseif attackLevel == 2 then
                        GameVariables.Protocol = "Haymaker"
                    elseif GameVariables.currentAttack:GetAttribute("Paired") and not (GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.Animation:GetAttribute("Finisher")) and not (GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.Animation:GetAttribute("Counter")) then
                        GameVariables.Protocol = "SyncedBlock"
                    end
                end

                if not GameVariables.attackFrames then -- Will wait for an attack to end before attacking again
                    repeat task.wait()
                    until GameVariables.attackFrames or not GameVariables.isAttacking
                end

                if enemyPlayer and GameVariables.isAttacking and GameVariables.attackFrames then
                    GameVariables.GlobalRemoteEvent:FireServer(enemyCharacter, GameVariables.Protocol, GameVariables.currentAttack, nil, nil, GameVariables.isEnemyHoldingBlock, false)
                -- else
                --     warn({enemyPlayer, GameVariables.isAttacking, GameVariables.attackFrames})
                end
            end
        end)

        GameVariables.humanoid.Died:Connect(function()
            touchedConnection:Disconnect()
            print("disconnecting connection")
        end)
    end
end

local function handleAttackInput(input) --[[ When user presses attack then this will run through the code to make it happen, unless they cant currently do one ]]

    -- before attacking, check if we're currently dodging so we can do a dodge attack:
    if GameVariables.getPublicPlayerInstance(GameVariables.player.Name)["isDodging"] == true then
        if not GameVariables.waitingToAttack then
            GameVariables.waitingToAttack = true
            while GameVariables.dodgeTrack.IsPlaying do -- wait for entire dodge attack to end
                task.wait()
                print("waiting for dodge to end..")
            end
            -- do the dodge attack (if not already):
            if not GameVariables.isAttacking then
                dodgeAttack()
            end
        end
    else
        GameVariables.followUpCount += 1
        GameVariables.distanceBetween = (GameVariables.raycastResult.Instance.Position - GameVariables.humanoidRootPart.Position).Magnitude
        
        if GameVariables.isEnemyHoldingBlock and GameVariables.pairedChain <= GameVariables.PairedChainMAX then
            GameVariables.pairedChain += 1
            print("paired chain added. Num of times: " .. tostring(GameVariables.pairedChain))
        end
        
        if GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) and not GameVariables.waitingToAttack and not GameVariables.canFollowUp and not GameVariables.pairedPlaying then
            if GameVariables.pairedChain <= GameVariables.PairedChainMAX then
                GameVariables.animPair = {math.random(1, 2), math.random(1, 2)}
                GameVariables.Protocol = "AttackStarted"
                GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, GameVariables.currentAttack, GameVariables.animPair, GameVariables.pairedChain, nil, false)
            end
            attack()
            elseif GameVariables.canFollowUp then
                GameVariables.waitingToAttack = true
                while GameVariables.isAttacking do
                    wait()
                end
                if GameVariables.followUpCount > 1 then
                    if GameVariables.pairedChain <= GameVariables.PairedChainMAX then
                        GameVariables.animPair = {math.random(1, 2), math.random(1, 2)}
                        GameVariables.Protocol = "AttackStarted"
                        GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, nil, GameVariables.animPair, GameVariables.pairedChain, false)
                    end
                    attack(GameVariables.pairedChain)
                end
                GameVariables.waitingToAttack = false
            end
        end
    end
    
        
function BasicStriking.Attack(input)
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    and not GameVariables.waitingToAttack 
    and GameVariables.lockOnDebounce.Value 
    and GameVariables.pairedChain <= GameVariables.PairedChainMAX 
    and GameVariables.boolCheck({nil, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) 
    and (GameVariables.raycastResult.Instance.Position - GameVariables.humanoidRootPart.Position).Magnitude <= 4.25 
    and GameVariables.getPublicPlayerInstance(GameVariables.enemyChar.Name)["isDodging"] ~= true -- gets the public canAttack of the player and makes sure its true before attacking
    then
        handleAttackInput(input)
    end
end

return BasicStriking
