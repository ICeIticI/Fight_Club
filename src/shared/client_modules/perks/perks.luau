local MarketplaceService = game:GetService("MarketplaceService")

local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)
local perkButton = require(game.ReplicatedStorage.Shared.client_modules.perks.perkButton)

local Perks = {}

local gameGUI = ClientVariables.player.PlayerGui.gameGUI
local perks_screen = gameGUI.Frame.perks_screen
local perksSelection = perks_screen.perksSelection
local equippedPerks_screen = perks_screen.equippedPerks
local equipPurchase_screen = gameGUI.Frame.perks_screen.equipPurchase_screen

local function equipPerk(perk)
    perk.isEquipped = true
    perk.instance.Size = perk.equippedSize
    perk.instance.Parent = equippedPerks_screen
end

local function unequipPerk(perk)
    perk.isEquipped = false
    perk.instance.Size = perk.unequippedSize
    perk.instance.Parent = perksSelection.perksFrame
end

local function getPriceOfPerkInRobux(perk)
    local success, productInfo = pcall(function()
        return MarketplaceService:GetProductInfo(perk.productId, Enum.InfoType.Product)
    end)

    if success and productInfo then
        return productInfo.PriceInRobux
    else
        return warn("Failed to get price of robux with the given perk: " .. tostring(perk))
    end
end

local currentlyHighlightedPerk = nil -- when our mouse hovers over a perk
local currentlySelectedPerk = nil -- whenever we select a perk, this will be that perk


local function unHighlightPerk()
    currentlyHighlightedPerk = nil
    perksSelection.explanationOfPerk.TextLabel.Text = ""
end


local function deselectPerk()
    currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
    currentlySelectedPerk = nil
    unHighlightPerk()
end


local promptToPurchaseRobux = false

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
            unHighlightPerk()
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

                if currentlySelectedPerk.locked then
                    equipPurchase_screen.purchaseWithRobuxFrame.PurchaseWithRobuxButton:WaitForChild("Amount").Text = getPriceOfPerkInRobux(currentlySelectedPerk)
                    equipPurchase_screen.purchaseWithRobuxFrame.Visible = true
                    equipPurchase_screen.TextLabel.Text = "Would you like to purchase the '" ..tostring(currentlySelectedPerk.name) .. "' perk for " .. tostring(currentlySelectedPerk.cost) .. " Tokens?"
                elseif currentlySelectedPerk.isEquipped then
                    equipPurchase_screen.purchaseWithRobuxFrame.Visible = false
                    equipPurchase_screen.TextLabel.Text = "Unequip?"
                else
                    equipPurchase_screen.purchaseWithRobuxFrame.Visible = false
                    equipPurchase_screen.TextLabel.Text = "Equip?"
                end

                promptToPurchaseRobux = false
                equipPurchase_screen.Visible = true

                return
            end
        end)
    end
}
setmetatable(perkButton.instances, instancesMT)

-- local PerksRemoteFunction = game.ReplicatedStorage:WaitForChild("PerksRemoteFunction")

local equippedPerks_folder = ClientVariables.player.equippedPerks

equipPurchase_screen.Yes.Activated:Connect(function()
    if not ClientVariables.initialized or ClientVariables.humanoid.Health <= 0 then return end

    if not promptToPurchaseRobux then

        local getPerk, amountMissingForPurchase
        local success, result = pcall(function()
            getPerk, amountMissingForPurchase = ClientVariables.GlobalRemoteFunction:InvokeServer("getPerk", {name = currentlySelectedPerk.name})
        end)

        if not success then
            getPerk = false
            warn(result)
            return
        end

        if getPerk ~= true then
            -- they should be prompted to purchase this perk with robux or purchase more tokens
            
            if getPerk == "maxPerksEquipped" then
                -- they cant equip because they have the max amount of perks equipped
                equipPurchase_screen.Yes.Visible = false
                equipPurchase_screen.No.Visible = false

                equipPurchase_screen.Ok.Visible = true
                equipPurchase_screen.TextLabel.Text = "Failed to equip: Max amount of perks equipped. Unequip at least 1 perk before equipping this one."
                return
            elseif getPerk == "needMoreMoney" then
                equipPurchase_screen.TextLabel.Text = "You need " ..tostring(amountMissingForPurchase) .. " more Tokens to purchase the '" ..tostring(currentlySelectedPerk.name) .."' perk. Would you like to purchase more Tokens?"
            elseif getPerk == "needMoreKills" then
                equipPurchase_screen.TextLabel.Text = "You need " ..tostring(amountMissingForPurchase) .. " more Kills to be able to purchase the '" ..tostring(currentlySelectedPerk.name) .."' perk. Would you like to purchase this perk with Robux?"
            elseif getPerk == "characterDead" then
                return
            end

            promptToPurchaseRobux = true
            return 
        end

        print(#equippedPerks_folder:GetChildren(), currentlySelectedPerk.isEquipped)

        if currentlySelectedPerk.locked then
            currentlySelectedPerk:unlock()
            currentlySelectedPerk.locked = false
        else
            if currentlySelectedPerk.isEquipped then
                unequipPerk(currentlySelectedPerk)
            elseif #equippedPerks_folder:GetChildren() <= 5 then
                warn("less than 5")
                equipPerk(currentlySelectedPerk)
            end
        end
    
        deselectPerk()
    
        equipPurchase_screen.Visible = false
    else
        MarketplaceService:PromptProductPurchase(ClientVariables.player, currentlySelectedPerk.productId)
    end
end)

equipPurchase_screen.No.Activated:Connect(function()
    deselectPerk()
    equipPurchase_screen.Visible = false
end)

equipPurchase_screen.Ok.Activated:Connect(function()
    deselectPerk()
    equipPurchase_screen.Visible = false

    equipPurchase_screen.Yes.Visible = true
    equipPurchase_screen.No.Visible = true
    equipPurchase_screen.Ok.Visible = false
end)

equipPurchase_screen.purchaseWithRobuxFrame.PurchaseWithRobuxButton.Activated:Connect(function()
    -- if not ClientVariables.initialized or ClientVariables.humanoid.Health <= 0 then return end
    
    MarketplaceService:PromptProductPurchase(ClientVariables.player, currentlySelectedPerk.productId)
end)

local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")
local equippedPerks = ClientVariables.player:WaitForChild("equippedPerks")
local unequippedPerks = ClientVariables.player:WaitForChild("unequippedPerks")

ClientVariables.GlobalBindableEvent.Event:Connect(function(protocol, data)
    if protocol == "perkPurchased" then
        local purchasedPerk = perkButton.FindPerkByName(data.perkName)
        purchasedPerk:unlock()
        currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
        currentlySelectedPerk = nil
        equipPurchase_screen.Visible = false

        for _, perk in pairs(perkButton.instances) do
            perk.cost = perksFolder:FindFirstChild(perk.name):GetAttribute("Cost")
        end
    end
end)

for _, perk in pairs(perksFolder:GetChildren()) do
    local locked = false
    local equipped

    if equippedPerks:FindFirstChild(perk.Name) then
        equipped = true
    elseif unequippedPerks:FindFirstChild(perk.Name) then
        equipped = false
    else
        locked = true
    end

    local newPerk = perkButton.new(perk.Name, perk.Value, perk:GetAttribute("Cost"), perk:GetAttribute("KillsRequired"), perk:GetAttribute("ProductId"), locked)
    
    if equipped then
        equipPerk(newPerk)
    else
        unequipPerk(newPerk)
    end
end

return Perks