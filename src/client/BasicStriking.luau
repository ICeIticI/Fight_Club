local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local function attack(followupCombo)
	if GameVariables.isEnemyHoldingBlock then
		GameVariables.isAttacking = true
		GameVariables.synchedBlock(nil, followupCombo)
	else
		local randAttackTABLE = {}
		if GameVariables.comboCounter == 0 then
			local randNumber
			GameVariables.randAttack = nil
			if followupCombo == true then -- players will be possibly able to do uppercuts if they are doing a followup combo from a past combo
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
		
		if GameVariables.comboCounter <=2 and GameVariables.enemyHumanoid.Health > 10 then
			
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
			
			if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
				GameVariables.lastAttack:Stop()
			end
			
			GameVariables.currentAttack = GameVariables.randAttack.Animation
			
			GameVariables.isAttacking = true
			GameVariables.randAttack:Play()
			GameVariables.lastAttack = GameVariables.randAttack
			GameVariables.comboCounter += 1
			
		elseif GameVariables.comboCounter >= 3 or GameVariables.enemyHumanoid.Health <= 10 then
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

GameVariables.Sync()

local player = GameVariables.player
local humanoidRootPart = GameVariables.humanoidRootPart
local TestObject = GameVariables.TestObject
print(player)
wait(3)
GameVariables.Set(TestObject, 9)
warn("changed on first client")

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and GameVariables.lockOnDebounce.Value and not GameVariables.waitingToAttack and GameVariables.pairedChain <= 2 and (GameVariables.raycastResult.Instance.Position - humanoidRootPart.Position).Magnitude <= 4.25 then -- atacking
																																				-- This part in simple terms makes sure the player is less or equal to 4 studs from enemy bfore attacking
		--[[ When the player presses attack, we want to randomly choose between a series of hooks or jabs
			 for attack level 1. Once combo counter finishes it's 3rd attack, we will transition to level
			 2 attacks (haymakers).]]

		GameVariables.distanceBetween = (GameVariables.raycastResult.Instance.Position - humanoidRootPart.Position).Magnitude
		GameVariables.followUpCount += 1
		if GameVariables.isEnemyHoldingBlock then
			GameVariables.pairedChain += 1
			print("paired chain added. Num of times: ".. tostring(GameVariables.pairedChain))
		end
		
		if GameVariables.boolCheck(GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isDodging) and not GameVariables.waitingToAttack then
			if GameVariables.pairedChain <= 2 then
				GameVariables.animPair = {math.random(1,2), math.random(1,2)} -- first index will determine if its left or right. Second index will tell which specific animation will play, given the direction. Both are randomly selected.
				GameVariables.Protocol = "AttackStarted"
				GameVariables.GlobalRemoteEvent:FireServer(Players:GetPlayerFromCharacter(GameVariables.enemyChar), GameVariables.Protocol, nil, GameVariables.animPair, GameVariables.pairedChain) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
			end
			print(GameVariables.isAttacking)
			attack()

		elseif GameVariables.canFollowUp == true then -- the player followed up with their attack.
        GameVariables.waitingToAttack = true
			print("waiting on next attack")
			while GameVariables.isAttacking do
				wait()
			end
			if GameVariables.followUpCount == 1 then
				--[[ *NOTE: Uppercuts will ONLY be doable on a follow-up, so I will
				            need to create a unique attack() function to make it
				            a choice.]]
				if GameVariables.pairedChain <= 2 then
					GameVariables.animPair = {math.random(1,2), math.random(1,2)}
					GameVariables.Protocol = "AttackStarted"
					GameVariables.GlobalRemoteEvent:FireServer(Players:GetPlayerFromCharacter(GameVariables.enemyChar), GameVariables.Protocol, nil, GameVariables.animPair, GameVariables.pairedChain) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
				end
				print(GameVariables.isAttacking)
				attack(true) -- true is used for a followup combo, which enables uppercuts.
				GameVariables.waitingToAttack = false
			end
		end
    end
end)