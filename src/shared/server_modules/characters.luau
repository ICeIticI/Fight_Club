--[[

* This module stores the data of created character objects.

* This File will initially be an empty table until the game runs and modules begin creating characters, storing them here.

]]

local Characters = {}

function Characters:GetCharacterObjectByPlayer(plr) --[[ Method that gets a character based off an assigned player. WIll return nil otherwise. ]]
    for _, charInstance in pairs(self) do
        if type(charInstance) == "table" and charInstance.player == plr then
            return charInstance
        end
    end
    return nil
end

function Characters:GetCharacterObjectByCharacter(char)
    for _, charInstance in pairs(self) do
        if type(charInstance) == "table" and charInstance.character == char then
            return charInstance
        end
    end
    return nil
end

return Characters