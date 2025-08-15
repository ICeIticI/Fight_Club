-- Class for each perk button in the perks screen

local PerkButton = {}

function PerkButton.new(name, description)
    local perkButton = {
        name = name,
        description = description,
        instance = Instance.new("TextButton")
    }

    perkButton.instance.Name = perkButton.name
    perkButton.instance.Text = perkButton.name
    perkButton.instance.BackgroundColor3 = Color3.fromRGB(0,0,0)
    perkButton.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
    perkButton.instance.TextColor3 = Color3.fromRGB(255, 38, 0)
    perkButton.instance.TextScaled = true
    perkButton.instance.BorderSizePixel = 1
    perkButton.instance.Size = UDim2.new({0.333, 0},{0.2, 0})

    return perkButton
end

return PerkButton