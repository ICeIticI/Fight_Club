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


local function getGrabAnimation(characterInstance)
    if grabType == "attempt" then
        return AnimationInstances.FC_GrabAttempt1 -- will be a more sophisticated way in the future when we start dealing with fighter classes and other animations
    elseif grabType == "success" then
        return AnimationInstances.FC_GrabSuccess1
    elseif grabType == "secure" then
        return AnimationInstances.FC_GrabSecure1
    elseif grabType == "attack" then
        return characterInstance.randomAnimation(characterInstance.AT_GrabAttacks)
        -- return AnimationInstances.FC_GrabAttack1
    elseif grabType == "execute" then
        return AnimationInstances.FC_GrabExecute1
    elseif grabType == "breakout" then
        return AnimationInstances.FC_EndGrab1
    end
end

local function setupGrabAnimation(characterInstance : table, enemyInstance : any?)
    local trackData = {}
    
    
    trackData.Animation = getGrabAnimation(characterInstance)
    trackData.AnimationId = trackData.Animation.AnimationId
    
    if trackData.Animation:GetAttribute("AnimType") == 1 then
        trackData.attackLvl = 1
        characterInstance.attackDamage = characterInstance:setupAttackDamage(trackData)
        if enemyInstance and enemyInstance.humanoid.Health <= characterInstance.attackDamage then
            grabType = "execute"
        end
    end
    

    characterInstance.currentGrab_trackData = trackData
    trackData.Paired_Attribute = true


    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "setupGrabAnimation", trackData)
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    return trackData
end

local function playGrabAnimation(characterInstance, trackData, bool : boolean?)
    if characterInstance.player then
        characterInstance.GlobalRemoteEvent:FireClient(characterInstance.player, "playGrabAnimation", {bool = bool})
    else 
        -- is an AI. Send directly to animation_centric instead of to the client then to centric.

    end

    characterInstance.simulateIsPlayingOfLastData(false)

    if bool == nil then
        trackData.IsPlaying = true
        characterInstance.manageAnimation(trackData)
    end

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

    if self.characterInstance.isGrappling then     
        grabType = "breakout"
        local trackData = setupGrabAnimation(self.characterInstance)
        playGrabAnimation(self.characterInstance, trackData)
        enemyInstance:receive("repelGrab", self.characterInstance)
    else
        grabType = "complete"
        playGrabAnimation(self.characterInstance, self.characterInstance.currentGrab_trackData, false)
        self.characterInstance.reset()

    end
    
    self.characterInstance.isInGrappleSuccess = false
end

function Character_Grapple:Execute(enemyInstance)
    grabType = "execute"
    local trackData = setupGrabAnimation(self.characterInstance)
    self.characterInstance.humanoidRootPart:FindFirstChild("grabWeld").Enabled = false
    self.characterInstance.isGrappling = false


    playGrabAnimation(self.characterInstance, trackData)
    enemyInstance:receive("receiveGrabExecution", self.characterInstance)
end

function Character_Grapple:Success(enemyInstance) --[[ The character attempted to grab the enemy and succeeded. We'll now strike the enemy to transition into :Secure() ]]
    grabType = "success"
    local trackData = setupGrabAnimation(self.characterInstance)
    self.characterInstance.isInGrappleSuccess = true

    if grabType == "execute" then -- if the enemy has low enough HP to kill them with a single attack, then we will just execute them instead
        self:Execute(enemyInstance)
    else
        playGrabAnimation(self.characterInstance, trackData)
        enemyInstance:receive("receiveGrabSuccess", self.characterInstance)
        
        while trackData.IsPlaying do task.wait() end
        return true
    end
end

function Character_Grapple:Secure_TurnLeft(enemyInstance)
    return warn("Add a turning-left animation for grapple secure")
end

function Character_Grapple:Secure_TurnRight(enemyInstance)
    return warn("Add a turning-right animation for grapple secure")
end

function Character_Grapple:GrabAttack(enemyInstance)
    grabType = "attack"
    local trackData = setupGrabAnimation(self.characterInstance, enemyInstance)
    
    if grabType == "execute" then -- if the enemy has low enough HP to kill them with a single attack, then we will just execute them instead
        self:Execute(enemyInstance)
    else
        playGrabAnimation(self.characterInstance, trackData)
        self.characterInstance.lastAttackData = trackData
        enemyInstance:receive("receiveGrabAttack", self.characterInstance)
    end
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
    while enemyInstance.isInSecureGrapple and self.characterInstance.isGrappling do
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