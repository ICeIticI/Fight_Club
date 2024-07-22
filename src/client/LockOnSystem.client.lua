local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
local LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")

LocalBindableEvent.Event:Connect(function(givenObject, newValue)
    print(GameVariables.TestObject)
    GameVariables[givenObject] = newValue
    print(givenObject.Name.. " was changed to "..tostring(newValue))
    print(GameVariables.TestObject)
end)


local player = GameVariables.player
print(player)