--[[

* Module that gets called by both the client and server for some things.

* For example, NPC animations are managed on the server, and player one's are
    managed on the client. The method of initializing the animations is the same
    on both the server and client, so they need the same functions in this case.

]]

local Animation_Centric = {}
Animation_Centric.__index = Animation_Centric

-- Modules:

local Attack_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.attack_animation_manager)
local Receive_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.receive_animation_manager)
local Misc_Animation_Management = require(game.ReplicatedStorage.Shared.animation_management.misc_animation_manager)

local function randomAnimationTrack(aTrackTbl, attribute1, a1Value, attribute2, a2Value) --[[ Will return a randomly-picked animation from a given table. You can put in attributes to filter what kind of animation you want.]]

    	local randAttackTbl = {}

	for _, v in pairs(aTrackTbl) do
		if
		(
			attribute1 == nil 
			or (a1Value ~= nil 
			and v.Animation:GetAttribute(attribute1) == a1Value) 
			or (v.Animation:GetAttribute(attribute1) 
			and a1Value == nil)) 
			and 
			(attribute2 == nil 
			or (a2Value ~= nil 
			and v.Animation:GetAttribute(attribute2) == a2Value) 
			or (v.Animation:GetAttribute(attribute2) 
			and a2Value == nil)
		) 

		then
			table.insert(randAttackTbl, v)
		end
	end

	return randAttackTbl[math.random(1, #randAttackTbl)] -- returns the randomly-selected animation track

end


function Animation_Centric.initialize_animations(moduleTbl) --[[ Will initialize both the animations and their corresponding tracks ]]
    print("reached here init")
    moduleTbl.AllAnimations = {}
    for _, obj in pairs(moduleTbl.plrObjectsFolder:GetChildren()) do
        if obj:IsA("Animation") then
            moduleTbl[obj.Name] = obj
            moduleTbl[obj.Name .. "TRACK"] = moduleTbl.charAnimator:LoadAnimation(obj)
            table.insert(moduleTbl.AllAnimations, moduleTbl[obj.Name .. "TRACK"])
        end
    end
    print("checkpoint 1")
    -- Sorting all the animations into other animation tables for managing:

    moduleTbl.attack1Table = {}
    moduleTbl.attack2Table = {}

    moduleTbl.pairedAttacksTable = {} -- the for loop below will fill this with all of the attacking paired animations
    moduleTbl.pairedBlocksTable = {} -- same above except for receiving animations.
    
    moduleTbl.counterAttacksTable = {}
    moduleTbl.dodgeAttacksTable = {}

    moduleTbl.attackTrack = nil -- the animation track of the current attack being performed

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
        print("checkpoint 2")
        
		local EndOfAttackExists = false -- for the functions that don't have this event, I want them to run code when the animation has stopped. However, animations that have this marker won't be able to run it.

        --[[
		if v.Animation:GetAttribute("AnimType") == 1 then -- anim type 1 is attacks
			Attack_Animation_Management.manage(moduleTbl, v, v.Animation, EndOfAttackExists)
			
		elseif v.Animation:GetAttribute("AnimType") == 2 then -- anim type 2 is receive
            Receive_Animation_Management.manage(moduleTbl, v, v.Animation)

		else -- Misc. Animations such as blocking
			Misc_Animation_Management.manage(moduleTbl, v)
			
		end
        ]]

    end
    
end

function Animation_Centric.setupAttackAnimation(moduleTbl, attackLvl) --[[ Will setup an attack. Execute after using the .playAttackAnimation() ]]
                                                -- AttackTbl would be the table of attacks, such as attack1Tbl or attack2Tbl
    if attackLvl == 1 then
        
        if not moduleTbl.attackTrack  then
            moduleTbl.attackTrack = randomAnimationTrack(moduleTbl.attack1Table, "AttackSeries", moduleTbl.randLvl1Type)
        else
            local sameAttackChance = math.random(1, 100)
            if sameAttackChance > 10 or moduleTbl.lastAttack.Animation:GetAttribute("AttackSeries") == "Uppercuts" then
                for _, v in pairs(moduleTbl.attack1Table) do
                    if v ~= moduleTbl.attackTrack and v.Animation:GetAttribute("AttackSeries") == moduleTbl.randLvl1Type then
                        moduleTbl.attackTrack = v
                        break
                    end
                end
                moduleTbl.attackTrack = randomAnimationTrack(moduleTbl.attack1Table, "AttackSeries", moduleTbl.randLvl1Type)
            end
        end
    
    elseif attackLvl == 2 then

        moduleTbl.attackTrack = moduleTbl.attack2Table[math.random(1, #moduleTbl.attack2Table)]
    end
end

function Animation_Centric.playAttackAnimation(moduleTbl) --[[ We setup an attack animation before (using the .setUpAttackAnimation). This will execute that animation.  ]]
    
    if moduleTbl.lastAttack and moduleTbl.lastAttack.IsPlaying and not moduleTbl.isAttacking then
        moduleTbl.lastAttack:Stop()
    end
        moduleTbl.currentAttack = moduleTbl.attackTrack.Animation
        moduleTbl.attackTrack:Play()
        moduleTbl.lastAttack = moduleTbl.attackTrack

end

return Animation_Centric