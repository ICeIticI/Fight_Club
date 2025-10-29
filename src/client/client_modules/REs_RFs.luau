--[[ 

* This script will handle all the Remote Events and Remote Functions

* If I decide to scale my client-receiving events & functions, then this script will be replaced by multiple.

]]

local ModuleLoader

local REs_RFs = {}

function REs_RFs.init()

    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)
    
    ModuleLoader.ClientVariables.GlobalRemoteFunction.OnClientInvoke = function(protocol, data)
        if protocol == "createAnimationTracks" then -- initializes animations on character creation
            ModuleLoader.animation_centric.initialize_animations(ModuleLoader.ClientVariables) 
        elseif protocol == "lockOn" then
            if ModuleLoader.ClientVariables.lockOnDebounce.Value == true then
                ModuleLoader.lockOn.Lock(data)
            else
                ModuleLoader.lockOn.Unlock(data)
            end
        end
    end
    
    ModuleLoader.ClientVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(protocol, data)
        if protocol == "setupClientAttackAnimation" then -- Will set up the attack animation for the upcoming attack
            ModuleLoader.animation_centric.setupAttackAnimation(ModuleLoader.ClientVariables, data)
        elseif protocol == "playAttackAnimation" then
            ModuleLoader.animation_centric.playAttackAnimation(ModuleLoader.ClientVariables)
        elseif protocol == "setupReceiveAnimation" then
            ModuleLoader.animation_centric.setupReceiveAnimation(ModuleLoader.ClientVariables, data)
        elseif protocol == "playReceiveAnimation" then
            ModuleLoader.animation_centric.playReceiveAnimation(ModuleLoader.ClientVariables)
        elseif protocol == "setupGrabAnimation" then
            ModuleLoader.animation_centric.setupGrabAnimation(ModuleLoader.ClientVariables, data)
        elseif protocol == "playGrabAnimation" then
            ModuleLoader.animation_centric.playGrabAnimation(ModuleLoader.ClientVariables, data)
        elseif protocol == "playBlockStartAnimation" then
            ModuleLoader.animation_centric.playBlockStartAnimation(ModuleLoader.ClientVariables)
        elseif protocol == "playBlockAnimation" then
            ModuleLoader.animation_centric.playBlockAnimation(ModuleLoader.ClientVariables)
        elseif protocol == "stopBlockingAnimation" then
            ModuleLoader.animation_centric.stopBlocking(ModuleLoader.ClientVariables)

        elseif protocol == "setupRagdoll" then
            ModuleLoader.ragdollFunction.setupRagdoll(data.character, data.id)
        elseif protocol == "ragdoll" then
            ModuleLoader.ragdollFunction.ragdoll(data.character, data.id, data.ragdollBool)

        elseif protocol == "initialized" then
            ModuleLoader.ClientVariables.initialized = true

        elseif protocol == "updateMyDeadState" then
            data.humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, data.stateEnabled)
        
        elseif protocol == "shakeCamera" then
            ModuleLoader.utilities.shakeCamera(game:GetService("TweenService"), game.Workspace.CurrentCamera, data)
        
        elseif protocol == "perkPurchased" then
           ModuleLoader.ClientVariables.GlobalBindableEvent:Fire(protocol, data)

        elseif protocol == "updateCurrentAttacker" then
            ModuleLoader.ClientVariables.attackingChar = data.attackingChar
        end
    
        --[[ ^ Might put the animation events into the animation_centric script 
                once we start getting non-animation events. Then create a 
                specific remote event for animation_centric to handle them.
            ]]
    end)

end


return REs_RFs