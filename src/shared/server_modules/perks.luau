local perksFolder = Instance.new("Folder")
perksFolder.Name = "perksFolder"
perksFolder.Parent = game.ReplicatedStorage

local GlobalBindableEvent = game.ReplicatedStorage:WaitForChild("GlobalBindableEvent")

print('h')
local function newPerk(name, description, modifierTable, cost, killsRequired, productId)
    
    local perk = Instance.new("StringValue")
    perk.Name = name
    perk.Value = description
    perk.modifierTable = modifierTable
    perk:SetAttribute("Cost", cost)
    perk:SetAttribute("KillsRequired", killsRequired)
    perk:SetAttribute("ProductId", productId) -- for if they decide to purchase this perk with robux
    perk.Parent = perksFolder
    
    GlobalBindableEvent:Fire("addProductIdToTable", {name = name, productId = productId})
    return perk
end

local Perks = {}

local basePrice = 50 -- alot of perks will start out at 50, but when you buy a perk, the baseprice will increase, so it will be another 10 tokens for each

local activePerks = {
    newPerk("Iron Fists", "Increases attack damage", {Damage = 1.25}, basePrice, 15, 3382902336),
    newPerk("Meat Head", "Increases health", {Health = 1.25}, basePrice, 30, 3382903295),
    newPerk("Unbreakable", "Increases block absorption", {BlockAbsorption = 1.25}, basePrice, 45, 3382904079),
    newPerk("Cardiosaurus Rex", "Decreases stamina degradation", {StaminaDegradation = 0.75}, basePrice, 60, 3382905392),
    newPerk("Full-Auto", "Increases attack speed", {Speed = 1.25}, basePrice, 75, 3382906629),
    newPerk("Retaliation Specialist", "Counters and Dodge Attacks deal more damage", {Damage = 1.35}, basePrice, 50, 3383626413),
    newPerk("Bloodthirsty", "Each Takedown restores health", {Health = 0.2}, basePrice, 80, 3384023927)
}

Perks.MaxActivePerks = 5 -- how many perks a player can equip at once

function Perks.getPerks(tbl, parent)
    if not tbl then tbl = {} end
    
    for ownedPerkName, _ in pairs(tbl) do
        for _, avaliablePerk in pairs(activePerks) do
            if avaliablePerk.Name == ownedPerkName then
                avaliablePerk:Clone().Parent = parent
                break
            end
        end
    end
    
    -- if not next(perks) then warn("Nothing in perks table") end
end


return Perks