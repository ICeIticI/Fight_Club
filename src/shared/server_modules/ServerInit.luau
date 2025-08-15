--[[  ]]

local MarketplaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")

local DataStoreService
local KillsStore
local MoneyStore
local DonationsStore
if game.PlaceId ~= 0 then -- project must be published to use DatStores
	DataStoreService = game:GetService("DataStoreService")
	KillsStore = DataStoreService:GetOrderedDataStore("KillsStore")
	MoneyStore = DataStoreService:GetOrderedDataStore("MoneyStore")
	DonationsStore = DataStoreService:GetOrderedDataStore("DonationsStore")
end

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

MarketplaceService.ProcessReceipt = function(receiptInfo) -- Runs when a player presses 'Buy' on a developer product
	local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId) -- receiptInfo is a dictionary of stuff when the buy button is pressed, which includes the playerId of what player purchased.
	
	
	if not player then -- player left before we can do anything with this purchase
		print("Player left")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- if the script makes it here, then the player is still in the game and we can do stuff in return because of their purchase
	print(receiptInfo.CurrencySpent)
	player.Donations.Value += receiptInfo.CurrencySpent

	return Enum.ProductPurchaseDecision.PurchaseGranted -- We can now safely close the purchase
end

local ServerInit = {}

local function rewardForKills(player)
	local kills = player.leaderstats.Takedowns

	print(kills, BadgeService:UserHasBadgeAsync(player.UserId, 1102891297529600))
	if kills.Value >= 1 and not BadgeService:UserHasBadgeAsync(player.UserId, 1102891297529600) then
		BadgeService:AwardBadge(player.UserId, 1102891297529600)
	end

	if kills.Value >= 5 and not BadgeService:UserHasBadgeAsync(player.UserId, 	611484439045336) then
		BadgeService:AwardBadge(player.UserId, 	611484439045336)
	end

	if kills.Value >= 10 and not BadgeService:UserHasBadgeAsync(player.UserId, 	1092644572406442) then
		BadgeService:AwardBadge(player.UserId, 	1092644572406442)
	end
end

local function setupNewPlayer(player)
	if BadgeService:UserHasBadgeAsync(player.UserId, 1214839343920223) then return end

	BadgeService:AwardBadge(player.UserId, 4315096651447293)
end

local function rewardForPlayingAlpha(player)
	if BadgeService:UserHasBadgeAsync(player.UserId, 1214839343920223) then return end
	
	BadgeService:AwardBadge(player.UserId, 1214839343920223)
end

local EarlyAccessSupporterUserIds = {
	[132236406] = true, -- me (for testing)

}


ServerInit.playerInstances = {} -- Making this a module variable so ServerEvents can access this when it needs to get playerInstances

function ServerInit.InitializePlayer(player)

	setupNewPlayer(player)
	rewardForPlayingAlpha(player)
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

	kills:GetPropertyChangedSignal("Value"):Connect(function()
		rewardForKills(player)
	end)

	
	local donations = Instance.new("IntValue")
	donations.Name = "Donations"
	donations.Parent = player

	if game.PlaceId == 0 then return warn("Can't access curent-player's saved data as this project is not published.") end

	-- retrieving the player's kills and donations via DataStore:
	local kills_key = "id_" .. player.UserId .. "_kills"
	local money_key = "id_" .. player.UserId .. "_money"
	local donations_key = "id_" .. player.UserId .. "_donations"
	
	local success, data = pcall(function()
		return KillsStore:GetAsync(kills_key)
	end)

	if success then
		kills.Value = data or 0
		rewardForKills(player)
	else
		warn(data)
	end

	success = nil

	success, data = pcall(function()
		return DonationsStore:GetAsync(donations_key)
	end)

	if success then
		donations.Value = data or 0
	else
		warn(data)
	end

	success, data = pcall(function()
		return MoneyStore:GetAsync(money_key)
	end)

	if success then
		money.Value = data or 0
	else
		warn(data)
	end

	if EarlyAccessSupporterUserIds[player.UserId] then -- this player is a early-access supporter. They were promised rewards in my promotion.
		local EASupporterScreen = game.ServerStorage.EASupporterGreeting:Clone()
		EASupporterScreen.Parent = player.PlayerGui
	end

end

function ServerInit.RemovePlayer(player)

	if game.PlaceId == 0 then return end

	
	local kills_key = "id_" .. player.UserId .. "_kills"
	local money_key = "id_" .. player.UserId .. "_money"
	local donations_key = "id_" .. player.UserId .. "_donations"

	local kills = player.leaderstats.Takedowns
	local money = player.leaderstats.Tokens
	local donations = player.Donations
	
	if player.UserId < 1 then
		DonationsStore:RemoveAsync(donations_key)
		KillsStore:RemoveAsync(kills_key, kills.Value)
		MoneyStore:RemoveAsync(money_key)
		return warn("player ID not valid to save: " .. player.UserId) 
	end

	local success, result = pcall(function()
		return KillsStore:SetAsync(kills_key, kills.Value)
	end)

	if not success then
		warn(result)
	end

	success, result = pcall(function()
		return DonationsStore:SetAsync(donations_key, donations.Value)
	end)

	if not success then
		warn(result)
	end

	success, result = pcall(function()
		return MoneyStore:SetAsync(money_key, money.Value)
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