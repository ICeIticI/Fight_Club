local Character_Attack = {}
Character_Attack.__index = Character_Attack

local function playAttackAnimation(characterInstance) --[[ Responsible for handling the logic of when an attack ANIMATION starts ]]
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient("playAttackAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end
end

local function setupAttackAnimation(attackLvl, characterInstance) --[[ Will ready an attack animation on the client ]]
    if characterInstance.player then
        local data = {
            attackLvl
        }
        characterInstance.GlobalRemoteEvent:FireClient("setUpClientAttackAnimation", data)
    else
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end
end


function Character_Attack:level1() --[[ Throw a level 1 attack, such as a jab or hook ]]
    -- Getting an animation ready on the client to play:
    setupAttackAnimation(1, self)
    -- Playing said animation:
    playAttackAnimation(self)
    print(self)
    self.comboCounter += 1
end

function Character_Attack:level2() --[[ Throw a level 2 attack, such as a haymaker ]]
    print("lvl 2 attack")
    setupAttackAnimation(2, self)
    playAttackAnimation(self)
    self.comboCounter += 1
end

function Character_Attack:level3() --[[ Throw a level 3 attack, or in other words, execute the enemy ]]
    print("lvl 3 attack")
end

function Character_Attack:counterAttack() --[[ Perform a counter attack, turning the enemy's attack against them. ]]
    print("counter attack")
end

function Character_Attack:dodgeAttack() --[[ Attempt to evade the attack of the enemy, leaving them open. ]]
    self.attackTrack = self.randomAnimationTrack(self.dodgeAttacksTable, "DodgeAttack", true, "AnimDirection", self.dodgeTrack.Animation:GetAttribute("AnimDirection"))
    
    if self.attackTrack.Animation.AnimationId ~= self.FC_LDodgeAttack1.AnimationId then
        self.repositionInFrontOfEnemy() -- We dont reposition for left dodge attack cause it makes it not as cool for some reason
    end
    
    if self.attackTrack.Animation.AnimationId == self.FC_LDodgeAttack1.AnimationId then
        
        self.setCharacterCFrame(self.character, self.humanoidRootPart.CFrame * CFrame.new(2 , 0, 0))
        
        local moveDistanceX = -3
        local moveDistanceZ = -3
        local travelTime = 0.14/0.60
        self.setLinearVelocity(Vector3.new(moveDistanceX/travelTime, 0, moveDistanceZ/travelTime), travelTime)
    
    elseif self.attackTrack.Animation.AnimationId == self.FC_RDodgeAttack1.AnimationId then
    
        local moveDistance = 2.5
        local travelTime = 0.26/0.60
        self.setLinearVelocity(Vector3.new(moveDistance/travelTime, 0, 0), travelTime)
    end
    

    -- self.dodgeAttackTrack:Play()
    self.attackTrack:Play()
    print(self.attackTrack, self.dodgeTrack)

    self.waitingToAttack = false
    local reason = "dodgeAttack"
    self.GlobalRemoteEvent:FireServer(self.enemyChar, reason, self.attackTrack.Animation)

end

return Character_Attack