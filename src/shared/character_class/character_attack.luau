
local Character_Attack = {}
Character_Attack.__index = Character_Attack

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local attackType -- When we call an attack function (such as :level1()), we will set this variable to whatever attack that was, such as "level1". This will change with each attack. Then we will set it to nil after detection so it doesn't trip an unwanted attack in the future.

local function getAnimation(characterInstance, trackData, attacker_characterInstance) --[[ Returns a randomly-chosen animation with the given data about what our animation is planned to be (trackData). Level 3 attacks may need the enemy's characterInstance to see what attack they're doing before getting our own ]]
    if trackData.attackLvl == 1 then
        
        if not characterInstance.currentAttack_trackData then
            return characterInstance.randomAnimation(AnimationInstances, {AttackSeries = trackData.attackType})
        else
            local sameAttackChance = math.random(1, 100)
            if sameAttackChance > 10 or characterInstance.currentAttack_trackData.attackType == "Uppercuts" then
                -- opposite attack of the same attack type
                for _, v in pairs(AnimationInstances) do
                    if v.AnimationId ~= characterInstance.currentAttack_trackData.AnimationId and v:GetAttribute("AttackSeries") == characterInstance.currentAttack_trackData.attackType then
                        return v
                        -- warn("Random attack track found.")
                        -- break
                    end
                end
                -- moduleTbl.attackTrack = randomAnimationTrack(moduleTbl.attack1Table, "AttackSeries", trackData.attackType)
                -- print(moduleTbl.attackTrack)
            else
                -- same attack as last time
                return characterInstance.currentAttack_trackData.Animation -- use the previous attack animation because we got the random chance of doing same attack again.
            end
        end
    
    elseif trackData.attackLvl == 2 then

        return characterInstance.randomAnimation(AnimationInstances, {AttackLevel = 2})

    elseif trackData.attackLvl == 3 then

        if not attacker_characterInstance then return warn("You forgot to add the enemy's character instance to this function call") end
        
        
        if attackType == "DodgeAttack" then
            attackType = nil

            return characterInstance.randomAnimation(AnimationInstances, {DodgeAttack = true, AnimDirection = characterInstance.lastReceiveData.Animation:GetAttribute("AnimDirection"), AnimType = 1})

        elseif attackType == "CounterAttack" then
            attackType = nil
            if attacker_characterInstance.currentAttack_trackData.Animation:GetAttribute("AnimDirection") == "Left" then
                return characterInstance.randomAnimation(AnimationInstances, {AnimDirection = "Left", Counter = true})
            elseif attacker_characterInstance.currentAttack_trackData.Animation:GetAttribute("AnimDirection") == "Right" then
                return characterInstance.randomAnimation(AnimationInstances, {AnimDirection = "Right", Counter = true})
            end

            return warn("No left or right counterattack track found!") -- If we get to this point, then something went wrong
        
        elseif attackType == "SyncBlock" then -- For sync blocks, may need to change this in the future when we start using pairedPlaying more.
            attackType = nil

            if (characterInstance.didFollowUp) or (characterInstance.comboCounter and characterInstance.comboCounter > 1) or (characterInstance.lastReceiveData and characterInstance.lastReceiveData.Animation:GetAttribute("SyncBlockFinisher") and characterInstance.lastReceiveData.IsPlaying) then
                -- if characterInstance.pairedAttack and characterInstance.pairedAttack.IsPlaying then -- runs for the attacker
                        
                --     characterInstance.pairedAttack:Stop()
                    if characterInstance.pairedChain == 3 then

                        -- This should be managed by the enemyInstance so they can have a lvl 3 receive attack of their own custom.
                        if attacker_characterInstance.animPair and attacker_characterInstance.animPair[1] == 1 then
                            if attacker_characterInstance.animPair and attacker_characterInstance.animPair[2] == 1 then
                                attacker_characterInstance.pairedReceive = AnimationInstances.FC_SyncBlock3L1RECEIVER
                                return AnimationInstances.FC_SyncBlock3L1

                            elseif attacker_characterInstance.animPair and attacker_characterInstance.animPair[2] == 2 then
                                attacker_characterInstance.pairedReceive = AnimationInstances.FC_SyncBlock3L2RECEIVER
                                return AnimationInstances.FC_SyncBlock3L2
                            end
                        
                            elseif attacker_characterInstance.animPair and attacker_characterInstance.animPair[1] == 2 then
                            
                            if attacker_characterInstance.animPair and attacker_characterInstance.animPair[2] == 1 then
                                attacker_characterInstance.pairedReceive = AnimationInstances.FC_SyncBlock3R1RECEIVER
                                return AnimationInstances.FC_SyncBlock3R1

                            elseif attacker_characterInstance.animPair and attacker_characterInstance.animPair[2] == 2 then
                                attacker_characterInstance.pairedReceive = AnimationInstances.FC_SyncBlock3R2RECEIVER
                                return AnimationInstances.FC_SyncBlock3R2
                            end
                        end



                        print("The enemy will pick their lvl 3 receive sync block.")
                        error("Add a level 3 sync block. Enemy must pick it")
                        
                    else
                        if characterInstance.lastAttackData.Animation.AnimationId == AnimationInstances.FC_SyncBlock1L.AnimationId then
                            return AnimationInstances.FC_SyncBlock1R
                        elseif characterInstance.lastAttackData.Animation.AnimationId == AnimationInstances.FC_SyncBlock1R.AnimationId then
                            return AnimationInstances.FC_SyncBlock1L
                        elseif characterInstance.lastAttackData.Animation.AnimationId == AnimationInstances.FC_SyncBlock2L.AnimationId then
                            return AnimationInstances.FC_SyncBlock2R
                        elseif characterInstance.lastAttackData.Animation.AnimationId == AnimationInstances.FC_SyncBlock2R.AnimationId then
                            return AnimationInstances.FC_SyncBlock2L
                        end
                        return error("No animation found based on last attack track:", characterInstance.lastAttackData)
                    end
                -- end

            else -- for non-followup attacks

                if (characterInstance.animPair and characterInstance.animPair[1] == 1) or (characterInstance.animPair and characterInstance.animPair[1] == 1) then
                    if (characterInstance.animPair and characterInstance.animPair[2] == 1) or (characterInstance.animPair and characterInstance.animPair[2] == 1) then
                        return AnimationInstances.FC_SyncBlock1L
                        -- characterInstance.pairedBlock = AnimationInstances.FC_SyncBlock1LRECEIVER
                    elseif (characterInstance.animPair and characterInstance.animPair[2] == 2) or (characterInstance.animPair and characterInstance.animPair[2] == 2) then
                        return AnimationInstances.FC_SyncBlock2L
                        -- characterInstance.pairedBlock = AnimationInstances.FC_SyncBlock2LRECEIVER
                    end
                
                elseif (characterInstance.animPair and characterInstance.animPair[1] == 2) or (characterInstance.animPair and characterInstance.animPair[1] == 2) then
                    if (characterInstance.animPair and characterInstance.animPair[2] == 1) or (characterInstance.animPair and characterInstance.animPair[2] == 1) then
                        return AnimationInstances.FC_SyncBlock1R
                        -- characterInstance.pairedBlock = AnimationInstances.FC_SyncBlock1RRECEIVER
                    elseif (characterInstance.animPair and characterInstance.animPair[2] == 2) or (characterInstance.animPair and characterInstance.animPair[2] == 2) then
                        return AnimationInstances.FC_SyncBlock2R
                        -- characterInstance.pairedBlock = AnimationInstances.FC_SyncBlock2RRECEIVER
                    end
                end
            end
        end
    end
    
    return warn("^ No Animation found with the given trackData ^")
