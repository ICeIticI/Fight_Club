local ServerEvents = {}

local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)
local utilities = require(game.ReplicatedStorage.Shared.utilities)
local perks = require(game.ReplicatedStorage.Shared.server_modules.perks)

local GlobalRemoteFunction = game.ReplicatedStorage:WaitForChild("GlobalRemoteFunction")

GlobalRemoteFunction.OnServerInvoke = function(player, protocol, data)

    if protocol == "getPerk" then
        local money = player:WaitForChild("leaderstats"):WaitForChild("Tokens")
        local kills = player.leaderstats:WaitForChild("Takedowns")
        
        local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")
        local desiredPerk = perksFolder:FindFirstChild(data.name):Clone()

        if desiredPerk then

            -- do we own the perk?
            local isUnequipped = player.unequippedPerks:FindFirstChild(data.name)
            local isEquipped = player.equippedPerks:FindFirstChild(data.name)

            
            if isEquipped then
                isEquipped.Parent = player.unequippedPerks
            elseif #player.equippedPerks:GetChildren() >= perks.MaxActivePerks then
                return "maxPerksEquipped"
            elseif isUnequipped then
                isUnequipped.Parent = player.equippedPerks
                perks.applyStatChange(characters:GetCharacterObjectByPlayer(player), isUnequipped)
            else
                -- make sure they have enough moneys and enough kills:
                if money.Value >= desiredPerk:GetAttribute("Cost") 
                and kills.Value >= desiredPerk:GetAttribute("KillsRequired") 
                then
                    -- charge and apply perk:
                    money.Value -= desiredPerk:GetAttribute("Cost")
                    desiredPerk.Parent = player.unequippedPerks
                else
                    if kills.Value < desiredPerk:GetAttribute("KillsRequired") then
                        return "needMoreKills", (desiredPerk:GetAttribute("KillsRequired") - kills.Value)
                    elseif money.Value < desiredPerk:GetAttribute("Cost") then
                        return "needMoreMoney", (desiredPerk:GetAttribute("Cost") - kills.Value)
                    end
                    return false
                end
            end
            return true
        end
        return false
    end
end

return ServerEvents