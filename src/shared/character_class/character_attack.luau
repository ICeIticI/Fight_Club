
local Character_Attack = {}
Character_Attack.__index = Character_Attack

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)


local function getAnimation(characterInstance, trackData, attacker_characterInstance) --[[ Returns a randomly-chosen animation with the given data about what our animation is planned to be (trackData). Level 3 attacks may need the enemy's characterInstance to see what attack they're doing before getting our own ]]
    if trackData.attackLvl == 1 then
        
        if not trackData.attackId  then
            return characterInstance.randomAnimation(AnimationInstances, "AttackSeries", trackData.attackType)
        else
            local sameAttackChance = math.random(1, 100)
            if sameAttackChance > 10 or trackData.attackType == "Uppercuts" then
                for _, v in pairs(AnimationInstances) do
                    if v.AnimationId ~= trackData.attackId and v:GetAttribute("AttackSeries") == trackData.attackType then
                        return v
                        -- warn("Random attack track found.")
                        -- break
                    end
                end
                -- moduleTbl.attackTrack = randomAnimationTrack(moduleTbl.attack1Table, "AttackSeries", trackData.attackType)
                -- print(moduleTbl.attackTrack)
            end
        end
    
    elseif trackData.attackLvl == 2 then

        return characterInstance.randomAnimation(AnimationInstances, "AttackLevel", 2)

    elseif trackData.attackLvl == 3 then

        if not attacker_characterInstance then return warn("You forgot to add the enemy's character instance to this function call") end
        
        if trackData.DodgeAttack_Attribute then

            return characterInstance.randomAnimation(characterInstance.dodgeAttacksTable, "DodgeAttack", true, "AnimDirection", characterInstance.dodgeAnimation:GetAttribute("AnimDirection"))

        elseif trackData.Counter_Attribute then
        
            if attacker_characterInstance.currentAttack:GetAttribute("AnimDirection") == "Left" then
                return characterInstance.randomAnimation(characterInstance.AnimationInstances, "AnimDirection", "Left", "Counter", true)
            elseif attacker_characterInstance.currentAttack:GetAttribute("AnimDirection") == "Right" then
                return characterInstance.randomAnimation(characterInstance.AnimationInstances, "AnimDirection", "Right", "Counter", true)
            end

            return warn("No left or right counterattack track found!") -- If we get to this point, then something went wrong
        
        elseif 
        end

    end
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

local function setRandomAttackType(followupCombo) --[[ Will set the attack type when a new combo starts ]]
    local randNumber
    -- moduleTbl.randAttack = nil
    if followupCombo then
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

    if characterInstance.comboCounter == 0 then -- Randomize attackType for a new combo:
        -- Store the current attackType in characterInstance so it doesn't get forgotten when we attack in the future (for throwing the same type of attack again. If we throw a hook, we wanna followup with another hook):
        characterInstance.attackType = setRandomAttackType(characterInstance.comboCounter)

    end
    -- Whether or not we are starting a new series of attacks (such as jabs, or hooks) or not, we want our attackType to be what's already stored.
    trackData.attackType = characterInstance.attackType
    trackData.Animation = getAnimation(characterInstance, trackData, enemy_characterInstance)

    if attackLvl == 3 then -- beyond the lvl 1's and 2's:

        trackData.Counter_Attribute = characterInstance.isCountering -- When true, we are countering:
        trackData.DodgeAttack_Attribute = characterInstance.isDodging
        -- trackData.Animation = characterInstance.currentAttack

    end
    
    if characterInstance.player then
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

