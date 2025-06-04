local Character_Receive = {}
Character_Receive.__index = Character_Receive

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)
-- local Characters = require(game.ReplicatedStorage.Shared.server_modules.characters)


local function getReceiveAnimation(characterInstance, trackData) --[[ Will return the receiver animation that gets played based on what specific attack the enemy did. ]]
    if trackData.receivingType == "Dodge" then

        if trackData.DodgeDirection == "Right" then
            return AnimationInstances.FC_RightDodge
        elseif trackData.DodgeDirection == "Left" then
            return AnimationInstances.FC_LeftDodge
        elseif trackData.DodgeDirection == "Back" then
            return AnimationInstances.FC_BackDodge
        end

    elseif trackData.receivingType == "bracingBlock" then

        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            return AnimationInstances.FC_BracingBlockR
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            return AnimationInstances.FC_BracingBlockL
        end

    elseif trackData.receivingType == "syncBlock" then

        if characterInstance.pairedChain <= characterInstance.PairedChainMAX and characterInstance.canSyncBlock then
            if characterInstance.currentReceiveAnimTRACK and characterInstance.currentReceiveAnimTRACK.IsPlaying then -- runs for the receiver
                
                characterInstance.pairedBlock:Stop()
                if characterInstance.followupCombo == 3 then
                    
                    -- if characterInstance.sentAnimPair and characterInstance.sentAnimPair[1] == 1 then
                    --     if characterInstance.sentAnimPair and characterInstance.sentAnimPair[2] == 1 then
                    --         return characterInstance.FC_SyncBlock3L1RECEIVERTRACK
                    --     elseif characterInstance.sentAnimPair and characterInstance.sentAnimPair[2] == 2 then
                    --         return characterInstance.FC_SyncBlock3L2RECEIVERTRACK
                    --     end
                    
                    -- elseif characterInstance.sentAnimPair and characterInstance.sentAnimPair[1] == 2 then
                        
                    --     if characterInstance.sentAnimPair and characterInstance.sentAnimPair[2] == 1 then
                    --         return characterInstance.FC_SyncBlock3R1RECEIVERTRACK
                    --     elseif characterInstance.sentAnimPair and characterInstance.sentAnimPair[2] == 2 then
                    --         return characterInstance.FC_SyncBlock3R2RECEIVERTRACK
                    --     end
                    -- end
                    print("You pick your lvl 3 receive sync block!")
                    error("Add a level 3 sync block. This char instance must pick it")

                else

                    if characterInstance.pairedBlock == AnimationInstances.FC_SyncBlock1LRECEIVERTRACK then
                        return AnimationInstances.FC_SyncBlock1RRECEIVERTRACK
                    elseif characterInstance.pairedBlock == AnimationInstances.FC_SyncBlock1RRECEIVERTRACK then
                        return AnimationInstances.FC_SyncBlock1LRECEIVERTRACK
                    elseif characterInstance.pairedBlock == AnimationInstances.FC_SyncBlock2LRECEIVERTRACK then
                        return AnimationInstances.FC_SyncBlock2RRECEIVERTRACK
                    elseif characterInstance.pairedBlock == AnimationInstances.FC_SyncBlock2RRECEIVERTRACK then
                        return AnimationInstances.FC_SyncBlock2LRECEIVERTRACK
                    end
                end
            end

            characterInstance.pairedPlaying = true
            characterInstance.SetSpeed(false)

            if characterInstance.isBlocking then
                characterInstance.pairedBlock:Play()
            end
        end
    
    elseif trackData.receivingType == "Level1" then

        if trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftHook1.AnimationId or trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftJab.AnimationId then
            return AnimationInstances.FC_LeftHook1RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftUppercut.AnimationId then
            return AnimationInstances.FC_LeftUppercutRECEIVER

        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightHook1.AnimationId or trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightJab.AnimationId then
            return AnimationInstances.FC_RightHook1RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightUppercut.AnimationId then
            return AnimationInstances.FC_RightUppercutRECEIVER
        end
    elseif trackData.receivingType == "Level2" then
        print(trackData.attackerAnim)
        if trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftHaymaker.AnimationId then
            return AnimationInstances.FC_LeftHaymakerRECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightHaymaker.AnimationId then
            return AnimationInstances.FC_RightHaymakerRECEIVER
        end
    elseif trackData.receivingType == "Parry" then
        
        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            -- Perform a left parry
            warn("ParryL")
            return AnimationInstances.FC_RightParry
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            -- Perform a right parry
            warn("ParryR")
            return AnimationInstances.FC_LeftParry
        end
    elseif trackData.receivingType == "gettingParried" then
        characterInstance.attackTrack:Stop()
        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            return AnimationInstances.FC_RightParryRECEIVER
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            return AnimationInstances.FC_LeftParryRECEIVER
        end
    elseif trackData.receivingType == "dodgeAttack" then

        -- We will get dodge-attacked
            
        if characterInstance.attackTrack then -- stop any attack that's playing
            characterInstance.attackTrack:Stop() 
        end
        
        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            return AnimationInstances.FC_LDodgeAttack1RECEIVER
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            return AnimationInstances.FC_RDodgeAttack1RECEIVER
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Back" then
            return AnimationInstances.FC_BDodgeAttack1RECEIVER
        end

    elseif trackData.receivingType == "counterAttack" then
        -- We are gonna get countered
            
        -- GameVariables.repositionInFrontOfEnemy()
        if characterInstance.attackTrack and characterInstance.attackTrack.IsPlaying then
            characterInstance.attackTrack:Stop() -- stop an attack if its playing
        end

        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            if trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftCounter1.AnimationId then
                return AnimationInstances.FC_LeftCounter1RECEIVER

            elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftCounter2.AnimationId then
                return AnimationInstances.FC_LeftCounter2RECEIVER
            end
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            if trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightCounter1.AnimationId then
                return AnimationInstances.FC_RightCounter1RECEIVER

            elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightCounter2.AnimationId then
                return AnimationInstances.FC_RightCounter2RECEIVER
            end
        end
    end

    return warn("No receive animation found with the given attacker's animation.")
