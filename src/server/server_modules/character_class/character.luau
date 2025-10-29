--[[

* This is the class for creating characters, whether clients or NPCs

* Each character function will link to another class, to organize and prevent scripts from
    being too large in size.

* Will be server-based. If a client wishes to do an action, it will be sent to the server and
    validated before they can do a desired action. Otherwise NPCs can willy-nilly do stuff.

]]

-- modules
local ModuleLoader

-- -- local character_init = require(game.ReplicatedStorage.Shared.character_class.character_init)
-- -- local character_attack = require(game.ReplicatedStorage.Shared.character_class.character_attack) -- contains the attack functions and what not
-- -- local character_block = require(game.ReplicatedStorage.Shared.character_class.character_block)
-- -- local character_grapple = require(game.ReplicatedStorage.Shared.character_class.character_grapple)
-- -- local character_receive = require(game.ReplicatedStorage.Shared.character_class.character_receive)
-- -- local character_hitboxes = require(game.ReplicatedStorage.Shared.character_class.character_hitboxes)
-- -- local character_ragdoll = require(game.ReplicatedStorage.Shared.character_class.character_ragdoll)

-- -- local Attack_Animation_Manager = require(game.ReplicatedStorage.Shared.server_modules.animation_management.attack_animation_manager)
-- -- local Receive_Animation_Manager = require(game.ReplicatedStorage.Shared.server_modules.animation_management.receive_animation_manager)
-- -- local Misc_Animation_Manager = require(game.ReplicatedStorage.Shared.server_modules.animation_management.misc_animation_manager)

-- local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)

local Character = {}
Character.__index = Character

function Character.init()
    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)

    -- Create a table that stores IDs for players so we can referance them.
    Character.available_character_id_table = {} -- Table of usable character IDs
    Character.id_amount = game.Players.MaxPlayers
    
    for id = 0, Character.id_amount do -- DOESN'T ACCOUNT FOR NPCS. NEEDS MODIFIED.
        table.insert(Character.available_character_id_table, id)
    end

    ModuleLoader.character_attack.init()
    ModuleLoader.character_block.init()
    ModuleLoader.character_grapple.init()
    ModuleLoader.character_receive.init()
    ModuleLoader.character_ragdoll.init()
    ModuleLoader.character_hitboxes.init()

    ModuleLoader.attack_animation_manager.init()
    ModuleLoader.receive_animation_manager.init()
    ModuleLoader.misc_animation_manager.init()
end


local function getNextId() --[[ Local function that will get an available ID, remove it from the available pool and return it. Should only be used when storing an ID somewhere, otherwise we lose that ID. ]]
    local i, charId = next(Character.available_character_id_table)

    if charId ~= nil then
        table.remove(Character.available_character_id_table, i)
    else -- The available IDs table somehow ran out of values. This shouldn't happen.
        for id = Character.id_amount, Character.id_amount * 2 do -- create a new set of IDs following after the initial set
            table.insert(Character.available_character_id_table, id)
        end
        Character.id_amount *= 2 -- permanently increase the id_amount in case this happens again.
        charId = next(Character.available_character_id_table)
    end
    return charId
end


