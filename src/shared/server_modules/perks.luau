local utilities = require(game.ReplicatedStorage.Shared.utilities)

local perksFolder = Instance.new("Folder")
perksFolder.Name = "perksFolder"
perksFolder.Parent = game.ReplicatedStorage

local GlobalBindableEvent = game.ReplicatedStorage:WaitForChild("GlobalBindableEvent")

local function newPerk(name, description, modifierTable, cost, killsRequired, productId)

    local perk = Instance.new("StringValue")
    perk.Name = name
    perk.Value = description

    local modFolder = Instance.new("Folder")
    modFolder.Name = "modFolder"
    modFolder.Parent = perk
    for i, v in pairs(modifierTable) do
        local newMod = Instance.new("NumberValue")
        newMod.Name = i
        newMod.Value = v
        newMod.Parent = modFolder
    end

    perk:SetAttribute("Cost", cost)
    perk:SetAttribute("KillsRequired", killsRequired)
    perk:SetAttribute("ProductId", productId) -- for if they decide to purchase this perk with robux
    perk.Parent = perksFolder
    
    GlobalBindableEvent:Fire("addProductIdToTable", {name = name, productId = productId})
    return perk
end

local Perks = {}

local basePrice = 100 -- alot of perks will start out at this number, but when you buy a perk, the baseprice will increase, so it will be another 10 tokens for each
local intermediatePrice = 200

local activePerks = {
    newPerk("Iron Fists", "Increases attack damage", {A1Damage = 1.2, A2Damage = 1.2, syncBlockDamage = 1.2, counterAttackDamage = 1.2}, basePrice, 20, 3382902336),
    newPerk("Meat Head", "Increases health", {MaxHealth = 1.25}, basePrice, 35, 3382903295),
    newPerk("Unbreakable", "Increases block absorption", {BlockAbsorption = 1.35}, basePrice, 45, 3382904079),
    newPerk("Cardiosaurus Rex", "Decreases stamina degradation", {staminaDrainRate = 0.5}, basePrice, 60, 3382905392),
    newPerk("Full-Auto", "Increases attack speed", {attackSpeed = 1.25}, basePrice, 75, 3382906629),
    newPerk("Retaliation Specialist", "Counters and Dodge Attacks deal more damage", {counterAttackDamage = 1.35}, basePrice, 50, 3383626413),
    newPerk("Bloodthirsty", "Each Takedown restores health", {HealthRegen = 0.2}, intermediatePrice, 80, 3384023927)
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

Perks.modifierTable = {}

function Perks.applyStatChange(characterInstance, perk, bool)
    -- Getting the stat changes from the int folder parented by the perk:
    local perkIntStatChanges = perk:WaitForChild("modFolder"):GetChildren()

    -- For each stat change by the perk, we will add it to it's respected perk multiplier in statMultipliers:
    for _, scValue in pairs(perkIntStatChanges) do

        local statChangeValue = scValue.Value -- needed to set statMultuplier values to nil to get rid of them from the table, since I cant set .Value to nil
        if bool == false then
            statChangeValue = nil
        end

        local statMultiplierName = scValue.Name.."_Multiplier"
        local finalStatValueName = string.gsub(scValue.Name, "_Multiplier", "")

        -- add to the specific table of stats to be multiplied:
        characterInstance.statMultipliers:FindFirstChild(statMultiplierName):SetAttribute(perk.Name:gsub(" ", "_"), statChangeValue)

        -- Then after adding the new stat change(s), re-calculate:
        characterInstance.finalStatValues[finalStatValueName].Value = utilities.multiplyTableValuesTogether(characterInstance.statMultipliers[statMultiplierName]:GetAttributes())

        -- Then apply:
        characterInstance.proxyTable_finalStatValues[finalStatValueName] = characterInstance.finalStatValues[finalStatValueName].Value
        print(characterInstance.statMultipliers[statMultiplierName]:GetAttributes())
    end
end

function Perks.updatePrices(additionalCost)
    for _, perk in pairs(perksFolder:GetChildren()) do
        perk:SetAttribute("Cost", perk:GetAttribute("Cost") + additionalCost)
    end
end


return Perks