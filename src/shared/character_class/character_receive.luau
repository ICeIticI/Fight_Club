local TweenService = game:GetService("TweenService")
local Character_Receive = {}
Character_Receive.__index = Character_Receive

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)
local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)
local utilities = require(game.ReplicatedStorage.Shared.utilities)


local function getReceiveAnimation(characterInstance, trackData) --[[ Will return the receiver animation that gets played based on what specific attack the enemy did. ]]
    if trackData.type == "Dodge" then

        if trackData.DodgeDirection == "Right" then
            return AnimationInstances.FC_RightDodge
        elseif trackData.DodgeDirection == "Left" then
            return AnimationInstances.FC_LeftDodge
        elseif trackData.DodgeDirection == "Back" then
            return AnimationInstances.FC_BackDodge
        end

    elseif trackData.type == "bracingBlock" then

        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            return AnimationInstances.FC_BracingBlockR
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            return AnimationInstances.FC_BracingBlockL
        end

    elseif trackData.type == "syncBlock" then
        if characterInstance.pairedChain <= characterInstance.PairedChainMAX and characterInstance.canSyncBlock then

            -- if trackData.lastReceiveData and trackData.lastReceiveData.IsPlaying then -- runs for the receiver
                
                -- characterInstance.pairedBlock:Stop()
                if characterInstance.pairedChain == 3 then

                    return characterInstance.pairedReceive
                    
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
                    -- error("Pick your lvl 3 sync block")

                else
                    if trackData.attackerAnim.AnimationId == AnimationInstances.FC_SyncBlock1L.AnimationId then
                        return AnimationInstances.FC_SyncBlock1LRECEIVER
                    elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_SyncBlock1R.AnimationId then
                        return AnimationInstances.FC_SyncBlock1RRECEIVER
                    elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_SyncBlock2L.AnimationId then
                        return AnimationInstances.FC_SyncBlock2LRECEIVER
                    elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_SyncBlock2R.AnimationId then
                        return AnimationInstances.FC_SyncBlock2RRECEIVER
                    end
                end
            -- end

            -- characterInstance.pairedPlaying = true
            -- characterInstance.SetSpeed(false)

            -- if characterInstance.isBlocking then
            --     characterInstance.pairedBlock:Play()
            -- end
        end
    
    elseif trackData.type == "Level1" then

        if trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftHook1.AnimationId or trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftJab.AnimationId then
            return AnimationInstances.FC_LeftHook1RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftUppercut.AnimationId then
            return AnimationInstances.FC_LeftUppercutRECEIVER

        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightHook1.AnimationId or trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightJab.AnimationId then
            return AnimationInstances.FC_RightHook1RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightUppercut.AnimationId then
            return AnimationInstances.FC_RightUppercutRECEIVER
        end
    elseif trackData.type == "Level2" then
        if trackData.attackerAnim.AnimationId == AnimationInstances.FC_LeftHaymaker.AnimationId then
            return AnimationInstances.FC_LeftHaymakerRECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_RightHaymaker.AnimationId then
            return AnimationInstances.FC_RightHaymakerRECEIVER
        end
    elseif trackData.type == "Parry" then
        
        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            -- Perform a left parry
            warn("ParryL")
            return AnimationInstances.FC_RightParry
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            -- Perform a right parry
            warn("ParryR")
            return AnimationInstances.FC_LeftParry
        end
    elseif trackData.type == "gettingParried" then
        -- characterInstance.attackTrack:Stop()
        if trackData.attackerAnim:GetAttribute("AnimDirection") == "Left" then
            return AnimationInstances.FC_LeftParryRECEIVER
        elseif trackData.attackerAnim:GetAttribute("AnimDirection") == "Right" then
            return AnimationInstances.FC_RightParryRECEIVER
        end
    elseif trackData.type == "dodgeAttack" then

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

    elseif trackData.type == "counterAttack" then
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
    elseif trackData.type == "grabAttempt" then
        return AnimationInstances.FC_GrabAttempt1RECEIVER
    elseif trackData.type == "grabSuccess" then
        return AnimationInstances.FC_GrabSuccess1RECEIVER
    elseif trackData.type == "grabSecure" then
        return AnimationInstances.FC_GrabSecure1RECEIVER
    elseif trackData.type == "grabAttack" then

        if trackData.attackerAnim.AnimationId == AnimationInstances.FC_GrabAttack1.AnimationId then
            return AnimationInstances.FC_GrabAttack1RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_GrabAttack2.AnimationId then
            return AnimationInstances.FC_GrabAttack2RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_GrabAttack3.AnimationId then
            return AnimationInstances.FC_GrabAttack3RECEIVER
        end
    
    elseif trackData.type == "repelGrab" then
        return AnimationInstances.FC_EndGrab1RECEIVER
    elseif trackData.type == "grabExecution" then
        
        if trackData.attackerAnim.AnimationId == AnimationInstances.FC_GrabExecute1.AnimationId then
            return AnimationInstances.FC_GrabExecute1RECEIVER
        elseif trackData.attackerAnim.AnimationId == AnimationInstances.FC_GrabExecute2.AnimationId then
            return AnimationInstances.FC_GrabExecute2RECEIVER
        end

    end

    return warn("No receive animation found with the given attacker's animation.")
