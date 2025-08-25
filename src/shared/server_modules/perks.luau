local perksFolder = Instance.new("Folder")
perksFolder.Name = "perksFolder"
perksFolder.Parent = game.ReplicatedStorage

local function newPerk(name, description, cost, killsRequired, productId)
    local perk = Instance.new("StringValue")
    perk.Name = name
    perk.Value = description
    perk:SetAttribute("Cost", cost)
    perk:SetAttribute("KillsRequired", killsRequired)
    perk:SetAttribute("ProductId", productId) -- for if they decide to purchase this perk with robux
    perk.Parent = perksFolder

    return perk
end

local Perks = {}

local basePrice = 50 -- alot of perks will start out at 50, but when you buy a perk, the baseprice will increase, so it will be another 10 tokens for each

local activePerks = {
    newPerk("Iron Fists", "Increases attack damage", basePrice, 15, "3382902336"),
    newPerk("Meat Head", "Increases health", basePrice, 30, "3382903295"),
    newPerk("Unbreakable", "Increases block absorption", basePrice, 45, "3382904079"),
    newPerk("Cardiosaurus Rex", "Decreases stamina degradation", basePrice, 60, "3382905392"),
    newPerk("Full-Auto", "Increases attack speed", basePrice, 75, "3382906629"),
}

function Perks.getPerks(tbl, prnt)
    if not tbl then tbl = {} end
    
    for ownedPerkName, _ in pairs(tbl) do
        for _, avaliablePerk in pairs(activePerks) do
            if avaliablePerk.Name == ownedPerkName then
                avaliablePerk:Clone().Parent = prnt
                break
            end
        end
    end
    
    -- if not next(perks) then warn("Nothing in perks table") end
end


return Perks