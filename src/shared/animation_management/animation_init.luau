--[[

* Module that gets called by both the client and server for some things.

* For example, NPC animations are managed on the server, and player one's are
    manged on the client. The method of initializing the animations is the same
    on both the server and client, so they need the same function(s) in this case.

]]

local Animation_Init = {}
Animation_Init.__index = Animation_Init

-- Modules:

local Attack_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.attack_animation_manager)
local Receive_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.receive_animation_manager)
local Misc_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.misc_animation_manager)

function Animation_Init.initialize_animations(moduleTbl) --[[ Will initialize both the animations and their corresponding tracks ]]
    moduleTbl.AllAnimations = {}
    for _, obj in pairs(moduleTbl.plrObjectsFolder:GetChildren()) do
        if obj:IsA("Animation") then
            moduleTbl[obj.Name] = obj
            moduleTbl[obj.Name .. "TRACK"] = moduleTbl.charAnimator:LoadAnimation(obj)
            table.insert(moduleTbl.AllAnimations, moduleTbl[obj.Name .. "TRACK"])
        end
    end

    -- Sorting all the animations into other animation tables for managing:

    moduleTbl.attack1Table = {}
    moduleTbl.attack2Table = {}

    moduleTbl.pairedAttacksTable = {} -- the for loop below will fill this with all of the attacking paired animations
    moduleTbl.pairedBlocksTable = {} -- same above except for receiving animations.
    
    moduleTbl.counterAttacksTable = {}
    moduleTbl.dodgeAttacksTable = {}

    for _, v in pairs(moduleTbl.AllAnimations) do -- this for loop fills in the attack1 and attack2Table based off attributes
        if v.Animation:GetAttribute("AttackSeries") then -- standard attacks have the "AttackSeries" attribute so its how we define it as a stnadard attack
            if v.Animation:GetAttribute("AttackLevel") == 1 then -- level 1's will be added to the attack1Table
                table.insert(moduleTbl.attack1Table, v)
            elseif v.Animation:GetAttribute("AttackLevel") == 2 then -- level 2's will be added to the attack2Table
                table.insert(moduleTbl.attack2Table, v)
            end
        elseif v.Animation:GetAttribute("Paired") then -- adds paired animations into either pairedAttacks or pairedBlocks
            if v.Animation:GetAttribute("AnimType") == 1 then

                if v.Animation:GetAttribute("Counter") and not v.Animation:GetAttribute("DodgeAttack") then
                    -- is a counter attack
                    table.insert(moduleTbl.counterAttacksTable, v)
                elseif v.Animation:GetAttribute("DodgeAttack") then
                    -- is a dodge attack
                    table.insert(moduleTbl.dodgeAttacksTable, v)
                end
                table.insert(moduleTbl.pairedAttacksTable, v)

            elseif v.Animation:GetAttribute("AnimType") == 2 then
                table.insert(moduleTbl.pairedBlocksTable, v)
            end
        end

        
		local EndOfAttackExists = false -- for the functions that don't have this event, I want them to run code when the animation has stopped. However, animations that have this marker won't be able to run it.

		if v.Animation:GetAttribute("AnimType") == 1 then -- anim type 1 is attacks
			Attack_Animation_Management.manage(moduleTbl, v, v.Animation, EndOfAttackExists)
			
		elseif v.Animation:GetAttribute("AnimType") == 2 then -- anim type 2 is receive
            Receive_Animation_Management.manage(moduleTbl, v, v.Animation)

		else -- Misc. Animations such as blocking
			Misc_Animation_Management.manage(moduleTbl, v)
			
		end
    end
    
end

return Animation_Init