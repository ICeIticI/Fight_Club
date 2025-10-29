--[[

* This module stores the data of created character objects.

* This File will initially be an empty table until the game runs and modules begin creating characters, storing them here.

* Everything else in this table are methods of getting characterObjects.

]]

local ModuleLoader

local Characters = {}

function Characters.init()
    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)
end

function Characters:GetCharacterObjectByPlayer(plr) --[[ Method that gets a character based off an assigned player. WIll return nil otherwise. ]]
    
    if not plr or not plr:IsA("Player") then
        return warn("Provide a player object you idiot. You gave: ", plr)
    end

    for _, potentialCharacterInstance in pairs(self) do
        if type(potentialCharacterInstance) == "table" and potentialCharacterInstance.player == plr then
            return potentialCharacterInstance
        end
    end
    -- warn("No characterInstance found with the given player: ".. tostring(plr), self)
    return nil
end

function Characters:GetCharacterObjectByCharacter(char)
    
    if not char or not char:FindFirstChildWhichIsA("Humanoid") then
        return warn("Provide a character object you idiot. You gave:", char)
    end

    for _, potentialCharacterInstance in pairs(self) do
        if type(potentialCharacterInstance) == "table" and potentialCharacterInstance.character == char then
            return potentialCharacterInstance
        end
    end

    warn("No characterInstance found with the given character: ".. tostring(char))
    return nil
end


function Characters:GetCharacterObjectById(id)
    if not id or not type(id) == "number" then
        return warn("Provide an ID you idiot")
    end

    for _, potentialCharacterInstance in pairs(self) do
        if type(potentialCharacterInstance) == "table" and potentialCharacterInstance.id == id then
            return potentialCharacterInstance
        end
    end

    warn("No characterInstance found with the given ID: ".. tostring(id))
    return nil
end

return Characters