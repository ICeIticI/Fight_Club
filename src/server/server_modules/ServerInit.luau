--[[  ]]

local MarketplaceService -- defined in init() for modular purposes
local BadgeService
local DataStoreService
-- local HttpService = game:GetService("HttpService") -- used for encoding our tables into JSON format as a string since datastores are gay and dont accept tables as a format

local ModuleLoader

local ServerInit = {}

local function rewardForKills(player)
	local kills = player.leaderstats.Takedowns

	if kills.Value >= 1 and not BadgeService:UserHasBadgeAsync(player.UserId, 1102891297529600) then
		BadgeService:AwardBadge(player.UserId, 1102891297529600)
	end

	if kills.Value >= 5 and not BadgeService:UserHasBadgeAsync(player.UserId, 611484439045336) then
		BadgeService:AwardBadge(player.UserId, 	611484439045336)
	end

	if kills.Value >= 10 and not BadgeService:UserHasBadgeAsync(player.UserId, 1092644572406442) then
		BadgeService:AwardBadge(player.UserId, 	1092644572406442)
	end

	if kills.Value >= 15 and not BadgeService:UserHasBadgeAsync(player.UserId, 387159857183029) then
		BadgeService:AwardBadge(player.UserId, 	387159857183029)
	end

	if kills.Value >= 25 and not BadgeService:UserHasBadgeAsync(player.UserId, 4103765062926205) then
		BadgeService:AwardBadge(player.UserId, 	4103765062926205)
	end

	if kills.Value >= 50 and not BadgeService:UserHasBadgeAsync(player.UserId, 1698296839475848) then
		BadgeService:AwardBadge(player.UserId, 	1698296839475848)
	end

	if kills.Value >= 75 and not BadgeService:UserHasBadgeAsync(player.UserId, 4019803204170922) then
		BadgeService:AwardBadge(player.UserId, 	4019803204170922)
	end

	if kills.Value >= 100 and not BadgeService:UserHasBadgeAsync(player.UserId, 1025287893678257) then
		BadgeService:AwardBadge(player.UserId, 	1025287893678257)
	end

	if kills.Value >= 150 and not BadgeService:UserHasBadgeAsync(player.UserId, 258648843981034) then
		BadgeService:AwardBadge(player.UserId, 	258648843981034)
	end

	if kills.Value >= 200 and not BadgeService:UserHasBadgeAsync(player.UserId, 3153668988258146) then
		BadgeService:AwardBadge(player.UserId, 	3153668988258146)
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


