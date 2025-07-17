local Character_Grapple = {}
Character_Grapple.__index = Character_Grapple

local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)
local utilities = require(game.ReplicatedStorage.Shared.utilities)

local grabType = nil 


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
        return characterInstance.randomAnimation(characterInstance.AT_GrabExecutions)
        -- return AnimationInstances.FC_GrabExecute2
    elseif grabType == "breakout" then
        return AnimationInstances.FC_EndGrab1
    end
end

local function setupGrabAnimation(characterInstance : table, enemyInstance : any?)
    local trackData = {}
    
    
    trackData.Animation = getGrabAnimation(characterInstance)
    trackData.AnimationId = trackData.Animation.AnimationId
    
    if trackData.Animation:GetAttribute("AnimType") == 1 then
        trackData.attackLvl = trackData.Animation:GetAttribute("AttackLevel") or 1 -- only few grab attacks have an attacklevel thats not 1, so when we assign attacklevel to those few animations, its always different than 1
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
    while not self.characterInstance.speedSet do task.wait(0.1) end -- wait for the speed to get set before proceeding.

    -- to prevent positional glitches with grappling (such as going through walls), only reposition the grappler to the receiver if they're facing eachother. Otherwise, move the receiver to the grappler.
    -- This is until we get back grapples post alpha
    if self.characterInstance.humanoidRootPart.CFrame.LookVector:Dot(enemyInstance.humanoidRootPart.CFrame.LookVector) < -0.9 then
        self.characterInstance.repositionInFrontOfEnemy(enemyInstance.character)
    else
        enemyInstance.repositionInFrontOfEnemy(self.characterInstance.character)
    end

    playGrabAnimation(self.characterInstance, trackData)
    return not enemyInstance:receive("grabAttempt", self.characterInstance)
    -- ^ If the enemy successfully mitigates our grab, then we return without success, and vice versa

end

function Character_Grapple:EndGrab(enemyInstance)

    if self.characterInstance.isGrappling then     
        print("breakin out")
        grabType = "breakout"
        local trackData = setupGrabAnimation(self.characterInstance)
        playGrabAnimation(self.characterInstance, trackData)
        enemyInstance:receive("repelGrab", self.characterInstance)
    else
        grabType = "complete"
        print(grabType)
        self.characterInstance.isGrappling = false
        enemyInstance.isGrappling = false
        self.characterInstance.reset()
        enemyInstance.reset()

    end
    
    self.characterInstance.isInGrappleSuccess = false
    playGrabAnimation(enemyInstance, enemyInstance.lastReceiveData, false)

end

function Character_Grapple:Execute(enemyInstance)
    grabType = "execute"
    local trackData = setupGrabAnimation(self.characterInstance)
    self.characterInstance.setCharacterMassless(enemyInstance.character, false)
    enemyInstance.isInSecureGrapple = false
    -- self.characterInstance.humanoidRootPart:FindFirstChild("grabMotor").Enabled = false

    enemyInstance.character:FindFirstChild("Health").Enabled = false -- disables the health script inside the character, which regenerates their health.
    enemyInstance.humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    -- self.characterInstance.isGrappling = false


    playGrabAnimation(self.characterInstance, trackData)
    enemyInstance:receive("receiveGrabExecution", self.characterInstance)

    self.characterInstance.isInGrappleSuccess = false
end

function Character_Grapple:Success(enemyInstance) --[[ The character attempted to grab the enemy and succeeded. We'll now strike the enemy to transition into :Secure() ]]
    grabType = "success"

    enemyInstance.repositionInFrontOfEnemy(self.characterInstance.character)

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
    utilities.setCharacterNetworkOwnershipTo(enemyInstance.character, self.characterInstance.player)
    enemyInstance.repositionInFrontOfEnemy(self.characterInstance.character)
    -- local grabWeld = Instance.new("WeldConstraint")
    -- grabWeld.Name = "grabWeld"
    -- -- grabWeld.Enabled = false
    -- grabWeld.Parent = self.characterInstance.humanoidRootPart
    -- grabWeld.Part0 = self.characterInstance.character["Left Arm"]
    -- grabWeld.Part1 = enemyInstance.humanoidRootPart

    enemyInstance.humanoid.PlatformStand = true
    self.characterInstance.setCharacterMassless(enemyInstance.character, true)


    local grabMotor = Instance.new("Motor6D")
    grabMotor.Name = "grabMotor"
    grabMotor.Part0 = self.characterInstance.grapplePart
    grabMotor.Part1 = enemyInstance.humanoidRootPart
    grabMotor.Parent = grabMotor.Part0
    -- motor.C0 = self.characterInstance.humanoidRootPart.CFrame:ToObjectSpace(enemyInstance.humanoidRootPart.CFrame)
    -- motor.C1 = CFrame.new() -- usually identity
    -- motor.Parent = self.characterInstance.humanoidRootPart

    self.characterInstance.humanoidRootPart.CanCollide = false
    enemyInstance.humanoidRootPart.CanCollide = false
    
    -- grabWeld.Enabled = true
    self.characterInstance.isAttacking.Value = false

    while enemyInstance.isInSecureGrapple 
    and self.characterInstance.isGrappling do
        
        if self.characterInstance.movingDirection.Value == "right" then
            enemyInstance.movingDirection.Value = "left"
        elseif self.characterInstance.movingDirection.Value == "left" then	
            enemyInstance.movingDirection.Value = "right"
        elseif self.characterInstance.movingDirection.Value == "forwards" then
            enemyInstance.movingDirection.Value = "backwards"
        elseif self.characterInstance.movingDirection.Value == "backwards" then
            enemyInstance.movingDirection.Value = "forwards"
        elseif self.characterInstance.movingDirection.Value == "none" then
            enemyInstance.movingDirection.Value = "none"
        end
        if self.characterInstance.movingDirection.Value == "left" then
            -- Character_Grapple:Secure_TurnLeft()
        elseif self.characterInstance.movingDirection.Value == "right" then
            -- Character_Grapple:Secure_TurnRight()
        end
        -- enemyInstance.character:SetPrimaryPartCFrame(self.characterInstance.humanoidRootPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, math.rad(180), 0))
        
        if self.characterInstance.humanoid.Health <= 0 then
            enemyInstance.isInSecureGrapple = false
            self.characterInstance.isGrappling = false

        end

        task.wait(0.1)
    end

    
    self.characterInstance.setCharacterMassless(enemyInstance.character, false)
    enemyInstance.humanoid.PlatformStand = false
    utilities.setCharacterNetworkOwnershipTo(enemyInstance.character, enemyInstance.player)
    grabMotor:Destroy()
    grabMotor = nil
    -- grabWeld.Enabled = false
    -- grabWeld:Destroy()
    print("We broke out of the loop. Our current grab type:" , grabType)

    playGrabAnimation(self.characterInstance, trackData, false)



    if grabType == "execute" then
        return true
    else
        return false
    end
end

return Character_Grapple