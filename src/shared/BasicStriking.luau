
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)
wait()
-- local UserInputService = game:GetService("UserInputService")
-- local Players = game:GetService("Players")

print(GameVariables)

local BasicStriking = {}

-- GameVariables.SetPlayer(Players.LocalPlayer)

local function attack(followupCombo) -- the local attack function. This is responsible for the mechanics of the attack.

	if GameVariables.isEnemyHoldingBlock and not GameVariables.isGettingHit then -- Runs for sync blocks. We also want to make sure we aren't already getting hit before performing a sync block.
		GameVariables.isAttacking = true
		print(GameVariables)
		GameVariables.synchedBlock(nil, followupCombo) -- followupCombo will be nil the first time, as the attack() parameter will be empty, but afterwards it will have value.
		warn("Sync attack thrown")
	elseif GameVariables.isGettingHit then -- If the player attacked while already getting attacked, we want nothing to happen
		return false
	else
		local randAttackTABLE = {}

		if GameVariables.comboCounter == 0 then
			local randNumber
			GameVariables.randAttack = nil
			if followupCombo then -- players will be possibly able to do uppercuts if they are doing a followup combo from a past combo
				randNumber = math.random(2, 3)
			elseif not followupCombo then
				randNumber = math.random(1, 2) -- on a new combo without a followup, they can do only jabs or hooks on lvl 1's
			end
			-- a random number will be generated from above
			if randNumber == 1 then -- Hooks
			GameVariables.randLvl1Type = "Jabs" -- Will choose randomly between a set of attack types.
			elseif randNumber == 2 then
				GameVariables.randLvl1Type = "Hooks"
			elseif randNumber == 3 then
				GameVariables.randLvl1Type = "Uppercuts"
			end
		end
		
		if GameVariables.comboCounter <=2 and GameVariables.enemyHumanoid.Health > 10 then -- Will only throw lvl 1 attacks
			
			if not GameVariables.randAttack then -- This will run if the player hasn't started a combo yet
				for _, v in pairs(GameVariables.attack1Table) do -- This will get all attacks that are in the given attackSeries and puts them in a table, then randomly selects one of them by index number.
					if v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
						table.insert(randAttackTABLE, v)
					end
				end
				GameVariables.randAttack = randAttackTABLE[math.random(1,#randAttackTABLE)]
				
			else -- The player has thrown an attack before.
				
				local sameAttackChance = math.random(1,100)
				if sameAttackChance > 10 or GameVariables.lastAttack.Animation:GetAttribute("AttackSeries") == "Uppercuts" then
					for _, v in pairs(GameVariables.attack1Table) do
						if v ~= GameVariables.randAttack and v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
							GameVariables.randAttack = v
							break
						end
					end
				end
			end
			-- warn(true)
			if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
				GameVariables.lastAttack:Stop()
			end
			
			GameVariables.currentAttack = GameVariables.randAttack.Animation
			
			GameVariables.isAttacking = true
			GameVariables.randAttack:Play()
			GameVariables.lastAttack = GameVariables.randAttack
			GameVariables.comboCounter += 1
			
		elseif GameVariables.comboCounter >= 3 or GameVariables.enemyHumanoid.Health <= 10 then -- Will throw only haymakers
			GameVariables.randAttack = GameVariables.attack2Table[math.random(1, #GameVariables.attack2Table)]

			if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
				GameVariables.lastAttack:Stop()
			end
			
			GameVariables.currentAttack = GameVariables.randAttack.Animation
			GameVariables.isAttacking = true
			GameVariables.randAttack:Play()
			GameVariables.lastAttack = GameVariables.randAttack
			GameVariables.comboCounter+=1

		end
	end
end

function BasicStriking.manageHitboxes() -- Manages the attack hitboxes of the player's character. When the player is attacking and they hit an enemy, then we would send a remote event to the server if it's a player. Otherwise we would send a bindable event to the local script controlling the npc.
	
	wait() -- We can probably find a more 'professional' way of waiting for the character to load completely before running these functions.
	for _, v in pairs(GameVariables.hitboxesFolderATTACK) do --[[Creates :Connect events for each element in the 
										hitboxesFolderATTACK folder.]]		
		local touchedConnection = v.Touched:Connect(function(touchedObject)

			--[[
			if touchedObject:GetAttribute("ReceiveBox") and GameVariables.comboCounter >= 3 then
				print(GameVariables.isAttacking)
				print(GameVariables.hitDebounce)
			end
			]]
			
			-- warn(touchedObject)
			if GameVariables.isAttacking and not GameVariables.hitDebounce and touchedObject:GetAttribute("ReceiveBox") and touchedObject.Parent.Parent:FindFirstChild("Humanoid") and GameVariables.currentAttack then
				GameVariables.hitDebounce = true
				
				local enemyCharacter = touchedObject.Parent.Parent
				local enemyPlayer = game.Players:GetPlayerFromCharacter(enemyCharacter)

				-- for _, v in pairs(enemyCharacter.Humanoid.charAnimator:GetPlayingAnimationTracks()) do
				-- 	if v.Animation.AnimationId == "rbxassetid://18266066281" or v.Animation.AnimationId == "rbxassetid://16976697757" then
				-- 		GameVariables.isEnemyHoldingBlock = true
				-- 	end
				-- end
				warn(tostring(GameVariables.FC_RightCounter1:GetAttribute("AttackLevel")) .. " " .. tostring(GameVariables.currentAttack:GetAttribute("AttackLevel")))
				if GameVariables.currentAttack:GetAttribute("AttackLevel") == 1 then
					print("CONDITIOBN MET")
					GameVariables.Protocol = "Hook" -- Protocol is used to determine what function in the server to perform when a RemoteEvent is used. A "Hook" Protocol will do more damage than a "Jab" Protocol for example.
				elseif GameVariables.currentAttack:GetAttribute("AttackLevel") == 2 then
					GameVariables.Protocol = "Haymaker"
				elseif GameVariables.currentAttack:GetAttribute("Paired") and not GameVariables.currentAttack:GetAttribute("Finisher") and not GameVariables.currentAttack:GetAttribute("Counter") then -- if its paired and not a finisher or counter, then it must be a synced block.
					GameVariables.Protocol = "SyncedBlock"
				elseif GameVariables.currentAttack:GetAttribute("Paired") and GameVariables.currentAttack:GetAttribute("Counter") then
					GameVariables.Protocol = "CounterAttack"
					print("this condition for counterattack has been met.")
				end
				
				if not GameVariables.attackFrames then
					repeat
						wait()
					until GameVariables.attackFrames or not GameVariables.isAttacking
				end
				if enemyPlayer and GameVariables.isAttacking then
					warn(GameVariables.Protocol)
					GameVariables.GlobalRemoteEvent:FireServer(enemyCharacter, GameVariables.Protocol, GameVariables.currentAttack, nil, nil, GameVariables.isEnemyHoldingBlock, false) -- Deal damage to other client.
				end
			end
		end)
		GameVariables.humanoid.Died:Connect(function()
			touchedConnection:Disconnect()
			print("disconnecting connection")
		end)
	end
end

-- hitboxManager()

-- GameVariables.player.CharacterAdded:Connect(function()
-- 	hitboxManager()
-- end)

function BasicStriking.Attack(input) --[[ this will run through a series of checks as well as running the local function attack() within the script. ]]

	-- UserInputService.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 and GameVariables.lockOnDebounce.Value and GameVariables.player.Name == "Player2" then -- for testing
			warn("2 seconds till attack...")
			wait(2) -- FOR TESTING BRACING BLOCKS, COUNTERS AND PARRYS. DELETE WHEN DONE!!!
		end


		if input.UserInputType == Enum.UserInputType.MouseButton1
		and GameVariables.lockOnDebounce.Value -- the player is locked on
		and not GameVariables.waitingToAttack -- the player is not already waiting to attack
		and GameVariables.pairedChain <= GameVariables.PairedChainMAX -- their current chain of attacks isnt more than the max (3)
		and GameVariables.boolCheck({nil, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) -- makes sure they arent attacking, blocking, or dodging
		and (GameVariables.raycastResult.Instance.Position - GameVariables.humanoidRootPart.Position).Magnitude <= 4.25 then -- atacking
																																																																								-- This part in simple terms makes sure the player is less or equal to 4 studs from enemy bfore attacking
			--[[ When the player presses attack, we want to randomly choose between a series of hooks or jabs
				for attack level 1. Once combo counter finishes it's 3rd attack, we will transition to level
				2 attacks (haymakers).]]

			
			
			GameVariables.followUpCount += 1
			GameVariables.distanceBetween = (GameVariables.raycastResult.Instance.Position - GameVariables.humanoidRootPart.Position).Magnitude
			
			if GameVariables.isEnemyHoldingBlock and GameVariables.pairedChain <= GameVariables.PairedChainMAX then -- For paired attacks. To keep track of the number of times the player does a sync block.
				GameVariables.pairedChain += 1 -- the current chain of attacks in a Sync block. There can be 3 chained sync blocks
				print("paired chain added. Num of times: ".. tostring(GameVariables.pairedChain))
			end
			
			if GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) and not GameVariables.waitingToAttack and not GameVariables.canFollowUp and not GameVariables.pairedPlaying then -- for the sync block and attack to play simultaneously
				if GameVariables.pairedChain <= GameVariables.PairedChainMAX then
					GameVariables.animPair = {math.random(1,2), math.random(1,2)} -- first index will determine if its left or right. Second index will tell which specific animation will play, given the direction. Both are randomly selected.
					GameVariables.Protocol = "AttackStarted"
					GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, nil, GameVariables.animPair, GameVariables.pairedChain, nil, false) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
				end			

				attack()
			elseif GameVariables.canFollowUp == true then -- the player followed up with their attack.
			GameVariables.waitingToAttack = true
				while GameVariables.isAttacking do
					wait()
				end
				if GameVariables.followUpCount > 1 then -- For followup attacks

					if GameVariables.pairedChain <= GameVariables.PairedChainMAX then
						GameVariables.animPair = {math.random(1,2), math.random(1,2)}
						GameVariables.Protocol = "AttackStarted"
						GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, nil, GameVariables.animPair, GameVariables.pairedChain, false) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
					end

					attack(GameVariables.pairedChain) -- pairedChain is used for a followup combo, which enables uppercuts.
				end
				GameVariables.waitingToAttack = false
			end
		-- elseif input.KeyCode == Enum.KeyCode.T then -- for debugging why animations wont work on respawn -- ITS NOT THE ANIMATIONS THAT ISNT WORKING...
		-- 	GameVariables.FC_LeftHook1TRACK:Play()
		end

		-- for printing:
		if GameVariables.raycastResult and input.UserInputType == Enum.UserInputType.MouseButton1 then
			local debuggingAttackTable = {
				GameVariables.lockOnDebounce.Value, -- should be true
				GameVariables.waitingToAttack, -- should be false
				GameVariables.canFollowUp, -- at first it should be false, on followup it should be true
				GameVariables.pairedPlaying, -- false at first
				GameVariables.pairedChain, -- less than 3
				GameVariables.followUpCount, -- less than 1 at first
				GameVariables.comboCounter, -- should be 0 at first
				GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}),
				GameVariables.isAttacking,
				GameVariables.isBlocking,
				GameVariables.isCountering,
				GameVariables.isGettingHit,
			(GameVariables.raycastResult.Instance.Position - GameVariables.humanoidRootPart.Position).Magnitude
			} -- alot of the time it wont allow the player to attack no matter what, so this table will print when the player can't attack at all.
			-- if GameVariables.lockOnDebounce.Value ~= true then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if GameVariables.waitingToAttack ~= false then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if (GameVariables.canFollowUp ~= false and GameVariables.followUpCount < 1) or (GameVariables.canFollowUp ~= true and GameVariables.followUpCount >= 1) then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if (GameVariables.pairedPlaying ~= false and GameVariables.followUpCount < 1) or (GameVariables.canFollowUp ~= true and GameVariables.followUpCount >= 1) then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if GameVariables.pairedChain >= 3 then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if GameVariables.followUpCount < 1 then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if GameVariables.comboCounter ~= 0 then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			-- if GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) ~= true then
			-- 	table.insert(debuggingAttackTable, GameVariables.lockOnDebounce.Value)
			-- end
			
			print("variables for attacking:")
			print(debuggingAttackTable)
		end
	-- end)
end

return BasicStriking