local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)

local UIManager = {}

-- pre-defining these variables so a variable doesnt get created every time stam gets changed, which is good for memory.

local gameFrame
local healthBar
local healthFrameLabel
local staminaBar
local staminaFrameLabel

local mobile_attackButton
local mobile_blockButton

local staminaChecker
local healthChecker

local loadingScreenFrame
local loadingLabel

local primaryColor = "#000000" -- black
local secondaryColor = "#ff2600" -- a red I happen to pick out that we're sticking with

local reverseDots = false
local function cycleDots(textLabel)
    local noDotString = textLabel.Text:gsub("%.", "") -- Should just return "Loading" without the dots, unless I change it to something else

	local dotCount = textLabel.Text:gsub("[^%.]", "") -- Returns only dots and gets rid of anything else.  %a = letters, %s = whitespace
    if dotCount == "" then
        reverseDots = false
        textLabel.Text = noDotString .. "."

	elseif dotCount == "." then
        if not reverseDots then
            textLabel.Text = noDotString .. ".."
        else
            textLabel.Text = noDotString .. ""
        end

	elseif dotCount == ".." then
        if not reverseDots then
            textLabel.Text = noDotString .. "..."
        else
            textLabel.Text = noDotString .. "."
        end
        
	elseif dotCount == "..." then
		reverseDots = true
        textLabel.Text = noDotString .. ".."
	end

    task.wait(0.2)
end


function UIManager.manageUI()

    gameFrame = ClientVariables.player.PlayerGui.gameGUI.Frame
    healthBar = gameFrame.healthLabel
    healthFrameLabel = gameFrame.healthFrameLabel
    staminaBar = gameFrame.staminaLabel
    staminaFrameLabel = gameFrame.staminaFrameLabel

    -- mobile UI:
    if ClientVariables.isOnMobile then
        
        gameFrame.mobile_controls.Visible = true

        mobile_attackButton = gameFrame.mobile_controls.attackButton
        mobile_blockButton = gameFrame.mobile_controls.blockButton
    
        mobile_attackButton.InputBegan:Connect(function()
            ClientVariables.isAttackButtonHeld = true
            -- ClientVariables.isBlockButtonHeld = true

            ClientVariables.LocalBindableEvent:Fire("mobileInputBegan", {input = {UserInputType = "mobile_attackButton"}})
        end)
        mobile_attackButton.InputEnded:Connect(function()
            ClientVariables.isAttackButtonHeld = false
        end)
    
        mobile_blockButton.InputBegan:Connect(function()
            ClientVariables.isBlockButtonHeld = true
            ClientVariables.LocalBindableEvent:Fire("mobileInputBegan", {input = {UserInputType = "mobile_blockButton"}})
        end)
        mobile_blockButton.InputEnded:Connect(function()
            ClientVariables.isBlockButtonHeld = false
            ClientVariables.LocalBindableEvent:Fire("mobileInputEnded", {input = {UserInputType = "mobile_blockButton"}})
        end)
    end

    -- local drainRate = 1 -- how much stamina gets drained per wait()
    -- local regenRate = 1 -- how much stamina gets regenerated per wait()
    
    
    -- Health management:
    
    local healthFraction
    
    staminaChecker = ClientVariables.stamina:GetPropertyChangedSignal("Value"):Connect(function()
        healthFraction = ClientVariables.stamina.Value/ClientVariables.maxStamina.Value
        staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, healthFraction * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    end)
    
    local staminaFraction

    healthChecker = ClientVariables.humanoid.HealthChanged:Connect(function(health)
        staminaFraction = health / ClientVariables.humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthBar.Size.X.Scale, healthBar.Size.X.Offset, staminaFraction * healthFrameLabel.Size.Y.Scale, healthBar.Size.Y.Offset)
        if health <= 0 then
            staminaChecker:Disconnect()
            healthChecker:Disconnect()

            staminaChecker, healthChecker = nil, nil
        end
    end)

    gameFrame.fightingStyles_button.Activated:Connect(function()
        gameFrame.fightingStyles_screen.Visible = not gameFrame.fightingStyles_screen.Visible
    end)

    gameFrame.perks_button.Activated:Connect(function()
        gameFrame.perks_screen.Visible = not gameFrame.perks_screen.Visible
    end)

    loadingScreenFrame = ClientVariables.player.PlayerGui.loadingScreen.Frame
    loadingLabel = loadingScreenFrame.loadingLabel

    while not ClientVariables.initialized do
        task.wait()
        cycleDots(loadingLabel)
    end
    loadingScreenFrame.Parent.Enabled = false

end

return UIManager