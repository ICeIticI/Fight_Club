--[[

* This script will manage the basic striking of the player when they press attack

* Depending on what attack they've thrown before, they will either do a 
    level 1 attack (light attacks like hooks and jabs), a 
    level 2 attack (heavy attacks like overhands or underhands), or a 
    level 3 attack (a finisher syncronized animation between attacker and enemy).

]]

local Strike = {}
Strike.__index = Strike -- Tell Luau to look in this module for methods not found by default on the instance we're creating (defining our own methods)

function Strike:level1() --[[ Method that will make the character throw a level 1 attack (such as a jab or hook) ]]

end

function Strike:level2() --[[ Method that will have the character throw a level 2 attack (which will be a heavy strike like a overhand or underhand) ]]
    
end

function Strike:level3() --[[ Method that will cause the character to "finish off" the enemy in a cool syncronized animation ]]
    
end

return Strike