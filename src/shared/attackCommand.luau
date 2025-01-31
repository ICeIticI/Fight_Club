--[[
Local Script

* This module runs when the character presses attack

* The module is also used to do logical checks before initiating any attack, such as if they're already attacking, or if they're getting
  hit.

]]

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local strike = require(game.ReplicatedStorage.Shared.attacking.strike)


-- Variables:

local attackCooldown = 1 -- Variable that will prevent the player from being to spam punches at an insane speed. The value it equals depends on the attack being currently thrown.
local attackInstance -- will be whatever gets returned from calling a function from strike to return us an attack to use. Should have all the variables needed for this script when it comes to understanding our current attack.
local canAttack = true

local AttackCommand = {}
AttackCommand.__index = AttackCommand

-- local functions:

local function getLevel1Type() -- This local function basically fires when a character is starting a new combo, and need to find the type of lvl 1 attack they will use for the combo (such as jabs, hooks, or uppercuts)
	local randNumber
	local level1Type = nil -- what will be returned. Should equal a string like "Jabs" or "Hooks" as a Level1Type
	GameVariables.randAttack = nil
	if GameVariables.pairedChain then -- players will be possibly able to do uppercuts if they are doing a followup combo from a past combo
		randNumber = math.random(2, 3)
	elseif not GameVariables.pairedChain then
		randNumber = math.random(1, 2) -- on a new combo without a followup, they can do only jabs or hooks on lvl 1's
	end
	-- a random number will be generated from above
	if randNumber == 1 then -- Hooks
	level1Type = "Jabs" -- Will choose randomly between a set of attack types.
	elseif randNumber == 2 then
		level1Type = "Hooks"
	elseif randNumber == 3 then
		level1Type = "Uppercuts"
	end
	return level1Type
end

local function sendAttackStartSignal() -- function used to send the "AttackStarted" protocol to the server and then to the enemy client so a sync block can be performed... in sync.
	GameVariables.animPair = {math.random(1,2), math.random(1,2)} -- first index will determine if its left or right. Second index will tell which specific animation will play, given the direction. Both are randomly selected.
	GameVariables.Protocol = "AttackStarted"
	GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, GameVariables.currentAttack, GameVariables.animPair, GameVariables.pairedChain, nil, false) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
end


-- module methods/functions:

function AttackCommand:Call() --[[ Whenever the player presses attack, this function should be called, which will do all the checks to make sure the player CAN attack, and if they can, then this will call on one of the attacks from the attack modules. ]]
    
    -- Check to make sure the player can attack before calling a module
    GameVariables.followUpCount += 1
	GameVariables.distanceBetween = (GameVariables.raycastResult.Instance.Position - GameVariables.humanoidRootPart.Position).Magnitude
	
	if GameVariables.isEnemyHoldingBlock and GameVariables.pairedChain <= GameVariables.PairedChainMAX then -- For paired attacks. To keep track of the number of times the player does a sync block.
		GameVariables.pairedChain += 1 -- the current chain of attacks in a Sync block. There can be 3 chained sync blocks
		print("paired chain added. Num of times: ".. tostring(GameVariables.pairedChain))
	end
	
	print({GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) , not GameVariables.waitingToAttack , not GameVariables.canFollowUp , not GameVariables.pairedPlaying})
	if GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering, GameVariables.isGettingHit}) and not GameVariables.waitingToAttack and not GameVariables.canFollowUp and not GameVariables.pairedPlaying then -- for the sync block and attack to play simultaneously
		
		if GameVariables.pairedChain <= GameVariables.PairedChainMAX then
			sendAttackStartSignal()
		end			

		if GameVariables.isEnemyHoldingBlock and not GameVariables.isGettingHit then -- Runs for sync blocks. We also want to make sure we aren't already getting hit before performing a sync block.
			print("Sync blocking")
			GameVariables.synchedBlock(nil, GameVariables.pairedChain) -- followupCombo will be nil the first time, as the attack() parameter will be empty, but afterwards it will have value.
		elseif GameVariables.isGettingHit then -- If the player attacked while already getting attacked, we want nothing to happen
			return false
		else
			if GameVariables.comboCounter == 0 then -- If the player hasn't started an attack yet, we will either do jabs or hooks
				GameVariables.randLvl1Type = getLevel1Type()
			end

			if GameVariables.comboCounter <=2 and GameVariables.enemyHumanoid.Health > 10 then -- Will only throw lvl 1 attacks
			
				if not GameVariables.randAttack then -- This will run if the player hasn't started a combo yet
					-- for _, v in pairs(GameVariables.attack1Table) do -- This will get all attacks that are in the given attackSeries and puts them in a table, then randomly selects one of them by index number.
					-- 	if v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
					-- 		table.insert(randAttackTABLE, v)
					-- 	end
					-- end

					GameVariables.randAttack = GameVariables.randomAnimationTrack(GameVariables.attack1Table, "AttackSeries", GameVariables.randLvl1Type)
					
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
				
				-- GameVariables.isAttacking = true
				GameVariables.randAttack:Play()
				GameVariables.lastAttack = GameVariables.randAttack
				GameVariables.comboCounter += 1
			
			elseif GameVariables.comboCounter >= 3 or GameVariables.enemyHumanoid.Health <= 10 then -- Will throw only haymakers
				GameVariables.randAttack = GameVariables.attack2Table[math.random(1, #GameVariables.attack2Table)]

				if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
					GameVariables.lastAttack:Stop()
				end
				
				GameVariables.currentAttack = GameVariables.randAttack.Animation
				-- GameVariables.isAttacking = true
				GameVariables.randAttack:Play()
				GameVariables.lastAttack = GameVariables.randAttack
				GameVariables.comboCounter+=1

			end
		end

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

end

return AttackCommand