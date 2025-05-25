local Character_Receive = {}
Character_Receive.__index = Character_Receive

local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

-- Mitigation methods:

function Character_Receive:bracingBlock(attackerAnim) --[[ Block an enemy attack with a shell guard ]]
    if attackerAnim:GetAttribute("AnimDirection") == "Left" then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_BracingBlockRTRACK
    elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_BracingBlockLTRACK
    end
end

function Character_Receive:syncBlock() --[[ Block an enemy attack in smooth syncronization ]]
    
end

function Character_Receive:dodge() --[[ Dodge away from an incoming strike ]]
    
end

function Character_Receive:parry(attackerAnim) --[[ Parry an incoming strike ]]
    local enemyInstance = Characters:GetCharacterObjectByCharacter(self.characterInstance.hitCharacter)
    
    if attackerAnim:GetAttribute("AnimDirection") == "Left" then
        -- Perform a left parry
        warn("ParryL")
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightParryTRACK
    elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
        -- Perform a right parry
        warn("ParryR")
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftParryTRACK
    end
    self.characterInstance.humanoid:TakeDamage(enemyInstance.attackDamage / 2)
    enemyInstance.humanoid:TakeDamage(enemyInstance.attackDamage / 2)
    self.hitSFX:Play()
    -- local Protocol = "Parry"
    -- self.characterInstance.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, Protocol, currentAttack)

    self.characterInstance.hitSFX:Play()
    -- self.characterInstance.playHitSFX()

end


-- Non-mitigation (got struck):

function Character_Receive:receiveLevel1(attackerAnim) --[[ Get hit by a level 1 attack such as jabs and hooks ]]
    
    if attackerAnim.AnimationId == self.characterInstance.FC_LeftHook1.AnimationId or attackerAnim.AnimationId == self.characterInstance.FC_LeftJab.AnimationId then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftHook1RECEIVERTRACK
    elseif attackerAnim.AnimationId == self.characterInstance.FC_LeftUppercut.AnimationId then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftUppercutRECEIVERTRACK

    elseif attackerAnim.AnimationId == self.characterInstance.FC_RightHook1.AnimationId or attackerAnim.AnimationId == self.characterInstance.FC_RightJab.AnimationId then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightHook1RECEIVERTRACK
    elseif attackerAnim.AnimationId == self.characterInstance.FC_RightUppercut.AnimationId then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightUppercutRECEIVERTRACK
    end

    self.characterInstance.playReceivingTrack()

end

function Character_Receive:receiveLevel2(attackerAnim) --[[ Get hit by a level 2 attack such as haymakers ]]
    
    if attackerAnim.AnimationId == self.characterInstance.FC_LeftHaymaker.AnimationId then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftHaymakerRECEIVERTRACK
    elseif attackerAnim.AnimationId == self.characterInstance.FC_RightHaymaker.AnimationId then
        self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightHaymakerReceiverTRACK
    end

    self.characterInstance.playReceivingTrack()

end

function Character_Receive:receiveLevel3() --[[ Get hit by a level 3 attack, which essentially are executions ]]
    
end


function Character_Receive:receiveSyncBlock() --[[ Try to attack an enemy but we get blocked in syncronization instead ]]
    
end

function Character_Receive:receiveDodgeAttack() --[[ The enemy dodged away from our strike and caused us to get dodge-attacked ]]
    
end

function Character_Receive:receiveParry() --[[ We tried to strike the enemy but they parried us ]]
    
end

function Character_Receive:receiveCounter() --[[ We tried striking the enemy, but they countered us ]]
    
end

return Character_Receive