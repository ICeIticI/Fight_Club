local Character_Receive = {}
Character_Receive.__index = Character_Receive

local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)


local function setupTrackData(receivingFromType, attackerAnim) --[[ Because tracks are played on the client, we kinda just have to replicate the attributes of the track when forming the animation here on the server. ]]
    local trackData = {
        receivingFromType = receivingFromType,
        attackerAnim = attackerAnim
        }

    -- if attackLvl == 1 or attackLvl == 2 then
    --     trackData.Counter_Attribute = false
    --     trackData.Paired_Attribute = false
    -- end
    return trackData
end

local function setupReceiveAnimation(characterInstance, receivingFromType, attackerAnim)
    local trackData = setupTrackData(receivingFromType, attackerAnim)
    
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupReceiveAnimation", trackData)
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end
end


local function playReceivingTrack(characterInstance) --[[ After we define an animation track to play in response to an enemy action, this will play said track. ]]
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playReceiveAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end
end

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

function Character_Receive:parry(attacker_characterInstance) --[[ Parry an incoming strike ]]
    local attackerAnim = attacker_characterInstance.currentAttack    
    
    -- if attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --     -- Perform a left parry
    --     warn("ParryL")
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightParryTRACK
    -- elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --     -- Perform a right parry
    --     warn("ParryR")
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftParryTRACK
    -- end
    setupReceiveAnimation(self.characterInstance, "Parry", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.humanoid:TakeDamage(attacker_characterInstance.attackDamage / 2)
    attacker_characterInstance.humanoid:TakeDamage(attacker_characterInstance.attackDamage / 2)
    self.characterInstance.hitSFX:Play()
    -- local Protocol = "Parry"
    -- self.characterInstance.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, Protocol, currentAttack)

    -- self.characterInstance.playHitSFX()

end


-- Non-mitigation (got struck):

function Character_Receive:receiveLevel1(attacker_characterInstance) --[[ Get hit by a level 1 attack such as jabs and hooks ]]
    local attackerAnim = attacker_characterInstance.currentAttack
    
    -- if attackerAnim.AnimationId == self.characterInstance.FC_LeftHook1.AnimationId or attackerAnim.AnimationId == self.characterInstance.FC_LeftJab.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftHook1RECEIVERTRACK
    -- elseif attackerAnim.AnimationId == self.characterInstance.FC_LeftUppercut.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftUppercutRECEIVERTRACK
    
    -- elseif attackerAnim.AnimationId == self.characterInstance.FC_RightHook1.AnimationId or attackerAnim.AnimationId == self.characterInstance.FC_RightJab.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightHook1RECEIVERTRACK
    -- elseif attackerAnim.AnimationId == self.characterInstance.FC_RightUppercut.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightUppercutRECEIVERTRACK
    -- end
    
    -- self.characterInstance.playReceivingTrack()
    setupReceiveAnimation(self.characterInstance, "Level1", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.humanoid:TakeDamage(self.characterInstance.attackDamage)

end

function Character_Receive:receiveLevel2(attacker_characterInstance) --[[ Get hit by a level 2 attack such as haymakers ]]
    local attackerAnim = attacker_characterInstance.currentAttack

    -- if attackerAnim.AnimationId == self.characterInstance.FC_LeftHaymaker.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftHaymakerRECEIVERTRACK
    -- elseif attackerAnim.AnimationId == self.characterInstance.FC_RightHaymaker.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightHaymakerReceiverTRACK
    -- end

    -- self.characterInstance.playReceivingTrack()

    setupReceiveAnimation(self.characterInstance, "Level2", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.humanoid:TakeDamage(self.characterInstance.attackDamage)
end

function Character_Receive:receiveLevel3() --[[ Get hit by a level 3 attack, which essentially are executions ]]
    
end


function Character_Receive:receiveSyncBlock() --[[ Try to attack an enemy but we get blocked in syncronization instead ]]
    
end

function Character_Receive:receiveDodgeAttack() --[[ The enemy dodged away from our strike and caused us to get dodge-attacked ]]
    
end

function Character_Receive:receiveParry(attacker_characterInstance) --[[ We tried to strike the enemy but they parried us ]]
    local attackerAnim = attacker_characterInstance.currentAttack

    -- self.characterInstance.randAttack:Stop()
    -- if attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightParryRECEIVERTRACK
    -- elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftParryRECEIVERTRACK
    -- end
    setupReceiveAnimation(self.characterInstance, "gettingParried", attackerAnim)
    playReceivingTrack(self.characterInstance)
end

function Character_Receive:receiveCounter() --[[ We tried striking the enemy, but they countered us ]]
    
end

return Character_Receive