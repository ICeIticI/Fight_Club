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



-- Local functions:

local function getLvl1InCombo() -- Local function that runs when the character attacks while in a combo when doing level 1 attacks, which will cause the next attack to be MOST LIKELY the opposite attack, but theres a small chance its the same attack. HOWEVER the Attack Series that the character is using will be the same
	for _, v in pairs(GameVariables.attack1Table) do
		if v ~= GameVariables.randAttack and v.Animation:GetAttribute("AttackSeries") == GameVariables.randLvl1Type then
			return v
		end
	end
end


-- Module methods/functions:

function Strike:getLevel1() --[[ Method that will make the character throw a level 1 attack (such as a jab or hook) ]]
    
	local attackInstance = {}
	attackInstance.__index = attackInstance
	
	if not GameVariables.randAttack then -- This will run if the player hasn't started a combo yet

		GameVariables.randAttack = GameVariables.randomAnimationTrack(GameVariables.attack1Table, "AttackSeries", GameVariables.randLvl1Type)
		
	else -- The player has thrown an attack before.
		
		local sameAttackChance = math.random(1,100)
		if sameAttackChance > 10 or GameVariables.lastAttack.Animation:GetAttribute("AttackSeries") == "Uppercuts" then
			GameVariables.randAttack = getLvl1InCombo()
		end
	end

	if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
		GameVariables.lastAttack:Stop()
	end

	GameVariables.currentAttack = GameVariables.randAttack.Animation

	
	-- attackInstance.AnimationTrack = GameVariables.randAttack -- attackInstance variables so attacKCommand can access them
	-- attackInstance.Animation = GameVariables.currentAttack

	
	function attackInstance.Attack() --[[ Remember that Strike:get{level} returns an instance, so here we're just defining functions for that instance, which is attackInstance, a nested instance similar to this module. ]]
		
		GameVariables.randAttack:Play()
		GameVariables.lastAttack = GameVariables.randAttack
		GameVariables.comboCounter += 1
		print(GameVariables.comboCounter)
	end

	return attackInstance
	
end

function Strike:getLevel2() --[[ Method that will have the character throw a level 2 attack (which will be a heavy strike like a overhand or underhand) ]]
    
	local attackInstance = {}
	attackInstance.__index = attackInstance

	if GameVariables.lastAttack and GameVariables.lastAttack.IsPlaying and not GameVariables.isAttacking then
		GameVariables.lastAttack:Stop()
	end
	
	GameVariables.randAttack = GameVariables.attack2Table[math.random(1, #GameVariables.attack2Table)]
	GameVariables.currentAttack = GameVariables.randAttack.Animation

	function attackInstance.Attack() --[[ Remember that Strike:get{level} returns an instance, so here we're just defining functions for that instance, which is attackInstance, a nested instance similar to this module. ]]
		
		GameVariables.randAttack:Play()
		GameVariables.lastAttack = GameVariables.randAttack
		GameVariables.comboCounter += 1
	end

	return attackInstance

end

function Strike:getLevel3() --[[ Method that will cause the character to "finish off" the enemy in a cool syncronized animation ]]
    
end

return Strike