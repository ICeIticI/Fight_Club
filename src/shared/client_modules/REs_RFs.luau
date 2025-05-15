--[[ 

* This script will handle all the Remote Events and Remote Functions

* If I decide to scale my client-receiving events & functions, then this script will be replaced by multiple.

]]

local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.REs_RFs)
local Animation_Centric = require(game.ReplicatedStorage.Shared.animation_management.Animation_Centric)


ClientVariables.GlobalRemoteEvent.OnClientEvent:Connect(function(protocol)
    if protocol == "createAnimationTracks" then -- initializes animations on character creation
    Animation_Centric.initialize_animations(ClientVariables)
    elseif protocol == "setUpClientAttackAnimation" then -- Will set up the attack animation for the upcoming attack
        ClientVariables.randomAnimationTrack(ClientVariables.attack1Table, "AttackSeries", ClientVariables.randLvl1Type)
	end
end)