local Character_Init = {}
Character_Init.__index = Character_Init

-- Create a table that stores IDs for players so we can referance them.
local available_character_id_table = {} -- Table of usable character IDs
local id_amount = game.Players.MaxPlayers

for id = 0, id_amount do -- DOESN'T ACCOUNT FOR NPCS. NEEDS MODIFIED.
    table.insert(available_character_id_table, id)
end

local function getNextId() -- [[ Local function that will get an available ID, remove it from the available pool and return it. Should only be used when storing an ID somewhere, otherwise we lose that ID. ]]
    local charId = next(available_character_id_table)

    if charId ~= nil then
        table.remove(available_character_id_table, charId)
        return charId
    else -- The available IDs table somehow ran out of values. This shouldn't happen.
        for id = id_amount, id_amount * 2 do -- create a new set of IDs following after the initial set
            table.insert(available_character_id_table, id)
        end
        charId = next(available_character_id_table)
        return charId
    end
end

function Character_Init.init()
    local self = {}

    -- define public variables here that the Character will have:
    self.id = getNextId()
    
    return self
end

return Character_Init