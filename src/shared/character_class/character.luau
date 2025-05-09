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
local character_receive = require(game.ReplicatedStorage.Shared.character_class.character_receive)

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
        print(available_character_id_table, charId)
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
function Character.new(plr) --[[ Constructor function that will create a new instance of a character. ]]
    local self = setmetatable(character_init.init(), Character) -- Setting the metatable to Character gives it access to inheritance for methods and functions.
    self.id = getNextId()
    self.player = plr
    print(self.id)
    characters[self.id] = self
    return self
end

-- function Character:assignPlayer(plr) --[[ Method that associates this character class with an actual player, if applicable. ]]
--     self.player = plr
-- end

function Character:erase() --[[ Method that will delete the Character object to free up data and prevent memory leaks. ]]
    self = nil
end

function Character:lockOn()
    if self.player ~= nil then
        
    else

    end
end

function Character:attack(attack_level) --[[ The character will do some sort of attack ]]
    if attack_level == 1 then
        character_attack.level1()
    elseif attack_level == 2 then
        character_attack.level2()
    elseif attack_level == 3 then
        character_attack.level3()
    end
end

function Character:block(sentBool) --[[ The character will get ready to block an incoming attack ]]
    if sentBool == true then
        character_block.enable()
    elseif sentBool == false then
        character_block.disable()
    end
end

function Character:grapple() --[[ The character will grapple with an enemy ]]
    
end

function Character:receive(receiveType) --[[ The character will receive an attack ]]


    -- Mitigate attacks:
    if receiveType == "bracingBlock" then
        character_receive.bracingBlock()
    elseif receiveType == "SyncBlock" then
       character_receive.syncBlock()
    elseif receiveType == "dodge" then
        character_receive.dodge()
    elseif receiveType == "parry" then
        character_receive.parry()


    -- No mitigation (got struck by an attack):
    elseif receiveType == "receiveLevel1" then
        character_receive.receiveLevel1()
    elseif receiveType == "receiveLevel2" then
        character_receive.receiveLevel2()
    elseif receiveType == "receiveLevel3" then
        character_receive.receiveLevel3()

    elseif receiveType == "receiveSyncBlock" then
        character_receive.receiveSyncBlock()
    elseif receiveType == "receiveDodgeAttack" then
        character_receive.receiveDodgeAttack()
    elseif receiveType == "receiveParry" then
        character_receive.receiveParry()
    end
end

return Character