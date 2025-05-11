local Character_Attack = {}
Character_Attack.__index = Character_Attack

function Character_Attack:level1() --[[ Throw a level 1 attack, such as a jab or hook ]]
    print("lvl 1 attack")
end

function Character_Attack:level2() --[[ Throw a level 2 attack, such as a haymaker ]]
    print("lvl 2 attack")
end

function Character_Attack:level3() --[[ Throw a level 3 attack, or in other words, execute the enemy ]]
    print("lvl 3 attack")
end

function Character_Attack:counterAttack() --[[ Perform a counter attack, turning the enemy's attack against them. ]]
    print("counter attack")
end

function Character_Attack:dodgeAttack() --[[ Attempt to evade the attack of the enemy, leaving them open. ]]
    self.randAttack = self.randomAnimationTrack(self.dodgeAttacksTable, "DodgeAttack", true, "AnimDirection", self.dodgeTrack.Animation:GetAttribute("AnimDirection"))
    
    if self.randAttack.Animation.AnimationId ~= self.FC_LDodgeAttack1.AnimationId then
        self.repositionInFrontOfEnemy() -- We dont reposition for left dodge attack cause it makes it not as cool for some reason
    end
    
    if self.randAttack.Animation.AnimationId == self.FC_LDodgeAttack1.AnimationId then
        
        self.setCharacterCFrame(self.character, self.humanoidRootPart.CFrame * CFrame.new(2 , 0, 0))
        
        local moveDistanceX = -3
        local moveDistanceZ = -3
        local travelTime = 0.14/0.60
        self.setLinearVelocity(Vector3.new(moveDistanceX/travelTime, 0, moveDistanceZ/travelTime), travelTime)
    
    elseif self.randAttack.Animation.AnimationId == self.FC_RDodgeAttack1.AnimationId then
    
        local moveDistance = 2.5
        local travelTime = 0.26/0.60
        self.setLinearVelocity(Vector3.new(moveDistance/travelTime, 0, 0), travelTime)
    end
    

    -- self.dodgeAttackTrack:Play()
    self.randAttack:Play()
    print(self.randAttack, self.dodgeTrack)

    self.waitingToAttack = false
    local reason = "dodgeAttack"
    self.GlobalRemoteEvent:FireServer(self.enemyChar, reason, self.randAttack.Animation)

end

return Character_Attack