end

local function setupTrackData(attackLvl) --[[ Because tracks are played on the client, we kinda just have to replicate the attributes of the track when forming the animation here on the server. ]]
    local trackData = {
        attackLvl = attackLvl
        }

    if attackLvl == 1 or attackLvl == 2 then
        trackData.Counter_Attribute = false
        trackData.Paired_Attribute = false
    end
    return trackData
end

local function setRandomAttackType(didFollowUp) --[[ Will set the attack type when a new combo starts ]]
    local randNumber
    -- moduleTbl.randAttack = nil
    if didFollowUp == true then
        randNumber = math.random(2, 3)
    else
        randNumber = math.random(1, 2)
    end

    if randNumber == 1 then
        return "Jabs"
    elseif randNumber == 2 then
        return "Hooks"
    elseif randNumber == 3 then
        return "Uppercuts"
    end
end

local function setupAttackAnimation(attackLvl, characterInstance, enemy_characterInstance : Required_For_Level_3_Attacks) --[[ Will ready an attack animation on the client ]]
    local trackData = setupTrackData(attackLvl)

    if characterInstance.comboCounter == 0 and trackData.attackLvl == 1 then -- Randomize attackType for a new combo:
        -- Store the current attackType in characterInstance so it doesn't get forgotten when we attack in the future (for throwing the same type of attack again. If we throw a hook, we wanna followup with another hook):
        characterInstance.currentAttack_trackData = nil
        characterInstance.attackType = setRandomAttackType(characterInstance.didFollowUp)

    end
    -- Whether or not we are starting a new series of attacks (such as jabs, or hooks) or not, we want our attackType to be what's already stored.
    trackData.attackType = characterInstance.attackType
    trackData.Animation = getAnimation(characterInstance, trackData, enemy_characterInstance)
    trackData.AnimationId = trackData.Animation.AnimationId
    if attackLvl == 3 then -- beyond the lvl 1's and 2's:

        trackData.Counter_Attribute = trackData.Animation:GetAttribute("Counter") -- When true, we are countering:
        trackData.Paired_Attribute = trackData.Animation:GetAttribute("Paired")
        trackData.DodgeAttack_Attribute = trackData.Animation:GetAttribute("DodgeAttack")
        -- trackData.Animation = characterInstance.currentAttack

    end

    characterInstance.currentAttack_trackData = trackData
    characterInstance.attackDamage = characterInstance:setupAttackDamage(trackData)

    if characterInstance.player ~= nil then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupClientAttackAnimation", trackData)
    else
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
end