function ServerInit.init()

	MarketplaceService = game:GetService("MarketplaceService")
	BadgeService = game:GetService("BadgeService")

	ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)
	
	ServerInit.GlobalRemoteEvent = Instance.new("RemoteEvent") -- used by each client in a server for communication with server-client or client to server
	ServerInit.GlobalRemoteEvent.Name = "GlobalRemoteEvent"
	ServerInit.GlobalRemoteEvent.Parent = game.ReplicatedStorage
	
	ServerInit.GlobalRemoteFunction = Instance.new("RemoteFunction") -- used for similar reasons as the GlobalRemoteEvent, but used when we want something returned
	ServerInit.GlobalRemoteFunction.Name = "GlobalRemoteFunction"
	ServerInit.GlobalRemoteFunction.Parent = game.ReplicatedStorage
	
	ServerInit.GlobalBindableEvent = Instance.new("BindableEvent")
	ServerInit.GlobalBindableEvent.Name = "GlobalBindableEvent"
	ServerInit.GlobalBindableEvent.Parent = game.ReplicatedStorage
	
	-- Creating specific remote events/functions for client-server communication:
	
	ServerInit.input_check_FUNCTION = Instance.new("RemoteFunction")
	ServerInit.input_check_FUNCTION.Name = "input_check_FUNCTION"
	ServerInit.input_check_FUNCTION.Parent = game.ReplicatedStorage
	
	ServerInit.KillsStore = nil
	ServerInit.MoneyStore = nil
	ServerInit.PerksStore = nil
	ServerInit.DonationsStore = nil
	if game.PlaceId ~= 0 then -- project must be published to use DatStores
		DataStoreService = game:GetService("DataStoreService")
		ServerInit.KillsStore = DataStoreService:GetOrderedDataStore("KillsStore")
		ServerInit.MoneyStore = DataStoreService:GetOrderedDataStore("MoneyStore")
		ServerInit.DonationsStore = DataStoreService:GetOrderedDataStore("DonationsStore")
		ServerInit.PerksStore = DataStoreService:GetDataStore("PerksStore") -- ordered datastores are for leaderboard and numeric stuff, everything else can use normal datastores
	end
	
	ServerInit.donationProductIds = { -- must have one of these product ids in order to get on the donations board
		[3415064247] = true,
		[3349676917] = true,
		[3349682499] = true,
		[3349686568] = true,
		[3349688117] = true,
		[3349689893] = true,
		[3350402904] = true,
		[3350445161] = true,
	}
	
	ServerInit.perkProductIds = {
		-- [3382902336] = "Iron Fists",
		-- [3382903295] = "Meat Head",
		-- [3382904079] = "Unbreakable",
		-- [3382905392] = "Cardiosaurus Rex",
		-- [3382906629] = "Full-Auto"
	}
	
	ServerInit.GlobalBindableEvent.Event:Connect(function(protocol, data)
		if protocol == "addProductIdToTable" then
			ServerInit.perkProductIds[data.productId] = data.name
		end
	end)
	
	ModuleLoader.perks.init()
	local perksFolder = game.ReplicatedStorage:WaitForChild("perksFolder")
	
	MarketplaceService.ProcessReceipt = function(receiptInfo) -- Runs when a player presses 'Buy' on a developer product
		local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId) -- receiptInfo is a dictionary of stuff when the buy button is pressed, which includes the playerId of what player purchased.
		
		
		if not player then -- player left before we can do anything with this purchase
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		-- if the script makes it here, then the player is still in the game and we can do stuff in return because of their purchase
		
		if ServerInit.donationProductIds[receiptInfo.ProductId] then
			player.Donations.Value += receiptInfo.CurrencySpent
		elseif ServerInit.perkProductIds[receiptInfo.ProductId] then
			local desiredPerk = perksFolder:FindFirstChild(ServerInit.perkProductIds[receiptInfo.ProductId]):Clone()
			desiredPerk.Parent = player.unequippedPerks
			ServerInit.GlobalRemoteEvent:FireClient(player, "perkPurchased", {perkName = ServerInit.perkProductIds[receiptInfo.ProductId]})
		end
	
		return Enum.ProductPurchaseDecision.PurchaseGranted -- We can now safely close the purchase
	end
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
		while not ModuleLoader.characters:GetCharacterObjectByPlayer(player) do task.wait(0.1) end

		ModuleLoader.perks.applyStatChange(ModuleLoader.characters:GetCharacterObjectByPlayer(player), child, true)
	end)

	unequippedPerks.ChildAdded:Connect(function(child)
		while not ModuleLoader.characters:GetCharacterObjectByPlayer(player) do task.wait(0.1) end

		ModuleLoader.perks.applyStatChange(ModuleLoader.characters:GetCharacterObjectByPlayer(player), child, false)
	end)

	if game.PlaceId == 0 then return warn("Can't access curent-player's saved data as this project is not published.") end

	-- retrieving the player's kills and donations via DataStore:
	local kills_key = "id_" .. player.UserId .. "_kills"
	local money_key = "id_" .. player.UserId .. "_money"
	local perks_key = "id_" .. player.UserId .. "_perks"
	local donations_key = "id_" .. player.UserId .. "_donations"
	
	local success, data = pcall(function()
		return ServerInit.KillsStore:GetAsync(kills_key)
	end)

	if success then
		kills.Value = data or 0
		rewardForKills(player)
	else
		warn(data)
	end

	success = nil

	success, data = pcall(function()
		return ServerInit.DonationsStore:GetAsync(donations_key)
	end)

	if success then
		donations.Value = data or 0
	else
		warn(data)
	end

	success, data = pcall(function()
		return ServerInit.MoneyStore:GetAsync(money_key)
	end)

	if success then
		money.Value = data or 0
	else
		warn(data)
	end

	-- perks data:

	success, data = pcall(function()
		return ServerInit.PerksStore:GetAsync(perks_key)
	end)

	if success then
		if data then
			ModuleLoader.perks.getPerks(data.equippedPerks, player.equippedPerks)
			ModuleLoader.perks.getPerks(data.unequippedPerks, player.unequippedPerks)

			-- make sure the player didnt manage to get more than the max amount of equipped perks:
			if #player.equippedPerks:GetChildren() > ModuleLoader.perks.MaxActivePerks then
				for _, perk in pairs(player.equippedPerks:GetChildren()) do
					perk.Parent = player.unequippedPerks
					if #player.equippedPerks:GetChildren() <= ModuleLoader.perks.MaxActivePerks then
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
		while not ModuleLoader.characters:GetCharacterObjectByPlayer(player) do task.wait(0.1) end
		
		-- applying currently-equipped perks:
		for _, perk in pairs(equippedPerks:GetChildren()) do
			ModuleLoader.perks.applyStatChange(ModuleLoader.characters:GetCharacterObjectByPlayer(player), perk, true)
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
	local ownedPerks = {equippedPerks = ModuleLoader.utilities.TurnInstancesToVariables(player.equippedPerks:GetChildren()), unequippedPerks = ModuleLoader.utilities.TurnInstancesToVariables(player.unequippedPerks:GetChildren())}
	local donations = player.Donations
	
	if player.UserId < 1 then
		ServerInit.DonationsStore:RemoveAsync(donations_key)
		ServerInit.KillsStore:RemoveAsync(kills_key, kills.Value)
		ServerInit.MoneyStore:RemoveAsync(money_key)
		return warn("player ID not valid to save: " .. player.UserId) 
	end

	local success, result = pcall(function()
		return ServerInit.KillsStore:SetAsync(kills_key, kills.Value)
	end)

	if not success then
		warn(result)
	end

	success, result = pcall(function()
		return ServerInit.DonationsStore:SetAsync(donations_key, donations.Value)
	end)

	if not success then
		warn(result)
	end

	success, result = pcall(function()
		return ServerInit.MoneyStore:SetAsync(money_key, money.Value)
	end)

	if not success then
		warn(result)
	end

	success, result = pcall(function()
		return ServerInit.PerksStore:SetAsync(perks_key, ownedPerks)
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