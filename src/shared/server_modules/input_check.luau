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
input_check_FUNCTION.OnServerInvoke = function(plr, input)

    local characterObject = characters:GetCharacterByPlayer(plr)
    if not characterObject then return end

    if LockOnInputs[input.UserInputType] or LockOnInputs[input.KeyCode] then


        if not characterObject.isAttacking 
        and not characterObject.isGettingHit 
        and not characterObject.pairedPlaying 
        and not characterObject.isDodging
        and not characterObject.isBlocking 
        and not characterObject.waitingToAttack
        then -- the player should not be able to lock off when in action, whether thats attacking, blocking, dodging, countering, etc
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = characterObject.character:GetChildren()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            
            characterObject.raycastResult =
            workspace:Raycast(characterObject.humanoidRootPart.Position,
                                characterObject.humanoidRootPart.CFrame.LookVector * 8,
                                rayParams) -- Raycast in front of player to find an enemy
                                

            if characterObject.raycastResult and not characterObject.raycastResult.Instance.Parent:GetAttribute("TavernKeeper") and characterObject.raycastResult.Instance.Parent:FindFirstChild("Humanoid") then -- We found an alive enemy to lock onto (thats not the tavern keeper).
                
                characterObject.enemyHumanoid = characterObject.raycastResult.Instance.Parent:FindFirstChild("Humanoid")
                characterObject.enemyChar = characterObject.enemyHumanoid.Parent
                characterObject.lockOnDebounce.Value = not characterObject.lockOnDebounce.Value -- always assures lockOnDebouce is opposite of itself to change. Saves me lines of code
                
                
            if not game.Players:GetPlayerFromCharacter(characterObject.enemyChar) then -- then our target isn't a player. We'll send a bindable event to the character
                    if characterObject.enemyChar.Name == "TestDummy" then
                        characterObject.LocalBindableEvent:Fire(characterObject.lockOnDebounce)
                    end
                end
                
            elseif characterObject.raycastResult == nil and characterObject.lockOnDebounce.Value == true then -- no enemy detected by raycast
                characterObject.lockOnDebounce.Value = false
                
            end
        
            -- GameVariables.lockOnDebounce.Value = not GameVariables.lockOnDebounce.Value
            
        
            if (characterObject.lockOnDebounce.Value == true and characterObject.raycastResult.Instance.Parent:FindFirstChild("Humanoid")) 
            or (characterObject.isGettingHit and not characterObject.lockOnDebounce.Value) 
            then -- Runs when the player locks onto somebody
                characterObject.enemyHumanoidRootPart = characterObject.raycastResult.Instance.Parent:WaitForChild("HumanoidRootPart")
                characterObject.setSpeed(true)
            -- Passed the lock-on check. Activate the lock-on code:
                return "LockOnInput", {
                    lockOnDebounce = characterObject.lockOnDebounce, 
                    enemyHumanoidRootPart = characterObject.enemyHumanoidRootPart,
                    enemyHumanoid = characterObject.enemyHumanoid,
                    rayParams = rayParams
                }
            end

            if characterObject.lockOnDebounce.Value == false 
            or workspace:Raycast(characterObject.humanoidRootPart.Position,
                                characterObject.humanoidRootPart.CFrame.LookVector * 7,
                                rayParams) 
            then
                characterObject.lockOnDebounce.Value = false
                characterObject.setSpeed(true)
                return "LockOnInput", {
                    lockOnDebounce = characterObject.lockOnDebounce, 
                }
            end
        end

    elseif AttackInputs[input.UserInputType] or AttackInputs[input.KeyCode] then

        if not characterObject.waitingToAttack 
        and characterObject.lockOnDebounce.Value 
        and characterObject.pairedChain <= characterObject.PairedChainMAX 
        and characterObject.boolCheck({nil, characterObject.isBlocking, characterObject.isCountering, characterObject.isGettingHit}) 
        and (characterObject.raycastResult.Instance.Position - characterObject.humanoidRootPart.Position).Magnitude <= 7
        and characterObject.isDodging ~= true -- gets the public canAttack of the player and makes sure its true before attacking
        then
            -- before attacking, check if we're currently dodging so we can do a dodge attack:
            if characterObject.isDodging == true then
                if not characterObject.waitingToAttack then
                    characterObject.waitingToAttack = true
                    while characterObject.dodgeTrack.IsPlaying do -- wait for entire dodge attack to end
                        task.wait()
                        print("waiting for dodge to end..")
                    end
                    -- do the dodge attack (if not already):
                    if not characterObject.isAttacking then
                        characterObject.character_attack:dodgeAttack()
                    end
                end
            else
                characterObject.followUpCount += 1
                characterObject.distanceBetween = (characterObject.raycastResult.Instance.Position - characterObject.humanoidRootPart.Position).Magnitude
                
                if characterObject.isEnemyHoldingBlock and characterObject.pairedChain <= characterObject.PairedChainMAX then
                    characterObject.pairedChain += 1
                end
                
                if characterObject.boolCheck({characterObject.isAttacking, characterObject.isBlocking, characterObject.isCountering, characterObject.isGettingHit}) and not characterObject.waitingToAttack and not characterObject.canFollowUp and not characterObject.pairedPlaying then
                    if characterObject.pairedChain <= characterObject.PairedChainMAX then
                        characterObject.animPair = {math.random(1, 2), math.random(1, 2)}
                        --[[
                        characterObject.Protocol = "AttackStarted"
                        characterObject.GlobalRemoteEvent:FireClient(characterObject.enemyChar, characterObject.Protocol, characterObject.currentAttack, characterObject.animPair, characterObject.pairedChain, nil, false)
                        ]] 
                    end
                    characterObject:basicAttack(characterObject.comboCounter)
                elseif characterObject.canFollowUp then
                    characterObject.waitingToAttack = true
                    while characterObject.isAttacking do
                        task.wait()
                    end
                    if characterObject.followUpCount > 1 then
                        if characterObject.pairedChain <= characterObject.PairedChainMAX then
                            characterObject.animPair = {math.random(1, 2), math.random(1, 2)}
                            --[[
                            characterObject.Protocol = "AttackStarted"
                            characterObject.GlobalRemoteEvent:FireServer(characterObject.enemyChar, characterObject.Protocol, nil, characterObject.animPair, characterObject.pairedChain, false)
                            ]]
                        end
                        warn("we got here with our attack")
                        characterObject.character_attack:basicAttack(characterObject.comboCounter) -- followup attack
                    end
                    characterObject.waitingToAttack = false
                end
            end

        end
        
    elseif BlockInputs[input.UserInputType] or BlockInputs[input.KeyCode] then
        -- print("block input")

    -- elseif GrappleInputs[input.UserInputType] or GrappleInputs[input.KeyCode] then

    end
end

return Input_Check