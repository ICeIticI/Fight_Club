local Character_Init = {}
Character_Init.__index = Character_Init

function Character_Init.init()
    local self = {}

    -- define public variables here that the Character will have:
    
    self.id = nil -- the ID is how the server will identify which character this is when we need to retrieve it from the characters table.
    self.player = nil -- If the character is a player, their player object will be stored here.

    

    return self
end

return Character_Init