function Character_Attack:syncBlock(attacker_characterInstance, comboCounter) --[[ Attack an enemy holding their block, resulting in a syncronization of clashing attacks & blocks. ]]
    
    if self.characterInstance.pairedChain <= self.characterInstance.PairedChainMAX and self.characterInstance.canSyncBlock then
        
        if comboCounter and comboCounter > 1 then

            if self.characterInstance.pairedAttack and self.characterInstance.pairedAttack.IsPlaying then -- runs for the attacker
                    
                self.characterInstance.pairedAttack:Stop()
                if comboCounter == 3 then

                    -- This should be managed by the enemyInstance so they can have a lvl 3 receive attack of their own custom.
                    print("Enemy you pick your lvl 3 receive sync block!")
                    -- if self.characterInstance.animPair and self.characterInstance.animPair[1] == 1 then
                    --     if self.characterInstance.animPair and self.characterInstance.animPair[2] == 1 then
                    --         self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock3L1TRACK
                    --     elseif self.characterInstance.animPair and self.characterInstance.animPair[2] == 2 then
                    --         self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock3L2TRACK
                    --     end
                    -- elseif self.characterInstance.animPair and self.characterInstance.animPair[1] == 2 then
                    --     if self.characterInstance.animPair and self.characterInstance.animPair[2] == 1 then
                    --         self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock3R1TRACK
                    --     elseif self.characterInstance.animPair and self.characterInstance.animPair[2] == 2 then
                    --         self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock3R2TRACK
                    --     end
                    -- end
                    
                else

                    if self.characterInstance.pairedAttack == self.characterInstance.FC_SyncBlock1LTRACK then
                        self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock1RTRACK
                    elseif self.characterInstance.pairedAttack == self.characterInstance.FC_SyncBlock1RTRACK then
                        self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock1LTRACK
                    elseif self.characterInstance.pairedAttack == self.characterInstance.FC_SyncBlock2LTRACK then
                        self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock2RTRACK
                    elseif self.characterInstance.pairedAttack == self.characterInstance.FC_SyncBlock2RTRACK then
                        self.characterInstance.pairedAttack = self.characterInstance.FC_SyncBlock2LTRACK
                    end
                end
            end

        else -- for non-followup attacks

            if (self.characterInstance.sentAnimPair and self.characterInstance.sentAnimPair[1] == 1) or (ClientVariables.animPair and ClientVariables.animPair[1] == 1) then
				if (self.characterInstance.sentAnimPair and self.characterInstance.sentAnimPair[2] == 1) or (ClientVariables.animPair and ClientVariables.animPair[2] == 1) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock1LTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock1LRECEIVERTRACK
				elseif (self.characterInstance.sentAnimPair and self.characterInstance.sentAnimPair[2] == 2) or (ClientVariables.animPair and ClientVariables.animPair[2] == 2) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock2LTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock2LRECEIVERTRACK
				end
			
			elseif (self.characterInstance.sentAnimPair and self.characterInstance.sentAnimPair[1] == 2) or (ClientVariables.animPair and ClientVariables.animPair[1] == 2) then
				if (self.characterInstance.sentAnimPair and self.characterInstance.sentAnimPair[2] == 1) or (ClientVariables.animPair and ClientVariables.animPair[2] == 1) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock1RTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock1RRECEIVERTRACK
				elseif (self.characterInstance.sentAnimPair and self.characterInstance.sentAnimPair[2] == 2) or (ClientVariables.animPair and ClientVariables.animPair[2] == 2) then
					ClientVariables.pairedAttack = ClientVariables.FC_SyncBlock2RTRACK
					ClientVariables.pairedBlock = ClientVariables.FC_SyncBlock2RRECEIVERTRACK
				end
            end
        end


        self.characterInstance.pairedPlaying = true
        self.characterInstance.SetSpeed(false)
        self.characterInstance.currentAttack = self.characterInstance.pairedAttack.Animation
        if self.characterInstance.distanceBetween ~= 3 then -- we want the sync to happen at three studs ideally
            local enemyRoot = self.characterInstance.raycastResult.Instance.Parent.HumanoidRootPart
            
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

    self.characterInstance.isCountering = true
    attacker_characterInstance.currentReceiveAnimTRACK = nil -- So they don't play their previous animation on accident for the counter receive.
    
    self.characterInstance.repositionInFrontOfEnemy()
    local trackData = setupAttackAnimation(3, self.characterInstance)
    playAttackAnimation(self.characterInstance, trackData)

    print("counter attack")
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
    
    local trackData = setupAttackAnimation(3, self.characterInstance, attacker_characterInstance)

    if trackData.Animation.AnimationId ~= self.characterInstance.FC_LDodgeAttack1.AnimationId then
        self.characterInstance.repositionInFrontOfEnemy() -- We dont reposition for left dodge attack cause it makes it not as cool for some reason
    end
    
    if trackData.Animation.AnimationId == self.characterInstance.FC_LDodgeAttack1.AnimationId then
        
        -- self.characterInstance.setCharacterCFrame(self.characterInstance.character, self.characterInstance.humanoidRootPart.CFrame * CFrame.new(2 , 0, 0))
        self.characterInstance.humanoidRootPart.CFrame = self.characterInstance.humanoidRootPart.CFrame * CFrame.new(2 , 0, 0)
        
        local moveDistanceX = -3
        local moveDistanceZ = -3
        local travelTime = 0.14/0.60
        self.characterInstance:setLinearVelocity(Vector3.new(moveDistanceX/travelTime, 0, moveDistanceZ/travelTime), travelTime)
    
    elseif trackData.Animation.AnimationId == self.characterInstance.FC_RDodgeAttack1.AnimationId then
    
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