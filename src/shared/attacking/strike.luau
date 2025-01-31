--[[

* This script will manage the basic striking of the player when they press attack

* Depending on what attack they've thrown before, they will either do a 
    level 1 attack (light attacks like hooks and jabs), a 
    level 2 attack (heavy attacks like overhands or underhands), or a 
    level 3 attack (a finisher syncronized animation between attacker and enemy).

]]
    
local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local Strike = {}
Strike.__index = Strike -- Tell Luau to look in this module for methods not found by default on the instance we're creating (defining our own methods)

function Strike:getLevel1() --[[ Method that will make the character throw a level 1 attack (such as a jab or hook) ]]
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
	GameVariables.randAttack:Play() -- !!! MAKE SURE THIS FUNCTION RETURNS AN INSTANCE WITH VARIABLES, ANIMATIONS, METHODS, ETC FOR ATTACKCOMMAND to access these 
	GameVariables.lastAttack = GameVariables.randAttack
	GameVariables.comboCounter += 1
end

function Strike:getLevel2() --[[ Method that will have the character throw a level 2 attack (which will be a heavy strike like a overhand or underhand) ]]
    
end

function Strike:getLevel3() --[[ Method that will cause the character to "finish off" the enemy in a cool syncronized animation ]]
    
end

return Strike