-- constructor function for Character:
function Character.new(charModel, data) --[[ Constructor function that will create a new instance of a character. ]]

    local characterInstancesFolder = game.Workspace:FindFirstChild("Characters") 
    or (function()
        -- Creates a characterInstancesFolder if it doesn't exist yet:
        local newCharacterInstancesFolder = Instance.new("Folder")
        newCharacterInstancesFolder.Name = "Characters"
        newCharacterInstancesFolder.Parent = game.Workspace
        return newCharacterInstancesFolder
    end)() -- <- Immediately call the function since this 'or' statement returns the actual function. It never runs until we call it like we do here.
    charModel.Parent = characterInstancesFolder

    local self = setmetatable(ModuleLoader.character_init.init(charModel, data), Character) -- Setting the metatable to Character gives it access to inheritance for methods and functions.
    -- while not self.initialized do task.wait() end
    
    self.character:SetAttribute("id", getNextId())
    self.id = self.character:GetAttribute("id")

    self.character_attack = setmetatable({}, { __index = ModuleLoader.character_attack })
    self.character_block = setmetatable({}, { __index = ModuleLoader.character_block })
    self.character_grapple = setmetatable({}, { __index = ModuleLoader.character_grapple })
    self.character_receive = setmetatable({}, { __index = ModuleLoader.character_receive })
    
    self.attack_animation_manager = setmetatable({}, { __index = ModuleLoader.attack_animation_manager})
    self.receive_animation_manager = setmetatable({}, { __index = ModuleLoader.receive_animation_manager})
    self.misc_animation_manager = setmetatable({}, { __index = ModuleLoader.misc_animation_manager })

    self.character_hitboxes = setmetatable({}, { __index = ModuleLoader.character_hitboxes })
    self.character_ragdoll = setmetatable({}, { __index = ModuleLoader.character_ragdoll })

    -- assign the Character instance to the other modules:

    -- functionalities:
    self.character_attack.characterInstance = self
    self.character_block.characterInstance = self
    self.character_grapple.characterInstance = self
    self.character_receive.characterInstance = self

    -- animation management:
    self.attack_animation_manager.characterInstance = self
    self.receive_animation_manager.characterInstance = self
    self.misc_animation_manager.characterInstance = self

    -- everything else:
    self.character_hitboxes.characterInstance = self
    self.character_ragdoll.characterInstance = self

    ModuleLoader.characters[self.id] = self

    self.character_hitboxes:manageHitboxes()
    self.character_ragdoll:InitializeCharacter()
    
    self.initialized = true
    if self.player then -- done loading. Get rid of clients loading screen:
        self.GlobalRemoteEvent:FireClient(self.player, "initialized")
    end

    return self
end

-- function Character:assignPlayer(plr) --[[ Method that associates this character class with an actual player, if applicable. ]]
--     self.player = plr
-- end

function Character:erase() --[[ Method that will delete the Character object to free up data and prevent memory leaks. ]]
    ModuleLoader.characters[self.id] = nil
    self = nil
end

function Character:lockOn() --[[ Makes the character lock onto an enemy (Will need to be added to once we start having NPCs and stuff). ]]
    if self.player ~= nil then
        
    else

    end
end

function Character:basicAttack(enemyInstance) --[[ The character will do some sort of attack ]]
    
    if self.isInGrappleSuccess and not self.isAttacking.Value then
        self.character_grapple:GrabAttack(enemyInstance)
    elseif enemyInstance.isBlocking and not self.isGettingHit and enemyInstance.humanoid.MoveDirection.Magnitude == 0 and self.comboCounter == 0 then
        -- self.synchedBlock(nil, comboCounter)
        local animPair = {math.random(1, 2), math.random(1, 2)}
        self.animPair = animPair
        enemyInstance.animPair = animPair
        self.character_attack:syncBlock(enemyInstance)
        enemyInstance:receive("syncBlock", self)
    elseif self.isGettingHit then
        return false
    elseif ModuleLoader.characters:GetCharacterObjectByCharacter(self.enemyChar) and ModuleLoader.characters:GetCharacterObjectByCharacter(self.enemyChar).isDodging ~= true and not self.isGrappling then -- gets the public canAttack of the player and makes sure its true before attacking

        -- also if they are even further than 3 studs then we can implement a running-ish punch (like in RDR2)
        -- move character closer to enemy if they are a bit too far
            if self.distanceBetween > 3 then
                -- local speedUnit = 2500 -- 1 speed unit is 1 stud per second
                local distanceToTravel = self.distanceBetween - 3 -- we want to be 3 studs away from the enemy
                local timeToArrive = 0.55
                local speed = -(distanceToTravel / timeToArrive)
    
                self:setLinearVelocity(Vector3.new(0, 0, speed), timeToArrive)
            end

        if self.comboCounter <= 2 and self.enemyChar.Humanoid.Health > 10 then
            -- character_attack.level1()
            self.character_attack:level1()
        elseif self.comboCounter >= 3 or self.enemyHumanoid.Health <= 10 then
            -- character_attack.level2()
            self.character_attack:level2()

        else
            warn("Attack call failed! :(")
        end

    
        
    -- elseif comboCounter == 3 then
    --     -- character_attack.level3()
    --     self.character_attack:level3()
    end
