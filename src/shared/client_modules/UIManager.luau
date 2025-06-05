local ClientVariables = require(game.ReplicatedStorage.Shared.client_modules.ClientVariables)

local UIManager = {}

local gameFrame
local healthBar
local healthFrameLabel
local staminaBar
local staminaFrameLabel

local staminaChecker
local healthChecker

function UIManager.manageUI()

    gameFrame = ClientVariables.player.PlayerGui.gameGUI.Frame
    healthBar = gameFrame.healthLabel
    healthFrameLabel = gameFrame.healthFrameLabel
    staminaBar = gameFrame.staminaLabel
    staminaFrameLabel = gameFrame.staminaFrameLabel

    -- local drainRate = 1 -- how much stamina gets drained per wait()
    -- local regenRate = 1 -- how much stamina gets regenerated per wait()
    
    
    -- Health management:
    
    
    staminaChecker = ClientVariables.stamina:GetPropertyChangedSignal("Value"):Connect(function()
        staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, ClientVariables.stamina.Value/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    end)
    
    
    healthChecker = ClientVariables.humanoid.HealthChanged:Connect(function(health)
        local newYScale = health / ClientVariables.humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthBar.Size.X.Scale, healthBar.Size.X.Offset, newYScale * healthFrameLabel.Size.Y.Scale, healthBar.Size.Y.Offset)
        if health <= 0 then
            staminaChecker:Disconnect()
            healthChecker:Disconnect()

            staminaChecker, healthChecker = nil, nil
        end
    end)
    -- -- Stamina management:
    -- ClientVariables.stamina = 100 -- the stamina of the player. If they get 0 they wont be able to block or parry
    -- local blockCost = 10
    -- local isRegening = false -- Gets set to true when the character's stamina is regenerating, so it doesn't stack

    -- ClientVariables.FC_BlockStartTRACK:GetPropertyChangedSignal("IsPlaying"):Connect(function()
    --     -- if ClientVariables.stamina - blockCost >= 0 then -- If a block occurs when they have less then 10 stamina, then the size of the green bar will not disappear but keep going
    --     --     ClientVariables.stamina -= blockCost
    --     -- else
    --     --     ClientVariables.stamina = 0
    --     -- end
        
    --     staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, ClientVariables.stamina.Value/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    --     -- if ClientVariables.stamina <= 0 then
    --     --     ClientVariables.block(false)
    --     -- end

    --     -- if not isRegening then
    --     --     while (not ClientVariables.FC_BlockStartTRACK.IsPlaying and not ClientVariables.FC_BlockTRACK.IsPlaying) and ClientVariables.stamina < 100 do
    --     --         isRegening = true
    --     --         ClientVariables.stamina += regenRate
    --     --         staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, ClientVariables.stamina.Value/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    --     --         task.wait()
    --     --     end
    --     --     isRegening = false
    --     -- end
    -- end)

    -- ClientVariables.FC_BlockTRACK:GetPropertyChangedSignal("IsPlaying"):Connect(function()
    --     while ClientVariables.FC_BlockTRACK.IsPlaying do
    --         ClientVariables.stamina -= drainRate
    --         staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, ClientVariables.stamina.Value/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    --         if ClientVariables.stamina <= 0 then
    --             ClientVariables.block(false)
    --         end
    --         task.wait()
    --     end
    --     if not isRegening then
    --         while not ClientVariables.FC_BlockTRACK.IsPlaying and ClientVariables.stamina < 100 do
    --             isRegening = true
    --             ClientVariables.stamina += regenRate
    --             staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, ClientVariables.stamina.Value/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
    --             task.wait()
    --         end
    --         isRegening = false
    --     end
    -- end)
    
end

return UIManager