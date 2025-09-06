--[[  ]]

local MarketplaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")
-- local HttpService = game:GetService("HttpService") -- used for encoding our tables into JSON format as a string since datastores are gay and dont accept tables as a format

local GlobalRemoteEvent = Instance.new("RemoteEvent") -- used by each client in a server for communication with server-client or client to server
GlobalRemoteEvent.Name = "GlobalRemoteEvent"
GlobalRemoteEvent.Parent = game.ReplicatedStorage

local GlobalRemoteFunction = Instance.new("RemoteFunction") -- used for similar reasons as the GlobalRemoteEvent, but used when we want something returned
GlobalRemoteFunction.Name = "GlobalRemoteFunction"
GlobalRemoteFunction.Parent = game.ReplicatedStorage

local GlobalBindableEvent = Instance.new("BindableEvent")
GlobalBindableEvent.Name = "GlobalBindableEvent"
GlobalBindableEvent.Parent = game.ReplicatedStorage

-- Creating specific remote events/functions for client-server communication:

local input_check_FUNCTION = Instance.new("RemoteFunction")
input_check_FUNCTION.Name = "input_check_FUNCTION"
input_check_FUNCTION.Parent = game.ReplicatedStorage

local DataStoreService
local KillsStore
local MoneyStore
local PerksStore
local DonationsStore
if game.PlaceId ~= 0 then -- project must be published to use DatStores
	DataStoreService = game:GetService("DataStoreService")
	KillsStore = DataStoreService:GetOrderedDataStore("KillsStore")
	MoneyStore = DataStoreService:GetOrderedDataStore("MoneyStore")
	DonationsStore = DataStoreService:GetOrderedDataStore("DonationsStore")
	PerksStore = DataStoreService:GetDataStore("PerksStore") -- ordered datastores are for leaderboard and numeric stuff, everything else can use normal datastores
end

local donationProductIds = { -- must have one of these product ids in order to get on the donations board
	[3349676917] = true,
	[3349682499] = true,
	[3349686568] = true,
	[3349688117] = true,
	[3349689893] = true,
	[3350402904] = true,
	[3350445161] = true,
}

local perkProductIds = {
	-- [3382902336] = "Iron Fists",
	-- [3382903295] = "Meat Head",
	-- [3382904079] = "Unbreakable",
	-- [3382905392] = "Cardiosaurus Rex",
	-- [3382906629] = "Full-Auto"
}

GlobalBindableEvent.Event:Connect(function(protocol, data)
	print(protocol)
	if protocol == "addProductIdToTable" then
		perkProductIds[data.productId] = data.name
		print(perkProductIds)
	end
end)

local utilities = require(game.ReplicatedStorage.Shared.utilities)
local perks = require(game.ReplicatedStorage.Shared.server_modules.perks)
local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")

MarketplaceService.ProcessReceipt = function(receiptInfo) -- Runs when a player presses 'Buy' on a developer product
	local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId) -- receiptInfo is a dictionary of stuff when the buy button is pressed, which includes the playerId of what player purchased.
	
	
	if not player then -- player left before we can do anything with this purchase
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- if the script makes it here, then the player is still in the game and we can do stuff in return because of their purchase
	
	if donationProductIds[receiptInfo.ProductId] then
		player.Donations.Value += receiptInfo.CurrencySpent
	elseif perkProductIds[receiptInfo.ProductId] then
		local desiredPerk = perksFolder:FindFirstChild(perkProductIds[receiptInfo.ProductId]):Clone()
		desiredPerk.Parent = player.unequippedPerks
		GlobalRemoteEvent:FireClient(player, "perkPurchased", {perkName = perkProductIds[receiptInfo.ProductId]})
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted -- We can now safely close the purchase
end

local ServerInit = {}

local function rewardForKills(player)
	local kills = player.leaderstats.Takedowns

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
	[132236406] = true, -- me (cause i said so)
	[8671423836] = true, -- kai.bangstat
	[4970028999] = true, -- shadowfirenew
	[6045827681] = true, -- nightshade_bro (one of shadows friends)
	[1025234589] = true -- boris2015cash (another friend of shadow)

}

local function createStatMultiplier(name, parent)
	local newStatMultiplier = Instance.new("Folder")
	newStatMultiplier.Name = name
	newStatMultiplier.Parent = parent

	-- each statMultiplier has one default multiplier of 1 so there is something to multiply and it will just be the same number:
	newStatMultiplier:SetAttribute("defaultMultiplier", 1)

	return newStatMultiplier
