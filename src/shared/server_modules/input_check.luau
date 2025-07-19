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
local AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.Touch] = true, [Enum.KeyCode.ButtonB] = true} -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
local BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true}
local GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true}
local LockOnInputs = {[Enum.KeyCode.Q] = true, [Enum.KeyCode.ButtonL2] = true} -- May have LockOnInputs for each system


local input_check_FUNCTION = game.ReplicatedStorage:WaitForChild("input_check_FUNCTION")
input_check_FUNCTION.OnServerInvoke = function(plr, input, active)

    local characterInstance = characters:GetCharacterObjectByPlayer(plr)
    if not characterInstance then return end
    if characterInstance.humanoid.Health <= 0 then return end
    -- if characterInstance.isGrappling and not characterInstance.isInGrappleSuccess and not characterInstance.isInSecureGrapple then return end

    if LockOnInputs[input.UserInputType] or LockOnInputs[input.KeyCode] then

        if not characterInstance.isAttacking.Value
        and not characterInstance.isGettingHit 
        and not characterInstance.pairedPlaying 
        and not characterInstance.isDodging
        and not characterInstance.waitingToAttack
        and not characterInstance.isGrappling
        then -- the player should not be able to lock off when in action, whether thats attacking, blocking, dodging, countering, etc

            characterInstance.lockOnRayParams = utilities.initializeLockOnRayParams(characterInstance)
            
            characterInstance.raycastResult = workspace:Raycast(
                characterInstance.humanoidRootPart.Position,
                characterInstance.humanoidRootPart.CFrame.LookVector * 8,
                characterInstance.lockOnRayParams
            ) -- Raycast in front of player to find an enemy

            
            if not characterInstance.raycastResult then
                characterInstance.lockOnDebounce.Value = false
                return warn("nothing in the raycast result found")
            -- else
            --     warn(
            --         {
            --         not characterInstance.isAttacking.Value,
            --         not characterInstance.isGettingHit,
            --         not characterInstance.pairedPlaying, 
            --         not characterInstance.isDodging,
            --         not characterInstance.isBlocking, 
            --         not characterInstance.waitingToAttack,
            --         not characterInstance.lockOnDebounce.Value
            --     },
            --     characterInstance.raycastResult.Instance, 
            --     characterInstance.raycastResult.Instance.Parent,
            --     characterInstance..Parent.Parent
            -- )
            end

            characterInstance.raycastInstance = characterInstance.raycastResult.Instance
            
            -- if not characterInstance.raycastResult then return warn("No result") end

            -- if characterInstance.raycastResult.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
            --     characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent
            -- elseif characterInstance.raycastResult.Instance.Parent.Parent:FindFirstChildWhichIsA("Humanoid") or characterInstance.raycastResult.Instance:GetAttribute("ReceiveBox") then
            --     characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent.Parent
            -- end
            if characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model"):FindFirstChildWhichIsA("Humanoid") then
                --[[ we may have raycasted their arm that could potentially be 
                sticking through a wall. Dont wanna lock onto an enemy behind a 
                wall, so we will re-raycast, but this time, DIRECTLY to the HRP.
                If there is somehow no raycast, it means they're probably just
                behind a wall and their arm was sticking through it or something.]]

                if characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model").Humanoid.deadState.Value == true then return end
                
                local targetRootPart = characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model").HumanoidRootPart
                if not targetRootPart then return error("Not sure how theres not HRP for the target you selected, even though we already made sure, but here we are I guess we screwed up somehow lol") end

                -- Filter out everything of our target except their HRP:
                local newFilter = characterInstance.lockOnRayParams.FilterDescendantsInstances
                -- table.insert(newFilter, characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model"))

                for _, child in pairs(characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model"):GetChildren()) do
                    if child ~= targetRootPart then
                        table.insert(newFilter, child)
                    end
                end

                characterInstance.lockOnRayParams.FilterDescendantsInstances = newFilter


                -- Then raycast again. Should only get their HRP in the raycast if anything:

                characterInstance.raycastResult = workspace:Raycast(
                    characterInstance.humanoidRootPart.Position,
                    (targetRootPart.Position - characterInstance.humanoidRootPart.Position).Unit * ((targetRootPart.Position - characterInstance.humanoidRootPart.Position).Magnitude + 0.1), -- Adds 0.1 extra length to the end to make sure we have enough length to reach the HRP
                    characterInstance.lockOnRayParams
                )

                if not characterInstance.raycastResult then error("No instance found on this second cast to lock onto the enemy!") end

                characterInstance.raycastInstance = characterInstance.raycastResult.Instance

                local potentialEnemyChar = characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model")

                if potentialEnemyChar:FindFirstChildWhichIsA("Humanoid") then
                    characterInstance.enemyChar = potentialEnemyChar
                else
                    warn("The character is behind a wall or something.. cant lock on.")
                    characterInstance.enemyChar = nil
                end
            end

            local potentialEnemyInstance = characters:GetCharacterObjectByCharacter(characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model"))

            if not characterInstance.lockOnDebounce.Value -- can't be locked on already
            and characterInstance.enemyChar
            and characterInstance.raycastInstance
            and potentialEnemyInstance and not potentialEnemyInstance.isGrappling
            
            and active
            then -- We found an alive enemy to lock onto (that has a characterInstance, making them a fighter. The tavern keeper, for example, doesn't have a characterInstance.).
                -- characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent
                -- characterInstance.enemyHumanoid = characterInstance.enemyChar:FindFirstChild("Humanoid")
                characterInstance.lockOnDebounce.Value = not characterInstance.lockOnDebounce.Value -- always assures lockOnDebouce is opposite of itself to change. Saves me lines of code
                    
                    
                -- if not game.Players:GetPlayerFromCharacter(characterInstance.enemyChar) then -- then our target isn't a player. We'll send a bindable event to the character
                --     if characterInstance.enemyChar.Name == "TestDummy" then
                --         characterInstance.LocalBindableEvent:Fire(characterInstance.lockOnDebounce)
                --     end
                -- end
                
            elseif (
                characterInstance.lockOnDebounce.Value
            ) or (
                characterInstance.raycastResult == nil
                and characterInstance.lockOnDebounce.Value == true
            ) or (
                not active
            )
            then -- no enemy detected by raycast
                characterInstance.lockOnDebounce.Value = false
            end
        
            -- GameVariables.lockOnDebounce.Value = not GameVariables.lockOnDebounce.Value
            
            -- if characterInstance.lockOnDebounce.Value == true then -- Runs when the player locks onto somebody
            -- -- Passed the lock-on check. Activate the lock-on code:


            -- end

            -- if workspace:Raycast(characterInstance.humanoidRootPart.Position,
            --                     characterInstance.humanoidRootPart.CFrame.LookVector * 7,
            --                     characterInstance.lockOnRayParams) 
            -- then
            --     characterInstance.lockOnDebounce.Value = false
            -- end
        end

    elseif AttackInputs[input.UserInputType] or AttackInputs[input.KeyCode] then
        
        -- if not characterInstance.nextInput then
        --     characterInstance.nextInput = "attack"
        -- end

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
        print(characterInstance.nextInput)
        if not characterInstance.nextInput then
            print("next input is grab")
            characterInstance.nextInput = "grab"
        end

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
            print(characterInstance.character, characterInstance.isGrappling)
            local enemyInstance = characters:GetCharacterObjectByCharacter(characterInstance.enemyChar)
            characterInstance:grab(enemyInstance, nil)
            -- if enemyInstance:receive("grabAttempt", characterInstance) == false then
            --     enemyInstance:receive("receiveGrabSuccess", characterInstance)
            --     characterInstance:grab(enemyInstance, true)
    
            -- end
        end
        
    elseif BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode] then
        
        if active then
            if not characterInstance.nextInput then
                characterInstance.nextInput = "block"
                print("changed nextInput to BLOCK")
            end

            -- if the character isInSecureGrapple, that means THEY'RE the one GETTING grappled, not the one doing it. When doing a secure grapple to an enemy, this variable will be true for the enemy.
            if characterInstance.isGrappling and characterInstance.grappleDelay and not characterInstance.isInSecureGrapple and not characterInstance.isAttacking.Value then
                print("y u do this 2 me")
                characterInstance.isGrappling = false
                return
            end
            -- If the player is holding the block button, we store that as a variable:
            characterInstance.isBlockBeingPressed = true -- bool that lets us know if the block button is being held down. This does NOT mean they are blocking though, as this is used to check if the button itself is being held down.
            if characterInstance.lockOnDebounce.Value 
            and characterInstance.boolCheck({isAttacking = characterInstance.isAttacking.Value, isBlocking = characterInstance.isBlocking, isCountering = characterInstance.isCountering, isGrappling = characterInstance.isGrappling}) 
            and not characterInstance.pairedPlaying
            and characterInstance.stamina and characterInstance.stamina.Value > 0 
            then
                characterInstance:block(true)
            end
        else
            -- If the player is holding the block button, we store that as a variable:
            if BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode] then
                characterInstance.isBlockBeingPressed = false
            end

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