end

local function getDodgeInfo(characterInstance, trackData)
	-- local frontVector = characterInstance.character.HumanoidRootPart.CFrame.LookVector
    -- local frontDotProduct = characterInstance.humanoid.MoveDirection:Dot(frontVector)
    -- local rightVector = characterInstance.character.HumanoidRootPart.CFrame.RightVector -- the right side of where the character's facing
	-- local rightDotProduct = characterInstance.humanoid.MoveDirection:Dot(rightVector) -- rightDotProduct, like forwardDotProduct, will return a value it compares from the right side of where the character's facing. > 0 is right, < 0 is left.

    -- characterInstance.dodgeTrack = nil -- Will be what animation the player dodges with after some checks
    local distanceToTravel = 0 -- The distance the player will travel when dodging. This will be used to calculate vectorVelocity.
    local animTime = 0 -- The time the dodge animation will play for. Used for calculating vectorVelocity.
    local vectorVelocity = Vector3.zero -- When dodging, we obviously want the player to move, so this will be the moving part of the dodge. Depending on the dodge, this will equal a vector3 value.
    local direction = nil -- Will be set depending on the direction the character is going

    if characterInstance.movingDirection.Value == "right" then -- character is moving right
        distanceToTravel = 2
        animTime = 0.53
        vectorVelocity = Vector3.new(distanceToTravel / animTime, 0, 0)
        trackData.Animation = AnimationInstances.FC_RightDodge
        direction = "Right"

        -- we will also get dodge attack here to perform less calculations so we dont have to do it in BasicStriking
        -- GameVariables.dodgeAttackTrack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Right", "DodgeAttack", true)
    
    elseif characterInstance.movingDirection.Value == "left" then -- character is moving left
        distanceToTravel = -2
        animTime = 0.53 
        vectorVelocity = Vector3.new(distanceToTravel / animTime, 0, 0)
        trackData.Animation = AnimationInstances.FC_LeftDodge
        direction = "Left"
        
        -- we will also get dodge attack here to perform less calculations so we dont have to do it in BasicStriking
        -- GameVariables.dodgeAttackTrack = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Left", "DodgeAttack", true)
    else
        if characterInstance.movingDirection.Value == "backwards" then -- character is moving backwards
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
        type = receivingType,
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
    trackData.AnimationId = trackData.Animation.AnimationId

    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupReceiveAnimation", trackData)
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    -- lock us onto the attacker (if not done already): 
    if not characterInstance.lockOnDebounce.Value then
        local attacker_characterInstance = characters:GetCharacterObjectByCharacter(characterInstance.attackingChar)

        characterInstance.raycastInstance = attacker_characterInstance.character.HumanoidRootPart
        characterInstance.enemyChar = characterInstance.raycastInstance:FindFirstAncestorWhichIsA("Model")
        
        characterInstance.enemyHumanoid = characterInstance.enemyChar:WaitForChild("Humanoid")
        characterInstance.enemyHumanoidRootPart = characterInstance.enemyChar.HumanoidRootPart
        if not characterInstance.lockOnRayParams then characterInstance.lockOnRayParams = utilities.initializeLockOnRayParams(characterInstance) end
        
        characterInstance.lockOnDebounce.Value = true
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
    self.characterInstance.humanoid:TakeDamage(attacker_characterInstance.attackDamage / 2)
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "shakeCamera", {type = "BracingBlock", AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
end

function Character_Receive:syncBlock(attacker_characterInstance) --[[ Block an enemy attack in smooth syncronization ]]
    self.characterInstance.pairedChain += 1

    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "syncBlock", attackerAnim)
    self.characterInstance.pairedAttack = nil -- This gets returned on lvl 3 sync blocks so we dont wanna use old data so we clear it

    self.characterInstance.pairedPlaying = true
    self.characterInstance.SetSpeed(false)

    -- if self.characterInstance.isBlocking then
    --     self.characterInstance.pairedBlock:Play()
    -- end

    playReceivingTrack(self.characterInstance, trackData)

    while trackData.IsPlaying do task.wait() end
    print("are we blocking?: ", self.characterInstance.isBlockBeingPressed)
    self.characterInstance:block(self.characterInstance.isBlockBeingPressed)
end