end

function Character:repulseAttack(attack_type, attacker_characterInstance)
    if attack_type == "dodge" then
        self.character_attack:dodgeAttack(attacker_characterInstance)
    elseif attack_type == "counter" then
        self.character_attack:counterAttack(attacker_characterInstance)
    end
end

function Character:block(sentBool) --[[ The character will get ready to block an incoming attack ]]
    if sentBool == true then
        self.character_block:enable()
    elseif sentBool == false then
        self.character_block:disable()
    end
end

function Character:grab(enemyInstance) --[[ The character will attempt to grapple with an enemy ]]
    
    -- if success == nil then
        if self.character_grapple:Attempt(enemyInstance) == true then
            -- we succeeded with our grab
            self.character_grapple:Success(enemyInstance)
            if self.character_grapple:Secure(enemyInstance) then -- if it returns true, then its an execution. Don't run :EndGrab.
                return
            end
        end
        self.character_grapple:EndGrab(enemyInstance)

    -- elseif success == true then
    --     self.character_grapple:Success(enemyInstance)
    --     self.character_grapple:Secure(enemyInstance)
    --     self.character_grapple:EndGrab(enemyInstance)
    -- elseif success == false then
    --     self.character_grapple:EndGrab(enemyInstance)
    -- end
    
end

function Character:receive(receiveType, data) --[[ The character will receive an attack ]]
    -- Mitigate attacks:

    self.attackingChar = data.character
    self.GlobalRemoteEvent:FireClient(self.player, "updateCurrentAttacker", {attackingChar = self.attackingChar})

    if receiveType == "bracingBlock" then
        self.character_receive:bracingBlock(data)
    elseif receiveType == "syncBlock" then
       self.character_receive:syncBlock(data)
    elseif receiveType == "dodge" then
        self.character_receive:dodge(data)
    elseif receiveType == "parry" then
        self.character_receive:parry(data)
        
    -- mitigate attacks with our own attack:
    elseif receiveType == "counterAttack" then
        self.character_receive:receiveCounter(data)
    elseif receiveType == "dodgeAttack" then
        self.character_receive:receiveDodgeAttack(data)
    elseif receiveType == "repelGrab" then
        self.character_receive:repelGrab(data)
        
    -- No mitigation (got struck by an attack):
    elseif receiveType == "receiveLevel1" then
        self.character_receive:receiveLevel1(data)
    elseif receiveType == "receiveLevel2" then
        self.character_receive:receiveLevel2(data)
    elseif receiveType == "receiveLevel3" then
        self.character_receive:receiveLevel3(data)
    elseif receiveType == "receiveGrabSuccess" then
        self.character_receive:receiveGrabSuccess(data)
    elseif receiveType == "receiveGrabSecure" then
        self.character_receive:receiveGrabSecure(data)
    elseif receiveType == "receiveGrabAttack" then
        self.character_receive:receiveGrabAttack(data)
    elseif receiveType == "receiveParry" then
        self.character_receive:receiveParry(data)
    elseif receiveType == "grabAttempt" then
        return self.character_receive:receiveGrabAttempt(data)
    elseif receiveType == "receiveGrabExecution" then
        self.character_receive:receiveGrabExecution(data)
    end

end

return Character