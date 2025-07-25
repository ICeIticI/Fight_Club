--[[ A module with functions, variables, etc for other
     modules to use that are not tied to any specific 
     module.]]

local Utilities = {}
Utilities.__index = Utilities

Utilities.userInputTypes = {
    -- User Input Types
AttackInputs = {[Enum.UserInputType.MouseButton1] = true, [Enum.KeyCode.ButtonB] = true, ["mobile_attackButton"] = true}, -- This table is used for checking what inputs are allowed in the context of attacking. The permitted inputs are actually the index values so we can use the user's input as an index, and if it matches one of the ones in the table, then they pressed an attacking button.
BlockInputs = {[Enum.UserInputType.MouseButton2] = true, [Enum.KeyCode.ButtonX] = true, ["mobile_blockButton"] = true},
GrappleInputs = {[Enum.KeyCode.R] = true, [Enum.KeyCode.ButtonY] = true, ["mobile_grabButton"] = true},
LockOnInputs = {[Enum.KeyCode.Q] = true, [Enum.KeyCode.ButtonL2] = true} -- May have LockOnInputs for each system

}

function Utilities.activateLockOn(characterInstance, utilities, characters, active) --[[ Runs on input that activates lock on ]]
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
end

function Utilities.sendLockOnSignal(moduleTbl) --[[ Alerts the client to activate/deactivate lock on ]]

    if moduleTbl.player then
        -- is a player. Send to client for lock on:
        moduleTbl.GlobalRemoteFunction:InvokeClient(moduleTbl.player, "lockOn", {
        enemyHumanoid = moduleTbl.enemyHumanoid,
        enemyHumanoidRootPart = moduleTbl.enemyHumanoidRootPart,
        lockOnRayParams = moduleTbl.lockOnRayParams,
        isGrappling = moduleTbl.isGrappling
    })
    else
        --Is an AI. Send to server:

    end

    -- check to make sure they're qualified to lock-off since the duration of their lock-on is client-controlled:
    if (not moduleTbl.isAttacking.Value
    and not moduleTbl.isGettingHit 
    and not moduleTbl.pairedPlaying 
    and not moduleTbl.isDodging
    and not moduleTbl.waitingToAttack
    and not moduleTbl.isGrappling)
    or (not moduleTbl.enemyHumanoid) 
    or (moduleTbl.enemyHumanoid:GetStateEnabled(Enum.HumanoidStateType.Dead) == true)
    then -- the player should not be able to lock off when in action, whether thats attacking, blocking, dodging, countering, etc
        moduleTbl.enemyChar = nil
        moduleTbl.enemyHumanoid = nil
        moduleTbl.enemyHumanoidRootPart = nil
        moduleTbl.lockOnDebounce.Value = false
    end
end

function Utilities.setCharacterNetworkOwnershipTo(character, owner)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            child:SetNetworkOwner(owner)
        end
    end
end

function Utilities.initializeLockOnRayParams(moduleTbl : table) --[[ Setup raycast params for the first time. Contains a generic setup layout that returns the params. ]]
    local lockOnRayParams = RaycastParams.new()
    lockOnRayParams.FilterDescendantsInstances = {moduleTbl.character} -- Instead of doing :GetChildren(), this filters the entire character, so the decendants of the children of the character cant bypass the filter.
    lockOnRayParams.FilterType = Enum.RaycastFilterType.Exclude
    return lockOnRayParams
end

local cameraShakePresets = {
    Level1 = {
        shakeDuration = 0.2,
        shakeOffset = CFrame.new(.4, 0, 0)
    },

    Level2 = {
        shakeDuration = 0.4,
        shakeOffset = CFrame.new(1, .5, 0)
    },

    SyncBlock = {
        shakeDuration = 0.2,
        shakeOffset = CFrame.new(0.2, 0, 0)
    },

    Parry = {
        shakeDuration = 0.2,
        shakeOffset = CFrame.new(0.2, 0, 0)
    },

    BracingBlock = {
        shakeDuration = 0.2,
        shakeOffset = CFrame.new(0.5, 0, 0)
    },

    CounterAttack = {
        shakeDuration = 0.3,
        shakeOffset = CFrame.new(0.8, 0, 0)
    },

    DodgeAttack = {
        shakeDuration = 0.3,
        shakeOffset = CFrame.new(0.8, 0, 0)
    },

    GrabAttack = {
        shakeDuration = 0.4,
        shakeOffset = CFrame.new(2, 1, 0)
    },


    -- Camera shake due to you attacking:

    Strike = {
        shakeDuration = 0.2,
        shakeOffset = CFrame.new(0, 0, -0.4)
    }
}

local cameraShakeMultiplierByDirection = {
    Left = function()
        return -1
    end,
    Right = function()
        return 1
    end,
    None = function() -- random value for attacks that dont have an attack direction
        local randShakeDirectionTbl = {1 , -1}
        return randShakeDirectionTbl[math.random(1, #randShakeDirectionTbl)]
    end
}

function Utilities.shakeCamera(TweenService, camera, data)
    print(data)

    if not data.AnimDirection then
        data.AnimDirection = "None"
    end

    local currentShakeData = cameraShakePresets[data.type]
    local directionMultiply = cameraShakeMultiplierByDirection[data.AnimDirection]()

    local tweenInfo = TweenInfo.new(currentShakeData.shakeDuration, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true)
    local goal = {CFrame = camera.CFrame * (CFrame.new(currentShakeData.shakeOffset.X * directionMultiply,
                                                       currentShakeData.shakeOffset.Y * directionMultiply,
                                                       currentShakeData.shakeOffset.Z * directionMultiply
                                                    ))}
    TweenService:Create(camera, tweenInfo, goal):Play()
end

return Utilities