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
			GameVariables.animPair = {math.random(1,2), math.random(1,2)} -- first index will determine if its left or right. Second index will tell which specific animation will play, given the direction. Both are randomly selected.
			GameVariables.Protocol = "AttackStarted"
			GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, GameVariables.Protocol, GameVariables.currentAttack, GameVariables.animPair, GameVariables.pairedChain, nil, false) -- Every time the player attacks, it will send to the other player for blocking mechanisms and countering
		end			

	if GameVariables.isEnemyHoldingBlock and not GameVariables.isGettingHit then -- Runs for sync blocks. We also want to make sure we aren't already getting hit before performing a sync block.
	print("Sync blocking")
	GameVariables.synchedBlock(nil, GameVariables.pairedChain) -- followupCombo will be nil the first time, as the attack() parameter will be empty, but afterwards it will have value.
	elseif GameVariables.isGettingHit then -- If the player attacked while already getting attacked, we want nothing to happen
		return false
	else

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