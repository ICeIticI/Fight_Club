--[[ 

* Whenever a client produces input, it will be sent to this server module.

* This server script will handle doing the checking on whether or not the client is allowed to do an action.

* If they pass all the checks, then this module will call on another module for doing the desired action.

]]

-- Modules:

local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

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

    if LockOnInputs[input.UserInputType] or LockOnInputs[input.KeyCode] then

        if not characterInstance.isAttacking.Value
        and not characterInstance.isGettingHit 
        and not characterInstance.pairedPlaying 
        and not characterInstance.isDodging
        and not characterInstance.isBlocking 
        and not characterInstance.waitingToAttack
        then -- the player should not be able to lock off when in action, whether thats attacking, blocking, dodging, countering, etc
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = characterInstance.character:GetChildren()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            
            characterInstance.raycastResult = workspace:Raycast(
                characterInstance.humanoidRootPart.Position,
                characterInstance.humanoidRootPart.CFrame.LookVector * 8,
                rayParams
            ) -- Raycast in front of player to find an enemy
            
            print(characterInstance.character.Humanoid.Health)            
            if not characterInstance.raycastResult then
                characterInstance.lockOnDebounce.Value = false
                return warn("nothing in the raycast result found")
            else
                warn(
                    {
                    not characterInstance.isAttacking.Value,
                    not characterInstance.isGettingHit,
                    not characterInstance.pairedPlaying, 
                    not characterInstance.isDodging,
                    not characterInstance.isBlocking, 
                    not characterInstance.waitingToAttack,
                    not characterInstance.lockOnDebounce.Value
                },
                characterInstance.raycastResult.Instance, 
                characterInstance.raycastResult.Instance.Parent,
                characterInstance.raycastResult.Instance.Parent.Parent
            )
            end
            
            -- if not characterInstance.raycastResult then return warn("No result") end

            if characterInstance.raycastResult.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
                characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent
            elseif characterInstance.raycastResult.Instance.Parent.Parent:FindFirstChildWhichIsA("Humanoid") or characterInstance.raycastResult.Instance:GetAttribute("ReceiveBox") then
                characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent.Parent
            end

            if not characterInstance.lockOnDebounce.Value -- can't be locked on already
            and characterInstance.enemyChar
            and not characterInstance.raycastResult.Instance.Parent:GetAttribute("TavernKeeper")
            and characterInstance.raycastResult.Instance 
            then -- We found an alive enemy to lock onto (thats not the tavern keeper).
                
                -- characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent
                characterInstance.enemyHumanoid = characterInstance.enemyChar:FindFirstChild("Humanoid")
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
            ) 
            then -- no enemy detected by raycast
               
                characterInstance.lockOnDebounce.Value = false
                
            end
        
            -- GameVariables.lockOnDebounce.Value = not GameVariables.lockOnDebounce.Value
            
            if (
                characterInstance.lockOnDebounce.Value == true 
                -- and characterInstance.raycastResult.Instance.Parent:FindFirstChild("Humanoid")
            ) or (
                characterInstance.isGettingHit 
                and not characterInstance.lockOnDebounce.Value
            ) 
            then -- Runs when the player locks onto somebody
                print(characterInstance.lockOnDebounce.Value)
                -- characterInstance.enemyChar = characterInstance.raycastResult.Instance.Parent
                characterInstance.enemyHumanoidRootPart = characterInstance.enemyChar:WaitForChild("HumanoidRootPart")
                characterInstance.SetSpeed(true)
            -- Passed the lock-on check. Activate the lock-on code:

                print({lockOnDebounce = characterInstance.lockOnDebounce, 
                enemyHumanoidRootPart = characterInstance.enemyHumanoidRootPart,
                enemyHumanoid = characterInstance.enemyHumanoid,
                rayParams = rayParams})

                return "LockOnInput", {
                    lockOnDebounce = characterInstance.lockOnDebounce, 
                    enemyHumanoidRootPart = characterInstance.enemyHumanoidRootPart,
                    enemyHumanoid = characterInstance.enemyHumanoid,
                    rayParams = rayParams
                }

            end

            if characterInstance.lockOnDebounce.Value == false 
            or workspace:Raycast(characterInstance.humanoidRootPart.Position,
                                characterInstance.humanoidRootPart.CFrame.LookVector * 7,
                                rayParams) 
            then
                print("this runs.. doesn't it?..")
                characterInstance.lockOnDebounce.Value = false
                characterInstance.SetSpeed(true)
                characterInstance.enemyChar = nil
                return "LockOnInput", {
                    lockOnDebounce = characterInstance.lockOnDebounce
                }
            end
        end

    elseif AttackInputs[input.UserInputType] or AttackInputs[input.KeyCode] then

        if not characterInstance.waitingToAttack 
        and characterInstance.lockOnDebounce.Value 
        and characterInstance.pairedChain <= characterInstance.PairedChainMAX 
        and characterInstance.boolCheck({isBlocking = characterInstance.isBlocking, isCountering = characterInstance.isCountering, isGettingHit = characterInstance.isGettingHit}) 
        and (characterInstance.raycastResult.Instance.Position - characterInstance.humanoidRootPart.Position).Magnitude <= 7
        and characterInstance.isDodging ~= true -- gets the public canAttack of the player and makes sure its true before attacking
        then
            local enemyInstance = characters:GetCharacterObjectByCharacter(characterInstance.enemyChar)
            -- before attacking, check if we're currently dodging so we can do a dodge attack:
            if characterInstance.isDodging == true then
                
                if not characterInstance.waitingToAttack then
                    
                    characterInstance.waitingToAttack = true
                    while characterInstance.dodgeTrack.IsPlaying do -- wait for entire dodge attack to end
                        task.wait()
                        print("waiting for dodge to end..")
                    end

                    -- do the dodge attack (if not already):
                    if not characterInstance.isAttacking.Value then
                        characterInstance:repulseAttack("dodge", enemyInstance)
                        enemyInstance:receive("dodgeAttack", characterInstance)
                    end

                end
            else
                characterInstance.followUpCount += 1
                characterInstance.distanceBetween = (characterInstance.raycastResult.Instance.Position - characterInstance.humanoidRootPart.Position).Magnitude
                
                if characterInstance.isEnemyHoldingBlock and characterInstance.pairedChain <= characterInstance.PairedChainMAX then
                    characterInstance.pairedChain += 1
                end
                if characterInstance.boolCheck({isAttacking = characterInstance.isAttacking.Value, isBlocking = characterInstance.isBlocking, isCountering = characterInstance.isCountering, isGettingHit = characterInstance.isGettingHit}) 
                and not characterInstance.waitingToAttack 
                and not characterInstance.canFollowUp 
                and not characterInstance.pairedPlaying 
                then
                    -- characterInstance.waitingToAttack = true
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
                    characterInstance:basicAttack(enemyInstance)
                elseif characterInstance.canFollowUp then
                    characterInstance.waitingToAttack = true
                    characterInstance.didFollowUp = true -- when true, the character did a followup attack
                    while characterInstance.isAttacking.Value do
                        task.wait()
                    end
                    if characterInstance.followUpCount > 1 then
                        if characterInstance.pairedChain < characterInstance.PairedChainMAX then -- The third paired attack, we wanna have the receiver determine the anim so it will be calculated by them, after this player's characterInstance checks its the max value in character_attack.
                            characterInstance.animPair = {math.random(1, 2), math.random(1, 2)}
                            --[[
                            characterObject.Protocol = "AttackStarted"
                            characterObject.GlobalRemoteEvent:FireServer(characterObject.enemyChar, characterObject.Protocol, nil, characterObject.animPair, characterObject.pairedChain, false)
                            ]]
                        end
                        characterInstance:basicAttack(enemyInstance) -- followup attack
                    end
                    characterInstance.waitingToAttack = false
                end
            end

        end
        
    elseif (BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode]) and active then
        -- print("block input")
        -- If the player is holding the block button, we store that as a variable:
        characterInstance.isBlockBeingPressed = true -- bool that lets us know if the block button is being held down. This does NOT mean they are blocking though, as this is used to check if the button itself is being held down.
        
        if characterInstance.lockOnDebounce.Value 
        and characterInstance.boolCheck({isAttacking = characterInstance.isAttacking.Value, isBlocking = characterInstance.isBlocking, isCountering = characterInstance.isCountering}) 
        and not characterInstance.pairedPlaying
        and characterInstance.stamina and characterInstance.stamina.Value > 0 then
            characterInstance:block(true)
        end

    -- elseif GrappleInputs[input.UserInputType] or GrappleInputs[input.KeyCode] then


    elseif (BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode]) and not active then
        
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

return Input_Check