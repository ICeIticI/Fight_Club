--[[

* This module stores the data of created character objects.

* This File will initially be an empty table until the game runs and modules begin creating characters, storing them here.

]]

local Characters = {}

function Characters:GetCharacterByPlayer(plr) --[[ Method that gets a character based off an assigned player ]]
    for _, char in pairs(self) do
        if char.player == plr then
            return char
        end
    end
    return false
end

return Characters