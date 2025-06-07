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

    moduleTbl.attackTrack = getAnimationTrackById(moduleTbl, trackData.AnimationId)

end

function Animation_Centric.playAttackAnimation(moduleTbl) --[[ We setup an attack animation before (using the .setUpAttackAnimation). This will execute that animation.  ]]
    if not moduleTbl.attackTrack then return warn("Failed to play attack track, as it doesn't exist.") end

        moduleTbl.currentAttack = moduleTbl.attackTrack.Animation
        moduleTbl.attackTrack:Play()
        -- moduleTbl.lastAttackTrack = moduleTbl.attackTrack

end

function Animation_Centric.setupReceiveAnimation(moduleTbl, data)

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