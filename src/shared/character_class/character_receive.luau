local Character_Receive = {}
Character_Receive.__index = Character_Receive

-- Mitigation methods:

function Character_Receive.bracingBlock() --[[ Block an enemy attack with a shell guard ]]
    
end

function Character_Receive.syncBlock() --[[ Block an enemy attack in smooth syncronization ]]
    
end

function Character_Receive.dodge() --[[ Dodge away from an incoming strike ]]
    
end

function Character_Receive.parry() --[[ Parry an incoming strike ]]
    
end


-- Non-mitigation (got struck):

function Character_Receive.receiveLevel1() --[[ Get hit by a level 1 attack such as jabs and hooks ]]
    
end

function Character_Receive.receiveLevel2() --[[ Get hit by a level 2 attack such as haymakers ]]
    
end

function Character_Receive.receiveLevel3() --[[ Get hit by a level 3 attack, which essentially are executions ]]
    
end


function Character_Receive.receiveSyncBlock() --[[ Try to attack an enemy but we get blocked in syncronization instead ]]
    
end

function Character_Receive.receiveDodgeAttack() --[[ The enemy dodged away from our strike and caused us to get dodge-attacked ]]
    
end

function Character_Receive.receiveParry() --[[ We tried to strike the enemy but they parried us ]]
    
end

return Character_Receive