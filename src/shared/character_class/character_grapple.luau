local Character_Grapple = {}
Character_Grapple.__index = Character_Grapple

function Character_Grapple:Attempt(enemyInstance) --[[ The character goes to attempt to grab an enemy. If this succeeds, then it'll transition to the :Secure() method. ]]
    
end

function Character_Grapple:EndGrab(enemyInstance)
    
end

function Character_Grapple:Secure(enemyInstance) --[[ The character attempted to grab the enemy and succeeded. Now they can begin throwing blows and what not at the enemy while grappled on, and the enemy cant do anything about it except try to break free. ]]
    
end

return Character_Grapple