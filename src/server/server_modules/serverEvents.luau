local ServerEvents = {}

local ModuleLoader

function ServerEvents.init()
    
    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)
    local GlobalRemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("GlobalRemoteFunction")
    
    GlobalRemoteFunction.OnServerInvoke = function(player, protocol, data)
    
        if protocol == "getPerk" then
            if player.Character.Humanoid.Health <= 0 then return "characterDead" end
    
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
                elseif #player.equippedPerks:GetChildren() >= ModuleLoader.perks.MaxActivePerks then
                    return "maxPerksEquipped"
                elseif isUnequipped then
                    isUnequipped.Parent = player.equippedPerks
                else
                    -- make sure they have enough moneys and enough kills:
                    if money.Value >= desiredPerk:GetAttribute("Cost") 
                    and kills.Value >= desiredPerk:GetAttribute("KillsRequired") 
                    then
                        -- charge and apply perk:
                        money.Value -= desiredPerk:GetAttribute("Cost")
                        desiredPerk.Parent = player.unequippedPerks
                        ModuleLoader.perks.updatePrices(10)
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
end

return ServerEvents