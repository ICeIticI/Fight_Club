local MarketplaceService = game:GetService("MarketplaceService")
local SocialService = game:GetService("SocialService")

local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)
local uiButton = require(game.ReplicatedStorage.Shared.client_modules.uiButton)
local perks = require(game.ReplicatedStorage.Shared.client_modules.perks.perks)

local UIManager = {}


local donateButtons = {}

local primaryColor = "#000000" -- black
local secondaryColor = "#ff2600" -- a red I happen to pick out that we're sticking with

local originalHealthSize = ClientVariables.player.PlayerGui:WaitForChild("gameGUI").Frame.healthLabel.Size
local originalStaminaSize = ClientVariables.player.PlayerGui.gameGUI.Frame.staminaLabel.Size

local function writeCreditToPropsCreator() -- as usernames can change, this will just pull from Roblox the player Id of who contributed to this.      
    local propsTextButton = game:GetService("Workspace"):WaitForChild("tavern"):WaitForChild("CreditsBoard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("PropsFrame"):WaitForChild("Frame"):WaitForChild("TextButton")

        -- since they may change their username or whatever, this will just pull their name whenever a session starts
    local contributorId = 2259676713 -- wolf
    local contributorName = game.Players:GetNameFromUserIdAsync(contributorId)

    propsTextButton.Text = "Glass bottles created by " .. contributorName
end

local function waitForLoadingScreen(loadingScreen)
    task.spawn(function()
        while not ClientVariables.initialized do task.wait() end
    
        loadingScreen.Enabled = false
        print(loadingScreen.Enabled)
    end)
end

local gameFrame = ClientVariables.player.PlayerGui:WaitForChild("gameGUI").Frame
local buttons = {} -- table holding all the button objects defined in uiButton
local EASupporterGreeting = ClientVariables.player.PlayerGui:FindFirstChild("EASupporterGreeting")

local onAttackButtonActivated = function()
    ClientVariables.isAttackButtonHeld = true
    ClientVariables.LocalBindableEvent:Fire("mobileInputBegan", {input = {UserInputType = "mobile_attackButton"}})
end
local onAttackButtonDeactivated = function()
    ClientVariables.isAttackButtonHeld = false
end
local mobile_attackButton = uiButton.new(gameFrame.mobile_controls.attackButton, onAttackButtonActivated, onAttackButtonDeactivated)


local onBlockButtonActivated = function()
    ClientVariables.isBlockButtonHeld = true
    ClientVariables.LocalBindableEvent:Fire("mobileInputBegan", {input = {UserInputType = "mobile_blockButton"}})
end
local onBlockButtonDeactivated = function()
    ClientVariables.isBlockButtonHeld = false
    ClientVariables.LocalBindableEvent:Fire("mobileInputEnded", {input = {UserInputType = "mobile_blockButton"}})
end
local mobile_blockButton = uiButton.new(gameFrame.mobile_controls.blockButton, onBlockButtonActivated, onBlockButtonDeactivated)

local donation_buttonActivated = function()
    gameFrame.donateOptions.Visible = not gameFrame.donateOptions.Visible
end
buttons["donation_button"] = uiButton.new(gameFrame.buttons2.donation_button, donation_buttonActivated)

local howToPlay_buttonActivated = function()
    gameFrame.howToPlay_screen.Visible = not gameFrame.howToPlay_screen.Visible
end
buttons["howToPlay_button"] = uiButton.new(gameFrame.buttons2.howToPlay_button, howToPlay_buttonActivated)

local inviteDebounce = false -- makes sure invites cant be spam-sent.
local originalImage, originalHoverImage = "rbxassetid://110647224004441", "rbxassetid://121072355246741"

local inviteFriends_buttonActivated = function()
    if not inviteDebounce then
        inviteDebounce = true
        local canInvite = SocialService:CanSendCallInviteAsync(ClientVariables.player)
        if canInvite then
            SocialService:PromptGameInvite(ClientVariables.player)
            task.wait(1)
            inviteDebounce = false
        elseif not canInvite then
            gameFrame.buttons2.inviteFriends_button.Image = "rbxassetid://87462560606638"
            gameFrame.buttons2.inviteFriends_button.HoverImage = ""
            task.wait(5)
            gameFrame.buttons2.inviteFriends_button.Image = originalImage
            gameFrame.buttons2.inviteFriends_button.HoverImage = originalHoverImage
            inviteDebounce = false
        end
    end
end
buttons["inviteFriends_button"] = uiButton.new(gameFrame.buttons2.inviteFriends_button, inviteFriends_buttonActivated)

local EASupporterGreetingActivated = function()
    EASupporterGreeting.Frame.Parent.Enabled = false
end
if EASupporterGreeting then
    buttons["EASupporterGreeting"] = uiButton.new(EASupporterGreeting:WaitForChild("Frame"):WaitForChild("Close"), EASupporterGreetingActivated)
end

function UIManager.manageUI()

    local loadingScreen = ClientVariables.player.PlayerGui.loadingScreen 
    loadingScreen.Enabled = true

    local healthBar = gameFrame.healthLabel
    local healthFrameLabel = gameFrame.healthFrameLabel
    local staminaBar = gameFrame.staminaLabel
    local staminaFrameLabel = gameFrame.staminaFrameLabel

    donateButtons = (function()
        local buttons = {}
        for _, child in pairs(gameFrame.donateOptions:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                table.insert(buttons, child)
            end
        end
        return buttons
    end)()

    for i, button in pairs(donateButtons) do
        buttons[i] = uiButton.new(button, function()
            local productId = button:GetAttribute("productId")
            MarketplaceService:PromptProductPurchase(ClientVariables.player, productId)
        end)
    end

    -- mobile UI:
    if ClientVariables.isOnMobile then
        print("we on mobile my g")
        
        gameFrame.mobile_controls.Visible = true

        mobile_attackButton.instance.InputBegan:Connect(onAttackButtonActivated)
        mobile_attackButton.instance.InputEnded:Connect(onAttackButtonDeactivated)
        mobile_blockButton.instance.InputBegan:Connect(onBlockButtonActivated)
        mobile_blockButton.instance.InputEnded:Connect(onBlockButtonDeactivated)
    end

    -- local drainRate = 1 -- how much stamina gets drained per wait()
    -- local regenRate = 1 -- how much stamina gets regenerated per wait()
    
    
    -- Health management:
    
    local healthFraction
    while not ClientVariables.stamina do task.wait() end
    local staminaChecker = ClientVariables.stamina:GetPropertyChangedSignal("Value"):Connect(function()
        healthFraction = ClientVariables.stamina.Value/ClientVariables.maxStamina.Value
        staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, healthFraction * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    end)
    
    local staminaFraction

    -- Deactivated until its added to the game
    --[[
    gameFrame.buttons1.fightingStyles_button.Activated:Connect(function()
        gameFrame.fightingStyles_screen.Visible = not gameFrame.fightingStyles_screen.Visible
    end)
    
    --]]
    -- gameFrame.buttons1.perks_button.Activated:Connect(function()
    --     gameFrame.perks_screen.Visible = not gameFrame.perks_screen.Visible
    -- end)

    for _, button in pairs(buttons) do
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

    while ClientVariables.humanoid and ClientVariables.humanoid.Health <= 0 do task.wait() end
    local healthChecker
    healthChecker = ClientVariables.humanoid.HealthChanged:Connect(function(health)
        staminaFraction = health / ClientVariables.humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthBar.Size.X.Scale, healthBar.Size.X.Offset, staminaFraction * healthFrameLabel.Size.Y.Scale, healthBar.Size.Y.Offset)
        if health <= 0 then
            for _, button in pairs(buttons) do
                button.activatedConnection:Disconnect()
            end
            staminaChecker:Disconnect()
            healthChecker:Disconnect()
            staminaChecker, healthChecker = nil, nil
        end
    end)

end

return UIManager