local function playAttackAnimation(characterInstance, trackData) --[[ Responsible for handling the logic of when an attack ANIMATION starts ]]
    
    -- characterInstance.lastAttackTrackId = characterInstance.

    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playAttackAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    characterInstance.simulateIsPlayingOfLastData(false)
    trackData.IsPlaying = true
    characterInstance.manageAnimation(trackData)
    characterInstance.lastAttackData = trackData
    -- characterInstance.currentAttack_trackData = nil
    
end

-- local attack1_waitTime = 0.45/0.60
-- local attack2_waitTime = 1

function Character_Attack:level1() --[[ Throw a level 1 attack, such as a jab or hook ]]
    
    -- Getting an animation ready on the client to play:
    local trackData = setupAttackAnimation(1, self.characterInstance)

    -- Playing said animation:
    playAttackAnimation(self.characterInstance, trackData)
    -- if self.characterInstance.comboCounter < 1 then -- For debuggin! Delete after!
    self.characterInstance.comboCounter += 1
    -- end

end

function Character_Attack:level2() --[[ Throw a level 2 attack, such as a haymaker ]]
    print("lvl 2 attack")
    local trackData = setupAttackAnimation(2, self.characterInstance)
    playAttackAnimation(self.characterInstance, trackData)
    self.characterInstance.comboCounter += 1
end

function Character_Attack:level3() --[[ Throw a level 3 attack, or in other words, execute the enemy ]]
    print("lvl 3 attack")
end

function Character_Attack:syncBlock(attacker_characterInstance) --[[ Attack an enemy holding their block, resulting in a syncronization of clashing attacks & blocks. ]]
    
    attackType = "SyncBlock"

    if self.characterInstance.pairedChain <= self.characterInstance.PairedChainMAX and self.characterInstance.canSyncBlock then
        self.characterInstance.pairedChain += 1

        self.characterInstance.pairedPlaying = true
        self.characterInstance.SetSpeed(false)
        -- self.characterInstance.currentAttack = self.characterInstance.pairedAttack.Animation
        if self.characterInstance.distanceBetween ~= 3 then -- we want the sync to happen at three studs ideally
            local enemyRoot = self.characterInstance.raycastResult.Instance:FindFirstAncestorWhichIsA("Model").HumanoidRootPart
            
            local direction = enemyRoot.Position - self.characterInstance.humanoidRootPart.Position -- the direction toward the enemy from the player
            local normalizedDirection = direction.Unit -- makes the unit measuring toward the player equal to 1. It is the |absolute value|
            
            local tweenPart = self.characterInstance.character:WaitForChild("HumanoidRootPart")

            local Info = TweenInfo.new(

                0.2,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out,
                0,
                false,
                0

            )

            local tweenGoals = {}
            
            tweenGoals.CFrame = CFrame.new(enemyRoot.Position - normalizedDirection * 3) * CFrame.Angles(self.characterInstance.humanoidRootPart.CFrame:ToOrientation())
                                                                                            -- This above basically makes the player maintain the same orientation.
            local repositionTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
            repositionTween:Play()
        end

        local trackData = setupAttackAnimation(3, self.characterInstance, attacker_characterInstance)
        playAttackAnimation(self.characterInstance, trackData)
    end
