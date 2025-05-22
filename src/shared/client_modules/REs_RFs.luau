--[[ 

* This script will handle all the Remote Events and Remote Functions

* If I decide to scale my client-receiving events & functions, then this script will be replaced by multiple.

]]

local REs_RFs = {}

local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)
local Animation_Centric = require(game.ReplicatedStorage.Shared.animation_management.animation_centric)

function REs_RFs.init()
    
    ClientVariables.GlobalRemoteFunction.OnClientInvoke = function(protocol)
        if protocol == "createAnimationTracks" then -- initializes animations on character creation
            Animation_Centric.initialize_animations(ClientVariables)
        end
    end
    
    ClientVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(protocol, data)
        if protocol == "setUpClientAttackAnimation" then -- Will set up the attack animation for the upcoming attack
            Animation_Centric.setupAttackAnimation(ClientVariables, data)
        elseif protocol == "playAttackAnimation" then
            Animation_Centric.playAttackAnimation(ClientVariables)
        end
    
        --[[ ^ Might put the animation events into the animation_centric script 
                once we start getting non-animation events. Then create a 
                specific remote event for animation_centric to handle them.
            ]]
    end)

end


return REs_RFs