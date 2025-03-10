local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local UIManager = {}

function UIManager.Init()
    local gameFrame = GameVariables.player.PlayerGui.gameGUI.Frame
    local healthBar = gameFrame.healthLabel
    local healthFrameLabel = gameFrame.healthFrameLabel
    local staminaBar = gameFrame.staminaLabel
    local staminaFrameLabel = gameFrame.staminaFrameLabel

    -- Health management:
    
    GameVariables.humanoid.HealthChanged:Connect(function(health)
        local newYScale = health / GameVariables.humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthBar.Size.X.Scale, healthBar.Size.X.Offset, newYScale * healthFrameLabel.Size.Y.Scale, healthBar.Size.Y.Offset)
    end)
    
    -- Stamina management:
    GameVariables.stamina = 100 -- the stamina of the player. If they get 0 they wont be able to block or parry

    GameVariables.FC_BlockStartTRACK:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        GameVariables.stamina -= 10
        
        staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
        if GameVariables.stamina <= 0 then
            GameVariables.block(false)
        end

        while not (GameVariables.FC_BlockStartTRACK.IsPlaying and GameVariables.FC_BlockTRACK.IsPlaying) and GameVariables.stamina < 100 do
            GameVariables.stamina += 1
            staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            task.wait()
        end
    end)

    GameVariables.FC_BlockTRACK:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        while GameVariables.FC_BlockTRACK.IsPlaying do
            GameVariables.stamina -= 1
            staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            if GameVariables.stamina <= 0 then
                GameVariables.block(false)
            end
            task.wait()
        end
        
        while not GameVariables.FC_BlockTRACK.IsPlaying and GameVariables.stamina < 100 do
            GameVariables.stamina += 1
            staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, GameVariables.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            task.wait()
        end
    end)
    
end

return UIManager