function Character_Receive:dodge(attacker_characterInstance) --[[ Dodge away from an incoming strike ]]
    
    
    -- Typically attackingChar gets assigned on hitbox collision but this doesnt happen with a dodge.
    self.characterInstance.attackingChar = attacker_characterInstance.character
    -- local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation
    
    -- no need for attackerAnim this time. We dont depend on it for dodges.
    local trackData = setupReceiveAnimation(self.characterInstance, "Dodge", nil)
    self.characterInstance.iFrames = true
    print("block??")
    task.spawn(function()
        self.characterInstance:block(false)
    end)
    print("not blocking")
    playReceivingTrack(self.characterInstance, trackData)
    self.characterInstance:setLinearVelocity(self.characterInstance.dodgeVelocity, self.characterInstance.dodgeLength)
    self.characterInstance.SetSpeed(false)
    self.characterInstance.isDodging = true

    task.wait(0.4)
    self.characterInstance.iFrames = false

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
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "shakeCamera", {type = "Parry", AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
    self.characterInstance.playHitSFX(trackData)
    -- Move the below damage code to the receive parry
    attacker_characterInstance.humanoid:TakeDamage(attacker_characterInstance.attackDamage / 2)
    -- self.characterInstance.hitSFX:Play()
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
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "shakeCamera", {type = trackData.type, AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
    self.characterInstance.playHitSFX(trackData)
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
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "shakeCamera", {type = trackData.type, AnimDirection = trackData.Animation:GetAttribute("AnimDirection")})
    self.characterInstance.playHitSFX(trackData)
end

-- function Character_Receive:receiveLevel3() --[[ Get hit by a level 3 attack, which essentially are executions ]]
    
-- end

function Character_Receive:receiveDodgeAttack(attacker_characterInstance) --[[ The enemy dodged away from our strike and caused us to get dodge-attacked ]]
    local attackerAnim = attacker_characterInstance.currentAttack_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "dodgeAttack", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:receiveParry(attacker_characterInstance) --[[ We tried to strike the enemy but they parried us ]]
    local attackerAnim = attacker_characterInstance.lastReceiveData.Animation

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

    while trackData.IsPlaying do task.wait() end
    attacker_characterInstance.isAttacking.Value = false
end


function Character_Receive:receiveGrabAttempt(attacker_characterInstance) --[[ An enemy is attempting to grab us ]]
    local attackerAnim = attacker_characterInstance.currentGrab_trackData.Animation

    self.characterInstance.isGrappling = true
    self.characterInstance.SetSpeed(false)
    self.characterInstance.attackingChar = attacker_characterInstance.character

    local trackData = setupReceiveAnimation(self.characterInstance, "grabAttempt", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)

    -- Detect next input. If its the attack button in the window of time they can deny a grab, then it will allow them to deny.
    -- If its the block button, then their opportunity is gone. No matter what button they press now, even pressed in the time frame, will mean they will get grapped.
    self.characterInstance.nextInput = nil -- will be set on their next action input
    print(self.characterInstance.character.Name .. " is receiving a grab")
    print(self.characterInstance.nextInput)
    while trackData.IsPlaying do task.wait() end -- wait for the whole grab attempt to end before returning true or false (which means we succeeded or not with tryna grab the enemy)
    
    print(self.characterInstance.character.Name .. " is no longer getting grabbed")
    print(self.characterInstance.nextInput)
    if self.characterInstance.nextInput == "grab" and not self.characterInstance.isBlocking then
        print("grab defend successful")
        return true -- we successfully defended against the grab attempt
    else
        print("failed to defend grab attempt against enemy")
        return false
    end

end

function Character_Receive:repelGrab(attacker_characterInstance) --[[ Either we stopped the enemy from grabbing us or we broke free of a grab success ]]
    local attackerAnim = attacker_characterInstance.currentGrab_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "repelGrab", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)

    while trackData.IsPlaying do task.wait() end

    self.characterInstance.reset()
    attacker_characterInstance.reset()
end

function Character_Receive:receiveGrabExecution(attacker_characterInstance)
    local attackerAnim = attacker_characterInstance.currentGrab_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "grabExecution", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:receiveGrabSuccess(attacker_characterInstance) --[[ The enemy successfully got a hold on us ]]
    local attackerAnim = attacker_characterInstance.currentGrab_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "grabSuccess", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

function Character_Receive:receiveGrabSecure(attacker_characterInstance)
    local attackerAnim = attacker_characterInstance.currentGrab_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "grabSecure", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)

    self.characterInstance.escapeGrappleProgress = 0 -- When this hits 100, the character will escape. For NPCs, this will probably just automatically go up since they don't have input
    self.characterInstance.isInSecureGrapple = true -- when true, the player is given the option to spam the attack button to "break free" of the grab
end

function Character_Receive:receiveGrabAttack(attacker_characterInstance)
    local attackerAnim = attacker_characterInstance.currentGrab_trackData.Animation

    local trackData = setupReceiveAnimation(self.characterInstance, "grabAttack", attackerAnim)
    playReceivingTrack(self.characterInstance, trackData)
end

return Character_Receive