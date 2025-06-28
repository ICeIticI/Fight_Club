--[[ 
Module that holds a table of AnimationIds for each fighter class (such as
for the basic brawler, counterpuncher, brute, etc. Any kind of class I'll 
want to add.)
]]

local Fighter_Kits = {}
Fighter_Kits.__index = Fighter_Kits

local function newKit() --[[ A class function that gets called when we add a new animation kit to the game. By default, every animation in this table the function returns will be the default brawler animation Ids, until we overwrite it with the class's own. Also useful if some fighter classes share animations with default. ]]
    return {
        Idle = "16976891984",
        BlockStart = "18266066281",
        Block = "16976697757"
    
        -- Add the rest of the animations
    }
end

Fighter_Kits.brawler = newKit() -- The default fighter class every player will start out with.
-- ^ Since newKit() returns the default animations, we don't need to manually add any AnimationIds.

-- Add more classes (such as counterpuncher, tank, etc) and call newKit() and start adding animations:

return Fighter_Kits