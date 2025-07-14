--[[ A module with functions, variables, etc for other
     modules to use that are not tied to any specific 
     module.]]

local Utilities = {}
Utilities.__index = Utilities

function Utilities.sendLockOnSignal(moduleTbl)

    moduleTbl.GlobalRemoteFunction:InvokeClient(moduleTbl.player, "lockOn", {
        lockOnDebounce = moduleTbl.lockOnDebounce, 
        enemyHumanoid = moduleTbl.enemyHumanoid,
        enemyHumanoidRootPart = moduleTbl.enemyHumanoidRootPart,
        lockOnRayParams = moduleTbl.lockOnRayParams
    })

    -- check to make sure they're qualified to lock-off since the duration of their lock-on is client-controlled:
    if not moduleTbl.isAttacking.Value
    and not moduleTbl.isGettingHit 
    and not moduleTbl.pairedPlaying 
    and not moduleTbl.isDodging
    and not moduleTbl.waitingToAttack
    and not moduleTbl.isGrappling
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

return Utilities