--[[

* Module that gets called by both the client and server for some things.

* For example, NPC animations are managed on the server, and player one's are
    managed on the client. The method of initializing the animations is the same
    on both the server and client, so they need the same functions in this case.

]]
local Animation_Centric = {}
Animation_Centric.__index = Animation_Centric


local function getAnimationTrackById(moduleTbl, AnimationId)
    for _, animationTrack in pairs(moduleTbl.AllAnimations) do
        if animationTrack.Animation.AnimationId == AnimationId then
            return animationTrack
        end
    end

    return warn("No AnimationTrack was found with the given AnimationId: " .. tostring(AnimationId))
end

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
    moduleTbl.AllAnimations = {}
    for _, obj in pairs(require(game.ReplicatedStorage.Shared.AnimationInstances)) do
        if obj:IsA("Animation") then
            -- moduleTbl[obj.Name] = obj
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

                if v.Animation:GetAttribute("Counter") then
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

        -- making the characterInstance accessible from animation_centric:
        moduleTbl.animation_centric = setmetatable({}, { __index = Animation_Centric})
        moduleTbl.animation_centric.characterInstance = moduleTbl
        
        --[[
		local EndOfAttackExists = false -- for the functions that don't have this event, I want them to run code when the animation has stopped. However, animations that have this marker won't be able to run it.
        
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

function Animation_Centric.setupAttackAnimation(moduleTbl, trackData) --[[ Will setup an attack. Execute after using the .playAttackAnimation() ]]
                                                -- AttackTbl would be the table of attacks, such as attack1Tbl or attack2Tbl
    
    
    if moduleTbl.attackTrack and moduleTbl.attackTrack.IsPlaying and not moduleTbl.isAttacking then
        moduleTbl.attackTrack:Stop()
    end
    if moduleTbl.currentReceiveAnimTRACK and moduleTbl.currentReceiveAnimTRACK.IsPlaying and not moduleTbl.isGettingHit then
        moduleTbl.currentReceiveAnimTRACK:Stop()
    end

    if trackData.attackLvl == 1 or trackData.attackLvl == 2 then
        moduleTbl.attackTrack = getAnimationTrackById(moduleTbl, trackData.AnimationId)
    elseif trackData.attackLvl == 3 then
        
        if trackData.Counter_Attribute then
            moduleTbl.attackTrack:Stop()
        
            if moduleTbl.attackTrack.Animation:GetAttribute("AnimDirection") == "Left" then
                moduleTbl.attackTrack = randomAnimationTrack(moduleTbl.counterAttacksTable, "AnimDirection", "Left", "Counter", true)
            elseif moduleTbl.attackTrack.Animation:GetAttribute("AnimDirection") == "Right" then
                moduleTbl.attackTrack = randomAnimationTrack(moduleTbl.counterAttacksTable, "AnimDirection", "Right", "Counter", true)
            end
        end
    end
end

function Animation_Centric.playAttackAnimation(moduleTbl) --[[ We setup an attack animation before (using the .setUpAttackAnimation). This will execute that animation.  ]]
    if not moduleTbl.attackTrack then return warn("Failed to play attack track, as it doesn't exist.") end

        moduleTbl.currentAttack = moduleTbl.attackTrack.Animation
        moduleTbl.attackTrack:Play()
        -- moduleTbl.lastAttackTrack = moduleTbl.attackTrack

end

function Animation_Centric.setupReceiveAnimation(moduleTbl, data)
    -- if data.receivingFromType == "AttackStart" then

    --     if data.IsADodge then

    --         if data.DodgeDirection == "Right" then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightDodgeTRACK
    --         elseif data.DodgeDirection == "Left" then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftDodgeTRACK
    --         elseif data.DodgeDirection == "Back" then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_BackDodgeTRACK
    --         end

    --     end
    
    -- elseif data.receivingFromType == "Level1" then

    --     if data.attackerAnim.AnimationId == moduleTbl.FC_LeftHook1.AnimationId or data.attackerAnim.AnimationId == moduleTbl.FC_LeftJab.AnimationId then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftHook1RECEIVERTRACK
    --     elseif data.attackerAnim.AnimationId == moduleTbl.FC_LeftUppercut.AnimationId then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftUppercutRECEIVERTRACK

    --     elseif data.attackerAnim.AnimationId == moduleTbl.FC_RightHook1.AnimationId or data.attackerAnim.AnimationId == moduleTbl.FC_RightJab.AnimationId then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightHook1RECEIVERTRACK
    --     elseif data.attackerAnim.AnimationId == moduleTbl.FC_RightUppercut.AnimationId then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightUppercutRECEIVERTRACK
    --     end
    -- elseif data.receivingFromType == "Level2" then

    --     if data.attackerAnim.AnimationId == moduleTbl.FC_LeftHaymaker.AnimationId then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftHaymakerRECEIVERTRACK
    --     elseif data.attackerAnim.AnimationId == moduleTbl.FC_RightHaymaker.AnimationId then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightHaymakerReceiverTRACK
    --     end
    -- elseif data.receivingFromType == "Parry" then
        
    --     if data.attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --         -- Perform a left parry
    --         warn("ParryL")
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightParryTRACK
    --     elseif data.attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --         -- Perform a right parry
    --         warn("ParryR")
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftParryTRACK
    --     end
    -- elseif data.receivingFromType == "gettingParried" then
    --     moduleTbl.attackTrack:Stop()
    --     if data.attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightParryRECEIVERTRACK
    --     elseif data.attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftParryRECEIVERTRACK
    --     end
    -- elseif data.receivingFromType == "dodgeAttack" then

    --     -- We will get dodge-attacked
            
    --     if moduleTbl.attackTrack then -- stop any attack that's playing
    --         moduleTbl.attackTrack:Stop() 
    --     end
        
    --     if data.attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LDodgeAttack1RECEIVERTRACK
    --     elseif data.attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RDodgeAttack1RECEIVERTRACK
    --     elseif data.attackerAnim:GetAttribute("AnimDirection") == "Back" then
    --         moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_BDodgeAttack1RECEIVERTRACK
    --     end

    -- elseif data.receivingFromType == "counterAttack" then
    --     -- We are gonna get countered
            
    --     -- GameVariables.repositionInFrontOfEnemy()
    --     if moduleTbl.attackTrack and moduleTbl.attackTrack.IsPlaying then
    --         moduleTbl.attackTrack:Stop() -- stop an attack if its playing
    --     end

    --     if data.attackerAnim:GetAttribute("AnimDirection") == "Left" then
    --         if data.attackerAnim.AnimationId == moduleTbl.FC_LeftCounter1.AnimationId then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftCounter1RECEIVERTRACK

    --         elseif data.attackerAnim.AnimationId == moduleTbl.FC_LeftCounter2.AnimationId then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_LeftCounter2RECEIVERTRACK
    --         end
    --     elseif data.attackerAnim:GetAttribute("AnimDirection") == "Right" then
    --         if data.attackerAnim.AnimationId == moduleTbl.FC_RightCounter1.AnimationId then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightCounter1RECEIVERTRACK

    --         elseif data.attackerAnim.AnimationId == moduleTbl.FC_RightCounter2.AnimationId then
    --             moduleTbl.currentReceiveAnimTRACK = moduleTbl.FC_RightCounter2RECEIVERTRACK
    --         end
    --     end
    -- end

    if moduleTbl.currentReceiveAnimTRACK and moduleTbl.currentReceiveAnimTRACK.IsPlaying and not moduleTbl.isGettingHit then
        moduleTbl.currentReceiveAnimTRACK:Stop()
    end
    if moduleTbl.attackTrack and moduleTbl.attackTrack and moduleTbl.attackTrack.IsPlaying and not moduleTbl.isAttacking then
        moduleTbl.attackTrack:Stop()
    end

    moduleTbl.currentReceiveAnimTRACK = getAnimationTrackById(moduleTbl, data.AnimationId)

end

function Animation_Centric.playReceiveAnimation(moduleTbl)
    if not moduleTbl.currentReceiveAnimTRACK then return warn("Failed to play receiving animation track, as it doesn't exist.") end

    moduleTbl.currentReceiveAnimTRACK:Play()

    -- -- reposition the player to face the enemy if they counter them (not a parry)
    -- if moduleTbl.currentReceiveAnimTRACK.Animation:GetAttribute("Counter") and not (moduleTbl.currentReceiveAnimTRACK == moduleTbl.FC_RightParryTRACK or moduleTbl.currentReceiveAnimTRACK == moduleTbl.FC_LeftParryTRACK) then
    --     moduleTbl.repositionInFrontOfEnemy()
    -- end
end

function Animation_Centric.playBlockStartAnimation(moduleTbl)
    moduleTbl.FC_BlockStartTRACK:Play()
end

function Animation_Centric.playBlockAnimation(moduleTbl)
    moduleTbl.FC_BlockTRACK:Play()
end

function Animation_Centric.stopBlocking(moduleTbl)
    moduleTbl.FC_BlockStartTRACK:Stop()
    moduleTbl.FC_BlockTRACK:Stop()
end

return Animation_Centric