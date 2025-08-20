--[[ 

* Whenever a client produces input, it will be sent to this server module.

* This server script will handle doing the checking on whether or not the client is allowed to do an action.

* If they pass all the checks, then this module will call on another module for doing the desired action.

]]

-- Modules:

local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)
local utilities = require(game.ReplicatedStorage.Shared.utilities)

local Input_Check = {}

-- User Input Types
local AttackInputs = utilities.userInputTypes.AttackInputs -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
local BlockInputs = utilities.userInputTypes.BlockInputs
local GrappleInputs = utilities.userInputTypes.GrappleInputs
local LockOnInputs = utilities.userInputTypes.LockOnInputs -- May have LockOnInputs for each system


local input_check_FUNCTION = game.ReplicatedStorage:WaitForChild("input_check_FUNCTION")
input_check_FUNCTION.OnServerInvoke = function(plr, input, active)

    local characterInstance = characters:GetCharacterObjectByPlayer(plr)
    if not characterInstance then return end
    if characterInstance.humanoid.Health <= 0 then return end
    -- if characterInstance.isGrappling and not characterInstance.isInGrappleSuccess and not characterInstance.isInSecureGrapple then return end

    if LockOnInputs[input.UserInputType] or LockOnInputs[input.KeyCode] then

        utilities.activateLockOn(characterInstance, utilities, characters, active)

    elseif AttackInputs[input.UserInputType] or AttackInputs[input.KeyCode] then
        
        -- if not characterInstance.nextInput then
        --     characterInstance.nextInput = "attack"
        -- end

        if not characterInstance.lockOnDebounce.Value then
            utilities.activateLockOn(characterInstance, utilities, characters, active)
        end

        if characterInstance.isInSecureGrapple then
            characterInstance.escapeGrappleProgress += characterInstance.escapeGrappleProgressPower

            if characterInstance.escapeGrappleProgress >= 100 then -- the character broke free from a secure grapple
                characterInstance.isInSecureGrapple = false
                -- characters:GetCharacterObjectByCharacter(characterInstance.enemyChar):EndGrab(characterInstance)
            end
        end
        
        if not characterInstance.waitingToAttack 
        and characterInstance.lockOnDebounce.Value 
        and characterInstance.pairedChain <= characterInstance.PairedChainMAX 
        and characterInstance.boolCheck({isBlocking = characterInstance.isBlocking}) 
        and (characterInstance.raycastInstance.Position - characterInstance.humanoidRootPart.Position).Magnitude <= 7
        -- and characterInstance.isDodging ~= true -- gets the public canAttack of the player and makes sure its true before attacking
        then
            local enemyInstance = characters:GetCharacterObjectByCharacter(characterInstance.enemyChar)
            -- before attacking, check if we're currently dodging so we can do a dodge attack:
            if characterInstance.isDodging == true then
                
                if not characterInstance.waitingToAttack then
                    
                    characterInstance.waitingToAttack = true
                    while characterInstance.lastReceiveData.IsPlaying do -- wait for entire dodge attack to end
                        task.wait(0.1)
                    end

                    -- do the dodge attack (if not already):
                    if not characterInstance.isAttacking.Value then
                        characterInstance:repulseAttack("dodge", enemyInstance)
                        enemyInstance:receive("dodgeAttack", characterInstance)
                    end

                end

            else
                characterInstance.followUpCount += 1
                characterInstance.distanceBetween = (characterInstance.raycastInstance.Position - characterInstance.humanoidRootPart.Position).Magnitude
                
                -- if characterInstance.isEnemyHoldingBlock and characterInstance.pairedChain <= characterInstance.PairedChainMAX then
                --     characterInstance.pairedChain += 1
                -- end
                
                if characterInstance.boolCheck({isAttacking = characterInstance.isAttacking.Value, isBlocking = characterInstance.isBlocking, isCountering = characterInstance.isCountering, isGettingHit = characterInstance.isGettingHit}) 
                and not characterInstance.waitingToAttack 
                and not characterInstance.canFollowUp
                and not (characterInstance.pairedPlaying and not characterInstance.isGrappling) 
                then
                    -- characterInstance.waitingToAttack = true
                    characterInstance.syncBlockFollowup = false
                    
                    characterInstance:basicAttack(enemyInstance)
                    if characterInstance.pairedChain <= characterInstance.PairedChainMAX then
                        characterInstance.animPair = {math.random(1, 2), math.random(1, 2)}
                        --[[
                        characterObject.Protocol = "AttackStarted"
                        characterObject.GlobalRemoteEvent:FireClient(characterObject.enemyChar, characterObject.Protocol, characterObject.currentAttack, characterObject.animPair, characterObject.pairedChain, nil, false)
                        ]]
                        if enemyInstance.isBlocking and enemyInstance.humanoid.MoveDirection.Magnitude > 0 then
                            -- The player is moving
                            enemyInstance:receive("dodge", characterInstance)

                        elseif enemyInstance.isBlocking and enemyInstance.canSyncBlock and enemyInstance.humanoid.MoveDirection.Magnitude == 0 then
                            -- The player is not moving and will perform a sync block
                            -- enemyInstance.synchedBlock(sentAnimPair, sentValue)
                        end
                    end
                elseif characterInstance.canFollowUp and characterInstance.comboCounter <= 3 then
                    characterInstance.waitingToAttack = true
                    characterInstance.didFollowUp = true -- when true, the character did a followup attack
                    characterInstance.isParrying = false -- var thats only true when a parry anim starts.
                    while characterInstance.isAttacking.Value do
                        task.wait()
                    end
                    if characterInstance.followUpCount > 1 then
                        if characterInstance.pairedChain < characterInstance.PairedChainMAX then -- The third paired attack, we wanna have the receiver determine the anim so it will be calculated by them, after this player's characterInstance checks its the max value in character_attack.
                            -- characterInstance.animPair = {math.random(1, 2), math.random(1, 2)}
                            --[[
                            characterObject.Protocol = "AttackStarted"
                            characterObject.GlobalRemoteEvent:FireServer(characterObject.enemyChar, characterObject.Protocol, nil, characterObject.animPair, characterObject.pairedChain, false)
                            ]]
                            characterInstance.syncBlockFollowup = true
                        end
                        characterInstance:basicAttack(enemyInstance) -- followup attack
                    end
                    characterInstance.waitingToAttack = false
                end
            end

        end

    elseif GrappleInputs[input.UserInputType] or GrappleInputs[input.KeyCode] then
        if not characterInstance.nextInput then
            characterInstance.nextInput = "grab"
        end

        if not characterInstance.lockOnDebounce.Value then
            utilities.activateLockOn(characterInstance, utilities, characters, active)
        end

        -- print(
        --     not characterInstance.isInSecureGrapple,
        --     not characterInstance.isInGrappleSuccess,
        --     characterInstance.lockOnDebounce.Value,
        --     characterInstance.enemyChar.Humanoid.Health > 0,
        --     not characterInstance.grappleDelay
        -- )

        if characterInstance.boolCheck({
            isAttacking = characterInstance.isAttacking.Value, 
            isBlocking = characterInstance.isBlocking,
            isCountering = characterInstance.isCountering,
            isDodging = characterInstance.isDodging,
            isGettingHit = characterInstance.isGettingHit, 
            isGrappling = characterInstance.isGrappling,})
        and characterInstance.lockOnDebounce.Value
        and characterInstance.enemyChar.Humanoid.Health > 0
        and not characterInstance.isInSecureGrapple
        and not characterInstance.isInGrappleSuccess

        and not characterInstance.grappleDelay
        then
            local enemyInstance = characters:GetCharacterObjectByCharacter(characterInstance.enemyChar)
            characterInstance:grab(enemyInstance, nil)
            -- if enemyInstance:receive("grabAttempt", characterInstance) == false then
            --     enemyInstance:receive("receiveGrabSuccess", characterInstance)
            --     characterInstance:grab(enemyInstance, true)
    
            -- end
        end
        
    elseif BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode] then
        
        if active then

            characterInstance.isBlockBeingPressed = true -- bool that lets us know if the block button is being held down. This does NOT mean they are blocking though, as this is used to check if the button itself is being held down.
            
            if not characterInstance.nextInput then
                characterInstance.nextInput = "block"
            end
            
            if not characterInstance.lockOnDebounce.Value then
                utilities.activateLockOn(characterInstance, utilities, characters, active)
            end
            -- if the character isInSecureGrapple, that means THEY'RE the one GETTING grappled, not the one doing it. When doing a secure grapple to an enemy, this variable will be true for the enemy.
            if characterInstance.isGrappling and characterInstance.grappleDelay and not characterInstance.isInSecureGrapple and not characterInstance.isAttacking.Value then
                characterInstance.isGrappling = false
                return
            end

            -- If the player is holding the block button, we store that as a variable:
            if characterInstance.lockOnDebounce.Value 
            and characterInstance.boolCheck({isAttacking = characterInstance.isAttacking.Value, isBlocking = characterInstance.isBlocking, isCountering = characterInstance.isCountering, isGrappling = characterInstance.isGrappling}) 
            and not characterInstance.pairedPlaying
            and characterInstance.stamina and characterInstance.stamina.Value > 0 
            then
                characterInstance:block(true)
            end
        else
            -- If the player is holding the block button, we store that as a variable:
            -- if BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode] then
                characterInstance.isBlockBeingPressed = false
            -- end

            if 
            (characterInstance.BlockStartAnimPlaying 
            or 
            characterInstance.holdingBlock) 
            and not characterInstance.pairedPlaying
            and not characterInstance.waitingToAttack 
            and not characterInstance.isAttacking.Value
            and not characterInstance.isDodging
            then
                characterInstance:block(false)
            end
        end
    end
end

return Input_Check