end

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

local function setupTrackData(receivingType, attackerAnim) --[[ Because tracks are played on the client, we kinda just have to replicate the attributes of the track when forming the animation here on the server. ]]
    local trackData = {
        receivingType = receivingType,
        attackerAnim = attackerAnim
        }

    return trackData
end

local function setupReceiveAnimation(characterInstance, receivingType, attackerAnim)
    local trackData = setupTrackData(receivingType, attackerAnim)

    if receivingType == "Dodge" then
        local dodgeInfo = getDodgeInfo(characterInstance, trackData)

        characterInstance.dodgeLength = dodgeInfo.animTime
        characterInstance.dodgeVelocity = dodgeInfo.vectorVelocity

        trackData.IsADodge = true
        trackData.DodgeDirection = dodgeInfo.direction
    end
    
    trackData.Animation = getReceiveAnimation(characterInstance, trackData)
    print(trackData.receivingType)
    trackData.AnimationId = trackData.Animation.AnimationId

    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupReceiveAnimation", trackData)
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
end


local function playReceivingTrack(characterInstance, trackData) --[[ After we define an animation track to play in response to an enemy action, this will play said track. ]]
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playReceiveAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    characterInstance.simulateIsPlayingOfLastData(false)
    trackData.IsPlaying = true
    characterInstance.manageAnimation(trackData)
    characterInstance.lastReceiveData = trackData

end

-- Mitigation methods:

function Character_Receive:bracingBlock(attacker_characterInstance) --[[ Block an enemy attack with a shell guard ]]
    
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "bracingBlock", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:syncBlock(attacker_characterInstance) --[[ Block an enemy attack in smooth syncronization ]]

    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "syncBlock", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:dodge(attacker_characterInstance) --[[ Dodge away from an incoming strike ]]
    
    
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation
    
    local trackData = setupReceiveAnimation(self.characterInstance, "Dodge", attackerAnim)
    self.characterInstance.iFrames = true
    self.characterInstance:block(false)
    playReceivingTrack(self.characterInstance, trackData)
    self.characterInstance:setLinearVelocity(self.dodgeVelocity, self.dodgeLength)
    self.SetSpeed(false)
    self.characterInstance.isDodging = true

end

function Character_Receive:parry(attacker_characterInstance) --[[ Parry an incoming strike ]]
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation    
    
    -- if attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --     -- Perform a left parry
    --     warn("ParryL")
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightParryTRACK
    -- elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --     -- Perform a right parry
    --     warn("ParryR")
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftParryTRACK
    -- end
    local trackData = setupReceiveAnimation(self.characterInstance, "Parry", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
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
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation
    
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
    playReceivingTrack(self.characterInstance, trackData)
    self.characterInstance.humanoid:TakeDamage(attacker_characterInstance.attackDamage)

end

function Character_Receive:receiveLevel2(attacker_characterInstance) --[[ Get hit by a level 2 attack such as haymakers ]]
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    -- if attackerAnim.AnimationId == self.characterInstance.FC_LeftHaymaker.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftHaymakerRECEIVERTRACK
    -- elseif attackerAnim.AnimationId == self.characterInstance.FC_RightHaymaker.AnimationId then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightHaymakerReceiverTRACK
    -- end

    -- self.characterInstance.playReceivingTrack()

    local trackData = setupReceiveAnimation(self.characterInstance, "Level2", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
    self.characterInstance.humanoid:TakeDamage(attacker_characterInstance.attackDamage)
end

function Character_Receive:receiveLevel3() --[[ Get hit by a level 3 attack, which essentially are executions ]]
    
end

function Character_Receive:receiveDodgeAttack(attacker_characterInstance) --[[ The enemy dodged away from our strike and caused us to get dodge-attacked ]]
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "dodgeAttack", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:receiveParry(attacker_characterInstance) --[[ We tried to strike the enemy but they parried us ]]
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    -- self.characterInstance.randAttack:Stop()
    -- if attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_RightParryRECEIVERTRACK
    -- elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.FC_LeftParryRECEIVERTRACK
    -- end
    local trackData = setupReceiveAnimation(self.characterInstance, "gettingParried", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:receiveCounter(attacker_characterInstance) --[[ We tried striking the enemy, but they countered us ]]
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation
    
    local trackData = setupReceiveAnimation(self.characterInstance, "counterAttack", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

return Character_Receive