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

local function lockButton(button)
    local lockImg = Instance.new("ImageLabel")
    lockImg.Name = "lockImage"
    lockImg.BackgroundTransparency = 1
    lockImg.ImageTransparency = 0.7
    lockImg.Image = "rbxassetid://84160492794704"
    lockImg.Size = UDim2.fromScale(1,1)
    lockImg.Parent = button
end

function PerkButton.new(name, description, cost, killsRequired, productId, locked)
    local self = setmetatable({}, PerkButton)
        self.name = name
        self.description = description
        self.equippedSize = UDim2.new(0.2, 0,1, 0)
        self.unequippedSize = UDim2.new(0.329, 0,0.2, 0)
        self.instance = initializeButton(self)
        self.cost = cost
        self.killsRequired = killsRequired
        self.productId = productId
        self.locked = locked
        
    if self.locked then
        lockButton(self.instance)
    end

    PerkButton.instances[#PerkButton.instances+1] = self -- like table.insert, but will allow metatable __newindex to trigger
    return self
end

function PerkButton:unlock()
    self.instance.lockImage:Destroy()
    self.locked = false
end

function PerkButton.FindPerkByName(name)
    for _, perk in pairs(PerkButton.instances) do
        if perk.name == name then
            return perk
        end
    end

    return warn("No perk found with the given name: " .. tostring(name))
end

return PerkButton