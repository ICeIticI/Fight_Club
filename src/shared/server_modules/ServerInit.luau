--[[  ]]


local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetOrderedDataStore("KillsStore")

local GlobalRemoteEvent = Instance.new("RemoteEvent") -- used by each client in a server for communication with server-client or client to server
GlobalRemoteEvent.Name = "GlobalRemoteEvent"
GlobalRemoteEvent.Parent = game.ReplicatedStorage

local GlobalRemoteFunction = Instance.new("RemoteFunction") -- used for similar reasons as the GlobalRemoteEvent, but used when we want something returned
GlobalRemoteFunction.Name = "GlobalRemoteFunction"
GlobalRemoteFunction.Parent = game.ReplicatedStorage


-- Creating specific remote events/functions for client-server communication:

local input_check_FUNCTION = Instance.new("RemoteFunction")
input_check_FUNCTION.Name = "input_check_FUNCTION"
input_check_FUNCTION.Parent = game.ReplicatedStorage

local ServerInit = {}


ServerInit.playerInstances = {} -- Making this a module variable so ServerEvents can access this when it needs to get playerInstances

function ServerInit.InitializePlayer(player)
	--[[ Initializes a player when one joins the game ]]

	-- local playerInstance = newPlayer(player) -- newPlayer() is returned a table of public variables of the player
	-- table.insert(ServerInit.playerInstances, playerInstance) -- add the specific playerInstance table to the rest of the public playerInstance tables
	
	local plrObjectsFolder = Instance.new("Folder") -- folder containing the public objects of the player
	plrObjectsFolder.Name = player.Name .. "_GameObjects"
	plrObjectsFolder.Parent = player

		-- Creating leaderstats, which will show how much money a player will have in playernames
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	-- Creating the money stat, which displays how much money a player has at a given time
	local money = Instance.new("IntValue")
	money.Name = "Tokens"
	money.Parent = leaderstats
	
	-- Defining the kills stat, which can perhaps be used for badges, and a sense of accomplishment
	local kills = Instance.new("IntValue")
	kills.Name = "Takedowns"
	kills.Parent = leaderstats

	-- retrieving the player's kills and tokens via DataStore:
	local player_key = "id_" .. player.UserId .. "_kills"
	
	local success, data = pcall(function()
		return DataStore:GetAsync(player_key)
	end)

	if success then
		kills.Value = data or 0
	end

end

function ServerInit.RemovePlayer(player)
	local player_key = "id_" .. player.UserId .. "_kills"
	local kills = player.leaderstats.Takedowns

	local success, result = pcall(function()
		return DataStore:SetAsync(player_key, kills.Value)
	end)

	if not success then
		warn(result)
	end

end

function ServerInit.ShutdownServer()
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		ServerInit.RemovePlayer(player)
	end
end

return ServerInit