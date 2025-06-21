local Character_Grapple = {}
Character_Grapple.__index = Character_Grapple

function Character_Grapple:Attempt(enemyInstance) --[[ The character goes to attempt to grab an enemy. If this succeeds, then it'll transition to the :Secure() method. ]]
    print("Attempting a grab")
    return true
end

function Character_Grapple:EndGrab(enemyInstance)
    print("Grab ended/failed")
end

function Character_Grapple:Success() --[[ The character attempted to grab the enemy and succeeded. We'll now strike the enemy to transition into :Secure() ]]
    
end

function Character_Grapple:Secure(enemyInstance) --[[ The character attempted to grab the enemy and succeeded. Now they can begin throwing blows and what not at the enemy while grappled on, and the enemy cant do anything about it except try to break free. ]]
    print("grab attempt successful!")
    return false
end

return Character_Grapple