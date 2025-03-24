local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local UIManager = {}

function UIManager.Init()

    local gameFrame = GameVariables.player.PlayerGui.gameGUI.Frame
    local healthBar = gameFrame.healthLabel
    local healthFrameLabel = gameFrame.healthFrameLabel
    local staminaBar = gameFrame.staminaLabel
    local staminaFrameLabel = gameFrame.staminaFrameLabel

    local drainRate = 1 -- how much stamina gets drained per wait()
    local regenRate = 1 -- how much stamina gets regenerated per wait()
    
    
    -- Health management:
    
    GameVariables.humanoid.HealthChanged:Connect(function(health)
        local newYScale = health / GameVariables.humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthBar.Size.X.Scale, healthBar.Size.X.Offset, newYScale * healthFrameLabel.Size.Y.Scale, healthBar.Size.Y.Offset)
    end)
    
    -- Stamina management:
    GameVariables.stamina = 100 -- the stamina of the player. If they get 0 they wont be able to block or parry
    local blockCost = 10
    local isRegening = false -- Gets set to true when the character's stamina is regenerating, so it doesn't stack

    GameVariables.FC_BlockStartTRACK:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if GameVariables.stamina - blockCost >= 0 then -- If a block occurs when they have less then 10 stamina, then the size of the green bar will not disappear but keep going
            GameVariables.stamina -= blockCost
        else
            GameVariables.stamina = 0
        end
        
        staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
        if GameVariables.stamina <= 0 then
            GameVariables.block(false)
        end

        if not isRegening then
            while (not GameVariables.FC_BlockStartTRACK.IsPlaying and not GameVariables.FC_BlockTRACK.IsPlaying) and GameVariables.stamina < 100 do
                isRegening = true
                GameVariables.stamina += regenRate
                staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
                task.wait()
            end
            isRegening = false
        end
    end)

    GameVariables.FC_BlockTRACK:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        while GameVariables.FC_BlockTRACK.IsPlaying do
            GameVariables.stamina -= drainRate
            staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            if GameVariables.stamina <= 0 then
                GameVariables.block(false)
            end
            task.wait()
        end
        if not isRegening then
            while not GameVariables.FC_BlockTRACK.IsPlaying and GameVariables.stamina < 100 do
                isRegening = true
                GameVariables.stamina += regenRate
                staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
                task.wait()
            end
            isRegening = false
        end
    end)
    
end

return UIManager