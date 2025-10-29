local MarketplaceService = game:GetService("MarketplaceService")

local ModuleLoader

local Perks = {}


local function equipPerk(perk)
    perk.isEquipped = true
    perk.instance.Size = perk.equippedSize
    perk.instance.Parent = Perks.equippedPerks_screen
end

local function unequipPerk(perk)
    perk.isEquipped = false
    perk.instance.Size = perk.unequippedSize
    perk.instance.Parent = Perks.perksSelection.perksFrame
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

local function unHighlightPerk()
    Perks.currentlyHighlightedPerk = nil
    Perks.perksSelection.explanationOfPerk.TextLabel.Text = ""
end

local function deselectPerk()
    Perks.currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
    Perks.currentlySelectedPerk = nil
    unHighlightPerk()
end

-- track each hovered button so we display the description
local instancesMT = { -- stores metamethods like tracking each new item added to the table
    __newindex = function(t, i, v)
        rawset(t, i, v)

        -- make each button track when it gets hovered:
        v.instance.MouseEnter:Connect(function()
            if Perks.currentlySelectedPerk then return end
            Perks.currentlyHighlightedPerk = v
            Perks.perksSelection.explanationOfPerk.TextLabel.Text = v.description
            v.instance.BorderColor3 = Color3.new(1, 1, 1)
        end)

        v.instance.MouseLeave:Connect(function()
            if Perks.currentlySelectedPerk then return end
            
            v.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
            if Perks.currentlyHighlightedPerk ~= v then return end
            unHighlightPerk()
        end)
        
        v.instance.Activated:Connect(function()

            if not Perks.currentlySelectedPerk or Perks.currentlySelectedPerk ~= v then -- do the select visual on the perk we pressed

                if Perks.currentlySelectedPerk then -- set the old perk back to normal
                    Perks.currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
                end

                -- current perk we dealing with:

                Perks.perksSelection.explanationOfPerk.TextLabel.Text = v.description
                v.instance.BorderColor3 = Color3.new(1, 1, 1)
                Perks.currentlySelectedPerk = v

                if Perks.currentlySelectedPerk.locked then
                    Perks.equipPurchase_screen.purchaseWithRobuxFrame.PurchaseWithRobuxButton:WaitForChild("Amount").Text = getPriceOfPerkInRobux(Perks.currentlySelectedPerk)
                    Perks.equipPurchase_screen.purchaseWithRobuxFrame.Visible = true
                    Perks.equipPurchase_screen.TextLabel.Text = "Would you like to purchase the '" ..tostring(Perks.currentlySelectedPerk.name) .. "' perk for " .. tostring(Perks.currentlySelectedPerk.cost) .. " Tokens?"
                elseif Perks.currentlySelectedPerk.isEquipped then
                    Perks.equipPurchase_screen.purchaseWithRobuxFrame.Visible = false
                    Perks.equipPurchase_screen.TextLabel.Text = "Unequip?"
                else
                    Perks.equipPurchase_screen.purchaseWithRobuxFrame.Visible = false
                    Perks.equipPurchase_screen.TextLabel.Text = "Equip?"
                end

                Perks.promptToPurchaseRobux = false
                Perks.equipPurchase_screen.Visible = true

                return
            end
        end)
    end
}


