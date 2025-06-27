local Character_Grapple = {}
Character_Grapple.__index = Character_Grapple

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local grabType = nil 

local function setCharacterNetworkOwnershipTo(character, owner)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            child:SetNetworkOwner(owner)
        end
    end
end


local function getGrabAnimation()
    if grabType == "attempt" then
        return AnimationInstances.FC_GrabAttempt1 -- will be a more sophisticated way in the future when we start dealing with fighter classes and other animations
    elseif grabType == "success" then
        return AnimationInstances.FC_GrabSuccess1
    elseif grabType == "secure" then
        return AnimationInstances.FC_GrabSecure1
    elseif grabType == "attack" then
        return AnimationInstances.FC_GrabAttack1
    -- grabAttack is done on character_attack rather than this script to make it easier to add to the game
    elseif grabType == "end" then
        return AnimationInstances.FC_EndGrab1
    end
end

local function setupGrabAnimation(characterInstance)
    local trackData = {}
    trackData.Animation = getGrabAnimation()
    trackData.AnimationId = trackData.Animation.AnimationId
    characterInstance.currentGrab_trackData = trackData
    trackData.Paired_Attribute = true

    if trackData.Animation:GetAttribute("AnimType") == 1 then
        trackData.attackLvl = 1
        characterInstance.attackDamage = characterInstance:setupAttackDamage(trackData)
    end

    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupGrabAnimation", trackData)
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
end

local function playGrabAnimation(characterInstance, trackData)
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playGrabAnimation")
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    characterInstance.simulateIsPlayingOfLastData(false)
    trackData.IsPlaying = true
    characterInstance.manageAnimation(trackData)

end


function Character_Grapple:Attempt(enemyInstance) --[[ The character goes to attempt to grab an enemy. If this succeeds, then it'll transition to the :Secure() method. ]]
    grabType = "attempt"
    
    local trackData = setupGrabAnimation(self.characterInstance)

    self.characterInstance.isGrappling = true
    self.characterInstance.SetSpeed(false)
    self.characterInstance.repositionInFrontOfEnemy(enemyInstance.character)

    playGrabAnimation(self.characterInstance, trackData)
    return not enemyInstance:receive("grabAttempt", self.characterInstance)
    -- ^ If the enemy successfully mitigates our grab, then we return without success, and vice versa

end

function Character_Grapple:EndGrab(enemyInstance)
    grabType = "end"
    self.characterInstance.isInGrappleSuccess = false
    local trackData = setupGrabAnimation(self.characterInstance)
    playGrabAnimation(self.characterInstance, trackData)
    enemyInstance:receive("repelGrab", self.characterInstance)

end

function Character_Grapple:Success(enemyInstance) --[[ The character attempted to grab the enemy and succeeded. We'll now strike the enemy to transition into :Secure() ]]
    grabType = "success"
    self.characterInstance.isInGrappleSuccess = true
    local trackData = setupGrabAnimation(self.characterInstance)
    
    playGrabAnimation(self.characterInstance, trackData)
    enemyInstance:receive("receiveGrabSuccess", self.characterInstance)
    
    while trackData.IsPlaying do task.wait() end
    return true
end

function Character_Grapple:Secure_TurnLeft(enemyInstance)
    return warn("Add a turning-left animation for grapple secure")
end

function Character_Grapple:Secure_TurnRight(enemyInstance)
    return warn("Add a turning-right animation for grapple secure")
end

function Character_Grapple:GrabAttack(enemyInstance)
    grabType = "attack"
    local trackData = setupGrabAnimation(self.characterInstance)
    playGrabAnimation(self.characterInstance, trackData)
    self.characterInstance.lastAttackData = trackData
    enemyInstance:receive("receiveGrabAttack", self.characterInstance)
    
end

function Character_Grapple:Secure(enemyInstance) --[[ The character attempted to grab the enemy and succeeded. Now they can begin throwing blows and what not at the enemy while grappled on, and the enemy cant do anything about it except try to break free. ]]
    grabType = "secure"
    local trackData = setupGrabAnimation(self.characterInstance)
    playGrabAnimation(self.characterInstance, trackData)
    enemyInstance:receive("receiveGrabSecure", self.characterInstance)

    -- local offset = Vector3.new(0, 1, -3)
    -- setCharacterNetworkOwnershipTo(enemyInstance.character, self.characterInstance.player)
    local grabWeld = Instance.new("WeldConstraint")
    grabWeld.Name = "grabWeld"
    -- grabWeld.Enabled = false
    grabWeld.Parent = self.characterInstance.humanoidRootPart
    grabWeld.Part0 = self.characterInstance.character["Left Arm"]
    grabWeld.Part1 = enemyInstance.humanoidRootPart
    -- grabWeld.C1 = CFrame.new(0,0,-3) * CFrame.Angles(0,math.rad(180), 0)
    self.characterInstance.setCharacterMassless(enemyInstance.character, true)
    enemyInstance.humanoid.PlatformStand = true
    -- enemyInstance.repositionInFrontOfEnemy(self.characterInstance.character)
    -- grabWeld.Enabled = true
    while enemyInstance.isInSecureGrapple do
        task.wait()
        if self.characterInstance.movingDirection == "left" then
            Character_Grapple:Secure_TurnLeft()
        elseif self.characterInstance.movingDirection == "right" then
            Character_Grapple:Secure_TurnRight()
        end
        -- enemyInstance.character:SetPrimaryPartCFrame(self.characterInstance.humanoidRootPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, math.rad(180), 0))
    end

    self.characterInstance.setCharacterMassless(enemyInstance.character, false)
    enemyInstance.humanoid.PlatformStand = false
    grabWeld.Enabled = false
    grabWeld:Destroy()

    return false
end

return Character_Grapple