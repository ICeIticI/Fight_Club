local Character_Receive = {}
Character_Receive.__index = Character_Receive

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)
-- local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)


local function getDodgeInfo(characterInstance, trackData)
	local frontVector = characterInstance.character.HumanoidRootPart.CFrame.LookVector
    local frontDotProduct = characterInstance.humanoid.MoveDirection:Dot(frontVector)
    local rightVector = characterInstance.character.HumanoidRootPart.CFrame.RightVector -- the right side of where the character's facing
	local rightDotProduct = characterInstance.humanoid.MoveDirection:Dot(rightVector) -- rightDotProduct, like forwardDotProduct, will return a value it compares from the right side of where the character's facing. > 0 is right, < 0 is left.

    -- characterInstance.dodgeTrack = nil -- Will be what animation the player dodges with after some checks
    local distanceToTravel = 0 -- The distance the player will travel when dodging. This will be used to calculate vectorVelocity.
    local animTime = 0 -- The time the dodge animation will play for. Used for calculating vectorVelocity.
    local vectorVelocity = Vector3.zero -- When dodging, we obviously want the player to move, so this will be the moving part of the dodge. Depending on the dodge, this will equal a vector3 value.
    local direction = nil -- Will be set depending on the direction the character is going

    if rightDotProduct > 0 and frontDotProduct > -0.5 then -- character is moving right
        distanceToTravel = 2
        animTime = 0.53
        vectorVelocity = Vector3.new(distanceToTravel / animTime, 0, 0)
        trackData.Animation = AnimationInstances.FC_RightDodge
        direction = "Right"

        -- we will also get dodge attack here to perform less calculations so we dont have to do it in BasicStriking
        -- GameVariables.dodgeAttackTrack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Right", "DodgeAttack", true)
    
    elseif rightDotProduct < 0 and frontDotProduct > -0.5 then -- character is moving left
        distanceToTravel = -2
        animTime = 0.53 
        vectorVelocity = Vector3.new(distanceToTravel / animTime, 0, 0)
        trackData.Animation = AnimationInstances.FC_LeftDodge
        direction = "Left"
        
        -- we will also get dodge attack here to perform less calculations so we dont have to do it in BasicStriking
        -- GameVariables.dodgeAttackTrack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Left", "DodgeAttack", true)
    else
        if frontDotProduct < 0 then -- character is moving backwards
            distanceToTravel = 2
            animTime = 0.23
            vectorVelocity = Vector3.new(0, 0, distanceToTravel / animTime)
            trackData.Animation = AnimationInstances.FC_BackDodge
            direction = "Back"
        end
    end
    
    if not direction then return warn("Failed to find a dodge direction") end

    return {
        direction = direction, 
        animTime = animTime, 
        vectorVelocity = vectorVelocity
    }
    

    -- if characterInstance.dodgeTrack then
    --     characterInstance.setPublicPlayerVariable("iFrames", true)
    --     characterInstance.block(false) -- stop blocking on dodge
    --     characterInstance.dodgeTrack:Play()
    --     characterInstance.setLinearVelocity(trackData.vectorVelocity, trackData.animTime)
    --     characterInstance.SetSpeed(false)
    --     characterInstance.setPublicPlayerVariable("isDodging", true)
        
    --     task.wait(0.4) -- The amount of time the player has iFrames for dodging
    --     characterInstance.setPublicPlayerVariable("iFrames", false)
        
    --     characterInstance.dodgeTrack.Stopped:Wait()

    --     if characterInstance.dodgeTrack.TimePosition >= characterInstance.dodgeTrack.Length then
    --         task.wait(0.2) -- give the dodger a bit of time to do an attack before the dodge ends after doing a successful dodge without getting hit when the dodge animation finishes.
    --     end
    --     characterInstance.setPublicPlayerVariable("isDodging", false) -- any reaon at all the animation stops, they are no longer dodging.
    --     if not characterInstance.isAttacking and not characterInstance.waitingToAttack then
    --         characterInstance.SetSpeed(true)
    --     end
    -- end
end

local function setupTrackData(receivingFromType, attackerAnim) --[[ Because tracks are played on the client, we kinda just have to replicate the attributes of the track when forming the animation here on the server. ]]
    local trackData = {
        receivingFromType = receivingFromType,
        attackerAnim = attackerAnim
        }

    return trackData
end

local function setupReceiveAnimation(characterInstance, receivingFromType, attackerAnim)
    local trackData = setupTrackData(receivingFromType, attackerAnim)

    if characterInstance.isDodging then
        local dodgeInfo = getDodgeInfo(characterInstance, trackData)
        characterInstance.dodgeLength = dodgeInfo.animTime
        characterInstance.dodgeVelocity = dodgeInfo.vectorVelocity

        trackData.IsADodge = true
        trackData.DodgeDirection = dodgeInfo.direction
    end

    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupReceiveAnimation", trackData)
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
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

    self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
end

function Character_Receive:syncBlock() --[[ Block an enemy attack in smooth syncronization ]]
    
end

function Character_Receive:dodge(attacker_characterInstance) --[[ Dodge away from an incoming strike ]]
    
    self.characterInstance.isDodging = true
    
    local attackerAnim = attacker_characterInstance.currentAttack
    
    setupReceiveAnimation(self.characterInstance, "AttackStart", attackerAnim)
    self.characterInstance.iFrames = true
    self.characterInstance:block(false)
    playReceivingTrack(self.characterInstance)
    self.characterInstance:setLinearVelocity(self.dodgeVelocity, self.dodgeLength)
    self.SetSpeed(false)
    self.characterInstance.isDodging = true

    GameVariables.dodgeTrack.Stopped:Wait()

    if GameVariables.dodgeTrack.TimePosition >= GameVariables.dodgeTrack.Length then
        task.wait(0.2) -- give the dodger a bit of time to do an attack before the dodge ends after doing a successful dodge without getting hit when the dodge animation finishes.
    end
    GameVariables.setPublicPlayerVariable("isDodging", false) -- any reaon at all the animation stops, they are no longer dodging.
    if not GameVariables.isAttacking and not GameVariables.waitingToAttack then
        GameVariables.SetSpeed(true)
    end
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
    -- Move the below damage code to the receive parry
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
    local trackData = setupReceiveAnimation(self.characterInstance, "Level1", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
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

    local trackData = setupReceiveAnimation(self.characterInstance, "Level2", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
    self.characterInstance.humanoid:TakeDamage(self.characterInstance.attackDamage)
end

function Character_Receive:receiveLevel3() --[[ Get hit by a level 3 attack, which essentially are executions ]]
    
end


function Character_Receive:receiveSyncBlock() --[[ Try to attack an enemy but we get blocked in syncronization instead ]]
    
    self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
end

function Character_Receive:receiveDodgeAttack(attacker_characterInstance) --[[ The enemy dodged away from our strike and caused us to get dodge-attacked ]]
    local attackerAnim = attacker_characterInstance.currentAttack

    local trackData = setupReceiveAnimation(self.characterInstance, "dodgeAttack", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
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

function Character_Receive:receiveCounter(attacker_characterInstance) --[[ We tried striking the enemy, but they countered us ]]
    local attackerAnim = attacker_characterInstance.currentAttack
    
    local trackData = setupReceiveAnimation(self.characterInstance, "counterAttack", attackerAnim)
    playReceivingTrack(self.characterInstance)
    self.characterInstance.receive_animation_manager:runOnIsPlaying(trackData)
end

return Character_Receive