function Perks.init()
    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)

    Perks.gameGUI = ModuleLoader.ClientVariables.player.PlayerGui.gameGUI
    Perks.perks_screen = Perks.gameGUI.Frame.perks_screen
    Perks.perksSelection = Perks.perks_screen.perksSelection
    Perks.equippedPerks_screen = Perks.perks_screen.equippedPerks
    Perks.equipPurchase_screen = Perks.gameGUI.Frame.perks_screen.equipPurchase_screen

    Perks.currentlyHighlightedPerk = nil -- when our mouse hovers over a perk
    Perks.currentlySelectedPerk = nil -- whenever we select a perk, this will be that perk
    Perks.promptToPurchaseRobux = false
    
    setmetatable(ModuleLoader.perkButton.instances, instancesMT)
    
    -- local PerksRemoteFunction = game.ReplicatedStorage:WaitForChild("PerksRemoteFunction")
    
    local equippedPerks_folder = ModuleLoader.ClientVariables.player.equippedPerks
    
    Perks.equipPurchase_screen.Yes.Activated:Connect(function()
        if not ModuleLoader.ClientVariables.initialized or ModuleLoader.ClientVariables.humanoid.Health <= 0 then return end
    
        if not Perks.promptToPurchaseRobux then
    
            local getPerk, amountMissingForPurchase
            local success, result = pcall(function()
                getPerk, amountMissingForPurchase = ModuleLoader.ClientVariables.GlobalRemoteFunction:InvokeServer("getPerk", {name = Perks.currentlySelectedPerk.name})
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
                    Perks.equipPurchase_screen.Yes.Visible = false
                    Perks.equipPurchase_screen.No.Visible = false
    
                    Perks.equipPurchase_screen.Ok.Visible = true
                    Perks.equipPurchase_screen.TextLabel.Text = "Failed to equip: Max amount of perks equipped. Unequip at least 1 perk before equipping this one."
                    return
                elseif getPerk == "needMoreMoney" then
                    Perks.equipPurchase_screen.TextLabel.Text = "You need " ..tostring(amountMissingForPurchase) .. " more Tokens to purchase the '" ..tostring(Perks.currentlySelectedPerk.name) .."' perk. Would you like to purchase more Tokens?"
                elseif getPerk == "needMoreKills" then
                    Perks.equipPurchase_screen.TextLabel.Text = "You need " ..tostring(amountMissingForPurchase) .. " more Kills to be able to purchase the '" ..tostring(Perks.currentlySelectedPerk.name) .."' perk. Would you like to purchase this perk with Robux?"
                elseif getPerk == "characterDead" then
                    return
                end
    
                Perks.promptToPurchaseRobux = true
                return 
            end
    
            if Perks.currentlySelectedPerk.locked then
                Perks.currentlySelectedPerk:unlock()
                Perks.currentlySelectedPerk.locked = false
            else
                if Perks.currentlySelectedPerk.isEquipped then
                    unequipPerk(Perks.currentlySelectedPerk)
                elseif #equippedPerks_folder:GetChildren() <= 5 then
                    equipPerk(Perks.currentlySelectedPerk)
                end
            end
        
            deselectPerk()
        
            Perks.equipPurchase_screen.Visible = false
        else
            MarketplaceService:PromptProductPurchase(ModuleLoader.ClientVariables.player, Perks.currentlySelectedPerk.productId)
        end
    end)
    
    Perks.equipPurchase_screen.No.Activated:Connect(function()
        deselectPerk()
        Perks.equipPurchase_screen.Visible = false
    end)
    
    Perks.equipPurchase_screen.Ok.Activated:Connect(function()
        deselectPerk()
        Perks.equipPurchase_screen.Visible = false
    
        Perks.equipPurchase_screen.Yes.Visible = true
        Perks.equipPurchase_screen.No.Visible = true
        Perks.equipPurchase_screen.Ok.Visible = false
    end)
    
    Perks.equipPurchase_screen.purchaseWithRobuxFrame.PurchaseWithRobuxButton.Activated:Connect(function()
        -- if not ClientVariables.initialized or ClientVariables.humanoid.Health <= 0 then return end
        
        MarketplaceService:PromptProductPurchase(ModuleLoader.ClientVariables.player, Perks.currentlySelectedPerk.productId)
    end)
    
    local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")
    local equippedPerks = ModuleLoader.ClientVariables.player:WaitForChild("equippedPerks")
    local unequippedPerks = ModuleLoader.ClientVariables.player:WaitForChild("unequippedPerks")
    
    ModuleLoader.ClientVariables.GlobalBindableEvent.Event:Connect(function(protocol, data)
        if protocol == "perkPurchased" then
            local purchasedPerk = ModuleLoader.perkButton.FindPerkByName(data.perkName)
            purchasedPerk:unlock()
            Perks.currentlySelectedPerk.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
            Perks.currentlySelectedPerk = nil
            Perks.equipPurchase_screen.Visible = false
    
            for _, perk in pairs(ModuleLoader.perkButton.instances) do
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
    
        local newPerk = ModuleLoader.perkButton.new(perk.Name, perk.Value, perk:GetAttribute("Cost"), perk:GetAttribute("KillsRequired"), perk:GetAttribute("ProductId"), locked)
        
        if equipped then
            equipPerk(newPerk)
        else
            unequipPerk(newPerk)
        end
    end
end

return Perks