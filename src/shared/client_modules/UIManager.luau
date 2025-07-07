local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)

local UIManager = {}

-- pre-defining these variables so a variable doesnt get created every time stam gets changed, which is good for memory.

local gameFrame
local healthBar
local healthFrameLabel
local staminaBar
local staminaFrameLabel

local staminaChecker
local healthChecker

local loadingScreenFrame
local loadingLabel

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

    loadingScreenFrame = ClientVariables.player.PlayerGui.loadingScreen.Frame
    loadingLabel = loadingScreenFrame.loadingLabel

    while not ClientVariables.initialized do
        task.wait()
        cycleDots(loadingLabel)
    end
    loadingScreenFrame.Parent.Enabled = false

end

return UIManager