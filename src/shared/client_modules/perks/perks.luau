local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)
local perkButton = require(game.ReplicatedStorage.Shared.client_modules.perks.perkButton)

local Perks = {}

local gameGUI = ClientVariables.player.PlayerGui.gameGUI
local perks_screen = gameGUI.Frame.perks_screen
local perksSelection = perks_screen.perksSelection
local equippedPerks = perks_screen.equippedPerks
local equipPurchase_screen = gameGUI.Frame.perks_screen.equipPurchase_screen

local function equipPerk(perk)
    perk.isEquipped = true
    perk.instance.Size = perk.equippedSize
    perk.instance.Parent = equippedPerks
end

local function unequipPerk(perk)
    perk.isEquipped = false
    perk.instance.Size = perk.unequippedSize
    perk.instance.Parent = perksSelection.perksFrame
end

local currentlyHighlightedPerk = nil -- when our mouse hovers over a perk
local currentlySelectedPerk = nil -- whenever we select a perk, this will be that perk

-- track each hovered button so we display the description
local instancesMT = { -- stores metamethods like tracking each new item added to the table
    __newindex = function(t, i, v)
        rawset(t, i, v)

        -- make each button track when it gets hovered:
        v.instance.MouseEnter:Connect(function()
            if currentlySelectedPerk then return end
            currentlyHighlightedPerk = v
            perksSelection.explanationOfPerk.TextLabel.Text = v.description
            v.instance.BorderColor3 = Color3.new(1, 1, 1)
        end)

        v.instance.MouseLeave:Connect(function()
            if currentlySelectedPerk then return end
            v.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
            if currentlyHighlightedPerk ~= v then return end
            currentlyHighlightedPerk = nil
            perksSelection.explanationOfPerk.TextLabel.Text = ""
        end)
        
        v.instance.Activated:Connect(function()

            if not currentlySelectedPerk or currentlySelectedPerk ~= v then -- do the select visual on the perk we pressed

                if currentlySelectedPerk then -- set the old perk back to normal
                    currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
                end

                -- current perk we dealing with:

                perksSelection.explanationOfPerk.TextLabel.Text = v.description
                v.instance.BorderColor3 = Color3.new(1, 1, 1)
                currentlySelectedPerk = v

                if currentlySelectedPerk.isEquipped then
                    equipPurchase_screen.TextLabel.Text = "Unequip?"
                else
                    equipPurchase_screen.TextLabel.Text = "Equip?"
                end

                equipPurchase_screen.Visible = true

                return
            end
        end)
    end
}
setmetatable(perkButton.instances, instancesMT)

-- local PerksRemoteFunction = game.ReplicatedStorage:WaitForChild("PerksRemoteFunction")

equipPurchase_screen.Yes.Activated:Connect(function()

    if not ClientVariables.GlobalRemoteFunction:InvokeServer("getPerk", {name = currentlySelectedPerk.name}) then return end

    if currentlySelectedPerk.isEquipped then
        unequipPerk(currentlySelectedPerk)
    else
        equipPerk(currentlySelectedPerk)
    end
    currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
    currentlySelectedPerk = nil

    equipPurchase_screen.Visible = false
end)

equipPurchase_screen.No.Activated:Connect(function()
    currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
    currentlySelectedPerk = nil
    
    equipPurchase_screen.Visible = false
end)

local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")
local equippedPerks = ClientVariables.player:WaitForChild("equippedPerks")
local unequippedPerks = ClientVariables.player:WaitForChild("unequippedPerks")

for _, perk in pairs(perksFolder:GetChildren()) do
    local locked = false

    if not equippedPerks:FindFirstChild(perk.Name) 
    and not unequippedPerks:FindFirstChild(perk.Name) 
    then
        locked = true
    end

    local newPerk = perkButton.new(perk.Name, perk.Value, locked)
    unequipPerk(newPerk)
end

return Perks