--[[

* This is the class for creating characters, whether clients or NPCs

* Each character function will link to another class, to organize and prevent scripts from
    being too large in size.

* Will be server-based. If a client wishes to do an action, it will be sent to the server and
    validated before they can do a desired action. Otherwise NPCs can willy-nilly do stuff.

]]

-- modules
local character_init = require(game.ReplicatedStorage.Shared.character_class.character_init)
local character_attack = require(game.ReplicatedStorage.Shared.character_class.character_attack) -- contains the attack functions and what not
local character_block = require(game.ReplicatedStorage.Shared.character_class.character_block)
local character_grapple = require(game.ReplicatedStorage.Shared.character_class.character_grapple)
local character_receive = require(game.ReplicatedStorage.Shared.character_class.character_receive)
local character_hitboxes = require(game.ReplicatedStorage.Shared.character_class.character_hitboxes)
local character_ragdoll = require(game.ReplicatedStorage.Shared.character_class.character_ragdoll)

local Attack_Animation_Manager = require(game.ReplicatedStorage.Shared.animation_management.attack_animation_manager)
local Receive_Animation_Manager = require(game.ReplicatedStorage.Shared.animation_management.receive_animation_manager)
local Misc_Animation_Manager = require(game.ReplicatedStorage.Shared.animation_management.misc_animation_manager)

local characters = require(game.ReplicatedStorage.Shared.server_modules.characters)
local Character = {}
Character.__index = Character


-- Create a table that stores IDs for players so we can referance them.
local available_character_id_table = {} -- Table of usable character IDs
local id_amount = game.Players.MaxPlayers

for id = 0, id_amount do -- DOESN'T ACCOUNT FOR NPCS. NEEDS MODIFIED.
    table.insert(available_character_id_table, id)
end

local function getNextId() --[[ Local function that will get an available ID, remove it from the available pool and return it. Should only be used when storing an ID somewhere, otherwise we lose that ID. ]]
    local i, charId = next(available_character_id_table)

    if charId ~= nil then
        print("Table of avaliable IDs.. " .. tostring(available_character_id_table), "Current ID: " .. tostring(charId))
        table.remove(available_character_id_table, i)
        return charId
    else -- The available IDs table somehow ran out of values. This shouldn't happen.
        for id = id_amount, id_amount * 2 do -- create a new set of IDs following after the initial set
            table.insert(available_character_id_table, id)
        end
        id_amount *= 2 -- permanently increase the id_amount in case this happens again.
        charId = next(available_character_id_table)
        return charId
    end
end


-- constructor function for Character:
function Character.new(charModel) --[[ Constructor function that will create a new instance of a character. ]]
    
    local self = setmetatable(character_init.init(charModel), Character) -- Setting the metatable to Character gives it access to inheritance for methods and functions.
    -- while not self.initialized do task.wait() end
    
    self.id = getNextId()
    
    self.character_attack = setmetatable({}, { __index = character_attack })
    self.character_block = setmetatable({}, { __index = character_block })
    self.character_grapple = setmetatable({}, { __index = character_grapple })
    self.character_receive = setmetatable({}, { __index = character_receive })
    
    self.attack_animation_manager = setmetatable({}, { __index = Attack_Animation_Manager})
    self.receive_animation_manager = setmetatable({}, { __index = Receive_Animation_Manager})
    self.misc_animation_manager = setmetatable({}, { __index = Misc_Animation_Manager })

    self.character_hitboxes = setmetatable({}, { __index = character_hitboxes })
    self.character_ragdoll = setmetatable({}, { __index = character_ragdoll })

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

    characters[self.id] = self

    self.character_hitboxes:manageHitboxes()
    self.character_ragdoll:InitializeCharacter()
    
    self.initialized = true
    return self
end

-- function Character:assignPlayer(plr) --[[ Method that associates this character class with an actual player, if applicable. ]]
--     self.player = plr
-- end

function Character:erase() --[[ Method that will delete the Character object to free up data and prevent memory leaks. ]]
    characters[self.id] = nil
    self = nil
end

function Character:lockOn() --[[ Makes the character lock onto an enemy (Will need to be added to once we start having NPCs and stuff). ]]
    if self.player ~= nil then
        
    else

    end
end

function Character:basicAttack(enemyInstance) --[[ The character will do some sort of attack ]]
    if enemyInstance.isBlocking and not self.isGettingHit and enemyInstance.humanoid.MoveDirection.Magnitude == 0 and self.comboCounter == 0 then
        -- self.synchedBlock(nil, comboCounter)
        local animPair = {math.random(1, 2), math.random(1, 2)}
        self.animPair = animPair
        enemyInstance.animPair = animPair
        self.character_attack:syncBlock(enemyInstance)
        enemyInstance:receive("syncBlock", self)
    elseif self.isGettingHit then
        return false
    elseif characters:GetCharacterObjectByCharacter(self.enemyChar) and characters:GetCharacterObjectByCharacter(self.enemyChar).isDodging ~= true then -- gets the public canAttack of the player and makes sure its true before attacking

        -- also if they are even further than 3 studs then we can implement a running-ish punch (like in RDR2)
        -- move character closer to enemy if they are a bit too far
            if self.distanceBetween > 3 then
                -- local speedUnit = 2500 -- 1 speed unit is 1 stud per second
                local distanceToTravel = self.distanceBetween - 3 -- we want to be 3 studs away from the enemy
                local timeToArrive = 0.55
                local speed = -(distanceToTravel / timeToArrive)
    
                self:setLinearVelocity(Vector3.new(0, 0, speed), timeToArrive)
            end

        if self.comboCounter <= 2 and self.enemyHumanoid.Health > 10 then
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

function Character:grab(enemyInstance, success) --[[ The character will attempt to grapple with an enemy ]]
    
    -- if success == nil then
        if self.character_grapple:Attempt(enemyInstance) == true then
            -- we succeeded with our grab
            self.character_grapple:Success(enemyInstance)
            self.character_grapple:Secure(enemyInstance)
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
    elseif receiveType == "receiveParry" then
        self.character_receive:receiveParry(data)
    elseif receiveType == "grabAttempt" then
        return self.character_receive:receiveGrabAttempt(data)
    end

end

return Character