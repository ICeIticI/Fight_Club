-- Modules:
local Attack_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.attack_animation_manager)

local Character_Attack = {}
Character_Attack.__index = Character_Attack

local function setupTrackData(attackLvl) --[[ Because tracks are played on the client, we kinda just have to replicate the attributes of the track when forming the animation here on the server. ]]
    local trackData = {
        attackLvl = attackLvl
        }

    if attackLvl == 1 or attackLvl == 2 then
        trackData.Counter_Attribute = false
    end
    return trackData
end

local function setupAttackAnimation(attackLvl, characterInstance) --[[ Will ready an attack animation on the client ]]
    local trackData = setupTrackData(attackLvl)
    
    if characterInstance.player then
        
        print(trackData)
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setUpClientAttackAnimation", trackData)
    else
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
end

local function playAttackAnimation(characterInstance) --[[ Responsible for handling the logic of when an attack ANIMATION starts ]]
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playAttackAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end
    
end


function Character_Attack:level1() --[[ Throw a level 1 attack, such as a jab or hook ]]
    -- Getting an animation ready on the client to play:
    local trackData = setupAttackAnimation(1, self.characterInstance)
    -- Playing said animation:
    playAttackAnimation(self.characterInstance)
    self.characterInstance.comboCounter += 1
    Attack_Animation_Management.runOnIsPlaying(trackData)
end

function Character_Attack:level2() --[[ Throw a level 2 attack, such as a haymaker ]]
    print("lvl 2 attack")
    local trackData = setupAttackAnimation(2, self.characterInstance)
    playAttackAnimation(self.characterInstance)
    self.characterInstance.comboCounter += 1
    Attack_Animation_Management.runOnIsPlaying(trackData)
end

function Character_Attack:level3() --[[ Throw a level 3 attack, or in other words, execute the enemy ]]
    print("lvl 3 attack")
end

function Character_Attack:counterAttack() --[[ Perform a counter attack, turning the enemy's attack against them. ]]
    print("counter attack")
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
    print(self.characterInstance.attackTrack, self.characterInstance.dodgeTrack)

    self.characterInstance.waitingToAttack = false
    local reason = "dodgeAttack"
    self.characterInstance.GlobalRemoteEvent:FireServer(self.characterInstance.enemyChar, reason, self.characterInstance.attackTrack.Animation)

end

return Character_Attack