local UIButton = {}
UIButton.__index = UIButton

function UIButton.new(buttonInstance, activateFunction, deactivateFunction: optional)
    local self = setmetatable({}, UIButton)
    self.instance = buttonInstance
    self.activateFunction = activateFunction
    self.deactivateFunction = deactivateFunction
    return self
end

function UIButton:Activate()
    self.activateFunction()
end

function UIButton:Deactivate()
    self.deactivateFunction()
end

return UIButton