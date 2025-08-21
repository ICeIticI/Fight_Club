-- Class for each perk button in the perks screen

local PerkButton = {}
PerkButton.__index = PerkButton

PerkButton.instances = {} -- stores each button created from PerkButton.new()

local function initializeButton(self) --[[ After creating a button object, we are gonna alter its properties and stuff. ]]
    
    local button = Instance.new("TextButton")
    button.Name = self.name
    button.Text = self.name
    button.Font = Enum.Font.SpecialElite
    button.BackgroundColor3 = Color3.fromRGB(0,0,0)
    button.BorderColor3 = Color3.fromRGB(255, 38, 0)
    button.TextColor3 = Color3.fromRGB(255, 38, 0)
    button.TextScaled = true
    button.BorderSizePixel = 1
    button.ZIndex = 2
    button.Size = self.unequippedSize

    return button
end

function PerkButton.new(name, description)
    local self = setmetatable({}, PerkButton)
        self.name = name
        self.description = description
        self.equippedSize = UDim2.new(0.2, 0,1, 0)
        self.unequippedSize =  UDim2.new(0.329, 0,0.2, 0)
        self.instance = initializeButton(self)
        self.colorsInverted = false
        
    PerkButton.instances[#PerkButton.instances+1] = self -- like table.insert, but will allow metatable __newindex to trigger
    return self
end

function PerkButton:invertColors()
    if not self.colorsInverted then
        self.instance.BackgroundColor3 = Color3.fromRGB(255, 38, 0)
        self.instance.BorderColor3 = Color3.fromRGB(0,0,0)
        self.instance.TextColor3 = Color3.fromRGB(0,0,0)
        self.colorsInverted = true
    else
        self.instance.BackgroundColor3 = Color3.fromRGB(0,0,0)
        self.instance.BorderColor3 = Color3.fromRGB(255, 38, 0)
        self.instance.TextColor3 = Color3.fromRGB(255, 38, 0)
        self.colorsInverted = false
    end
end

return PerkButton