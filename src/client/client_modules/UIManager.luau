local MarketplaceService = game:GetService("MarketplaceService")
local SocialService = game:GetService("SocialService")

local ModuleLoader

local UIManager = {}

local function writeCreditToPropsCreator() -- as usernames can change, this will just pull from Roblox the player Id of who contributed to this.      
    local propsTextButton = game:GetService("Workspace"):WaitForChild("tavern"):WaitForChild("CreditsBoard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("PropsFrame"):WaitForChild("Frame"):WaitForChild("TextButton")
    
    -- since they may change their username or whatever, this will just pull their name whenever a session starts
    local contributorId = 2259676713 -- wolf
    local contributorName = game.Players:GetNameFromUserIdAsync(contributorId)
    
    propsTextButton.Text = "Glass bottles created by " .. contributorName
end

local function waitForLoadingScreen(loadingScreen)
    task.spawn(function()
        while not ModuleLoader.ClientVariables.initialized do task.wait() end
        
        loadingScreen.Enabled = false
    end)
end

local onAttackButtonActivated = function()
        ModuleLoader.ClientVariables.isAttackButtonHeld = true
        ModuleLoader.ClientVariables.LocalBindableEvent:Fire("mobileInputBegan", {input = {UserInputType = "mobile_attackButton"}})
    end
local onAttackButtonDeactivated = function()
    ModuleLoader.ClientVariables.isAttackButtonHeld = false
end
local onBlockButtonActivated = function()
        ModuleLoader.ClientVariables.isBlockButtonHeld = true
        ModuleLoader.ClientVariables.LocalBindableEvent:Fire("mobileInputBegan", {input = {UserInputType = "mobile_blockButton"}})
    end
local onBlockButtonDeactivated = function()
        ModuleLoader.ClientVariables.isBlockButtonHeld = false
        ModuleLoader.ClientVariables.LocalBindableEvent:Fire("mobileInputEnded", {input = {UserInputType = "mobile_blockButton"}})
    end
local donation_buttonActivated = function()
        UIManager.gameFrame.donateOptions.Visible = not UIManager.gameFrame.donateOptions.Visible
    end
local howToPlay_buttonActivated = function()
        UIManager.gameFrame.howToPlay_screen.Visible = not UIManager.gameFrame.howToPlay_screen.Visible
end
local inviteFriends_buttonActivated = function()
    if not UIManager.inviteDebounce then
        UIManager.inviteDebounce = true
        local canInvite = SocialService:CanSendCallInviteAsync(ModuleLoader.ClientVariables.player)
        if canInvite then
            SocialService:PromptGameInvite(ModuleLoader.ClientVariables.player)
            task.wait(1)
            UIManager.inviteDebounce = false
        elseif not canInvite then
            UIManager.gameFrame.buttons2.inviteFriends_button.Image = "rbxassetid://87462560606638"
            UIManager.gameFrame.buttons2.inviteFriends_button.HoverImage = ""
            task.wait(5)
            UIManager.gameFrame.buttons2.inviteFriends_button.Image = UIManager.originalImage
            UIManager.gameFrame.buttons2.inviteFriends_button.HoverImage = UIManager.originalHoverImage
            UIManager.inviteDebounce = false
        end
    end
end
local EASupporterGreetingActivated = function()
    UIManager.EASupporterGreeting.Frame.Parent.Enabled = false
end

function UIManager.init()

    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)

    ModuleLoader.perks.init()

    UIManager.donateButtons = {}

    UIManager.primaryColor = "#000000" -- black
    UIManager.secondaryColor = "#ff2600" -- a red I happen to pick out that we're sticking with
    
    UIManager.originalHealthSize = ModuleLoader.ClientVariables.player.PlayerGui:WaitForChild("gameGUI").Frame.healthLabel.Size
    UIManager.originalStaminaSize = ModuleLoader.ClientVariables.player.PlayerGui.gameGUI.Frame.staminaLabel.Size
    
    UIManager.gameFrame = ModuleLoader.ClientVariables.player.PlayerGui:WaitForChild("gameGUI").Frame
    UIManager.buttons = {} -- table holding all the button objects defined in uiButton
    UIManager.EASupporterGreeting = ModuleLoader.ClientVariables.player.PlayerGui:FindFirstChild("EASupporterGreeting")
    
    UIManager.mobile_attackButton = ModuleLoader.uiButton.new(UIManager.gameFrame.mobile_controls.attackButton, onAttackButtonActivated, onAttackButtonDeactivated)
    UIManager.mobile_blockButton = ModuleLoader.uiButton.new(UIManager.gameFrame.mobile_controls.blockButton, onBlockButtonActivated, onBlockButtonDeactivated)
    
    UIManager.buttons["donation_button"] = ModuleLoader.uiButton.new(UIManager.gameFrame.buttons2.donation_button, donation_buttonActivated)
    UIManager.buttons["howToPlay_button"] = ModuleLoader.uiButton.new(UIManager.gameFrame.buttons2.howToPlay_button, howToPlay_buttonActivated)
    
    UIManager.inviteDebounce = false -- makes sure invites cant be spam-sent.
    UIManager.originalImage, UIManager.originalHoverImage = "rbxassetid://110647224004441", "rbxassetid://121072355246741"

    UIManager.buttons["inviteFriends_button"] = ModuleLoader.uiButton.new(UIManager.gameFrame.buttons2.inviteFriends_button, inviteFriends_buttonActivated)
    
    if UIManager.EASupporterGreeting then
        UIManager.buttons["EASupporterGreeting"] = ModuleLoader.uiButton.new(UIManager.EASupporterGreeting:WaitForChild("Frame"):WaitForChild("Close"), EASupporterGreetingActivated)
    end
    
    -- Deactivated until its added to the game
    --[[
        gameFrame.buttons1.fightingStyles_button.Activated:Connect(function()
        gameFrame.fightingStyles_screen.Visible = not gameFrame.fightingStyles_screen.Visible
    end)
    
    --]]
    UIManager.gameFrame.buttons1.perks_button.Activated:Connect(function()
        UIManager.gameFrame.perks_screen.Visible = not UIManager.gameFrame.perks_screen.Visible
    end)

    -- ! Below was the old .manageUI() function, merged with init: !

    local loadingScreen = ModuleLoader.ClientVariables.player.PlayerGui.loadingScreen 
    loadingScreen.Enabled = true

    local healthBar = UIManager.gameFrame.healthLabel
    local healthFrameLabel = UIManager.gameFrame.healthFrameLabel
    local staminaBar = UIManager.gameFrame.staminaLabel
    local staminaFrameLabel = UIManager.gameFrame.staminaFrameLabel

    UIManager.donateButtons = (function()
        local buttons = {}
        for _, child in pairs(UIManager.gameFrame.donateOptions:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                table.insert(buttons, child)
            end
        end
        return buttons
    end)()

    for i, button in pairs(UIManager.donateButtons) do
        UIManager.buttons[i] = ModuleLoader.uiButton.new(button, function()
            local productId = button:GetAttribute("productId")
            MarketplaceService:PromptProductPurchase(ModuleLoader.ClientVariables.player, productId)
        end)
    end

    -- mobile UI:
    if ModuleLoader.ClientVariables.isOnMobile then
        
        UIManager.gameFrame.mobile_controls.Visible = true

        UIManager.mobile_attackButton.instance.InputBegan:Connect(onAttackButtonActivated)
        UIManager.mobile_attackButton.instance.InputEnded:Connect(onAttackButtonDeactivated)
        UIManager.mobile_blockButton.instance.InputBegan:Connect(onBlockButtonActivated)
        UIManager.mobile_blockButton.instance.InputEnded:Connect(onBlockButtonDeactivated)
    end

    -- local drainRate = 1 -- how much stamina gets drained per wait()
    -- local regenRate = 1 -- how much stamina gets regenerated per wait()
    
    
    -- Health management:
    
    local healthFraction
    while not ModuleLoader.ClientVariables.stamina do task.wait() end
    local staminaChecker = ModuleLoader.ClientVariables.stamina:GetPropertyChangedSignal("Value"):Connect(function()
        healthFraction = ModuleLoader.ClientVariables.stamina.Value/ModuleLoader.ClientVariables.maxStamina.Value
        staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, healthFraction * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    end)
    
    local staminaFraction

    for _, button in pairs(UIManager.buttons) do
        button.activatedConnection = button.instance.Activated:Connect(function()
            button:Activate()
        end)
    end
    
    healthBar.Size = UDim2.new(healthBar.Size.X.Scale, 
    healthBar.Size.X.Offset, 
    1 
    * healthFrameLabel.Size.Y.Scale, 
    healthBar.Size.Y.Offset)

    writeCreditToPropsCreator()

    waitForLoadingScreen(loadingScreen)

    while ModuleLoader.ClientVariables.humanoid and ModuleLoader.ClientVariables.humanoid.Health <= 0 do task.wait() end
    local healthChecker
    healthChecker = ModuleLoader.ClientVariables.humanoid.HealthChanged:Connect(function(health)
        staminaFraction = health / ModuleLoader.ClientVariables.humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthBar.Size.X.Scale, healthBar.Size.X.Offset, staminaFraction * healthFrameLabel.Size.Y.Scale, healthBar.Size.Y.Offset)
        if health <= 0 then
            for _, button in pairs(UIManager.buttons) do
                button.activatedConnection:Disconnect()
            end
            staminaChecker:Disconnect()
            healthChecker:Disconnect()
            staminaChecker, healthChecker = nil, nil
        end
    end)
end

return UIManager