end


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

	local baseValues = Instance.new("Folder")
	baseValues.Name = "baseValues"
	baseValues.Parent = plrObjectsFolder

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


	local statMultipliers = Instance.new("Folder")
	statMultipliers.Name = "statMultipliers"
	statMultipliers.Parent = plrObjectsFolder
	createStatMultiplier("MaxHealth_Multiplier", statMultipliers)

	createStatMultiplier("A1Damage_Multiplier", statMultipliers)
	createStatMultiplier("A2Damage_Multiplier", statMultipliers)
	createStatMultiplier("syncBlockDamage_Multiplier", statMultipliers)
	createStatMultiplier("counterAttackDamage_Multiplier", statMultipliers)
	
	createStatMultiplier("pairedChainMAX_Multiplier", statMultipliers)
	createStatMultiplier("escapeGrappleProgressPower_Multiplier", statMultipliers)
	createStatMultiplier("staminaDrainRate_Multiplier", statMultipliers)
	createStatMultiplier("staminaRegenRate_Multiplier", statMultipliers)
	createStatMultiplier("BlockAbsorption_Multiplier", statMultipliers)
	createStatMultiplier("attackSpeed_Multiplier", statMultipliers)
	createStatMultiplier("HealthRegen_Multiplier", statMultipliers)

	local equippedPerks = Instance.new("Folder")
	equippedPerks.Name = "equippedPerks"
	equippedPerks.Parent = player

	local unequippedPerks = Instance.new("Folder")
	unequippedPerks.Name = "unequippedPerks"
	unequippedPerks.Parent = player

	equippedPerks.ChildAdded:Connect(function(child)
		while not characters:GetCharacterObjectByPlayer(player) do task.wait(0.1) end

		perks.applyStatChange(characters:GetCharacterObjectByPlayer(player), child, true)
	end)

	unequippedPerks.ChildAdded:Connect(function(child)
		while not characters:GetCharacterObjectByPlayer(player) do task.wait(0.1) end

		perks.applyStatChange(characters:GetCharacterObjectByPlayer(player), child, false)
	end)

	if game.PlaceId == 0 then return warn("Can't access curent-player's saved data as this project is not published.") end

	-- retrieving the player's kills and donations via DataStore:
	local kills_key = "id_" .. player.UserId .. "_kills"
	local money_key = "id_" .. player.UserId .. "_money"
	local perks_key = "id_" .. player.UserId .. "_perks"
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

	-- perks data:

	success, data = pcall(function()
		return PerksStore:GetAsync(perks_key)
	end)

	if success then
		print(data)
		if data then
			perks.getPerks(data.equippedPerks, player.equippedPerks)
			perks.getPerks(data.unequippedPerks, player.unequippedPerks)

			-- make sure the player didnt manage to get more than the max amount of equipped perks:
			if #player.equippedPerks:GetChildren() > perks.MaxActivePerks then
				for _, perk in pairs(player.equippedPerks:GetChildren()) do
					perk.Parent = player.unequippedPerks
					warn(player.Name .. "'s " ..tostring(perk.Name) .. " was moved to unequipped perks because they had too many active perks.")
					if #player.equippedPerks:GetChildren() <= perks.MaxActivePerks then
						warn("Now play has the max even")
						break
					end
				end
			end
		-- else
		-- 	player.equippedPerks = {}
		-- 	player.unequippedPerks = {}
		end
	else
		warn(data)
	end

	task.spawn(function()
		while not characters:GetCharacterObjectByPlayer(player) do task.wait(0.1) end
		
		-- applying currently-equipped perks:
		for _, perk in pairs(equippedPerks:GetChildren()) do
			perks.applyStatChange(characters:GetCharacterObjectByPlayer(player), perk, true)
		end
	end)

	if EarlyAccessSupporterUserIds[player.UserId] then -- this player is a early-access supporter. They were promised rewards in my promotion.
		local EASupporterScreen = game.ServerStorage.EASupporterGreeting:Clone()
		EASupporterScreen.Parent = player.PlayerGui
	end

end

function ServerInit.RemovePlayer(player)

	if game.PlaceId == 0 then return end

	
	local kills_key = "id_" .. player.UserId .. "_kills"
	local money_key = "id_" .. player.UserId .. "_money"
	local perks_key = "id_" .. player.UserId .. "_perks"
	local donations_key = "id_" .. player.UserId .. "_donations"

	local kills = player.leaderstats.Takedowns
	local money = player.leaderstats.Tokens
	local ownedPerks = {equippedPerks = utilities.TurnInstancesToVariables(player.equippedPerks:GetChildren()), unequippedPerks = utilities.TurnInstancesToVariables(player.unequippedPerks:GetChildren())}
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

	success, result = pcall(function()
		return PerksStore:SetAsync(perks_key, ownedPerks)
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