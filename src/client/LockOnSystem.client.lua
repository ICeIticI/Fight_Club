local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
local LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")

GameVariables.Sync()


local player = GameVariables.player
print(player)