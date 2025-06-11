--[[

* This module stores the data of created character objects.

* This File will initially be an empty table until the game runs and modules begin creating characters, storing them here.

* Everything else in this table are methods of getting characterObjects.

]]

local Characters = {}

function Characters:GetCharacterObjectByPlayer(plr) --[[ Method that gets a character based off an assigned player. WIll return nil otherwise. ]]
    
    if not plr or not plr:IsA("Player") then
        return warn("Provide a player object you idiot")
    end

    for _, charInstance in pairs(self) do
        if type(charInstance) == "table" and charInstance.player == plr then
            return charInstance
        end
    end
    warn("No characterInstance found with the given player: ".. tostring(plr))
    return nil
end

function Characters:GetCharacterObjectByCharacter(char)
    
    if not char or not char:FindFirstChildWhichIsA("Humanoid") then
        return warn("Provide a character object you idiot")
    end

    for _, charInstance in pairs(self) do
        if type(charInstance) == "table" and charInstance.character == char then
            return charInstance
        end
    end

    warn("No characterInstance found with the given character: ".. tostring(char))
    return nil
end


function Characters:GetCharacterObjectById(id)
    if not id or not type(id) == "number" then
        return warn("Provide an ID you idiot")
    end

    for _, charInstance in pairs(self) do
        if type(charInstance) == "table" and charInstance.id == id then
            return charInstance
        end
    end

    warn("No characterInstance found with the given ID: ".. tostring(id))
    return nil
end

return Characters