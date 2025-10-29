-- Instead of requiring modules across the codebase manually, this is a dynamic solution that centralizes module locations.

local ModuleLoader = {}

function ModuleLoader.init()
    local ServerScripts = game:GetService("ServerScriptService")
    local ClientScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
    local SharedScripts = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

    if game:GetService("RunService"):IsServer() then
        -- Runs for the server:
        for _, v in pairs(ServerScripts:GetDescendants()) do
            if v:IsA("ModuleScript") then
                ModuleLoader[v.Name] = require(v)
            end
        end
    else
        -- Runs for the client:
        for _, v in pairs(ClientScripts:GetDescendants()) do
            if v:IsA("ModuleScript") then
                ModuleLoader[v.Name] = require(v)
            end
        end 
    end

    -- Runs for both:
    for _, v in pairs(SharedScripts:GetDescendants()) do
        if v:IsA("ModuleScript") then
            ModuleLoader[v.Name] = require(v)
        end
    end
end

return ModuleLoader