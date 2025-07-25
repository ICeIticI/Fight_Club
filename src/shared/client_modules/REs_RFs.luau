--[[ 

* This script will handle all the Remote Events and Remote Functions

* If I decide to scale my client-receiving events & functions, then this script will be replaced by multiple.

]]

local REs_RFs = {}

local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)
local Animation_Centric = require(game.ReplicatedStorage.Shared.animation_centric)
local ragdollFunction = require(game.ReplicatedStorage.Shared.ragdollFunction)
local lockOn = require(game.ReplicatedStorage.Shared.client_modules.lockOn)
local utilities = require(game.ReplicatedStorage.Shared.utilities)

function REs_RFs.init()
    
    ClientVariables.GlobalRemoteFunction.OnClientInvoke = function(protocol, data)
        if protocol == "createAnimationTracks" then -- initializes animations on character creation
            Animation_Centric.initialize_animations(ClientVariables)
            
        elseif protocol == "lockOn" then
            if ClientVariables.lockOnDebounce.Value == true then
                lockOn.Lock(data)
            else
                lockOn.Unlock(data)
            end
        end
    end
    
    ClientVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(protocol, data)
        if protocol == "setupClientAttackAnimation" then -- Will set up the attack animation for the upcoming attack
            Animation_Centric.setupAttackAnimation(ClientVariables, data)
        elseif protocol == "playAttackAnimation" then
            Animation_Centric.playAttackAnimation(ClientVariables)
        elseif protocol == "setupReceiveAnimation" then
            Animation_Centric.setupReceiveAnimation(ClientVariables, data)
        elseif protocol == "playReceiveAnimation" then
            Animation_Centric.playReceiveAnimation(ClientVariables)
        elseif protocol == "setupGrabAnimation" then
            Animation_Centric.setupGrabAnimation(ClientVariables, data)
        elseif protocol == "playGrabAnimation" then
            Animation_Centric.playGrabAnimation(ClientVariables, data)
        elseif protocol == "playBlockStartAnimation" then
            Animation_Centric.playBlockStartAnimation(ClientVariables)
        elseif protocol == "playBlockAnimation" then
            Animation_Centric.playBlockAnimation(ClientVariables)
        elseif protocol == "stopBlockingAnimation" then
            Animation_Centric.stopBlocking(ClientVariables)

        elseif protocol == "setupRagdoll" then
            ragdollFunction.setupRagdoll(data.character, data.id)
        elseif protocol == "ragdoll" then
            ragdollFunction.ragdoll(data.character, data.id, data.ragdollBool)

        elseif protocol == "initialized" then
            ClientVariables.initialized = true

        elseif protocol == "updateMyDeadState" then
            data.humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, data.stateEnabled)
            print(data.humanoid.Parent.Name .. " dead state enabled: ", data.stateEnabled)
        
        elseif protocol == "shakeCamera" then
            utilities.shakeCamera(game:GetService("TweenService"), game.Workspace.CurrentCamera, data)
        end
    
        --[[ ^ Might put the animation events into the animation_centric script 
                once we start getting non-animation events. Then create a 
                specific remote event for animation_centric to handle them.
            ]]
    end)

end


return REs_RFs