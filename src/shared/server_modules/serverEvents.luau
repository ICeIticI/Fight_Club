local ServerEvents = {}

local GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

GlobalRemoteFunction.OnServerInvoke = function(player, protocol, data)
    print("Y")
    if protocol == "getPerk" then
        local money = player:WaitForChild("leaderstats"):WaitForChild("Tokens")
        local kills = player.leaderstats:WaitForChild("Takedowns")
        
        local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")
        local desiredPerk = perksFolder:FindFirstChild(data.name):Clone()

        if desiredPerk then

            -- do we own the perk?
            local isUnequipped = player.unequippedPerks:FindFirstChild(data.name)
            local isEquipped = player.equippedPerks:FindFirstChild(data.name)

            if isUnequipped then
                isUnequipped.Parent = player.equippedPerks
            elseif isEquipped then
                isEquipped.Parent = player.unequippedPerks
            else
                -- make sure they have enough moneys and enough kills:
                if money.Value >= desiredPerk:GetAttribute("Cost") 
                and kills.Value >= desiredPerk:GetAttribute("KillsRequired") 
                then
                    -- charge and apply perk:
                    money.Value -= desiredPerk:GetAttribute("Cost")
                    desiredPerk.Parent = player.unequippedPerks
                else
                    return false
                end
            end
            return true
        end
        return false
    end
end

return ServerEvents