end

function Character_Attack:counterAttack(attacker_characterInstance) --[[ Perform a counter attack, turning the enemy's attack against them. ]]
    
    -- NOTE: Damage is dealt as soon as the 'StartOfAttack' marker is reached.
    
    -- local attackerAnim = attacker_characterInstance.currentAttack

    attackType = "CounterAttack"

    self.characterInstance.isCountering = true
    -- attacker_characterInstance.currentReceiveAnimTRACK = nil -- So they don't play their previous animation on accident for the counter receive.
    
    self.characterInstance.repositionInFrontOfEnemy()
    local trackData = setupAttackAnimation(3, self.characterInstance, attacker_characterInstance)
    playAttackAnimation(self.characterInstance, trackData)

    -- if not self.characterInstance.isCountering then
        -- self.characterInstance.randAttack:Stop() -- NOTE: Needs to be done on the client
        
        -- if attackerAnim:GetAttribute("AnimDirection") == "Left" then
        --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.randomAnimationTrack(self.characterInstance.counterAttacksTable, "AnimDirection", "Left", "Counter", true)
        -- elseif attackerAnim:GetAttribute("AnimDirection") == "Right" then
        --     self.characterInstance.currentReceiveAnimTRACK = self.characterInstance.randomAnimationTrack(self.characterInstance.counterAttacksTable, "AnimDirection", "Right", "Counter", true)
        -- end
    -- end
end

function Character_Attack:dodgeAttack(attacker_characterInstance) --[[ Attempt to evade the attack of the enemy, leaving them open. ]]
    
    attackType = "DodgeAttack"

    local trackData = setupAttackAnimation(3, self.characterInstance, attacker_characterInstance)

    -- if trackData.Animation.AnimationId ~= AnimationInstances.FC_LDodgeAttack1.AnimationId then
        self.characterInstance.repositionInFrontOfEnemy() -- We dont reposition for left dodge attack cause it makes it not as cool for some reason
    -- end
    
    if trackData.Animation.AnimationId == AnimationInstances.FC_LDodgeAttack1.AnimationId then
        
        -- self.characterInstance.setCharacterCFrame(self.characterInstance.character, self.characterInstance.humanoidRootPart.CFrame * CFrame.new(2 , 0, 0))
        self.characterInstance.humanoidRootPart.CFrame = self.characterInstance.humanoidRootPart.CFrame * CFrame.new(-2, 0, 0)
        
        local moveDistanceX = -3
        local moveDistanceZ = -3
        local travelTime = 0.14/0.60
        self.characterInstance:setLinearVelocity(Vector3.new(moveDistanceX/travelTime, 0, moveDistanceZ/travelTime), travelTime)
    
    elseif trackData.Animation.AnimationId == AnimationInstances.FC_RDodgeAttack1.AnimationId then
    
        local moveDistance = 2.5
        local travelTime = 0.26/0.60
        self.characterInstance:setLinearVelocity(Vector3.new(moveDistance/travelTime, 0, 0), travelTime)
    end
    

    -- self.characterInstance.dodgeAttackTrack:Play()
    -- self.characterInstance.attackTrack:Play()
    self.characterInstance.waitingToAttack = false
    playAttackAnimation(self.characterInstance, trackData)
    -- -- Make enemy receive the dodge attack:
    -- local reason = "dodgeAttack"
    -- self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, reason, self.characterInstance.attackTrack.Animation)
end

return Character_Attack