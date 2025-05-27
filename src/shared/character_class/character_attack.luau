
local Character_Attack = {}
Character_Attack.__index = Character_Attack

local function randomAnimation(animFolder, attribute1, a1Value, attribute2, a2Value) --[[ Will return a randomly-picked animation from a given table. You can put in attributes to filter what kind of animation you want.]]

    	local randAttackTbl = {}

	for _, v in pairs(animFolder) do
		if
		(
			attribute1 == nil 
			or (a1Value ~= nil 
			and v:GetAttribute(attribute1) == a1Value) 
			or (v:GetAttribute(attribute1) 
			and a1Value == nil)) 
			and 
			(attribute2 == nil 
			or (a2Value ~= nil 
			and v:GetAttribute(attribute2) == a2Value) 
			or (v:GetAttribute(attribute2) 
			and a2Value == nil)
		) 

		then
			table.insert(randAttackTbl, v)
		end
	end

    if not next(randAttackTbl) then -- No matches were found with the specified attributes
        return warn("No animation tracks found with the specified parameters, and therefore no animation was randomly picked. Check your given attributes to see if your desired animations have them.")
    end


	return randAttackTbl[math.random(1, #randAttackTbl)] -- returns the randomly-selected animation track

end

local function getAnimationId(characterInstance, trackData, attacker_characterInstance) --[[ Returns a randomly-chosen animation with the given data about what our animation is planned to be (trackData). Level 3 attacks may need the enemy's characterInstance to see what attack they're doing before getting our own ]]
    if trackData.attackLvl == 1 then
        
        if not trackData.attackId  then
            return randomAnimation(characterInstance.plrObjectsFolder:GetChildren(), "AttackSeries", trackData.attackType).AnimationId
        else
            local sameAttackChance = math.random(1, 100)
            if sameAttackChance > 10 or trackData.attackType == "Uppercuts" then
                for _, v in pairs(characterInstance.plrObjectsFolder:GetChildren()) do
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

        return randomAnimation(characterInstance.plrObjectsFolder, "AttackLevel", 2).AnimationId

    elseif trackData.attackLvl == 3 then

        if not attacker_characterInstance then return warn("You forgot to add the enemy's character instance to this function call") end
        

        if trackData.Counter_Attribute then
            characterInstance.randAttack:Stop() -- NOTE: Needs to be done on the client
        
            if attacker_characterInstance.currentAttack:GetAttribute("AnimDirection") == "Left" then
                return randomAnimation(characterInstance.plrObjectsFolder, "AnimDirection", "Left", "Counter", true).AnimationId
            elseif attacker_characterInstance.currentAttack:GetAttribute("AnimDirection") == "Right" then
                return randomAnimation(characterInstance.plrObjectsFolder, "AnimDirection", "Right", "Counter", true).AnimationId
            end

            return warn("No left or right counterattack track found!") -- If we get to this point, then something went wrong
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

local function setupAttackAnimation(attackLvl, characterInstance, enemy_characterInstance : any?) --[[ Will ready an attack animation on the client ]]
    local trackData = setupTrackData(attackLvl)

    if characterInstance.comboCounter == 0 then -- Randomize attackType for a new combo:
        -- Store the current attackType in characterInstance so it doesn't get forgotten when we attack in the future (for throwing the same type of attack again. If we throw a hook, we wanna followup with another hook):
        characterInstance.attackType = setRandomAttackType(characterInstance.comboCounter)

    end
    -- Whether or not we are starting a new series of attacks (such as jabs, or hooks) or not, we want our attackType to be what's already stored.
    trackData.attackType = characterInstance.attackType
    trackData.AnimationId = getAnimationId(characterInstance, trackData, enemy_characterInstance)

    if attackLvl == 3 then -- beyond the lvl 1's and 2's:

        trackData.Counter_Attribute = characterInstance.isCountering -- When true, we are countering:
        trackData.Animation = characterInstance.currentAttack

    end
    
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupClientAttackAnimation", trackData)
    else
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
end

local function playAttackAnimation(characterInstance) --[[ Responsible for handling the logic of when an attack ANIMATION starts ]]
    
    -- characterInstance.lastAttackId = characterInstance.

    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playAttackAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end
    
end

-- local attack1_waitTime = 0.45/0.60
-- local attack2_waitTime = 1

function Character_Attack:level1() --[[ Throw a level 1 attack, such as a jab or hook ]]
    
    -- Getting an animation ready on the client to play:
    local trackData = setupAttackAnimation(1, self.characterInstance)

    -- Playing said animation:
    playAttackAnimation(self.characterInstance)
    -- if self.characterInstance.comboCounter < 1 then -- For debuggin! Delete after!
        self.characterInstance.comboCounter += 1
    -- end
    trackData.IsPlaying = true
    self.characterInstance.attack_animation_manager:runOnIsPlaying(trackData)
    
    -- task.wait(attack1_waitTime)
    
    -- if not self.characterInstance.isAttacking then
    --     trackData.IsPlaying = false
    --     self.characterInstance.attack_animation_manager:runOnIsPlaying(trackData)
    -- end
end

function Character_Attack:level2() --[[ Throw a level 2 attack, such as a haymaker ]]
    print("lvl 2 attack")
    local trackData = setupAttackAnimation(2, self.characterInstance)
    playAttackAnimation(self.characterInstance)
    self.characterInstance.comboCounter += 1
    trackData.IsPlaying = true
    self.characterInstance.attack_animation_manager:runOnIsPlaying(trackData)
end

function Character_Attack:level3() --[[ Throw a level 3 attack, or in other words, execute the enemy ]]
    print("lvl 3 attack")
end

function Character_Attack:counterAttack(attacker_characterInstance) --[[ Perform a counter attack, turning the enemy's attack against them. ]]
    
    -- NOTE: Damage is dealt as soon as the 'StartOfAttack' marker is reached.
    
    -- local attackerAnim = attacker_characterInstance.currentAttack

    self.characterInstance.isCountering = true
    attacker_characterInstance.currentReceiveAnimTRACK = nil -- So they don't play their previous animation on accident for the counter receive.
    
    self.characterInstance.repositionInFrontOfEnemy()
    setupAttackAnimation(3, self.characterInstance)
    playAttackAnimation(self.characterInstance)

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

function Character_Attack:dodgeAttack() --[[ Attempt to evade the attack of the enemy, leaving them open. ]]
    self.characterInstance.attackTrack = self.characterInstance.randomAnimationTrack(self.characterInstance.dodgeAttacksTable, "DodgeAttack", true, "AnimDirection", self.characterInstance.dodgeTrack.Animation:GetAttribute("AnimDirection"))
    
    if self.characterInstance.attackTrack.Animation.AnimationId ~= self.characterInstance.FC_LDodgeAttack1.AnimationId then
        self.characterInstance.repositionInFrontOfEnemy() -- We dont reposition for left dodge attack cause it makes it not as cool for some reason
    end
    
    if self.characterInstance.attackTrack.Animation.AnimationId == self.characterInstance.FC_LDodgeAttack1.AnimationId then
        
        self.characterInstance.setCharacterCFrame(self.characterInstance.character, self.characterInstance.humanoidRootPart.CFrame * CFrame.new(2 , 0, 0))
        
        local moveDistanceX = -3
        local moveDistanceZ = -3
        local travelTime = 0.14/0.60
        self.characterInstance.setLinearVelocity(Vector3.new(moveDistanceX/travelTime, 0, moveDistanceZ/travelTime), travelTime)
    
    elseif self.characterInstance.attackTrack.Animation.AnimationId == self.characterInstance.FC_RDodgeAttack1.AnimationId then
    
        local moveDistance = 2.5
        local travelTime = 0.26/0.60
        self.characterInstance.setLinearVelocity(Vector3.new(moveDistance/travelTime, 0, 0), travelTime)
    end
    

    -- self.characterInstance.dodgeAttackTrack:Play()
    self.characterInstance.attackTrack:Play()

    self.characterInstance.waitingToAttack = false
    local reason = "dodgeAttack"
    self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, reason, self.characterInstance.attackTrack.Animation)

end

return Character_Attack