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
    if GameVariables.comboCounter == 0 then -- If the player hasn't started an attack yet, we will either do jabs or hooks
			local randNumber

            local followupCombo = GameVariables.pairedChain
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
end

function Strike:getLevel2() --[[ Method that will have the character throw a level 2 attack (which will be a heavy strike like a overhand or underhand) ]]
    
end

function Strike:getLevel3() --[[ Method that will cause the character to "finish off" the enemy in a cool syncronized animation ]]
    
end

return Strike